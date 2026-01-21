import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    isAuthenticated: false,
    token: localStorage.getItem('token') || '',
    user: JSON.parse(localStorage.getItem('user')) || null
  }),

  getters: {
    isLoggedIn: (state) => state.isAuthenticated
  },

  actions: {
    // 登录
    login(credentials) {
      // 模拟登录请求
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          // 这里应该是真实的API调用
          if (credentials.username === 'admin' && credentials.password === 'admin123') {
            const token = 'fake-jwt-token-' + Date.now()
            const user = {
              id: 1,
              username: credentials.username,
              name: '管理员',
              email: 'admin@example.com',
              phone: '13800138000',
              role: 'admin',
              lastLogin: new Date().toLocaleString()
            }
            
            // 更新状态
            this.isAuthenticated = true
            this.token = token
            this.user = user
            
            // 保存到localStorage
            localStorage.setItem('token', token)
            localStorage.setItem('user', JSON.stringify(user))
            
            resolve({ token, user })
          } else {
            reject(new Error('用户名或密码错误'))
          }
        }, 1000)
      })
    },

    // 注册
    register(userData) {
      // 模拟注册请求
      return new Promise((resolve, reject) => {
        setTimeout(() => {
          // 这里应该是真实的API调用
          const user = {
            id: Math.floor(Math.random() * 1000),
            username: userData.username,
            name: userData.name,
            email: userData.email,
            phone: userData.phone || '',
            role: 'user',
            lastLogin: new Date().toLocaleString()
          }
          
          resolve(user)
        }, 1000)
      })
    },

    // 登出
    logout() {
      // 清除状态
      this.isAuthenticated = false
      this.token = ''
      this.user = null
      
      // 清除localStorage
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },

    // 检查登录状态
    checkAuth() {
      const token = localStorage.getItem('token')
      const user = localStorage.getItem('user')
      
      if (token && user) {
        this.isAuthenticated = true
        this.token = token
        this.user = JSON.parse(user)
      }
    }
  }
})