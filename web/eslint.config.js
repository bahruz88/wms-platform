import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import prettier from 'eslint-config-prettier';
import tseslint from 'typescript-eslint';
import noNumberForDecimal from './eslint-rules/no-number-for-decimal.mjs';

const wmsPlugin = {
  rules: {
    'no-number-for-decimal': noNumberForDecimal,
  },
};

export default tseslint.config(
  { ignores: ['dist', 'node_modules', 'src/api/generated', 'coverage'] },
  {
    extends: [js.configs.recommended, ...tseslint.configs.recommended],
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2022,
      globals: { ...globals.browser, ...globals.node },
    },
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
      wms: wmsPlugin,
    },
    rules: {
      ...reactHooks.configs.recommended.rules,
      'react-refresh/only-export-components': 'off',
      'wms/no-number-for-decimal': 'error',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
      '@typescript-eslint/no-explicit-any': 'warn',
      'no-restricted-syntax': [
        'error',
        {
          // Brand book: interface text is Azerbaijani; `i` uppercases to `I`, never `İ`.
          selector: "CallExpression[callee.property.name='toUpperCase']",
          message:
            'toUpperCase() is forbidden on interface text (design-system README): `i` becomes `I`, not `İ`.',
        },
      ],
    },
  },
  {
    files: ['eslint-rules/**/*.mjs', 'scripts/**/*.mjs'],
    languageOptions: { globals: { ...globals.node } },
  },
  prettier,
);
