<template>
  <div class="users-container">
    <!-- 导出按钮 -->
    <div class="header-actions">
      <el-button type="primary" @click="exportExcel">
        <el-icon><el-icon-document /></el-icon>
        <span>导出Excel</span>
      </el-button>
    </div>

    <!-- 搜索卡片 -->
    <el-card shadow="hover" class="search-card">
      <h3 class="section-title">搜索条件</h3>
      <div class="search-form">
        <div class="form-row">
          <el-form-item label="用户ID">
            <el-input v-model="searchForm.id" placeholder="请输入用户ID" clearable />
          </el-form-item>
          <el-form-item label="手机号">
            <el-input v-model="searchForm.phone" placeholder="请输入手机号" clearable />
          </el-form-item>
          <el-form-item label="昵称">
            <el-input v-model="searchForm.name" placeholder="请输入昵称" clearable />
          </el-form-item>
          <el-form-item label="会员状态">
            <el-select v-model="searchForm.memberStatus" placeholder="请选择会员状态" clearable>
              <el-option label="普通用户" value="normal" />
              <el-option label="VIP会员" value="vip" />
              <el-option label="SVIP会员" value="svip" />
            </el-select>
          </el-form-item>
          <el-form-item label="账户状态">
            <el-select v-model="searchForm.accountStatus" placeholder="请选择账户状态" clearable>
              <el-option label="已启用" value="active" />
              <el-option label="已禁用" value="inactive" />
              <el-option label="已封禁" value="banned" />
            </el-select>
          </el-form-item>
        </div>
        <div class="form-actions">
          <el-button type="primary" @click="searchUsers">
            <el-icon><el-icon-search /></el-icon>
            <span>搜索</span>
          </el-button>
          <el-button @click="resetSearch">
            <el-icon><el-icon-refresh-right /></el-icon>
            <span>重置</span>
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 用户列表表格 -->
    <el-card shadow="hover" class="users-table-card">
      <h3 class="section-title">用户列表</h3>
      <div class="table-container">
        <el-table :data="currentPageUsers" stripe style="width: 100%">
          <el-table-column label="用户" min-width="180">
            <template #default="scope">
              <div class="user-info">
                <div class="user-avatar" :style="{ background: `linear-gradient(135deg, ${getUserAvatarColor(scope.row.id)} 0%, ${getUserAvatarColor(scope.row.id, true)} 100%)` }">
                  {{ scope.row.name.charAt(0) }}
                </div>
                <div class="user-details">
                  <div class="user-name">{{ scope.row.name }}</div>
                  <div class="user-id">ID: {{ scope.row.id }}</div>
                </div>
              </div>
            </template>
          </el-table-column>
          <el-table-column prop="phone" label="手机号" min-width="120" />
          <el-table-column prop="registerTime" label="注册时间" min-width="160" />
          <el-table-column prop="lastLogin" label="最后登录" min-width="160" />
          <el-table-column label="会员状态" min-width="120">
            <template #default="scope">
              <el-tag :type="getMemberStatusType(scope.row.memberStatus)">
                {{ getMemberStatusText(scope.row.memberStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="账户状态" min-width="120">
            <template #default="scope">
              <el-tag :type="getAccountStatusType(scope.row.accountStatus)">
                {{ getAccountStatusText(scope.row.accountStatus) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" min-width="150" fixed="right">
            <template #default="scope">
              <el-button type="primary" link @click="viewUserDetail(scope.row)">
                <el-icon><el-icon-view /></el-icon>
                <span>详情</span>
              </el-button>
              <el-button type="warning" link @click="resetPassword(scope.row.id)">
                <el-icon><el-icon-key /></el-icon>
                <span>重置密码</span>
              </el-button>
              <el-button :type="scope.row.accountStatus === 'active' ? 'danger' : 'success'" link @click="toggleStatus(scope.row)">
                <el-icon><el-icon-refresh /></el-icon>
                <span>{{ scope.row.accountStatus === 'active' ? '禁用' : '启用' }}</span>
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 分页 -->
      <div class="pagination-container">
        <div class="pagination-info">
          共 {{ filteredUsers.length }} 条记录，每页 {{ pageSize }} 条
        </div>
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[5, 10, 20, 50]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="filteredUsers.length"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 用户详情模态框 -->
    <el-dialog
      v-model="detailDialogVisible"
      title="用户详情"
      width="500px"
      :close-on-click-modal="false"
    >
      <div v-if="currentUser" class="user-detail">
        <div class="detail-header">
          <div class="user-avatar large" :style="{ background: `linear-gradient(135deg, ${getUserAvatarColor(currentUser.id)} 0%, ${getUserAvatarColor(currentUser.id, true)} 100%)` }">
            {{ currentUser.name.charAt(0) }}
          </div>
          <div class="user-info-detail">
            <h4 class="user-name">{{ currentUser.name }}</h4>
            <div class="user-basic-info">
              <span>ID: {{ currentUser.id }}</span>
              <span>{{ currentUser.fullPhone }}</span>
            </div>
          </div>
        </div>
        <div class="detail-stats">
          <el-row :gutter="20">
            <el-col :span="12">
              <el-card shadow="hover" class="stat-card">
                <div class="stat-label">注册时间</div>
                <div class="stat-value">{{ currentUser.registerTime }}</div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card shadow="hover" class="stat-card">
                <div class="stat-label">最后登录</div>
                <div class="stat-value">{{ currentUser.lastLogin }}</div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card shadow="hover" class="stat-card">
                <div class="stat-label">会员状态</div>
                <div class="stat-value">{{ getMemberStatusText(currentUser.memberStatus) }}</div>
              </el-card>
            </el-col>
            <el-col :span="12">
              <el-card shadow="hover" class="stat-card">
                <div class="stat-label">账户状态</div>
                <div class="stat-value">{{ getAccountStatusText(currentUser.accountStatus) }}</div>
              </el-card>
            </el-col>
          </el-row>
        </div>
        <div class="health-info">
          <h4 class="section-title">健康评分</h4>
          <div class="health-score-card">
            <div class="score-circle">
              <span class="score-value">{{ currentUser.healthScore }}</span>
            </div>
            <div class="score-desc">
              <p>基于舌像和问卷的综合评估</p>
            </div>
          </div>
          <div class="constitution-tags">
            <el-tag v-for="(item, index) in currentUser.constitution" :key="index" size="large">
              {{ item }}
            </el-tag>
          </div>
        </div>
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">关闭</el-button>
          <el-button type="primary" @click="openEditModal">修改信息</el-button>
          <el-button type="warning" @click="resetPassword(currentUser.id)">重置密码</el-button>
          <el-button type="danger" @click="banUser(currentUser.id)">
            {{ currentUser.accountStatus === 'banned' ? '解除封禁' : '封禁账户' }}
          </el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 修改用户信息模态框 -->
    <el-dialog
      v-model="editDialogVisible"
      title="修改用户信息"
      width="600px"
      :close-on-click-modal="false"
    >
      <el-form v-model="editForm" label-position="top" class="edit-form">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户ID" prop="id">
              <el-input v-model="editForm.id" readonly />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="姓名" prop="name">
              <el-input v-model="editForm.name" placeholder="请输入姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="fullPhone">
              <el-input v-model="editForm.fullPhone" placeholder="请输入手机号" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="会员状态" prop="memberStatus">
              <el-select v-model="editForm.memberStatus" placeholder="请选择会员状态">
                <el-option label="普通用户" value="normal" />
                <el-option label="VIP会员" value="vip" />
                <el-option label="SVIP会员" value="svip" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="账户状态" prop="accountStatus">
              <el-select v-model="editForm.accountStatus" placeholder="请选择账户状态">
                <el-option label="已启用" value="active" />
                <el-option label="已禁用" value="inactive" />
                <el-option label="已封禁" value="banned" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="健康评分" prop="healthScore">
              <el-input v-model.number="editForm.healthScore" placeholder="请输入健康评分" type="number" min="0" max="100" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="体质类型" prop="constitution">
          <div class="constitution-checkbox-group">
            <el-checkbox-group v-model="editForm.constitution">
              <el-checkbox-button v-for="item in constitutionOptions" :key="item.value" :label="item.label">
                {{ item.label }}
              </el-checkbox-button>
            </el-checkbox-group>
          </div>
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveUserChanges">保存修改</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'
import {
  Document,
  Search,
  RefreshRight,
  View,
  Key,
  Refresh
} from '@element-plus/icons-vue'

// 定义组件别名
const ElIconDocument = Document
const ElIconSearch = Search
const ElIconRefreshRight = RefreshRight
const ElIconView = View
const ElIconKey = Key
const ElIconRefresh = Refresh

// 体质类型选项
const constitutionOptions = [
  { label: '平和质', value: '平和质' },
  { label: '气虚质', value: '气虚质' },
  { label: '阳虚质', value: '阳虚质' },
  { label: '阴虚质', value: '阴虚质' },
  { label: '痰湿质', value: '痰湿质' },
  { label: '湿热质', value: '湿热质' },
  { label: '血瘀质', value: '血瘀质' },
  { label: '气郁质', value: '气郁质' },
  { label: '特禀质', value: '特禀质' }
]

// 用户数据
const users = ref([
  { id: '100001', name: '李晓明', phone: '138****1234', fullPhone: '13812341234', memberStatus: 'svip', accountStatus: 'active', registerTime: '2024-01-15 09:30', lastLogin: '2024-12-27 14:25', healthScore: 92, constitution: ['平和质', '气虚质', '阳虚质'] },
  { id: '100002', name: '王芳', phone: '139****5678', fullPhone: '13956785678', memberStatus: 'vip', accountStatus: 'active', registerTime: '2024-02-20 14:15', lastLogin: '2024-12-26 18:42', healthScore: 85, constitution: ['痰湿质', '阴虚质'] },
  { id: '100003', name: '张伟', phone: '136****9012', fullPhone: '13690129012', memberStatus: 'normal', accountStatus: 'active', registerTime: '2024-03-10 08:45', lastLogin: '2024-12-27 10:18', healthScore: 78, constitution: ['湿热质', '血瘀质'] },
  { id: '100004', name: '刘洋', phone: '137****3456', fullPhone: '13734563456', memberStatus: 'svip', accountStatus: 'inactive', registerTime: '2024-04-05 16:30', lastLogin: '2024-12-25 22:15', healthScore: 88, constitution: ['平和质', '气郁质'] },
  { id: '100005', name: '陈静', phone: '135****7890', fullPhone: '13578907890', memberStatus: 'vip', accountStatus: 'banned', registerTime: '2024-05-18 11:20', lastLogin: '2024-12-27 08:55', healthScore: 80, constitution: ['痰湿质', '湿热质', '血瘀质'] },
  { id: '100006', name: '赵强', phone: '134****2345', fullPhone: '13423452345', memberStatus: 'normal', accountStatus: 'active', registerTime: '2024-06-25 13:45', lastLogin: '2024-12-27 09:30', healthScore: 75, constitution: ['气虚质', '阳虚质'] },
  { id: '100007', name: '孙丽', phone: '133****6789', fullPhone: '13367896789', memberStatus: 'svip', accountStatus: 'active', registerTime: '2024-07-12 10:20', lastLogin: '2024-12-26 16:45', healthScore: 95, constitution: ['平和质', '阴虚质'] },
  { id: '100008', name: '周杰', phone: '132****0123', fullPhone: '13201230123', memberStatus: 'vip', accountStatus: 'active', registerTime: '2024-08-30 15:10', lastLogin: '2024-12-27 11:20', healthScore: 82, constitution: ['痰湿质', '气郁质'] },
  { id: '100009', name: '吴敏', phone: '131****4567', fullPhone: '13145674567', memberStatus: 'normal', accountStatus: 'active', registerTime: '2024-09-18 09:50', lastLogin: '2024-12-25 14:30', healthScore: 79, constitution: ['湿热质', '阳虚质'] },
  { id: '100010', name: '郑华', phone: '130****8901', fullPhone: '13089018901', memberStatus: 'svip', accountStatus: 'active', registerTime: '2024-10-22 14:25', lastLogin: '2024-12-27 13:15', healthScore: 90, constitution: ['平和质', '血瘀质'] }
])

// 搜索表单
const searchForm = ref({
  id: '',
  phone: '',
  name: '',
  memberStatus: '',
  accountStatus: ''
})

// 分页数据
const currentPage = ref(1)
const pageSize = ref(5)

// 过滤后的用户列表
const filteredUsers = computed(() => {
  return users.value.filter(user => {
    // 多条件AND搜索
    const matchId = !searchForm.value.id || user.id.includes(searchForm.value.id)
    const matchPhone = !searchForm.value.phone || user.fullPhone.includes(searchForm.value.phone)
    const matchName = !searchForm.value.name || user.name.includes(searchForm.value.name)
    const matchMemberStatus = !searchForm.value.memberStatus || user.memberStatus === searchForm.value.memberStatus
    const matchAccountStatus = !searchForm.value.accountStatus || user.accountStatus === searchForm.value.accountStatus
    return matchId && matchPhone && matchName && matchMemberStatus && matchAccountStatus
  })
})

// 当前页用户数据
const currentPageUsers = computed(() => {
  const startIndex = (currentPage.value - 1) * pageSize.value
  const endIndex = startIndex + pageSize.value
  return filteredUsers.value.slice(startIndex, endIndex)
})

// 详情模态框
const detailDialogVisible = ref(false)
const currentUser = ref(null)

// 编辑模态框
const editDialogVisible = ref(false)
const editForm = ref({})

// 搜索用户
const searchUsers = () => {
  currentPage.value = 1 // 搜索后重置到第一页
  ElMessage.success('搜索完成')
}

// 重置搜索
const resetSearch = () => {
  searchForm.value = {
    id: '',
    phone: '',
    name: '',
    memberStatus: '',
    accountStatus: ''
  }
  currentPage.value = 1
  ElMessage.success('搜索条件已重置')
}

// 查看用户详情
const viewUserDetail = (user) => {
  currentUser.value = user
  detailDialogVisible.value = true
}

// 打开编辑模态框
const openEditModal = () => {
  if (currentUser.value) {
    // 深拷贝用户数据到编辑表单
    editForm.value = JSON.parse(JSON.stringify(currentUser.value))
    editDialogVisible.value = true
  }
}

// 保存用户修改
const saveUserChanges = () => {
  // 更新用户数据
  const index = users.value.findIndex(user => user.id === editForm.value.id)
  if (index !== -1) {
    users.value[index] = { ...editForm.value }
    // 更新当前查看的用户数据
    if (currentUser.value && currentUser.value.id === editForm.value.id) {
      currentUser.value = { ...editForm.value }
    }
    editDialogVisible.value = false
    ElMessage.success('用户信息已更新')
  }
}

// 重置密码
const resetPassword = (userId) => {
  ElMessage.warning('密码重置功能开发中')
}

// 切换用户状态
const toggleStatus = (user) => {
  const newStatus = user.accountStatus === 'active' ? 'inactive' : 'active'
  const index = users.value.findIndex(u => u.id === user.id)
  if (index !== -1) {
    users.value[index].accountStatus = newStatus
    if (currentUser.value && currentUser.value.id === user.id) {
      currentUser.value.accountStatus = newStatus
    }
    ElMessage.success(`用户状态已切换为${newStatus === 'active' ? '已启用' : '已禁用'}`)
  }
}

// 封禁/解封用户
const banUser = (userId) => {
  const user = users.value.find(u => u.id === userId)
  if (user) {
    const newStatus = user.accountStatus === 'banned' ? 'active' : 'banned'
    user.accountStatus = newStatus
    if (currentUser.value && currentUser.value.id === userId) {
      currentUser.value.accountStatus = newStatus
    }
    ElMessage.success(`用户已${newStatus === 'banned' ? '封禁' : '解封'}`)
  }
}

// 分页大小变化
const handleSizeChange = (newSize) => {
  pageSize.value = newSize
  currentPage.value = 1 // 切换每页条数后回到第一页
}

// 当前页码变化
const handleCurrentChange = (newPage) => {
  currentPage.value = newPage
}

// 导出Excel
const exportExcel = () => {
  ElMessage.info('报表导出中...')
  
  // 准备导出数据
  const exportData = users.value.map(user => ({
    '用户ID': user.id,
    '姓名': user.name,
    '手机号': user.fullPhone,
    '注册时间': user.registerTime,
    '最后登录': user.lastLogin,
    '会员状态': getMemberStatusText(user.memberStatus),
    '账户状态': getAccountStatusText(user.accountStatus),
    '健康评分': user.healthScore,
    '体质类型': user.constitution.join(', ')
  }))
  
  // 创建工作簿
  const wb = XLSX.utils.book_new()
  const ws = XLSX.utils.json_to_sheet(exportData)
  
  // 添加工作表
  XLSX.utils.book_append_sheet(wb, ws, '用户数据')
  
  // 导出文件
  setTimeout(() => {
    XLSX.writeFile(wb, `用户列表_${new Date().toISOString().slice(0, 10)}.xlsx`)
    ElMessage.success('报表导出成功！')
  }, 1000)
}

// 获取会员状态文本
const getMemberStatusText = (status) => {
  const map = {
    normal: '普通用户',
    vip: 'VIP会员',
    svip: 'SVIP会员'
  }
  return map[status] || status
}

// 获取会员状态标签类型
const getMemberStatusType = (status) => {
  const map = {
    normal: 'info',
    vip: 'warning',
    svip: 'success'
  }
  return map[status] || 'info'
}

// 获取账户状态文本
const getAccountStatusText = (status) => {
  const map = {
    active: '已启用',
    inactive: '已禁用',
    banned: '已封禁'
  }
  return map[status] || status
}

// 获取账户状态标签类型
const getAccountStatusType = (status) => {
  const map = {
    active: 'success',
    inactive: 'warning',
    banned: 'danger'
  }
  return map[status] || 'info'
}

// 根据用户ID生成头像颜色
const getUserAvatarColor = (id, isSecondary = false) => {
  const colors = ['#667eea', '#764ba2', '#48bb78', '#ed8936', '#f56565']
  const hash = id.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0)
  const index = hash % colors.length
  return isSecondary ? colors[(index + 1) % colors.length] : colors[index]
}
</script>

<style scoped>
.users-container {
  padding: 0;
  background-color: var(--el-bg-color);
}

.header-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  margin-bottom: 20px;
}

.search-card {
  margin-bottom: 20px;
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.section-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0 0 20px 0;
}

.search-form {
  width: 100%;
}

.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  margin-bottom: 20px;
}

.form-row :deep(.el-form-item) {
  margin-right: 20px;
}

.form-actions {
  display: flex;
  gap: 16px;
  justify-content: flex-end;
}

.users-table-card {
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.table-container {
  margin-bottom: 20px;
  overflow-x: auto;
}

:deep(.el-table__header-wrapper) {
  background-color: var(--el-bg-color-page);
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 20px;
  border-top: 1px solid var(--el-border-color);
}

.pagination-info {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

/* 用户信息 */
.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.user-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 14px;
}

.user-avatar.large {
  width: 80px;
  height: 80px;
  font-size: 28px;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.user-id {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

/* 详情页 */
.user-detail {
  padding: 10px 0;
}

.detail-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid var(--el-border-color);
}

.user-info-detail {
  display: flex;
  flex-direction: column;
}

.user-info-detail .user-name {
  font-size: 20px;
  margin-bottom: 8px;
}

.user-basic-info {
  display: flex;
  gap: 20px;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.detail-stats {
  margin-bottom: 30px;
}

.stat-card {
  text-align: center;
  height: 100%;
}

.stat-label {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
  margin-bottom: 8px;
}

.stat-value {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.health-info {
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
  padding: 20px;
  border-radius: var(--el-border-radius-large);
}

.health-info .section-title {
  margin-bottom: 20px;
}

.health-score-card {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 20px;
}

.score-circle {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background-color: var(--el-color-success);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 24px;
  font-weight: 700;
}

.score-desc {
  display: flex;
  flex-direction: column;
}

.score-desc h4 {
  font-size: 18px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.score-desc p {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 0;
}

.constitution-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

/* 编辑表单 */
.edit-form {
  width: 100%;
}

.constitution-checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .form-row {
    flex-direction: column;
  }
  
  .form-row :deep(.el-form-item) {
    margin-right: 0;
    width: 100%;
  }
}

@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .header-actions {
    justify-content: center;
  }
}
</style>