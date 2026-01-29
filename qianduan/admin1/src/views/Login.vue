<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="login-logo">
          <div class="logo-icon"></div>
          <div class="logo-text">
            <h1>灵境管理</h1>
            <p>Admin Console</p>
          </div>
        </div>
      </div>
      
      <div class="login-form-section">
        <h2 class="form-title">登录</h2>
        <p class="form-subtitle">欢迎回来，请登录您的账户</p>
        
        <el-form
          ref="loginFormRef"
          :model="loginForm"
          :rules="loginRules"
          label-position="top"
          class="login-form"
        >
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model="loginForm.username"
              placeholder="请输入用户名"
              prefix-icon="User"
            />
          </el-form-item>
          
          <el-form-item label="密码" prop="password">
            <el-input
              v-model="loginForm.password"
              type="password"
              placeholder="请输入密码"
              prefix-icon="Lock"
              show-password
            />
          </el-form-item>
          
          <el-form-item class="login-form-actions">
            <el-checkbox v-model="loginForm.rememberMe">记住我</el-checkbox>
            <el-link type="primary" href="#" @click.prevent="$router.push('/register')">
              没有账户？立即注册
            </el-link>
          </el-form-item>
          
          <el-button
            type="primary"
            :loading="loading"
            @click="handleLogin"
            class="login-button"
            size="large"
          >
            登录
          </el-button>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { ElMessage } from 'element-plus'

// 路由和状态管理
const router = useRouter()
const authStore = useAuthStore()

// 表单引用
const loginFormRef = ref(null)

// 加载状态
const loading = ref(false)

// 登录表单
const loginForm = reactive({
  username: '',
  password: '',
  rememberMe: false
})

// 表单验证规则
const loginRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' }
  ]
}

// 处理登录
const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    loading.value = true
    
    // 调用登录方法
    await authStore.login(loginForm)
    
    ElMessage.success('登录成功！')
    router.push('/')
  } catch (error) {
    if (error.name === 'ElFormValidationError') {
      ElMessage.error('请检查表单填写是否正确')
    } else {
      ElMessage.error(error.message || '登录失败，请重试')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 全局样式重置与基础设置 */
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* 登录卡片主体 */
.login-card {
  width: 100%;
  max-width: 480px;
  overflow: hidden;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.login-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 24px 72px rgba(0, 0, 0, 0.2);
}

/* 卡片头部 */
.login-header {
  padding: 40px;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

/* 头部装饰效果 */
.login-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 30% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
}

/* Logo区域 */
.login-logo {
  display: flex;
  align-items: center;
  gap: 16px;
  position: relative;
  z-index: 1;
}

.logo-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  background: url('../../lingjing.png') center center no-repeat;
  background-size: contain;
  background-color: white;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  transition: all 0.3s ease;
}

.logo-text h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.logo-text p {
  margin: 4px 0 0 0;
  font-size: 14px;
  font-weight: 300;
  opacity: 0.95;
  letter-spacing: 0.5px;
}

/* 表单区域 */
.login-form-section {
  padding: 40px;
}

.form-title {
  margin: 0 0 8px 0;
  font-size: 26px;
  font-weight: 700;
  color: #1f2937;
  letter-spacing: -0.5px;
}

.form-subtitle {
  margin: 0 0 36px 0;
  font-size: 14px;
  font-weight: 400;
  color: #6b7280;
  line-height: 1.5;
}

.login-form {
  width: 100%;
}

/* 表单项目样式 */
.login-form .el-form-item {
  margin-bottom: 24px;
}

.login-form .el-form-item__label {
  margin-bottom: 8px;
  padding: 0;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

/* 输入框样式优化 - 去除边框 */
.login-form .el-input {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.login-form .el-input__wrapper {
  padding: 10px 14px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 0 0 1px #dcdfe6;
}

.login-form .el-input__wrapper:hover {
  border: none;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
}

.login-form .el-input.is-focus .el-input__wrapper {
  border: none;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.4);
}

/* 表单操作区域 */
.login-form-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
  font-size: 14px;
}

.login-form-actions .el-checkbox__label {
  font-weight: 400;
  color: #6b7280;
}

.login-form-actions .el-link {
  font-weight: 500;
  color: #667eea;
}

.login-form-actions .el-link:hover {
  color: #5a67d8;
}

/* 登录按钮 */
.login-button {
  width: 100%;
  height: 48px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.login-button:hover {
  transform: translateY(-1px);
  background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.login-button:active {
  transform: translateY(0);
}

.login-button.is-loading .el-icon-loading {
  color: white;
}

/* 响应式设计 - 平板设备 */
@media (max-width: 768px) {
  .login-container {
    padding: 16px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
  
  .login-card {
    border-radius: 12px;
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12);
  }
  
  .login-header {
    padding: 32px 24px;
  }
  
  .login-form-section {
    padding: 32px 24px;
  }
  
  .form-title {
    font-size: 22px;
  }
  
  .form-subtitle {
    margin-bottom: 28px;
  }
}

/* 响应式设计 - 移动设备 */
@media (max-width: 480px) {
  .login-header {
    padding: 24px;
  }
  
  .login-form-section {
    padding: 24px;
  }
  
  .logo-text h1 {
    font-size: 20px;
  }
  
  .form-title {
    font-size: 20px;
  }
}
</style>