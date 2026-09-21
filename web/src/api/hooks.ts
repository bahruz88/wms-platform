import { useQuery, type UseQueryOptions, type UseQueryResult } from '@tanstack/react-query';
import { guarded, toPage, type Page } from './client';
import type { ApiError } from './problem';

/**
 * Small wrappers so screens do not repeat the same plumbing. Every list query normalises to
 * `{ items, page, size, total }` even when the endpoint answers with a bare array.
 */

export type ApiQueryResult<T> = UseQueryResult<T, ApiError>;

export function useApiQuery<T>(
  key: readonly unknown[],
  fetcher: () => Promise<T>,
  options?: Omit<UseQueryOptions<T, ApiError, T, readonly unknown[]>, 'queryKey' | 'queryFn'>,
): ApiQueryResult<T> {
  return useQuery<T, ApiError, T, readonly unknown[]>({
    queryKey: key,
    queryFn: () => guarded(fetcher, key.join('/')),
    ...options,
  });
}

export function useApiPage<T>(
  key: readonly unknown[],
  fetcher: () => Promise<unknown>,
  size = 50,
  options?: Omit<
    UseQueryOptions<Page<T>, ApiError, Page<T>, readonly unknown[]>,
    'queryKey' | 'queryFn'
  >,
): ApiQueryResult<Page<T>> {
  return useQuery<Page<T>, ApiError, Page<T>, readonly unknown[]>({
    queryKey: key,
    queryFn: async () => toPage<T>(await guarded(fetcher, key.join('/')), size),
    ...options,
  });
}
