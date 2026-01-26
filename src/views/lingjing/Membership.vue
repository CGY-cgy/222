<template>
  <div class="membership-container">
    <!-- 页面标题和操作 -->
    <div class="header-section">
      <h1 class="page-title">会员分析</h1>
      <p class="page-subtitle">会员转化、套餐分布与留存分析</p>
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
      <el-button type="primary" size="large" @click="exportReport">
        <el-icon><el-icon-document-download /></el-icon>
        <span>导出报表</span>
      </el-button>
    </div>

    <!-- 统计数据网格 -->
    <div class="stats-grid">
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon revenue">💰</div>
          <span class="stat-trend up">↑ 12.5%</span>
        </div>
        <div class="stat-value">¥{{ formatNumber(486920) }}</div>
        <div class="stat-label">总收入</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon members">💎</div>
          <span class="stat-trend up">↑ 8.3%</span>
        </div>
        <div class="stat-value">{{ formatNumber(12580) }}</div>
        <div class="stat-label">付费会员数</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon conversion">🎯</div>
          <span class="stat-trend up">↑ 3.2%</span>
        </div>
        <div class="stat-value">23.4%</div>
        <div class="stat-label">付费转化率</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon arpu">📊</div>
          <span class="stat-trend up">↑ 5.7%</span>
        </div>
        <div class="stat-value">¥{{ formatNumber(387) }}</div>
        <div class="stat-label">ARPU</div>
      </el-card>
    </div>

    <!-- 转化漏斗与套餐分布 -->
    <div class="grid-2">
      <!-- 会员转化漏斗 -->
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">会员转化漏斗</h3>
            <span class="chart-desc">注册到付费的转化路径</span>
          </div>
        </template>
        <div class="funnel-section">
          <div class="funnel-step">
            <div class="step-label">注册</div>
            <div class="step-value">100,000</div>
            <div class="step-bar" style="width: 100%;"></div>
            <div class="step-percentage">100%</div>
          </div>
          <div class="funnel-step">
            <div class="step-label">活跃</div>
            <div class="step-value">45,000</div>
            <div class="step-bar" style="width: 45%;"></div>
            <div class="step-percentage">45%</div>
          </div>
          <div class="funnel-step">
            <div class="step-label">试用</div>
            <div class="step-value">18,000</div>
            <div class="step-bar" style="width: 18%;"></div>
            <div class="step-percentage">18%</div>
          </div>
          <div class="funnel-step">
            <div class="step-label">付费</div>
            <div class="step-value">12,580</div>
            <div class="step-bar" style="width: 12.58%;"></div>
            <div class="step-percentage">12.58%</div>
          </div>
        </div>
      </el-card>

      <!-- 套餐分布 -->
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">套餐分布</h3>
            <span class="chart-desc">不同会员套餐的销售情况</span>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="packageDistributionChart"></canvas>
        </div>
        <div class="package-info">
          <div class="package-item" v-for="item in packageData" :key="item.name">
            <div class="package-name">{{ item.name }}</div>
            <div class="package-stats">
              <div class="stat">
                <span class="stat-label">订阅人数:</span>
                <span class="stat-value">{{ formatNumber(item.users) }}</span>
              </div>
              <div class="stat">
                <span class="stat-label">月收入:</span>
                <span class="stat-value">¥{{ formatNumber(item.revenue) }}</span>
              </div>
            </div>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 会员留存分析 -->
    <el-card shadow="hover" class="chart-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">会员留存分析</h3>
          <span class="chart-desc">各周期留存数据</span>
        </div>
      </template>
      <div class="retention-section">
        <div class="retention-grid">
          <div class="retention-item">
            <div class="retention-period">次日留存</div>
            <div class="retention-value">65.8%</div>
            <div class="retention-trend up">↑ 2.3%</div>
          </div>
          <div class="retention-item">
            <div class="retention-period">7日留存</div>
            <div class="retention-value">42.5%</div>
            <div class="retention-trend up">↑ 1.8%</div>
          </div>
          <div class="retention-item">
            <div class="retention-period">30日留存</div>
            <div class="retention-value">28.3%</div>
            <div class="retention-trend up">↑ 1.2%</div>
          </div>
          <div class="retention-item">
            <div class="retention-period">90日留存</div>
            <div class="retention-value">18.7%</div>
            <div class="retention-trend down">↓ 0.5%</div>
          </div>
        </div>
        <div class="chart-container">
          <canvas ref="retentionChart"></canvas>
        </div>
      </div>
    </el-card>

    <!-- 会员增长趋势 -->
    <el-card shadow="hover" class="chart-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">会员增长趋势</h3>
          <div class="chart-legend">
            <div class="legend-item">
              <span class="legend-color primary"></span>
              <span class="legend-text">新增会员</span>
            </div>
            <div class="legend-item">
              <span class="legend-color success"></span>
              <span class="legend-text">续费会员</span>
            </div>
          </div>
        </div>
      </template>
      <div class="chart-container">
        <canvas ref="growthTrendChart"></canvas>
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
const packageDistributionChart = ref(null)
const retentionChart = ref(null)
const growthTrendChart = ref(null)

