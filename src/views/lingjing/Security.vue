<template>
  <div class="security-container">
    <!-- 页面标题和操作 -->
    <div class="header-section">
      <h1 class="page-title">安全管理</h1>
      <p class="page-subtitle">系统安全评分、事件监控与配置管理</p>
    </div>

    <!-- 顶部操作栏 -->
    <div class="top-actions">
      <div class="date-range">
        <el-select v-model="currentDateRange" placeholder="选择日期范围" size="large" @change="updateAllCharts">
          <el-option label="最近7天" :value="7" />
          <el-option label="最近30天" :value="30" />
          <el-option label="最近90天" :value="90" />
        </el-select>
      </div>
      <el-button type="primary" size="large" @click="exportSecurityReport">
        <el-icon><el-icon-document-download /></el-icon>
        <span>导出报表</span>
      </el-button>
    </div>

    <!-- 安全评分与监控看板 -->
    <div class="security-score-section">
      <el-card shadow="hover" class="score-card">
        <div class="score-header">
          <div>
            <h3 class="score-title">安全评分</h3>
            <p class="score-subtitle">系统整体安全状况评估</p>
          </div>
          <div class="score-circle">
            <span class="score-value">92</span>
            <span class="score-unit">/100</span>
          </div>
        </div>
        <div class="score-metrics">
          <div class="metric-item">
            <div class="metric-value">12,345</div>
            <div class="metric-label">今日请求数</div>
          </div>
          <div class="metric-item">
            <div class="metric-value">99.9%</div>
            <div class="metric-label">系统可用性</div>
          </div>
          <div class="metric-item">
            <div class="metric-value">156</div>
            <div class="metric-label">今日拦截</div>
          </div>
          <div class="metric-item">
            <div class="metric-value">3</div>
            <div class="metric-label">待处理告警</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 安全事件趋势与分布 -->
    <div class="grid-2">
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">安全事件趋势</h3>
            <span class="chart-desc">过去 {{ currentDateRange }} 天的安全事件变化</span>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="securityTrendChart"></canvas>
        </div>
      </el-card>
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">安全事件分布</h3>
            <span class="chart-desc">不同类型安全事件占比</span>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="securityDistributionChart"></canvas>
        </div>
        <div class="event-types">
          <div class="event-item" v-for="item in securityEventTypes" :key="item.type">
            <div class="event-name">{{ item.name }}</div>
            <div class="event-count">{{ item.count }} 次</div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 安全配置与合规检查 -->
    <div class="security-config-section">
      <el-card shadow="hover" class="config-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">数据安全配置</h3>
            <span class="card-action">查看详情 →</span>
          </div>
        </template>
        <div class="config-grid">
          <div class="config-item">
            <div class="config-icon success">🔒</div>
            <div class="config-info">
              <div class="config-name">敏感数据加密</div>
              <div class="config-status">已启用</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon success">🌐</div>
            <div class="config-info">
              <div class="config-name">HTTPS/TLS</div>
              <div class="config-status">已启用</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon success">🗝️</div>
            <div class="config-info">
              <div class="config-name">密钥管理</div>
              <div class="config-status">已启用</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon warning">🔍</div>
            <div class="config-info">
              <div class="config-name">异常登录检测</div>
              <div class="config-status">待优化</div>
            </div>
          </div>
        </div>
      </el-card>

      <el-card shadow="hover" class="config-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">用户隐私与合规</h3>
            <span class="card-action">查看详情 →</span>
          </div>
        </template>
        <div class="config-grid">
          <div class="config-item">
            <div class="config-icon success">📜</div>
            <div class="config-info">
              <div class="config-name">隐私政策</div>
              <div class="config-status">已更新</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon success">🔑</div>
            <div class="config-info">
              <div class="config-name">权限最小化</div>
              <div class="config-status">已启用</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon success">👤</div>
            <div class="config-info">
              <div class="config-name">数据匿名化</div>
              <div class="config-status">已启用</div>
            </div>
          </div>
          <div class="config-item">
            <div class="config-icon success">🧪</div>
            <div class="config-info">
              <div class="config-name">第三方审计</div>
              <div class="config-status">已完成</div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 安全日志与告警 -->
    <el-card shadow="hover" class="chart-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">最近安全告警</h3>
          <el-button type="primary" link>查看全部告警 →</el-button>
        </div>
      </template>
      <div class="security-alerts">
        <div v-for="(alert, index) in securityAlerts" :key="index" class="alert-item">
          <div class="alert-icon" :class="alert.level">
            {{ alert.icon }}
          </div>
          <div class="alert-content">
            <div class="alert-title">{{ alert.title }}</div>
            <div class="alert-description">{{ alert.description }}</div>
            <div class="alert-meta">
              <span class="alert-time">{{ alert.time }}</span>
              <span class="alert-level-badge" :class="alert.level">{{ alert.levelText }}</span>
            </div>
          </div>
          <div class="alert-action">
            <el-button type="primary" size="small">处理</el-button>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { Chart, registerables } from 'chart.js'
