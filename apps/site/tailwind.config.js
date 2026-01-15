/** @type {import('tailwindcss').Config} */
export default {
  content: ['./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}'],
  theme: {
    extend: {
      colors: {
        // Terminal-core dark theme following 60-30-10 rule
        'terminal-black': '#0a0a0a',      // Primary (The Void) - 60%
        'terminal-dark': '#1a202c',       // Slightly lighter black
        'terminal-slate': '#4a5568',      // Secondary (The Structure) - 30%
        'terminal-divider': '#2d3748',    // For dividers and borders
        'terminal-cyan': '#06b6d4',       // Accents (The "Aura") - 10%
        'terminal-indigo': '#8b5cf6',
        'terminal-violet': '#a78bfa',
        'terminal-white': '#f7fafc',      // Typography
        'terminal-code-gray': '#a0aec0',  // Secondary typography
        'terminal-dim': '#718096',        // For metadata/dimmed text
      }
    },
  },
  plugins: [],
}