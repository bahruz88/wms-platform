import { expect, test } from '@playwright/test';
import { signInThroughKeycloak, sidebar, waitForAppShell } from '../helpers/login';
import { USER_LIST, USERS } from '../helpers/users';

/**
 * Authentication against the real Keycloak realm `wms`.
 *
 * Nothing here is stubbed: the browser walks the authorization-code + PKCE round trip, the realm
 * renders its own form, and the app exchanges the code at `/callback`. The assertions are the
 * three things a user would notice — I am in, I am still in after a reload, and I am out when I
 * say so.
 *
 * These tests deliberately start from a clean context (`storageState: undefined`) so they prove
 * the login itself, not the fixture that caches it.
 */

test.use({ storageState: { cookies: [], origins: [] } });

for (const user of USER_LIST) {
  test(`${user.username} signs in through Keycloak and lands in the app`, async ({ page }) => {
    await signInThroughKeycloak(page, user.username);

    // The username and the role code are printed in the sidebar's user block.
    const userButton = page.getByRole('button', { expanded: false }).filter({ hasText: user.username });
    await expect(userButton).toBeVisible();
    await expect(userButton).toContainText(user.role);

    // The token really carries tenant 1 — the app refuses to build a session without `tenant_id`.
    await userButton.click();
    const menu = page.getByRole('menu', { name: 'İstifadəçi menyusu' });
    await expect(menu).toBeVisible();
    await expect(menu).toContainText('Tenant');
    await expect(menu.getByText('1', { exact: true })).toBeVisible();
    await expect(menu).toContainText(user.role);
  });
}

test('the session survives a full page reload', async ({ page }) => {
  await signInThroughKeycloak(page, 'manager');
  const before = page.url();

  await page.reload();
  await waitForAppShell(page);

  expect(page.url()).toBe(before);
  await expect(sidebar(page)).toBeVisible();
  await expect(
    page.getByRole('button', { expanded: false }).filter({ hasText: 'manager' }),
  ).toBeVisible();

  // A second reload on a deep link keeps the same screen rather than bouncing to the dashboard.
  await page.goto('/inventory/balances');
  await waitForAppShell(page);
  await page.reload();
  await waitForAppShell(page);
  await expect(page).toHaveURL(/\/inventory\/balances$/);
  await expect(page.getByRole('heading', { name: 'Qalıqlar', level: 1 })).toBeVisible();
});

test('signing out ends the session and a protected route sends the user back to Keycloak', async ({
  page,
}) => {
  await signInThroughKeycloak(page, 'auditor');

  await page.getByRole('button', { expanded: false }).filter({ hasText: 'auditor' }).click();
  const menu = page.getByRole('menu', { name: 'İstifadəçi menyusu' });
  await menu.getByRole('button', { name: 'Çıxış' }).click();

  // `post_logout_redirect_uri` brings the browser back to the app with no session left.
  await page.waitForURL((url) => url.port === '3000', { timeout: 45_000 });
  await expect
    .poll(async () => page.evaluate(() => Object.keys(window.localStorage).filter((k) => k.startsWith('oidc.user'))))
    .toEqual([]);

  // With the SSO session gone, a protected route must reach the realm's login form again.
  await page.goto('/inventory/balances');
  await page.waitForURL(/\/realms\/wms\/protocol\/openid-connect\/auth/, { timeout: 45_000 });
  await expect(page.getByLabel('İstifadəçi adı və ya email')).toBeVisible();
});

test('a wrong password is refused by the realm and no session is created', async ({ page }) => {
  await page.goto('/login');
  await page.getByRole('button', { name: 'Daxil ol' }).click();
  await page.waitForURL(/\/realms\/wms\/protocol\/openid-connect\/auth/);

  await page.getByLabel('İstifadəçi adı və ya email').fill(USERS.keeper.username);
  await page.getByLabel('Şifrə', { exact: true }).fill('not-the-password');
  await page.locator('#kc-login').click();

  // The realm says so in the interface language, and the user stays on the form.
  await expect(page.getByText('Yanlış istifadəçi adı və ya şifrə.')).toBeVisible();
  await expect(page.getByRole('textbox', { name: 'İstifadəçi adı və ya email' })).toHaveAttribute(
    'aria-invalid',
    'true',
  );
  expect(page.url()).toContain('/realms/wms/');
  const stored = await page.evaluate(() =>
    Object.keys(window.localStorage).filter((k) => k.startsWith('oidc.user')),
  );
  expect(stored).toEqual([]);
});
