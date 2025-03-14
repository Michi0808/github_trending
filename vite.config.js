import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
        vue(),
        tailwindcss(),
    ],
    server: {
        proxy: {
            '/api': {
                target: process.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000',
                changeOrigin: true,
                secure: false,
            },
        },
        origin: 'https://github-trending-wpgw.onrender.com',
    },
    build: {
        outDir: 'public/build',
        emptyOutDir: true,
    },
});
