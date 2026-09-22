import { expect, type Page } from '@playwright/test';
import { USERS, type UserName } from './users';

/**
 * Signs a user in through the **real** Keycloak login form.
 *
 * The app sends the browser to the realm's authorization endpoint with PKCE S256; the form is
 * Keycloak's own, rendered in Azerbaijani, so the fields are found by their visible labels. After
 * the code is exchanged at `/callback` the app navigates to wherever the user's navigation starts
 * — the dashboard for a manager, «Qəbul» for a keeper — so the wait is for *any* app route other
 * than `/callback` and `/login`.
 */
export async function signInThroughKeycloak(page: Page, username: UserName): Promise<void> {
  const user = USERS[username];

  await waitForKeycloak(page);
  await page.goto('/login');
  await page.getByRole('button', { name: 'Daxil ol' }).click();

  await page.waitForURL(/\/realms\/wms\/protocol\/openid-connect\/auth/);

  // Keycloak's own form, in the realm's Azerbaijani locale.
  await page.getByLabel('İstifadəçi adı və ya email').fill(user.username);
  await page.getByLabel('Şifrə', { exact: true }).fill(user.password);
  await page.locator('#kc-login').click();

  await waitForAppShell(page);
}

/**
 * Blocks until the realm answers its discovery document.
 *
 * Keycloak is restarted by the deployment work running alongside this suite; sending the browser
 * to an authorization endpoint that is still booting produces a navigation timeout that says
 * nothing about the product.
 */
export async function waitForKeycloak(page: Page, timeout = 90_000): Promise<void> {
  const deadline = Date.now() + timeout;
  for (;;) {
    try {
      const res = await page.request.get(
        'http://localhost:8180/realms/wms/.well-known/openid-configuration',
        { timeout: 5_000 },
      );
      if (res.ok()) return;
    } catch {
      // still booting
    }
    if (Date.now() > deadline) throw new Error('Keycloak did not come up within 90s');
    await new Promise((r) => setTimeout(r, 2_000));
  }
}

/** Waits until an authenticated app route is rendered, whichever one the role lands on. */
export async function waitForAppShell(page: Page): Promise<void> {
  await page.waitForURL(
    (url) =>
      url.port === '3000' && !url.pathname.startsWith('/callback') && url.pathname !== '/login',
    { timeout: 45_000 },
  );
  await expect(page.locator('.wms-app, .wms-page-state').first()).toBeVisible({ timeout: 30_000 });
}

/**
 * Opens a route with an already-signed-in storage state.
 *
 * A stored access token older than the realm's 15-minute lifespan makes the app bounce through
 * Keycloak, which answers straight away from the SSO cookie — no form. The wait therefore has to
 * survive that bounce, which is why it is written against the rendered shell rather than the URL.
 */
export async function gotoApp(page: Page, path: string): Promise<void> {
  await page.goto(path);
  await page
    .waitForURL((url) => url.port === '3000' && !url.pathname.startsWith('/callback'), {
      timeout: 45_000,
    })
    .catch(() => undefined);
  await expect(page.locator('.wms-app, .wms-page-state').first()).toBeVisible({ timeout: 30_000 });
}

/** The sidebar navigation, by its accessible name. */
export function sidebar(page: Page) {
  return page.getByRole('navigation', { name: 'Əsas naviqasiya' });
}

/** Labels of every navigation entry the signed-in user is offered. */
export async function navLabels(page: Page): Promise<string[]> {
  const links = sidebar(page).getByRole('link');
  await expect(links.first()).toBeVisible();
  return (await links.allInnerTexts()).map((t) => t.trim()).filter(Boolean);
}

/** Opens the user menu pinned to the bottom of the sidebar. */
export async function openUserMenu(page: Page, username: string) {
  await page.getByRole('button', { expanded: false }).filter({ hasText: username }).click();
  return page.getByRole('menu', { name: 'İstifadəçi menyusu' });
}
