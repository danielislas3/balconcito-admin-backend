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
      console.log('💾 [AuthStore] Setting token:', token ? `${token.substring(0, 30)}...` : 'null')
      this.token = token
      if (typeof window !== 'undefined') {
        localStorage.setItem('auth_token', token)
        console.log('💾 [AuthStore] Token saved to localStorage')
      }
    },

    setUser(user: User) {
      console.log('👤 [AuthStore] Setting user:', user?.name || 'null')
      this.user = user
      if (typeof window !== 'undefined') {
        localStorage.setItem('auth_user', JSON.stringify(user))
        console.log('👤 [AuthStore] User saved to localStorage')
      }
    },

    setAuth(token: string, user: User) {
      console.log('🔐 [AuthStore] setAuth called with:', { token: token ? 'present' : 'missing', user: user?.name })
      this.setToken(token)
      this.setUser(user)
    },

    logout() {
      console.log('🚪 [AuthStore] Logging out')
      this.token = null
      this.user = null
      if (typeof window !== 'undefined') {
        localStorage.removeItem('auth_token')
        localStorage.removeItem('auth_user')
        console.log('🚪 [AuthStore] Removed from localStorage')
      }
    },

    initializeAuth() {
      if (typeof window !== 'undefined') {
        console.log('🔄 [AuthStore] Initializing auth from localStorage')
        const token = localStorage.getItem('auth_token')
        const userStr = localStorage.getItem('auth_user')

        console.log('🔄 [AuthStore] Found in localStorage:', {
          token: token ? `${token.substring(0, 30)}...` : 'null',
          user: userStr ? 'present' : 'null'
        })

        if (token && userStr) {
          try {
            const user = JSON.parse(userStr)
            this.token = token
            this.user = user
            console.log('🔄 [AuthStore] ✅ Auth initialized successfully:', user.name)
          } catch (error) {
            console.error('🔄 [AuthStore] ❌ Error parsing user from localStorage:', error)
            this.logout()
          }
        } else {
          console.log('🔄 [AuthStore] No auth data found in localStorage')
        }
      }
    }
  }
})
