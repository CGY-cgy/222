<template>
  <div class="analytics-container">
    <!-- 页面标题和操作 -->
    <div class="header-section">
      <h1 class="page-title">数据分析</h1>
      <p class="page-subtitle">平台功能使用数据与用户行为分析</p>
    </div>

    <!-- 顶部操作栏 -->
    <div class="top-actions">
      <el-select v-model="currentDateRange" placeholder="选择日期范围" size="large" @change="updateAllCharts">
        <el-option label="最近7天" :value="7" />
        <el-option label="最近30天" :value="30" />
        <el-option label="最近90天" :value="90" />
      </el-select>
      <el-button type="primary" size="large" @click="exportData">
        <el-icon><el-icon-document-download /></el-icon>
        <span>导出报表</span>
      </el-button>
    </div>

    <!-- 统计数据网格 -->
    <div class="stats-grid">
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon visits">👁️</div>
          <span class="stat-trend up">↑ 15.3%</span>
        </div>
        <div class="stat-value">{{ formatNumber(1234567) }}</div>
        <div class="stat-label">总访问量</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon active">🔥</div>
          <span class="stat-trend up">↑ 8.7%</span>
        </div>
        <div class="stat-value">{{ formatNumber(45892) }}</div>
        <div class="stat-label">日活跃用户</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon duration">⏱️</div>
          <span class="stat-trend up">↑ 5.2%</span>
        </div>
        <div class="stat-value">12.5 分钟</div>
        <div class="stat-label">平均使用时长</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon retention">🔄</div>
          <span class="stat-trend up">↑ 3.1%</span>
        </div>
        <div class="stat-value">67.8%</div>
        <div class="stat-label">次日留存率</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon completion">✅</div>
          <span class="stat-trend down">↓ 1.2%</span>
        </div>
        <div class="stat-value">89.3%</div>
        <div class="stat-label">功能完成率</div>
      </el-card>
    </div>

    <!-- 功能使用热力图 -->
    <el-card shadow="hover" class="chart-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">功能使用热力图</h3>
          <span class="chart-desc">各核心模块的使用频率</span>
        </div>
      </template>
      <div class="heatmap-section">
        <div class="heatmap-info">过去 {{ currentDateRange }} 天各模块使用频率</div>
        <div ref="heatmap" class="heatmap-container"></div>
        <div class="heatmap-weekdays">
          <span>周一</span><span>周二</span><span>周三</span><span>周四</span><span>周五</span><span>周六</span><span>周日</span>
        </div>
        <div class="heatmap-legend">
          <span>使用频率：</span>
          <div class="legend-colors">
            <span class="legend-item">
              <span class="legend-color low"></span>
              <span class="legend-text">低</span>
            </span>
            <span class="legend-item">
              <span class="legend-color medium"></span>
              <span class="legend-text">中</span>
            </span>
            <span class="legend-item">
              <span class="legend-color high"></span>
              <span class="legend-text">高</span>
            </span>
          </div>
        </div>
      </div>
    </el-card>

    <!-- 图表网格 -->
    <div class="charts-grid">
      <!-- 用户活跃度分布 -->
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">用户活跃度分布</h3>
            <span class="chart-desc">不同活跃度用户占比</span>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="userActivityChart"></canvas>
        </div>
      </el-card>

      <!-- 内容生态分析 -->
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">内容生态分析</h3>
            <div class="chart-legend">
              <div class="legend-item">
                <span class="legend-color primary"></span>
                <span class="legend-text">发帖量</span>
              </div>
              <div class="legend-item">
                <span class="legend-color success"></span>
                <span class="legend-text">互动量</span>
              </div>
              <div class="legend-item">
                <span class="legend-color warning"></span>
                <span class="legend-text">互动率</span>
              </div>
            </div>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="contentEcosystemChart"></canvas>
        </div>
      </el-card>
    </div>

    <!-- AI对话分析 -->
    <el-card shadow="hover" class="chart-card ai-chat-card">
      <template #header>
        <div class="card-header-content">
          <h3 class="card-title">AI对话分析</h3>
          <span class="chart-desc">AI助手使用情况统计</span>
        </div>
      </template>
      <div class="ai-chat-stats">
        <div class="ai-stat-item">
          <div class="ai-stat-value">1,234</div>
          <div class="ai-stat-label">今日对话数</div>
        </div>
        <div class="ai-stat-item">
          <div class="ai-stat-value">3.2s</div>
          <div class="ai-stat-label">平均回复时长</div>
        </div>
        <div class="ai-stat-item">
          <div class="ai-stat-value">96.7%</div>
          <div class="ai-stat-label">用户满意度</div>
        </div>
      </div>
      <div class="chart-container">
        <canvas ref="aiChatChart"></canvas>
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
const heatmap = ref(null)
const userActivityChart = ref(null)
const contentEcosystemChart = ref(null)
const aiChatChart = ref(null)

