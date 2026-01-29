<template>
  <div class="settings-container">
    <!-- 页面标题和操作 -->
    <div class="header-section">
      <h1 class="page-title">系统设置</h1>
      <p class="page-subtitle">配置系统参数、用户权限和通知规则</p>
    </div>

    <!-- 系统基本配置 -->
    <el-card shadow="hover" class="config-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">系统基本配置</h3>
        </div>
      </template>
      <el-form label-width="120px" :model="systemConfig" class="settings-form">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统名称">
              <el-input v-model="systemConfig.name" placeholder="请输入系统名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统版本">
              <el-input v-model="systemConfig.version" placeholder="请输入系统版本" disabled />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="API地址">
              <el-input v-model="systemConfig.apiUrl" placeholder="请输入API地址" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="版权信息">
              <el-input v-model="systemConfig.copyright" placeholder="请输入版权信息" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统状态">
              <el-switch v-model="systemConfig.status" :active-text="'正常'" :inactive-text="'维护中'" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="维护模式">
              <el-switch v-model="systemConfig.maintenanceMode" :active-text="'开启'" :inactive-text="'关闭'" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <div class="form-actions">
        <el-button type="primary" @click="saveSystemConfig">保存配置</el-button>
        <el-button @click="resetSystemConfig">重置</el-button>
      </div>
    </el-card>

    <!-- 用户权限设置 -->
    <el-card shadow="hover" class="config-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">用户权限设置</h3>
        </div>
      </template>
      <div class="permission-section">
        <div class="permission-description">
          <p>配置不同角色的权限设置，控制用户可访问的功能模块</p>
        </div>
        <div class="role-selection">
          <el-select v-model="selectedRole" placeholder="选择角色" size="large" @change="loadRolePermissions">
            <el-option v-for="role in roles" :key="role.value" :label="role.label" :value="role.value" />
          </el-select>
        </div>
        <div class="permission-grid">
          <div class="permission-item" v-for="(permission, index) in permissions" :key="index">
            <div class="permission-info">
              <div class="permission-name">{{ permission.name }}</div>
              <div class="permission-desc">{{ permission.description }}</div>
            </div>
            <div class="permission-action">
              <el-switch v-model="permission.enabled" :active-text="'启用'" :inactive-text="'禁用'" />
            </div>
          </div>
        </div>
      </div>
      <div class="form-actions">
        <el-button type="primary" @click="savePermissions">保存权限</el-button>
      </div>
    </el-card>

    <!-- 通知设置 -->
    <el-card shadow="hover" class="config-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">通知设置</h3>
        </div>
      </template>
      <el-form label-width="120px" :model="notificationConfig" class="settings-form">
        <el-form-item label="邮件通知">
          <el-switch v-model="notificationConfig.email.enabled" :active-text="'开启'" :inactive-text="'关闭'" />
        </el-form-item>
        <el-collapse v-model="activeCollapse" accordion>
          <el-collapse-item title="邮件配置" name="email">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="SMTP服务器">
                  <el-input v-model="notificationConfig.email.smtpHost" placeholder="请输入SMTP服务器地址" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="SMTP端口">
                  <el-input v-model="notificationConfig.email.smtpPort" placeholder="请输入SMTP端口" type="number" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="发件人邮箱">
                  <el-input v-model="notificationConfig.email.sender" placeholder="请输入发件人邮箱" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="邮箱密码">
                  <el-input v-model="notificationConfig.email.password" placeholder="请输入邮箱密码" type="password" show-password />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
        </el-collapse>
        <el-form-item label="短信通知">
          <el-switch v-model="notificationConfig.sms.enabled" :active-text="'开启'" :inactive-text="'关闭'" />
        </el-form-item>
        <el-collapse v-model="activeCollapse" accordion>
          <el-collapse-item title="短信配置" name="sms">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="短信API密钥">
                  <el-input v-model="notificationConfig.sms.apiKey" placeholder="请输入API密钥" type="password" show-password />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="短信模板ID">
                  <el-input v-model="notificationConfig.sms.templateId" placeholder="请输入模板ID" />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
        </el-collapse>
        <el-form-item label="微信通知">
          <el-switch v-model="notificationConfig.wechat.enabled" :active-text="'开启'" :inactive-text="'关闭'" />
        </el-form-item>
      </el-form>
      <div class="form-actions">
        <el-button type="primary" @click="saveNotificationConfig">保存配置</el-button>
      </div>
    </el-card>

    <!-- 存储设置 -->
    <el-card shadow="hover" class="config-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">存储设置</h3>
        </div>
      </template>
      <el-form label-width="120px" :model="storageConfig" class="settings-form">
        <el-form-item label="存储类型">
          <el-radio-group v-model="storageConfig.type">
            <el-radio label="local">本地存储</el-radio>
            <el-radio label="oss">OSS存储</el-radio>
            <el-radio label="s3">S3存储</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-collapse v-model="activeCollapse" accordion>
          <el-collapse-item title="OSS存储配置" name="oss" v-if="storageConfig.type === 'oss'">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="OSS端点">
                  <el-input v-model="storageConfig.oss.endpoint" placeholder="请输入OSS端点" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Bucket名称">
                  <el-input v-model="storageConfig.oss.bucket" placeholder="请输入Bucket名称" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Access Key">
                  <el-input v-model="storageConfig.oss.accessKey" placeholder="请输入Access Key" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Secret Key">
                  <el-input v-model="storageConfig.oss.secretKey" placeholder="请输入Secret Key" type="password" show-password />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
          <el-collapse-item title="S3存储配置" name="s3" v-if="storageConfig.type === 's3'">
            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item label="S3端点">
                  <el-input v-model="storageConfig.s3.endpoint" placeholder="请输入S3端点" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Bucket名称">
                  <el-input v-model="storageConfig.s3.bucket" placeholder="请输入Bucket名称" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Access Key">
                  <el-input v-model="storageConfig.s3.accessKey" placeholder="请输入Access Key" />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item label="Secret Key">
                  <el-input v-model="storageConfig.s3.secretKey" placeholder="请输入Secret Key" type="password" show-password />
                </el-form-item>
              </el-col>
            </el-row>
          </el-collapse-item>
        </el-collapse>
        <el-form-item label="上传大小限制(MB)">
          <el-input v-model="storageConfig.maxSize" placeholder="请输入上传大小限制" type="number" />
        </el-form-item>
        <el-form-item label="允许的文件类型">
          <el-input v-model="storageConfig.allowedTypes" placeholder="请输入允许的文件类型，以逗号分隔" />
        </el-form-item>
      </el-form>
      <div class="form-actions">
        <el-button type="primary" @click="saveStorageConfig">保存配置</el-button>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 系统配置
