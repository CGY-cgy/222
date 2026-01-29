<template>
  <div v-if="isAuthenticated" class="admin-container">
    <!-- 侧边栏 -->
    <aside :class="['sidebar', { collapsed: isSidebarCollapsed }]">
      <div class="sidebar-header">
        <div class="sidebar-logo">
          <div class="sidebar-logo-icon"></div>
          <div>
            <div class="sidebar-logo-text">灵境管理</div>
            <div class="sidebar-logo-sub">Admin Console</div>
          </div>
        </div>
      </div>
      <nav>
        <div class="nav-section">
          <div class="nav-section-title">主要功能</div>
          <el-menu :default-active="activeMenu" class="el-menu-vertical-demo" @select="handleMenuSelect">
            <el-menu-item index="dashboard">
              <template #icon>
                <el-icon><el-icon-s-data /></el-icon>
              </template>
              <span>数据看板</span>
            </el-menu-item>
            <el-menu-item index="users">
              <template #icon>
                <el-icon><el-icon-s-custom /></el-icon>
              </template>
              <span>用户管理</span>
            </el-menu-item>
            <el-menu-item index="analytics">
              <template #icon>
                <el-icon><el-icon-s-data /></el-icon>
              </template>
              <span>数据分析</span>
            </el-menu-item>
            <el-menu-item index="membership">
              <template #icon>
                <el-icon><el-icon-s-star /></el-icon>
              </template>
              <span>会员管理</span>
            </el-menu-item>
            <el-menu-item index="security">
              <template #icon>
                <el-icon><el-icon-s-tools /></el-icon>
              </template>
              <span>安全管理</span>
            </el-menu-item>
            <el-menu-item index="settings">
              <template #icon>
                <el-icon><el-icon-s-setting /></el-icon>
              </template>
              <span>系统设置</span>
            </el-menu-item>
          </el-menu>
        </div>
      </nav>
    </aside>
    <!-- 主内容区 -->
    <main class="main-content">
      <!-- 顶部导航 -->
      <header class="top-header">
        <div class="header-left">
          <el-button type="text" @click="toggleSidebar">
            <el-icon><el-icon-s-fold /></el-icon>
          </el-button>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleUserMenuCommand">
            <span class="user-info">
              <el-icon><el-icon-s-custom /></el-icon>
              <span>{{ user.name }}</span>
              <el-icon class="el-icon--right"><el-icon-arrow-down /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="changePassword">修改密码</el-dropdown-item>
                <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </header>
      <!-- 内容区域 -->
      <div class="content-wrapper">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>{{ pageTitle }}</span>
            </div>
          </template>
          <div class="card-content">
            <!-- 显示用户功能组件 -->
            <UserProfile v-if="activeUserMenu === 'profile'" />
            <ChangePassword v-else-if="activeUserMenu === 'changePassword'" />
            <!-- 根据不同菜单显示不同内容 -->
            <Dashboard v-else-if="activeMenu === 'dashboard'" />
            <Users v-else-if="activeMenu === 'users'" />
            <Analytics v-else-if="activeMenu === 'analytics'" />
            <Membership v-else-if="activeMenu === 'membership'" />
            <Security v-else-if="activeMenu === 'security'" />
            <Settings v-else-if="activeMenu === 'settings'" />
          </div>
        </el-card>
      </div>
    </main>
  </div>
  <!-- 未登录时显示路由视图 -->
  <router-view v-else />
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from './stores/auth'
import Dashboard from './components/Dashboard.vue'
import Users from './components/Users.vue'
import Analytics from './components/Analytics.vue'
import Membership from './components/Membership.vue'
import Security from './components/Security.vue'
import Settings from './components/Settings.vue'
import UserProfile from './components/UserProfile.vue'
import ChangePassword from './components/ChangePassword.vue'
import { ElMessage } from 'element-plus'
import {
  ElIcon,
  ElMenu,
  ElMenuItem,
  ElButton,
  ElDropdown,
  ElDropdownMenu,
  ElDropdownItem,
  ElCard
} from 'element-plus'
import {
  User,
  Star,
  DataAnalysis,
  Setting,
  Tools,
  Fold,
  ArrowDown
} from '@element-plus/icons-vue'

// 定义组件别名
const ElIconSData = DataAnalysis
const ElIconSCustom = User
const ElIconSStar = Star
const ElIconSTools = Tools
const ElIconSSetting = Setting
const ElIconSFold = Fold
const ElIconArrowDown = ArrowDown

// 路由和状态管理
const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

// 响应式数据
const activeMenu = ref('dashboard')
const isSidebarCollapsed = ref(false)
const activeUserMenu = ref('')
const isAuthenticated = computed(() => authStore.isAuthenticated)
const user = computed(() => authStore.user)

// 计算属性
const pageTitle = computed(() => {
  if (activeUserMenu.value === 'profile') {
    return '个人中心'
  } else if (activeUserMenu.value === 'changePassword') {
    return '修改密码'
  }
  const titles = {
    dashboard: '数据看板',
    users: '用户管理',
    analytics: '数据分析',
    membership: '会员管理',
    security: '安全管理',
    settings: '系统设置'
  }
  return titles[activeMenu.value] || '数据看板'
})

