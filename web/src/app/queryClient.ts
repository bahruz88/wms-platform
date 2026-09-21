import { QueryClient } from '@tanstack/react-query';
import { isApiError } from '@api/problem';

/**
 * A 4xx is an answer, not a hiccup: retrying it only produces the same problem again and hides
 * the `code` the user needs to see. Only transport failures and 5xx are retried.
 */
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      gcTime: 5 * 60_000,
      refetchOnWindowFocus: false,
      retry: (failureCount, error) => {
        if (isApiError(error) && error.status >= 400 && error.status < 500) return false;
        return failureCount < 2;
      },
    },
    mutations: {
      // Every POST already carries an Idempotency-Key, but a silent retry would still hide a
      // 409 from the user, so mutations never retry on their own.
      retry: false,
    },
  },
});
