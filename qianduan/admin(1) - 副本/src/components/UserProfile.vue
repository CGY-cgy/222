<template>
  <div class="profile-container">
    <h2 class="profile-title">个人中心</h2>
    <el-divider />
    
    <el-card shadow="hover" class="profile-card">
      <template #header>
        <div class="card-header">
          <span>个人信息</span>
        </div>
      </template>
      
      <div class="profile-content">
        <div class="profile-avatar-section">
          <div class="profile-avatar" :style="{ background: avatarColor }">{{ user.name.charAt(0) }}</div>
          <div class="profile-avatar-actions">
            <el-button type="primary" size="small">
              <el-icon><el-icon-upload /></el-icon>
              更换头像
            </el-button>
          </div>
        </div>
        
        <el-form :model="user" label-position="top" class="profile-form">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="用户名">
                <el-input v-model="user.username" disabled placeholder="请输入用户名" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="姓名">
                <el-input v-model="user.name" placeholder="请输入姓名" />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="邮箱">
                <el-input v-model="user.email" placeholder="请输入邮箱" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="手机号">
                <el-input v-model="user.phone" placeholder="请输入手机号" />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-row :gutter="20">
            <el-col :span="12">
              <el-form-item label="角色">
                <el-input v-model="user.role" disabled placeholder="请输入角色" />
              </el-form-item>
            </el-col>
            <el-col :span="12">
              <el-form-item label="最后登录时间">
                <el-input v-model="user.lastLogin" disabled placeholder="请输入最后登录时间" />
              </el-form-item>
            </el-col>
          </el-row>
          
          <el-form-item label="简介">
            <el-input
              v-model="user.bio"
              type="textarea"
              :rows="4"
              placeholder="请输入个人简介"
            />
          </el-form-item>
          
          <div class="profile-form-actions">
            <el-button type="primary" @click="saveProfile">保存修改</el-button>
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
import {
  Upload
} from '@element-plus/icons-vue'

// 定义组件别名
const ElIconUpload = Upload

// 用户数据
const user = reactive({
  username: 'admin',
  name: '管理员',
  email: 'admin@example.com',
  phone: '13800138000',
  role: '超级管理员',
  lastLogin: '2026-01-16 15:30:45',
  bio: '这是管理员的个人简介，负责管理整个系统。'
})

// 头像颜色
const avatarColor = ref('linear-gradient(135deg, #667eea 0%, #764ba2 100%)')

// 保存个人信息
const saveProfile = () => {
  ElMessage.success('个人信息保存成功！')
}

// 重置表单
const resetForm = () => {
  // 重置为原始数据
  Object.assign(user, {
    username: 'admin',
    name: '管理员',
    email: 'admin@example.com',
    phone: '13800138000',
    role: '超级管理员',
    lastLogin: '2026-01-16 15:30:45',
    bio: '这是管理员的个人简介，负责管理整个系统。'
  })
  ElMessage.info('表单已重置')
}
</script>

<style scoped>
.profile-container {
  padding: 0;
}

.profile-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin: 0 0 16px 0;
}

.profile-card {
  margin-bottom: 20px;
}

.profile-content {
  padding: 20px 0;
}

.profile-avatar-section {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 32px;
}

.profile-avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 28px;
  font-weight: 600;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.profile-avatar-actions {
  display: flex;
  gap: 12px;
}

.profile-form {
  width: 100%;
}

.profile-form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-start;
  margin-top: 24px;
}

@media (max-width: 768px) {
  .profile-avatar-section {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .profile-form-actions {
    flex-direction: column;
  }
}
</style>