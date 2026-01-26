<template>
  <div class="password-container">
    <h2 class="password-title">修改密码</h2>
    <el-divider />
    
    <el-card shadow="hover" class="password-card">
      <template #header>
        <div class="card-header">
          <span>修改密码</span>
        </div>
      </template>
      
      <div class="password-content">
        <el-form
          ref="passwordFormRef"
          :model="passwordForm"
          :rules="passwordRules"
          label-position="top"
          class="password-form"
        >
          <el-form-item label="当前密码" prop="oldPassword">
            <el-input
              v-model="passwordForm.oldPassword"
              type="password"
              placeholder="请输入当前密码"
              show-password
            />
          </el-form-item>
          
          <el-form-item label="新密码" prop="newPassword">
            <el-input
              v-model="passwordForm.newPassword"
              type="password"
              placeholder="请输入新密码"
              show-password
            />
            <div class="password-hint">
              <span class="hint-text">密码长度不少于6位，包含字母和数字</span>
            </div>
          </el-form-item>
          
          <el-form-item label="确认新密码" prop="confirmPassword">
            <el-input
              v-model="passwordForm.confirmPassword"
              type="password"
              placeholder="请再次输入新密码"
              show-password
            />
          </el-form-item>
          
          <div class="password-form-actions">
            <el-button type="primary" @click="changePassword" :loading="loading">保存修改</el-button>
            <el-button @click="resetForm">重置</el-button>
          </div>
        </el-form>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 表单引用
const passwordFormRef = ref(null)

// 加载状态
const loading = ref(false)

// 密码表单
const passwordForm = reactive({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// 表单验证规则
const passwordRules = {
  oldPassword: [
    { required: true, message: '请输入当前密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于 6 个字符', trigger: 'blur' }
  ],
  newPassword: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
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
    { required: true, message: '请确认新密码', trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== passwordForm.newPassword) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

// 修改密码
const changePassword = async () => {
  if (!passwordFormRef.value) return
  
  try {
    await passwordFormRef.value.validate()
    loading.value = true
    
    // 模拟API调用
    setTimeout(() => {
      // 这里应该是真实的API调用
      if (passwordForm.oldPassword === 'admin123') {
        ElMessage.success('密码修改成功！')
        resetForm()
      } else {
        ElMessage.error('当前密码错误，请重新输入')
      }
      loading.value = false
    }, 1000)
  } catch (error) {
    if (error.name === 'ElFormValidationError') {
      ElMessage.error('请检查表单填写是否正确')
    } else {
      ElMessage.error(error.message || '密码修改失败，请重试')
    }
    loading.value = false
  }
}

// 重置表单
const resetForm = () => {
  passwordForm.oldPassword = ''
  passwordForm.newPassword = ''
  passwordForm.confirmPassword = ''
  if (passwordFormRef.value) {
    passwordFormRef.value.clearValidate()
  }
}
</script>

<style scoped>
.password-container {
  padding: 0;
}

.password-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin: 0 0 16px 0;
}

.password-card {
  margin-bottom: 20px;
}

.password-content {
  padding: 20px 0;
}

.password-form {
  width: 100%;
  max-width: 500px;
}

.password-hint {
  margin-top: 8px;
}

.hint-text {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

.password-form-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

@media (max-width: 768px) {
  .password-form {
    max-width: 100%;
  }
  
  .password-form-actions {
    flex-direction: column;
  }
}
</style>