import * as XLSX from 'xlsx'
import { ElMessage } from 'element-plus'
import {
  Download
} from '@element-plus/icons-vue'

// 注册Chart.js组件
Chart.register(...registerables)

// 定义组件别名
const ElIconDocumentDownload = Download

// 响应式数据
const currentDateRange = ref(30)

// 图表引用
const securityTrendChart = ref(null)
const securityDistributionChart = ref(null)

// 图表实例
let securityTrendChartInstance = null
let securityDistributionChartInstance = null

// 安全事件类型
const securityEventTypes = [
  { type: 'brute_force', name: '暴力破解', count: 85, color: '#f56565' },
  { type: 'sql_injection', name: 'SQL注入', count: 32, color: '#ed8936' },
  { type: 'xss', name: '跨站脚本', count: 28, color: '#ed8936' },
  { type: 'ddos', name: 'DDoS攻击', count: 15, color: '#f56565' },
  { type: 'malware', name: '恶意软件', count: 8, color: '#f56565' },
  { type: 'anomaly', name: '异常访问', count: 120, color: '#48bb78' }
]

// 安全告警数据
const securityAlerts = [
  { id: 1, icon: '🔒', title: '多次登录失败', description: 'IP地址 192.168.1.100 连续10次登录失败', time: '2024-12-27 14:32:15', level: 'warning', levelText: '警告' },
  { id: 2, icon: '⚠️', title: '异常数据访问', description: '用户 ID: 100001 尝试访问未授权数据', time: '2024-12-27 13:45:22', level: 'danger', levelText: '危险' },
  { id: 3, icon: '🔍', title: '可疑IP访问', description: '来自未知IP的可疑访问请求', time: '2024-12-27 12:15:36', level: 'warning', levelText: '警告' },
  { id: 4, icon: '📈', title: '流量异常', description: '系统流量异常增长，疑似DDoS攻击', time: '2024-12-27 11:05:48', level: 'danger', levelText: '危险' },
  { id: 5, icon: '🔑', title: '密码过期提醒', description: '管理员账号密码将在3天后过期', time: '2024-12-27 10:30:12', level: 'info', levelText: '信息' }
]

// 颜色配置
const chartColors = {
  primary: '#667eea',
  secondary: '#764ba2',
  success: '#48bb78',
  warning: '#ed8936',
  danger: '#f56565'
}

// 初始化安全事件趋势图表
const initSecurityTrendChart = () => {
  if (securityTrendChart.value) {
    if (securityTrendChartInstance) {
      securityTrendChartInstance.destroy()
    }
    const ctx = securityTrendChart.value.getContext('2d')
    
    let labels, attackData, failedLoginData
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日']
      attackData = [120, 145, 132, 158, 172, 185, 168]
      failedLoginData = [85, 92, 88, 105, 112, 120, 108]
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      attackData = [120, 580, 1050, 1520, 2080, 2650, 3280]
      failedLoginData = [85, 420, 780, 1150, 1520, 1980, 2450]
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日']
      attackData = [120, 2850, 5800, 8950, 12200, 15650, 19300]
      failedLoginData = [85, 2100, 4350, 6750, 9300, 12000, 14850]
    }
    
    securityTrendChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '总攻击次数',
          data: attackData,
          borderColor: chartColors.danger,
          backgroundColor: 'rgba(245, 101, 101, 0.1)',
          fill: true,
          tension: 0.4
        }, {
          label: '失败登录次数',
          data: failedLoginData,
          borderColor: chartColors.warning,
          backgroundColor: 'rgba(237, 137, 54, 0.1)',
          fill: true,
          tension: 0.4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              callback: function(value) {
                return value.toLocaleString()
              }
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        }
      }
    })
  }
}

// 初始化安全事件分布图表
const initSecurityDistributionChart = () => {
  if (securityDistributionChart.value) {
    if (securityDistributionChartInstance) {
      securityDistributionChartInstance.destroy()
    }
    const ctx = securityDistributionChart.value.getContext('2d')
    
    const labels = securityEventTypes.map(item => item.name)
    const data = securityEventTypes.map(item => item.count)
    const colors = securityEventTypes.map(item => item.color)
    
    securityDistributionChartInstance = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: labels,
        datasets: [{
          data: data,
          backgroundColor: colors,
          borderWidth: 0,
          hoverOffset: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        cutout: '70%'
      }
    })
  }
}

// 更新所有图表
const updateAllCharts = () => {
  initSecurityTrendChart()
  initSecurityDistributionChart()
  ElMessage.success('图表数据已更新')
}