// 监听路由变化，更新活动菜单
watch(() => route.path, (newPath) => {
  // 清除用户功能菜单
  activeUserMenu.value = ''
  // 根据路由路径更新主菜单
  if (newPath === '/') {
    activeMenu.value = 'dashboard'
  } else if (newPath.startsWith('/users')) {
    activeMenu.value = 'users'
  } else if (newPath.startsWith('/analytics')) {
    activeMenu.value = 'analytics'
  } else if (newPath.startsWith('/membership')) {
    activeMenu.value = 'membership'
  } else if (newPath.startsWith('/security')) {
    activeMenu.value = 'security'
  } else if (newPath.startsWith('/settings')) {
    activeMenu.value = 'settings'
  }
})

// 初始化检查
onMounted(() => {
  // 检查认证状态
  authStore.checkAuth()
  // 根据当前路由更新活动菜单
  if (route.path === '/') {
    activeMenu.value = 'dashboard'
  }
})

// 方法
const handleMenuSelect = (key, keyPath) => {
  activeMenu.value = key
  // 关闭用户功能菜单
  activeUserMenu.value = ''
  // 导航到对应的路由
  switch (key) {
    case 'dashboard':
      router.push('/')
      break
    case 'users':
      router.push('/users')
      break
    case 'analytics':
      router.push('/analytics')
      break
    case 'membership':
      router.push('/membership')
      break
    case 'security':
      router.push('/security')
      break
    case 'settings':
      router.push('/settings')
      break
  }
}

const toggleSidebar = () => {
  isSidebarCollapsed.value = !isSidebarCollapsed.value
}

// 处理用户菜单命令
const handleUserMenuCommand = (command) => {
  if (command === 'logout') {
    // 退出登录
    authStore.logout()
    ElMessage.success('退出登录成功！')
    router.push('/login')
  } else {
    // 打开对应的用户功能
    activeUserMenu.value = command
    // 清除主菜单的选中状态
    activeMenu.value = ''
  }
}
</script>

<style scoped>
.admin-container {
  display: flex;
  height: 100vh;
  overflow: hidden;
  background-color: #f5f7fa;
}

/* 侧边栏优化 */
.sidebar {
  width: 240px;
  background-color: #ffffff;
  border-right: 1px solid #e4e7ed;
  display: flex;
  flex-direction: column;
  transition: all 0.3s cubic-bezier(0.645, 0.045, 0.355, 1);
  box-shadow: 2px 0 8px rgba(0, 0, 0, 0.05);
  z-index: 100;
}

.sidebar.collapsed {
  width: 80px;
  box-shadow: none;
}

.sidebar.collapsed .sidebar-logo-text,
.sidebar.collapsed .sidebar-logo-sub,
.sidebar.collapsed .nav-section-title,
.sidebar.collapsed .el-menu-item span {
  display: none;
}

.sidebar.collapsed .sidebar-logo {
  justify-content: center;
}

.sidebar.collapsed .el-menu-item {
  justify-content: center;
}

/* 侧边栏头部 */
.sidebar-header {
  padding: 16px 20px;
  border-bottom: 1px solid #f0f2f5;
  background-color: #ffffff;
}

.sidebar-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  transition: all 0.3s ease;
}

.sidebar-logo-icon {
  width: 44px;
  height: 44px;
  background: url('../../lingjing.png') center center no-repeat;
  background-size: contain;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
}

.sidebar-logo-text {
  font-size: 20px;
  font-weight: 700;
  color: #1f2937;
  transition: all 0.3s ease;
}

.sidebar-logo-sub {
  font-size: 12px;
  color: #6b7280;
  transition: all 0.3s ease;
  margin-top: 2px;
}

/* 导航菜单 */
.nav-section {
  padding: 20px 0;
  flex: 1;
  overflow-y: auto;
}

.nav-section::-webkit-scrollbar {
  width: 4px;
}

.nav-section::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.nav-section::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 2px;
}

.nav-section-title {
  font-size: 12px;
  font-weight: 600;
  color: #9ca3af;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 0 20px 12px;
}

/* Element Plus 菜单样式覆盖 */
.el-menu-vertical-demo {
  border-right: none;
  background-color: transparent;
}

.el-menu-item {
  height: 44px;
  line-height: 44px;
  margin: 0 8px;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.el-menu-item:hover {
  background-color: #f5f7fa;
  color: #409eff;
}

.el-menu-item.is-active {
  background-color: #ecf5ff;
  color: #409eff;
}

/* 主内容区域 */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* 顶部导航栏优化 */
.top-header {
  height: 64px;
  background-color: #ffffff;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
  z-index: 50;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  padding: 8px 16px;
  border-radius: 6px;
  transition: all 0.2s ease;
  font-size: 14px;
  color: #333;
}

.user-info:hover {
  background-color: #f5f7fa;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

/* 内容包装器 */
.content-wrapper {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  background-color: #f5f7fa;
}

.content-wrapper::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

.content-wrapper::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.content-wrapper::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 4px;
}

.content-wrapper::-webkit-scrollbar-thumb:hover {
  background: #a1a1a1;
}

/* 卡片样式优化 */
.el-card {
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.04);
  transition: box-shadow 0.3s ease;
  border: none;
}

.el-card:hover {
  box-shadow: 0 4px 16px 0 rgba(0, 0, 0, 0.08);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0;
}

.card-header span {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.card-content {
  padding: 24px;
}

/* 响应式设计优化 */
@media (max-width: 768px) {
  .sidebar {
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    transform: translateX(0);
  }
  
  .sidebar.collapsed {
    transform: translateX(-100%);
    width: 240px;
  }
  
  .content-wrapper {
    padding: 16px;
  }
  
  .top-header {
    padding: 0 16px;
  }
}
</style>