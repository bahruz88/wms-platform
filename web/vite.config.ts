import { fileURLToPath, URL } from 'node:url';
import react from '@vitejs/plugin-react';
import type { ProxyOptions } from 'vite';
import { defineConfig } from 'vitest/config';

const r = (p: string) => fileURLToPath(new URL(p, import.meta.url));

/**
 * The gateway (YARP) does not send CORS headers, so a browser on :3000 cannot call :5001 directly.
 * Dev and preview therefore proxy `/api` to it, which is also how the production image serves the
 * app: nginx in front of the static files, forwarding `/api` to the gateway. Leaving
 * `VITE_API_BASE_URL` empty makes the client use same-origin URLs and go through this proxy.
 */
const apiProxy: Record<string, ProxyOptions> = {
  '/api': {
    target: process.env.VITE_API_PROXY_TARGET ?? 'http://localhost:5001',
    changeOrigin: true,
  },
};

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': r('./src'),
      '@ds': r('./src/design-system'),
      '@api': r('./src/api'),
      '@app': r('./src/app'),
      '@auth': r('./src/auth'),
      '@features': r('./src/features'),
      '@core': r('./src/core'),
      '@generated': r('./src/api/generated'),
    },
  },
  server: {
    port: 3001,
    strictPort: true,
    proxy: apiProxy,
  },
  preview: {
    port: 3000,
    strictPort: true,
    proxy: apiProxy,
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        main: r('./index.html'),
        // The silent-renew iframe is its own entry so it never loads the application bundle.
        'silent-renew': r('./silent-renew.html'),
      },
    },
    sourcemap: false,
    chunkSizeWarningLimit: 900,
  },
  test: {
    globals: true,
    // The app defaults to same-origin URLs (the proxy); Node's `Request` cannot parse a relative
    // URL, so the client tests run against an absolute base.
    env: { VITE_API_BASE_URL: 'http://localhost:5001' },
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    css: true,
    include: ['src/**/*.test.{ts,tsx}', 'eslint-rules/**/*.test.ts'],
  },
});
