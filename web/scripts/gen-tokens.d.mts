/** Type surface for the token generator, so the staleness test can import it. */
export interface DesignToken {
  name: string;
  value: string | { light: string; dark: string };
  usage?: string;
}

export interface TypeStyle {
  name: string;
  fontSize: string;
  lineHeight: string;
  fontWeight: number;
  letterSpacing?: string;
  usage?: string;
}

export interface TokensJson {
  name: string;
  version: number;
  color: { themes: Array<{ id: string; name: string }>; tokens: DesignToken[] };
  type: {
    families: Record<string, string>;
    groups: Array<{ name: string; family: string; styles: TypeStyle[] }>;
  };
  spacing: { tokens: Array<{ name: string; value: string }> };
  radius: { tokens: Array<{ name: string; value: string }> };
  shadow: { tokens: Array<{ name: string; value: { light: string; dark: string } }> };
  opacity: { tokens: Array<{ name: string; value: string }> };
}

export function generate(tokensJson: TokensJson): string;
export function readTokens(): TokensJson;
export function expectedCss(): string;
export function currentCss(): string;