// 导出安全报告
const exportSecurityReport = () => {
  ElMessage.info('安全报告导出中...')
  
  // 准备导出数据
  const reportData = {
    '日期范围': `${currentDateRange.value}天`,
    '导出时间': new Date().toLocaleString(),
    '安全评分': '92/100',
    '今日请求数': '12,345',
    '系统可用性': '99.9%',
    '今日拦截': '156',
    '待处理告警': '3'
  }
  
  // 安全事件数据
  const eventSheetData = securityEventTypes.map(item => ({
    '事件类型': item.name,
    '发生次数': item.count
  }))
  
  // 创建工作簿
  const wb = XLSX.utils.book_new()
  
  // 添加概览工作表
  const overviewSheet = XLSX.utils.json_to_sheet([reportData])
  XLSX.utils.book_append_sheet(wb, overviewSheet, '概览')
  
  // 添加安全事件工作表
  const eventSheet = XLSX.utils.json_to_sheet(eventSheetData)
  XLSX.utils.book_append_sheet(wb, eventSheet, '安全事件')
  
  // 导出文件
  setTimeout(() => {
    XLSX.writeFile(wb, `安全报告_${currentDateRange.value}天_${new Date().toISOString().slice(0, 10)}.xlsx`)
    ElMessage.success('安全报告导出成功！')
  }, 1000)
}

// 生命周期钩子
onMounted(() => {
  initSecurityTrendChart()
  initSecurityDistributionChart()
})

onUnmounted(() => {
  // 清理图表实例
  if (securityTrendChartInstance) {
    securityTrendChartInstance.destroy()
  }
  if (securityDistributionChartInstance) {
    securityDistributionChartInstance.destroy()
  }
})
</script>

<style scoped>
.security-container {
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

.top-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  align-items: center;
  margin-bottom: 20px;
}

.security-score-section {
  margin-bottom: 20px;
}

.score-card {
  padding: 20px;
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
  border-radius: var(--el-border-radius-large);
}

.score-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.score-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin: 0;
}

.score-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 4px 0 0 0;
}

.score-circle {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--el-color-success), var(--el-color-primary));
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 32px;
  position: relative;
}

.score-value {
  font-size: 48px;
}

.score-unit {
  font-size: 18px;
  margin-left: 4px;
  opacity: 0.8;
}

.score-metrics {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  padding-top: 20px;
  border-top: 1px solid var(--el-border-color);
}

.metric-item {
  text-align: center;
}

.metric-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.metric-label {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.grid-2 {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.chart-card {
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
  margin-bottom: 20px;
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

.chart-desc {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.chart-container {
  height: 300px;
  padding: 10px;
}

.event-types {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  padding: 20px 0;
}

.event-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-base);
}

.event-name {
  font-size: 14px;
  color: var(--el-text-color-primary);
}

.event-count {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-color-primary);
}

.security-config-section {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.config-card {
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.config-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  padding: 20px 0;
}

.config-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-base);
  transition: all 0.3s ease;
}

.config-item:hover {
  transform: translateY(-2px);
  box-shadow: var(--el-box-shadow-light);
}

.config-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: bold;
}

.config-icon.success {
  background-color: rgba(72, 187, 120, 0.1);
  color: var(--el-color-success);
}

.config-icon.warning {
  background-color: rgba(237, 137, 54, 0.1);
  color: var(--el-color-warning);
}

.config-info {
  flex: 1;
}

.config-name {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.config-status {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.card-action {
  font-size: 14px;
  color: var(--el-color-primary);
  cursor: pointer;
}

.security-alerts {
  padding: 10px 0;
}

.alert-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-base);
  margin-bottom: 12px;
  transition: all 0.3s ease;
}

.alert-item:hover {
  box-shadow: var(--el-box-shadow-light);
}

.alert-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  font-weight: bold;
}

.alert-icon.danger {
  background-color: rgba(245, 101, 101, 0.1);
  color: var(--el-color-danger);
}

.alert-icon.warning {
  background-color: rgba(237, 137, 54, 0.1);
  color: var(--el-color-warning);
}

.alert-icon.info {
  background-color: rgba(102, 126, 234, 0.1);
  color: var(--el-color-primary);
}

.alert-content {
  flex: 1;
}

.alert-title {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.alert-description {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin-bottom: 8px;
}

.alert-meta {
  display: flex;
  align-items: center;
  gap: 12px;
}

.alert-time {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

.alert-level-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.alert-level-badge.danger {
  background-color: rgba(245, 101, 101, 0.1);
  color: var(--el-color-danger);
}

.alert-level-badge.warning {
  background-color: rgba(237, 137, 54, 0.1);
  color: var(--el-color-warning);
}

.alert-level-badge.info {
  background-color: rgba(102, 126, 234, 0.1);
  color: var(--el-color-primary);
}

.alert-action {
  margin-left: auto;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .score-metrics {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .grid-2 {
    grid-template-columns: 1fr;
  }
  
  .security-config-section {
    grid-template-columns: 1fr;
  }
  
  .config-grid {
    grid-template-columns: 1fr;
  }
  
  .event-types {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .score-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 20px;
  }
  
  .score-metrics {
    grid-template-columns: 1fr;
  }
  
  .top-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .event-types {
    grid-template-columns: 1fr;
  }
  
  .card-header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
  
  .alert-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .alert-action {
    margin-left: 0;
    align-self: flex-start;
  }
}
</style>