// 图表实例
let packageDistributionChartInstance = null
let retentionChartInstance = null
let growthTrendChartInstance = null

// 套餐数据
const packageData = [
  { name: '基础版', users: 8500, revenue: 127500, color: '#667eea' },
  { name: '专业版', users: 3200, revenue: 224000, color: '#48bb78' },
  { name: '企业版', users: 880, revenue: 135420, color: '#ed8936' }
]

// 颜色配置
const chartColors = {
  primary: '#667eea',
  secondary: '#764ba2',
  success: '#48bb78',
  warning: '#ed8936',
  danger: '#f56565'
}

// 格式化数字
const formatNumber = (num) => {
  return num.toLocaleString()
}

// 初始化套餐分布图表
const initPackageDistributionChart = () => {
  if (packageDistributionChart.value) {
    if (packageDistributionChartInstance) {
      packageDistributionChartInstance.destroy()
    }
    const ctx = packageDistributionChart.value.getContext('2d')
    
    const labels = packageData.map(item => item.name)
    const data = packageData.map(item => item.users)
    const colors = packageData.map(item => item.color)
    
    packageDistributionChartInstance = new Chart(ctx, {
      type: 'pie',
      data: {
        labels: labels,
        datasets: [{
          data: data,
          backgroundColor: colors,
          borderWidth: 0
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        }
      }
    })
  }
}

// 初始化留存分析图表
const initRetentionChart = () => {
  if (retentionChart.value) {
    if (retentionChartInstance) {
      retentionChartInstance.destroy()
    }
    const ctx = retentionChart.value.getContext('2d')
    
    let labels, day1Retention, day7Retention, day30Retention
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日']
      day1Retention = [65.8, 62.5, 60.2, 58.1, 56.3, 54.7, 53.2]
      day7Retention = [42.5, 41.8, 41.2, 40.5, 39.8, 39.2, 38.6]
      day30Retention = [28.3, 27.9, 27.5, 27.2, 26.9, 26.6, 26.3]
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      day1Retention = [65.8, 63.2, 60.7, 58.3, 56.1, 54.0, 52.1]
      day7Retention = [42.5, 41.2, 40.0, 38.8, 37.7, 36.7, 35.7]
      day30Retention = [28.3, 27.6, 27.0, 26.4, 25.8, 25.3, 24.8]
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日']
      day1Retention = [65.8, 61.5, 57.5, 53.8, 50.4, 47.2, 44.3]
      day7Retention = [42.5, 39.8, 37.3, 35.0, 32.8, 30.8, 29.0]
      day30Retention = [28.3, 26.8, 25.4, 24.1, 22.9, 21.8, 20.8]
    }
    
    retentionChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '次日留存率(%)',
          data: day1Retention,
          borderColor: chartColors.primary,
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          fill: true,
          tension: 0.4
        }, {
          label: '7日留存率(%)',
          data: day7Retention,
          borderColor: chartColors.success,
          backgroundColor: 'rgba(72, 187, 120, 0.1)',
          fill: true,
          tension: 0.4
        }, {
          label: '30日留存率(%)',
          data: day30Retention,
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
            max: 100,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
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

// 初始化会员增长趋势图表
const initGrowthTrendChart = () => {
  if (growthTrendChart.value) {
    if (growthTrendChartInstance) {
      growthTrendChartInstance.destroy()
    }
    const ctx = growthTrendChart.value.getContext('2d')
    
    let labels, newMembers, renewalMembers
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日']
      newMembers = [1200, 1350, 1420, 1380, 1520, 1650, 1720]
      renewalMembers = [350, 380, 420, 400, 450, 480, 520]
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      newMembers = [1200, 5800, 10500, 15200, 20800, 26500, 32800]
      renewalMembers = [350, 1800, 3500, 5200, 7100, 9200, 11500]
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日']
      newMembers = [1200, 28500, 58000, 89500, 122000, 156500, 193000]
      renewalMembers = [350, 16800, 34500, 53200, 73900, 96600, 121300]
    }
    
    growthTrendChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: '新增会员',
          data: newMembers,
          backgroundColor: chartColors.primary,
          borderRadius: 8,
          borderSkipped: false
        }, {
          label: '续费会员',
          data: renewalMembers,
          backgroundColor: chartColors.success,
          borderRadius: 8,
          borderSkipped: false
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

// 更新所有图表
const updateAllCharts = () => {
  initPackageDistributionChart()
  initRetentionChart()
  initGrowthTrendChart()
  ElMessage.success('图表数据已更新')
}

// 导出报表
const exportReport = () => {
  ElMessage.info('报表导出中...')
  
  // 准备导出数据
  const reportData = {
    '日期范围': `${currentDateRange.value}天`,
    '导出时间': new Date().toLocaleString(),
    '总收入': '¥486,920',
    '付费会员数': '12,580',
    '付费转化率': '23.4%',
    'ARPU': '¥387'
  }
  
  // 套餐数据
  const packageSheetData = packageData.map(item => ({
    '套餐名称': item.name,
    '订阅人数': item.users,
    '月收入': `¥${item.revenue.toLocaleString()}`
  }))
  
  // 创建工作簿
  const wb = XLSX.utils.book_new()
  
  // 添加概览工作表
  const overviewSheet = XLSX.utils.json_to_sheet([reportData])
  XLSX.utils.book_append_sheet(wb, overviewSheet, '概览')
  
  // 添加套餐分布工作表
  const packageSheet = XLSX.utils.json_to_sheet(packageSheetData)
  XLSX.utils.book_append_sheet(wb, packageSheet, '套餐分布')
  
  // 导出文件
  setTimeout(() => {
    XLSX.writeFile(wb, `会员分析报表_${currentDateRange.value}天_${new Date().toISOString().slice(0, 10)}.xlsx`)
    ElMessage.success('报表导出成功！')
  }, 1000)
}

// 生命周期钩子
onMounted(() => {
  initPackageDistributionChart()
  initRetentionChart()
  initGrowthTrendChart()
})

onUnmounted(() => {
  // 清理图表实例
  if (packageDistributionChartInstance) {
    packageDistributionChartInstance.destroy()
  }
  if (retentionChartInstance) {
    retentionChartInstance.destroy()
  }
  if (growthTrendChartInstance) {
    growthTrendChartInstance.destroy()
  }
})
</script>

<style scoped>
.membership-container {
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

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  padding: 20px;
  border-radius: var(--el-border-radius-large);
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.stat-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
}

.stat-icon.revenue {
  background-color: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.stat-icon.members {
  background-color: rgba(72, 187, 120, 0.1);
  color: #48bb78;
}

.stat-icon.conversion {
  background-color: rgba(237, 137, 54, 0.1);
  color: #ed8936;
}

.stat-icon.arpu {
  background-color: rgba(118, 75, 162, 0.1);
  color: #764ba2;
}

.stat-trend {
  font-size: 14px;
  font-weight: 500;
}

.stat-trend.up {
  color: var(--el-color-success);
}

.stat-trend.down {
  color: var(--el-color-danger);
}

.stat-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.stat-label {
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

.chart-legend {
  display: flex;
  gap: 16px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.legend-color {
  width: 8px;
  height: 8px;
  border-radius: 50%;
}

.legend-color.primary {
  background-color: var(--el-color-primary);
}

.legend-color.success {
  background-color: var(--el-color-success);
}

.chart-container {
  height: 300px;
  padding: 10px;
}

.funnel-section {
  padding: 20px 0;
}

.funnel-step {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  gap: 16px;
}

.step-label {
  width: 60px;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.step-value {
  width: 80px;
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
  text-align: right;
}

.step-bar {
  flex: 1;
  height: 24px;
  background: linear-gradient(90deg, var(--el-color-primary), var(--el-color-success));
  border-radius: 12px;
  transition: width 0.3s ease;
}

.step-percentage {
  width: 60px;
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

.package-info {
  padding: 20px 0;
}

.package-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-base);
  margin-bottom: 10px;
}

.package-name {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.package-stats {
  display: flex;
  gap: 20px;
}

.package-stats .stat {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.package-stats .stat-label {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

.package-stats .stat-value {
  font-size: 16px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.retention-section {
  padding: 10px 0;
}

.retention-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.retention-item {
  text-align: center;
  padding: 20px;
  background-color: var(--el-bg-color-page);
  border-radius: var(--el-border-radius-large);
}

.retention-period {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin-bottom: 8px;
}

.retention-value {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin-bottom: 8px;
}

.retention-trend {
  font-size: 14px;
  font-weight: 500;
}

.retention-trend.up {
  color: var(--el-color-success);
}

.retention-trend.down {
  color: var(--el-color-danger);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .grid-2 {
    grid-template-columns: 1fr;
  }
  
  .retention-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .top-actions {
    flex-direction: column;
    align-items: stretch;
  }
  
  .retention-grid {
    grid-template-columns: 1fr;
  }
  
  .funnel-step {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .step-value {
    text-align: left;
  }
  
  .card-header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>