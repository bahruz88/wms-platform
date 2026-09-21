/**
 * Testing Library's default normalizer collapses whitespace, which would turn the brand book's
 * U+202F narrow no-break space into an ordinary space and hide exactly the thing being asserted.
 * `RAW` keeps the text as the DOM holds it.
 */
export const RAW = { normalizer: (text: string) => text } as const;
