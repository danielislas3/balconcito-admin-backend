// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  compatibilityDate: '2024-11-01',
  devtools: { enabled: true },

  modules: [
    '@nuxt/ui',
    '@pinia/nuxt'
  ],

  runtimeConfig: {
    public: {
      apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:3000/api/v1'
    }
  },

  app: {
    head: {
      title: 'Balconcito ERP',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { name: 'description', content: 'Sistema de administración centralizado para Balconcito' }
      ]
    }
  },

  css: [],

  colorMode: {
    preference: 'light'
  },

  ui: {
    primary: 'green',
    gray: 'neutral'
  }
})
