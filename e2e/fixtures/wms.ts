import { test as base, expect, type Browser, type BrowserContext, type Page } from '@playwright/test';
import { closeDb } from '../helpers/db';
import { disposeApi } from '../helpers/api';
import { storageStatePath, type UserName } from '../helpers/users';

/**
 * The suite's own fixtures.
 *
 * `as(user)` hands back a page already carrying that user's signed-in storage state, which is how
 * an authorization test can compare two roles inside one test without signing anybody in again.
 * Every page opened this way also collects console errors, page errors and failed requests, and
 * `expectClean()` turns that collection into an assertion — the smoke pass fails on a console
 * error rather than printing it.
 */

export interface PageProblems {
  consoleErrors: string[];
  pageErrors: string[];
  failedRequests: string[];
  httpErrors: string[];
}

const problems = new WeakMap<Page, PageProblems>();

/** Requests whose failure is expected and is itself the thing under test. */
const IGNORED_REQUEST_PATTERNS: RegExp[] = [
  /\/silent-renew\.html/,
  /favicon\.ico/,
];

export function watch(page: Page): PageProblems {
  const existing = problems.get(page);
  if (existing) return existing;

  const record: PageProblems = {
    consoleErrors: [],
    pageErrors: [],
    failedRequests: [],
    httpErrors: [],
  };
  problems.set(page, record);

  page.on('console', (message) => {
    if (message.type() !== 'error') return;
    const text = message.text();
    // The browser emits its own console error for every non-2xx resource. That is the same fact
    // the `response` handler below records, with the URL and the status attached; counting it
    // twice would bury a genuine application error inside a list of HTTP statuses.
    if (/^Failed to load resource: the server responded with a status of \d{3}/.test(text)) return;
    record.consoleErrors.push(`${page.url()} :: ${text}`);
  });
  page.on('pageerror', (error) => {
    record.pageErrors.push(`${page.url()} :: ${error.message}`);
  });
  page.on('requestfailed', (request) => {
    const url = request.url();
    if (IGNORED_REQUEST_PATTERNS.some((p) => p.test(url))) return;
    record.failedRequests.push(`${request.method()} ${url} :: ${request.failure()?.errorText}`);
  });
  page.on('response', (response) => {
    const url = response.url();
    if (response.status() < 400) return;
    if (IGNORED_REQUEST_PATTERNS.some((p) => p.test(url))) return;
    record.httpErrors.push(`${response.status()} ${response.request().method()} ${url}`);
  });

  return record;
}

/** Clears everything collected so far — used between the steps of a walk over many routes. */
export function resetProblems(page: Page): void {
  const record = problems.get(page);
  if (!record) return;
  record.consoleErrors.length = 0;
  record.pageErrors.length = 0;
  record.failedRequests.length = 0;
  record.httpErrors.length = 0;
}

export function problemsOf(page: Page): PageProblems {
  return watch(page);
}

export interface AsUser {
  (user: UserName): Promise<Page>;
}

export const test = base.extend<{
  /** A page signed in as `user`, created on demand and closed with the test. */
  as: AsUser;
}>({
  as: async ({ browser }, use) => {
    const contexts: BrowserContext[] = [];
    const pages = new Map<UserName, Page>();

    const factory: AsUser = async (user: UserName) => {
      const cached = pages.get(user);
      if (cached) return cached;
      const context = await newSignedInContext(browser, user);
      contexts.push(context);
      const page = await context.newPage();
      watch(page);
      pages.set(user, page);
      return page;
    };

    await use(factory);

    for (const context of contexts) await context.close();
  },
});

export async function newSignedInContext(
  browser: Browser,
  user: UserName,
): Promise<BrowserContext> {
  return browser.newContext({
    storageState: storageStatePath(user),
    viewport: { width: 1600, height: 1000 },
    locale: 'az-AZ',
    timezoneId: 'Asia/Baku',
  });
}

test.afterAll(async () => {
  await closeDb();
  await disposeApi();
});

export { expect };
