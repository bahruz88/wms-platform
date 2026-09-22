import { expect, test as setup } from '@playwright/test';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { signInThroughKeycloak } from '../helpers/login';
import { storageStatePath, USER_LIST } from '../helpers/users';

/**
 * One real Keycloak sign-in per dev user, parked as a storage state.
 *
 * This is the only place the suite types a password. Everything downstream loads the state and
 * starts already signed in, which is what keeps forty tests from hammering the realm — and it is
 * still a *real* session: the same `oidc.user:...` entry the browser wrote after the authorization
 * code was exchanged with PKCE, not a hand-built token.
 */

for (const user of USER_LIST) {
  setup(`sign in as ${user.username}`, async ({ page }) => {
    await signInThroughKeycloak(page, user.username);

    // The shell must actually be up: a session that renders nothing is not a session.
    await expect(page.locator('.wms-app')).toBeVisible();

    const path = storageStatePath(user.username);
    mkdirSync(dirname(path), { recursive: true });
    await page.context().storageState({ path });
  });
}
