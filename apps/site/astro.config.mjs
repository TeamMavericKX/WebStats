import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), tailwind()],
  output: 'static',
  adapter: undefined,
  base: process.env.PUBLIC_BASE_URL || '/',  // Allow base URL to be set via environment variable
});