import { defineConfig, devices } from '@playwright/test';

/**
 * WMS end-to-end configuration.
 *
 * The suite runs against the **live stack** — the Vite preview on :3000, the YARP gateway on
 * :5001, Keycloak on :8180 and MySQL on :3308. Nothing is mocked: a test that passes here means
 * the browser really drove the product and the ledger really moved.
 *
 * Workers are kept low on purpose. The document flows post to a shared ledger and several of them
 * freeze a location; running them wide apart in time is cheaper than inventing per-worker tenants.
 */

export const BASE_URL = process.env.WMS_WEB_URL ?? 'http://localhost:3000';
export const GATEWAY_URL = process.env.WMS_API_URL ?? 'http://localhost:5001';
export const KEYCLOAK_URL = process.env.WMS_KEYCLOAK_URL ?? 'http://localhost:8180';

export default defineConfig({
  testDir: './tests',
  outputDir: './test-results',
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  // One worker. The document flows post to a shared ledger, and the machine this runs on is
  // usually busy with the rest of the build; contention produced more noise than the parallelism
  // was worth. The whole suite is a few minutes either way.
  workers: 1,
  timeout: 150_000,
  expect: { timeout: 20_000 },
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
    ['json', { outputFile: 'test-results/results.json' }],
  ],
  use: {
    baseURL: BASE_URL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
    video: 'off',
    actionTimeout: 30_000,
    navigationTimeout: 60_000,
    locale: 'az-AZ',
    timezoneId: 'Asia/Baku',
  },
  projects: [
    {
      // Signs every dev user in through the real Keycloak form once and parks the session on
      // disk, so the rest of the suite does not re-authenticate per test.
      name: 'setup',
      testDir: './fixtures',
      testMatch: /auth\.setup\.ts/,
      // Keycloak is restarted by the deployment work going on alongside this suite; a sign-in
      // that loses that race is not a product failure, so this one project retries. The test
      // projects never do — a flake there is a finding, not noise to be papered over.
      retries: 2,
      // `waitForKeycloak` alone may spend a minute waiting for a restart to finish.
      timeout: 180_000,
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'wms',
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], viewport: { width: 1600, height: 1000 } },
    },
  ],
});
