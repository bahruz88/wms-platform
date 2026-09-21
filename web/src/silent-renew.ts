import { UserManager } from 'oidc-client-ts';
import { oidcSettings } from '@auth/session';

/**
 * Silent-renew callback. `oidc-client-ts` opens this page in a hidden iframe after Keycloak
 * redirects back with a fresh code; `signinSilentCallback` hands the result to the parent window
 * through postMessage and nothing else on the page runs.
 */
new UserManager(oidcSettings).signinSilentCallback().catch((error: unknown) => {
  console.warn('[wms] silent renew callback failed:', error);
});
