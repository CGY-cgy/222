<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <div class="register-logo">
          <div class="logo-icon"></div>
          <div class="logo-text">
            <h1>灵境管理</h1>
            <p>Admin Console</p>
          </div>
        </div>
      </div>
      
      <div class="register-form-section">
        <h2 class="form-title">注册</h2>
        <p class="form-subtitle">创建新账户，开始管理您的平台</p>
        
        <el-form
          ref="registerFormRef"
          :model="registerForm"
          :rules="registerRules"
          label-position="top"
          class="register-form"
        >
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="用户名" prop="username">
                <el-input
                  v-model="registerForm.username"
                  placeholder="请输入用户名"
                  prefix-icon="User"
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="姓名" prop="name">
                <el-input
                  v-model="registerForm.name"
                  placeholder="请输入姓名"
                  prefix-icon="Avatar"
                />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="邮箱" prop="email">
                <el-input
                  v-model="registerForm.email"
                  type="email"
                  placeholder="请输入邮箱"
                  prefix-icon="Message"
                />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="手机号" prop="phone">
                <el-input
                  v-model="registerForm.phone"
                  placeholder="请输入手机号"
                  prefix-icon="Phone"
                />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-form-item label="密码" prop="password">
            <el-input
              v-model="registerForm.password"
              type="password"
              placeholder="请输入密码"
              prefix-icon="Lock"
              show-password
            />
            <div class="password-hint">
              <span class="hint-text">密码长度不少于6位，包含字母和数字</span>
            </div>
          </el-form-item>
          
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input
              v-model="registerForm.confirmPassword"
              type="password"
              placeholder="请再次输入密码"
              prefix-icon="Lock"
              show-password
            />
          </el-form-item>
          
          <el-form-item class="register-form-actions" prop="agreeTerms">
            <el-checkbox v-model="registerForm.agreeTerms">
              我已阅读并同意<a href="#" class="terms-link">服务条款</a>和<a href="#" class="terms-link">隐私政策</a>
            </el-checkbox>
          </el-form-item>
          
          <el-button
            type="primary"
            :loading="loading"
            @click="handleRegister"
            class="register-button"
            size="large"
          >
            注册
          </el-button>
          
          <div class="register-form-footer">
            <span>已有账户？</span>
            <el-link type="primary" href="#" @click.prevent="$router.push('/login')">
              立即登录
            </el-link>
          </div>
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
const registerFormRef = ref(null)

// 加载状态
const loading = ref(false)

// 注册表单
const registerForm = reactive({
  username: '',
  name: '',
  email: '',
  phone: '',
  password: '',
  confirmPassword: '',
  agreeTerms: false
})

// 表单验证规则
const registerRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '姓名长度在 2 到 20 个字符', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { type: 'email', message: '请输入有效的邮箱地址', trigger: ['blur', 'change'] }
  ],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入有效的手机号', trigger: ['blur', 'change'] }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 个字符', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$/.test(value)) {
          callback(new Error('密码必须包含字母和数字'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  agreeTerms: [
    { 
      validator: (rule, value, callback) => {
        if (!value) {
          callback(new Error('请阅读并同意服务条款和隐私政策'))
        } else {
          callback()
        }
      },
      trigger: 'change'
    }
  ]
}

// 处理注册
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  try {
    await registerFormRef.value.validate()
    loading.value = true
    
    // 调用注册方法
    await authStore.register(registerForm)
    
    ElMessage.success('注册成功！请登录您的账户')
    router.push('/login')
  } catch (error) {
    if (error.name === 'ElFormValidationError') {
      ElMessage.error('请检查表单填写是否正确')
    } else {
      ElMessage.error(error.message || '注册失败，请重试')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 全局样式重置与基础设置 */
.register-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
}

/* 注册卡片主体 */
.register-card {
  width: 100%;
  max-width: 600px;
  overflow: hidden;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.register-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 24px 72px rgba(0, 0, 0, 0.2);
}

/* 卡片头部 */
.register-header {
  padding: 40px;
  color: white;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

/* 头部装饰效果 */
.register-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: radial-gradient(circle at 30% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
}

/* Logo区域 */
.register-logo {
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
.register-form-section {
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

.register-form {
  width: 100%;
}

/* 表单项目样式 */
.register-form .el-form-item {
  margin-bottom: 24px;
}

.register-form .el-form-item__label {
  margin-bottom: 8px;
  padding: 0;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

/* 表单布局对齐优化 */
.register-form {
  width: 100%;
}

.register-form .el-row {
  display: flex;
  align-items: stretch;
  margin-left: -10px;
  margin-right: -10px;
}

.register-form .el-col {
  padding-left: 10px;
  padding-right: 10px;
}

/* 输入框样式优化 - 去除边框 */
.register-form .el-input {
  border-radius: 8px;
  transition: all 0.2s ease;
}

.register-form .el-input__wrapper {
  padding: 10px 14px;
  border-radius: 8px;
  border: none;
  box-shadow: 0 0 0 1px #dcdfe6;
}

.register-form .el-input__wrapper:hover {
  border: none;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
}

.register-form .el-input.is-focus .el-input__wrapper {
  border: none;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.4);
}

/* 表单按钮区域对齐 */
.register-form-footer {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  font-weight: 400;
  color: #6b7280;
}

/* 密码提示 */
.password-hint {
  margin-top: 8px;
}

.hint-text {
  font-size: 12px;
  font-weight: 400;
  color: #9ca3af;
  line-height: 1.4;
}

/* 表单操作区域 */
.register-form-actions {
  margin-bottom: 28px;
  font-size: 14px;
}

.terms-link {
  font-weight: 500;
  color: #667eea;
  text-decoration: none;
}

.terms-link:hover {
  color: #5a67d8;
  text-decoration: underline;
}

/* 注册按钮 */
.register-button {
  width: 100%;
  height: 48px;
  margin-bottom: 20px;
  font-size: 16px;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.register-button:hover {
  transform: translateY(-1px);
  background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.register-button:active {
  transform: translateY(0);
}

.register-button.is-loading .el-icon-loading {
  color: white;
}

/* 表单底部 */
.register-form-footer {
  text-align: center;
  font-size: 14px;
  font-weight: 400;
  color: #6b7280;
}

.register-form-footer .el-link {
  margin-left: 4px;
  font-weight: 500;
  color: #667eea;
}

.register-form-footer .el-link:hover {
  color: #5a67d8;
}

/* 响应式设计 - 平板设备 */
@media (max-width: 768px) {
  .register-container {
    padding: 16px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }
  
  .register-card {
    border-radius: 12px;
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.12);
  }
  
  .register-header {
    padding: 32px 24px;
  }
  
  .register-form-section {
    padding: 32px 24px;
  }
  
  .form-title {
    font-size: 22px;
  }
  
  .form-subtitle {
    margin-bottom: 28px;
  }
  
  .el-row {
    flex-direction: column;
  }
  
  .el-col {
    width: 100%;
  }
  
  .register-form .el-form-item {
    margin-bottom: 20px;
  }
}

/* 响应式设计 - 移动设备 */
@media (max-width: 480px) {
  .register-header {
    padding: 24px;
  }
  
  .register-form-section {
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