const systemConfig = reactive({
  name: '灵境管理后台',
  version: '1.0.0',
  apiUrl: 'https://api.lingjing.com',
  copyright: '© 2024 灵境科技',
  status: true,
  maintenanceMode: false
})

// 原始系统配置用于重置
const originalSystemConfig = { ...systemConfig }

// 角色数据
const roles = [
  { label: '超级管理员', value: 'admin' },
  { label: '普通管理员', value: 'manager' },
  { label: '操作员', value: 'operator' },
  { label: '查看者', value: 'viewer' }
]

// 当前选中角色
const selectedRole = ref('admin')

// 权限数据
const permissions = ref([
  { name: '数据看板', description: '查看数据看板', enabled: true },
  { name: '用户管理', description: '管理用户账户', enabled: true },
  { name: '数据分析', description: '查看数据分析报告', enabled: true },
  { name: '会员管理', description: '管理会员信息', enabled: true },
  { name: '安全管理', description: '配置安全设置', enabled: true },
  { name: '系统设置', description: '配置系统参数', enabled: true },
  { name: 'API管理', description: '管理API密钥', enabled: false },
  { name: '日志查看', description: '查看系统日志', enabled: true }
])

// 通知配置
const notificationConfig = reactive({
  email: {
    enabled: true,
    smtpHost: 'smtp.example.com',
    smtpPort: 587,
    sender: 'admin@example.com',
    password: ''
  },
  sms: {
    enabled: false,
    apiKey: '',
    templateId: ''
  },
  wechat: {
    enabled: false
  }
})

// 存储配置
const storageConfig = reactive({
  type: 'local',
  maxSize: 500,
  allowedTypes: 'jpg,jpeg,png,gif,pdf,doc,docx,xls,xlsx',
  oss: {
    endpoint: '',
    bucket: '',
    accessKey: '',
    secretKey: ''
  },
  s3: {
    endpoint: '',
    bucket: '',
    accessKey: '',
    secretKey: ''
  }
})

// 折叠面板激活项
const activeCollapse = ref('')

// 保存系统配置
const saveSystemConfig = () => {
  ElMessage.success('系统配置已保存')
}

// 重置系统配置
const resetSystemConfig = () => {
  Object.assign(systemConfig, originalSystemConfig)
  ElMessage.info('配置已重置')
}

// 加载角色权限
const loadRolePermissions = () => {
  ElMessage.success(`已加载${selectedRole.value}角色的权限配置`)
}

// 保存权限配置
const savePermissions = () => {
  ElMessage.success('权限配置已保存')
}

// 保存通知配置
const saveNotificationConfig = () => {
  ElMessage.success('通知配置已保存')
}

// 保存存储配置
const saveStorageConfig = () => {
  ElMessage.success('存储配置已保存')
}
</script>

<style scoped>
.settings-container {
  padding: 0;
  background-color: var(--el-bg-color);
}

.header-section {
  margin-bottom: 20px;
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin: 0;
}

.page-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 4px 0 0 0;
}

.config-card {
  margin-bottom: 20px;
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.card-header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0;
}

.settings-form {
  padding: 20px 0;
}

.form-actions {
  display: flex;
  justify-content: flex-start;
  gap: 16px;
  padding-top: 20px;
  border-top: 1px solid var(--el-border-color);
}

.permission-section {
  padding: 20px 0;
}

.permission-description {
  margin-bottom: 20px;
}

.permission-description p {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.role-selection {
  margin-bottom: 20px;
}

.permission-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
}

.permission-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-base);
  transition: all 0.3s ease;
}

.permission-item:hover {
  transform: translateY(-2px);
  box-shadow: var(--el-box-shadow-light);
}

.permission-info {
  flex: 1;
}

.permission-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.permission-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.permission-action {
  margin-left: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .permission-grid {
    grid-template-columns: 1fr;
  }
  
  .card-header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .form-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .permission-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .permission-action {
    margin-left: 0;
    align-self: flex-start;
  }
}
</style>