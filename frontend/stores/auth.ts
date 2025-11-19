import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: null as string | null,
    user: null as any | null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token
  },

  actions: {
    setToken(token: string) {
      this.token = token
      if (process.client) {
        localStorage.setItem('auth_token', token)
      }
    },

    setUser(user: any) {
      this.user = user
    },

    logout() {
      this.token = null
      this.user = null
      if (process.client) {
        localStorage.removeItem('auth_token')
      }
    },

    initializeAuth() {
      if (process.client) {
        const token = localStorage.getItem('auth_token')
        if (token) {
          this.token = token
        }
      }
    }
  }
})
