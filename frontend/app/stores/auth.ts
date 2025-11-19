import { defineStore } from 'pinia'

interface User {
  id: number
  email: string
  name: string
  role: string
}

interface AuthState {
  token: string | null
  user: User | null
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    token: null,
    user: null
  }),

  getters: {
    isAuthenticated: (state) => !!state.token && !!state.user,
    currentUser: (state) => state.user,
    userRole: (state) => state.user?.role
  },

  actions: {
    setToken(token: string) {
      this.token = token
      if (process.client) {
        localStorage.setItem('auth_token', token)
      }
    },

    setUser(user: User) {
      this.user = user
      if (process.client) {
        localStorage.setItem('auth_user', JSON.stringify(user))
      }
    },

    setAuth(token: string, user: User) {
      this.setToken(token)
      this.setUser(user)
    },

    logout() {
      this.token = null
      this.user = null
      if (process.client) {
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
      }
    },

    initializeAuth() {
      if (process.client) {
        const token = localStorage.getItem('auth_token')
        const userStr = localStorage.getItem('auth_user')

        if (token && userStr) {
          try {
            const user = JSON.parse(userStr)
            this.token = token
            this.user = user
          } catch (error) {
            console.error('Error parsing user from localStorage:', error)
            this.logout()
          }
        }
      }
    }
  }
})