// 图表实例
let userActivityChartInstance = null
let contentEcosystemChartInstance = null
let aiChatChartInstance = null

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

// 初始化热力图
const initHeatmap = () => {
  if (heatmap.value) {
    heatmap.value.innerHTML = ''
    const days = currentDateRange.value
    const modules = ['命理', '健康', '饮食', '规划', 'AI']
    
    for (let i = 0; i < days; i++) {
      const cell = document.createElement('div')
      cell.className = 'heatmap-cell'
      const level = Math.floor(Math.random() * 5) + 1 // 1-5级
      cell.classList.add(`level-${level}`)
      cell.title = `${modules[i % 5]}模块 - 第${i + 1}天`
      heatmap.value.appendChild(cell)
    }
  }
}

// 初始化用户活跃度分布图表
const initUserActivityChart = () => {
  if (userActivityChart.value) {
    if (userActivityChartInstance) {
      userActivityChartInstance.destroy()
    }
    const ctx = userActivityChart.value.getContext('2d')
    
    userActivityChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['低活跃度', '中活跃度', '高活跃度', '非常活跃'],
        datasets: [{
          label: '用户数量',
          data: [35000, 68000, 25000, 12000],
          backgroundColor: [
            'rgba(245, 101, 101, 0.8)',
            'rgba(237, 137, 54, 0.8)',
            'rgba(72, 187, 120, 0.8)',
            'rgba(102, 126, 234, 0.8)'
          ],
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

// 初始化内容生态分析图表
const initContentEcosystemChart = () => {
  if (contentEcosystemChart.value) {
    if (contentEcosystemChartInstance) {
      contentEcosystemChartInstance.destroy()
    }
    const ctx = contentEcosystemChart.value.getContext('2d')
    
    let labels, postData, interactionData, rateData
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日']
      postData = [156, 189, 234, 198, 267, 312, 289]
      interactionData = [892, 1056, 1234, 1189, 1456, 1876, 1623]
      rateData = [5.7, 5.6, 5.3, 6.0, 5.4, 6.0, 5.6]
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      postData = [4200, 4800, 5100, 4900, 5600, 6200, 5800]
      interactionData = [21560, 24890, 26540, 25120, 28760, 32150, 30480]
      rateData = [5.1, 5.2, 5.2, 5.1, 5.1, 5.2, 5.2]
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日']
      postData = [12500, 14200, 15300, 14800, 16700, 18500, 17600]
      interactionData = [62890, 71450, 76230, 73890, 82450, 91230, 87650]
      rateData = [5.0, 5.0, 5.0, 4.9, 4.9, 4.9, 4.9]
    }
    
    contentEcosystemChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: '发帖量',
          data: postData,
          backgroundColor: chartColors.primary,
          borderRadius: 8,
          borderSkipped: false,
          yAxisID: 'y'
        }, {
          label: '互动量',
          data: interactionData,
          backgroundColor: chartColors.success,
          borderRadius: 8,
          borderSkipped: false,
          yAxisID: 'y'
        }, {
          label: '互动率(%)',
          data: rateData,
          type: 'line',
          borderColor: chartColors.warning,
          backgroundColor: 'transparent',
          borderWidth: 2,
          borderDash: [5, 5],
          tension: 0.4,
          yAxisID: 'y1'
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
            type: 'linear',
            position: 'left',
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
          y1: {
            type: 'linear',
            position: 'right',
            beginAtZero: true,
            max: 10,
            grid: {
              display: false
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

// 初始化AI对话分析图表
const initAIChatChart = () => {
  if (aiChatChart.value) {
    if (aiChatChartInstance) {
      aiChatChartInstance.destroy()
    }
    const ctx = aiChatChart.value.getContext('2d')
    
    let labels, chatData, satisfactionData
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日']
      chatData = [1200, 1400, 1350, 1500, 1650, 1800, 1750]
      satisfactionData = [95.2, 94.8, 96.1, 95.5, 97.2, 96.8, 96.5]
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日']
      chatData = [4200, 4800, 5100, 4900, 5600, 6200, 5800]
      satisfactionData = [95.0, 95.5, 96.0, 96.2, 96.5, 96.7, 96.8]
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日']
      chatData = [12500, 14200, 15300, 14800, 16700, 18500, 17600]
      satisfactionData = [94.5, 95.0, 95.5, 96.0, 96.2, 96.5, 96.7]
    }
    
    aiChatChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '对话数',
          data: chatData,
          borderColor: chartColors.primary,
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          fill: true,
          tension: 0.4,
          yAxisID: 'y'
        }, {
          label: '满意度(%)',
          data: satisfactionData,
          borderColor: chartColors.success,
          backgroundColor: 'transparent',
          borderWidth: 2,
          tension: 0.4,
          yAxisID: 'y1'
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
            type: 'linear',
            position: 'left',
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
          y1: {
            type: 'linear',
            position: 'right',
            beginAtZero: true,
            max: 100,
            grid: {
              display: false
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
  initHeatmap()
  initUserActivityChart()
  initContentEcosystemChart()
  initAIChatChart()
  ElMessage.success('图表数据已更新')
}

// 导出数据
const exportData = () => {
  ElMessage.info('报表导出中...')
  
  // 准备导出数据
  const reportData = {
    '日期范围': `${currentDateRange.value}天`,
    '导出时间': new Date().toLocaleString(),
    '总访问量': '1,234,567',
    '日活跃用户': '45,892',
    '平均使用时长': '12.5 分钟',
    '次日留存率': '67.8%',
    '功能完成率': '89.3%'
  }
  
  // 模拟数据
  const contentData = {
    '周期': currentDateRange.value === 7 ? ['1日', '2日', '3日', '4日', '5日', '6日', '7日'] : 
            currentDateRange.value === 30 ? ['1日', '5日', '10日', '15日', '20日', '25日', '30日'] : 
            ['1日', '15日', '30日', '45日', '60日', '75日', '90日'],
    '发帖量': currentDateRange.value === 7 ? [156, 189, 234, 198, 267, 312, 289] : 
            currentDateRange.value === 30 ? [4200, 4800, 5100, 4900, 5600, 6200, 5800] : 
            [12500, 14200, 15300, 14800, 16700, 18500, 17600],
    '互动量': currentDateRange.value === 7 ? [892, 1056, 1234, 1189, 1456, 1876, 1623] : 
            currentDateRange.value === 30 ? [21560, 24890, 26540, 25120, 28760, 32150, 30480] : 
            [62890, 71450, 76230, 73890, 82450, 91230, 87650],
    '互动率(%)': currentDateRange.value === 7 ? [5.7, 5.6, 5.3, 6.0, 5.4, 6.0, 5.6] : 
              currentDateRange.value === 30 ? [5.1, 5.2, 5.2, 5.1, 5.1, 5.2, 5.2] : 
              [5.0, 5.0, 5.0, 4.9, 4.9, 4.9, 4.9]
  }
  
  const aiChatData = {
    '日期': currentDateRange.value === 7 ? ['1日', '2日', '3日', '4日', '5日', '6日', '7日'] : 
            currentDateRange.value === 30 ? ['1日', '5日', '10日', '15日', '20日', '25日', '30日'] : 
            ['1日', '15日', '30日', '45日', '60日', '75日', '90日'],
    '对话数': currentDateRange.value === 7 ? [1200, 1400, 1350, 1500, 1650, 1800, 1750] : 
            currentDateRange.value === 30 ? [4200, 4800, 5100, 4900, 5600, 6200, 5800] : 
            [12500, 14200, 15300, 14800, 16700, 18500, 17600],
    '满意度(%)': currentDateRange.value === 7 ? [95.2, 94.8, 96.1, 95.5, 97.2, 96.8, 96.5] : 
              currentDateRange.value === 30 ? [95.0, 95.5, 96.0, 96.2, 96.5, 96.7, 96.8] : 
              [94.5, 95.0, 95.5, 96.0, 96.2, 96.5, 96.7]
  }
  
  // 创建工作簿
  const wb = XLSX.utils.book_new()
  
  // 添加概览工作表
  const overviewSheet = XLSX.utils.json_to_sheet([reportData])
  XLSX.utils.book_append_sheet(wb, overviewSheet, '概览')
  
  // 添加内容生态工作表
  const contentSheetData = []
  for (let i = 0; i < contentData.周期.length; i++) {
    contentSheetData.push({
      '周期': contentData.周期[i],
      '发帖量': contentData.发帖量[i],
      '互动量': contentData.互动量[i],
      '互动率(%)': contentData.互动率[i]
    })
  }
  const contentSheet = XLSX.utils.json_to_sheet(contentSheetData)
  XLSX.utils.book_append_sheet(wb, contentSheet, '内容生态')
  
  // 添加AI对话工作表
  const aiChatSheetData = []
  for (let i = 0; i < aiChatData.日期.length; i++) {
    aiChatSheetData.push({
      '日期': aiChatData.日期[i],
      '对话数': aiChatData.对话数[i],
      '满意度(%)': aiChatData.满意度[i]
    })
  }
  const aiChatSheet = XLSX.utils.json_to_sheet(aiChatSheetData)
  XLSX.utils.book_append_sheet(wb, aiChatSheet, 'AI对话')
  
  // 导出文件
  setTimeout(() => {
    XLSX.writeFile(wb, `数据分析报表_${currentDateRange.value}天_${new Date().toISOString().slice(0, 10)}.xlsx`)
    ElMessage.success('报表导出成功！')
  }, 1000)
}

// 生命周期钩子
onMounted(() => {
  initHeatmap()
  initUserActivityChart()
  initContentEcosystemChart()
  initAIChatChart()
})

onUnmounted(() => {
  // 清理图表实例
  if (userActivityChartInstance) {
    userActivityChartInstance.destroy()
  }
  if (contentEcosystemChartInstance) {
    contentEcosystemChartInstance.destroy()
  }
  if (aiChatChartInstance) {
    aiChatChartInstance.destroy()
  }
})
</script>

<style scoped>
.analytics-container {
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
  grid-template-columns: repeat(5, 1fr);
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

.stat-icon.visits {
  background-color: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.stat-icon.active {
  background-color: rgba(72, 187, 120, 0.1);
  color: #48bb78;
}

.stat-icon.duration {
  background-color: rgba(237, 137, 54, 0.1);
  color: #ed8936;
}

.stat-icon.retention {
  background-color: rgba(118, 75, 162, 0.1);
  color: #764ba2;
}

.stat-icon.completion {
  background-color: rgba(245, 101, 101, 0.1);
  color: #f56565;
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

.legend-color.warning {
  background-color: var(--el-color-warning);
}

.chart-container {
  height: 300px;
  padding: 10px;
}

.heatmap-section {
  padding: 10px 0;
}

.heatmap-info {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin-bottom: 16px;
}

.heatmap-container {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 6px;
  margin-bottom: 12px;
  padding: 0 10px;
}

.heatmap-cell {
  aspect-ratio: 1;
  border-radius: 6px;
  transition: all 0.3s ease;
}

.heatmap-cell.level-1 {
  background-color: rgba(102, 126, 234, 0.2);
}

.heatmap-cell.level-2 {
  background-color: rgba(102, 126, 234, 0.4);
}

.heatmap-cell.level-3 {
  background-color: rgba(102, 126, 234, 0.6);
}

.heatmap-cell.level-4 {
  background-color: rgba(102, 126, 234, 0.8);
}

.heatmap-cell.level-5 {
  background-color: rgba(102, 126, 234, 1);
}

.heatmap-weekdays {
  display: flex;
  justify-content: space-between;
  margin-bottom: 16px;
  font-size: 11px;
  color: var(--el-text-color-tertiary);
  padding: 0 10px;
}

.heatmap-weekdays span {
  flex: 1;
  text-align: center;
}

.heatmap-legend {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.legend-colors {
  display: flex;
  gap: 16px;
  align-items: center;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
}

.legend-color.low {
  background-color: rgba(102, 126, 234, 0.2);
}

.legend-color.medium {
  background-color: rgba(102, 126, 234, 0.6);
}

.legend-color.high {
  background-color: rgba(102, 126, 234, 1);
}

.legend-text {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.ai-chat-card {
  margin-bottom: 20px;
}

.ai-chat-stats {
  display: flex;
  justify-content: space-around;
  gap: 20px;
  margin-bottom: 20px;
  padding: 20px;
  background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05));
  border-radius: var(--el-border-radius-large);
}

.ai-stat-item {
  text-align: center;
  flex: 1;
}

.ai-stat-value {
  font-size: 32px;
  font-weight: 700;
  color: var(--el-color-primary);
  margin-bottom: 4px;
}

.ai-stat-label {
  font-size: 14px;
  color: var(--el-text-color-secondary);
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .charts-grid {
    grid-template-columns: 1fr;
  }
  
  .ai-chat-stats {
    flex-direction: column;
    gap: 16px;
  }
  
  .ai-stat-item {
    text-align: left;
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
  
  .card-header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>