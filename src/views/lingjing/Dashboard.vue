<template>
  <div class="dashboard-container">
    <el-card shadow="hover" class="dashboard-header-card">
      <div class="header-content">
        <div>
          <h1 class="header-title">数据看板</h1>
          <p class="header-subtitle">实时监控平台运营数据与用户行为</p>
        </div>
        <div class="header-actions">
          <el-select v-model="currentDateRange" placeholder="选择日期范围" size="large" @change="updateAllCharts">
            <el-option label="最近7天" :value="7" />
            <el-option label="最近30天" :value="30" />
            <el-option label="最近90天" :value="90" />
          </el-select>
          <el-button type="primary" size="large" @click="exportReport">
            <el-icon><el-icon-download /></el-icon>
            <span>导出报表</span>
          </el-button>
        </div>
      </div>
    </el-card>

    <div class="stats-grid">
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon users">👥</div>
          <span class="stat-trend up">↑ 12.5%</span>
        </div>
        <div class="stat-value">128,456</div>
        <div class="stat-label">注册用户总数</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon revenue">💰</div>
          <span class="stat-trend up">↑ 8.3%</span>
        </div>
        <div class="stat-value">¥486,920</div>
        <div class="stat-label">本月收入</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon active">⚡</div>
          <span class="stat-trend up">↑ 15.2%</span>
        </div>
        <div class="stat-value">45,892</div>
        <div class="stat-label">日活跃用户</div>
      </el-card>
      <el-card shadow="hover" class="stat-card">
        <div class="stat-header">
          <div class="stat-icon conversion">🎯</div>
          <span class="stat-trend down">↓ 2.1%</span>
        </div>
        <div class="stat-value">23.4%</div>
        <div class="stat-label">会员转化率</div>
      </el-card>
    </div>

    <div class="dashboard-grid">
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">核心功能使用分析</h3>
            <div class="chart-legend">
              <div class="legend-item">
                <span class="legend-color primary"></span>
                <span class="legend-text">日均使用次数</span>
              </div>
            </div>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="functionUsageChart"></canvas>
        </div>
      </el-card>
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">功能使用热力图</h3>
          </div>
        </template>
        <div class="heatmap-info">过去30天各模块使用频率</div>
        <div ref="heatmap" class="heatmap-container"></div>
        <div class="heatmap-weekdays">
          <span>周一</span><span>周二</span><span>周三</span><span>周四</span><span>周五</span><span>周六</span><span>周日</span>
        </div>
      </el-card>
      <el-card shadow="hover" class="chart-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">AI对话使用情况</h3>
            <div class="chart-legend">
              <div class="legend-item">
                <span class="legend-color success"></span>
                <span class="legend-text">对话次数</span>
              </div>
              <div class="legend-item">
                <span class="legend-color warning"></span>
                <span class="legend-text">平均会话长度</span>
              </div>
            </div>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="aiChatChart"></canvas>
        </div>
      </el-card>
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
            </div>
          </div>
        </template>
        <div class="chart-container">
          <canvas ref="contentEcosystemChart"></canvas>
        </div>
      </el-card>
    </div>

    <div class="dashboard-bottom-grid">
      <el-card shadow="hover" class="activities-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">最新动态</h3>
            <a href="#" class="view-all-link">查看全部 →</a>
          </div>
        </template>
        <div class="activities-container" ref="latestActivities">
          <div v-for="(activity, index) in activities" :key="index" class="activity-item">
            <div class="activity-avatar" :style="{ background: activity.color }">
              {{ activity.user.charAt(0) }}
            </div>
            <div class="activity-content">
              <div class="activity-text">
                <template v-if="activity.action === '注册成功'">
                  新用户 <strong>{{ activity.user }}</strong> 注册成功
                </template>
                <template v-else>
                  用户 <strong>{{ activity.user }}</strong> {{ activity.action }}
                </template>
              </div>
              <div class="activity-time">{{ activity.timeAgo }}</div>
            </div>
          </div>
        </div>
      </el-card>
      <el-card shadow="hover" class="quick-actions-card">
        <template #header>
          <div class="card-header-content">
            <h3 class="card-title">快捷操作</h3>
          </div>
        </template>
        <div class="quick-actions-container">
          <el-button type="default" class="quick-action-btn" @click="navigateTo('users')">
            <div class="quick-action-icon primary">👤</div>
            <div class="quick-action-info">
              <div class="quick-action-title">用户管理</div>
              <div class="quick-action-desc">查看和管理所有用户</div>
            </div>
          </el-button>
          <el-button type="default" class="quick-action-btn" @click="navigateTo('analytics')">
            <div class="quick-action-icon success">📊</div>
            <div class="quick-action-info">
              <div class="quick-action-title">数据分析</div>
              <div class="quick-action-desc">查看详细统计报告</div>
            </div>
          </el-button>
          <el-button type="default" class="quick-action-btn" @click="navigateTo('security')">
            <div class="quick-action-icon warning">🔐</div>
            <div class="quick-action-info">
              <div class="quick-action-title">安全设置</div>
              <div class="quick-action-desc">管理账户安全策略</div>
            </div>
          </el-button>
          <el-button type="default" class="quick-action-btn" @click="backupData">
            <div class="quick-action-icon secondary">💾</div>
            <div class="quick-action-info">
              <div class="quick-action-title">数据备份</div>
              <div class="quick-action-desc">立即备份系统数据</div>
            </div>
          </el-button>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import { Chart, registerables } from 'chart.js';
import * as XLSX from 'xlsx';
import { ElMessage } from 'element-plus';
import {
  Download,
  ArrowUp,
  ArrowDown
} from '@element-plus/icons-vue';

// 注册Chart.js组件
Chart.register(...registerables);

// 定义组件别名
const ElIconDownload = Download;
const ElIconArrowUp = ArrowUp;
const ElIconArrowDown = ArrowDown;

// 响应式数据
const currentDateRange = ref(30);
const activities = ref([
  { user: '李晓明', action: '注册成功', color: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', timeAgo: '2分钟前' },
  { user: '王芳', action: '开通年度会员', color: '#48bb78', timeAgo: '15分钟前' },
  { user: '张伟', action: '完成健康问卷', color: '#ed8936', timeAgo: '32分钟前' },
  { user: '刘洋', action: '发布健康心得帖子', color: '#764ba2', timeAgo: '1小时前' },
  { user: '陈静', action: '使用舌像检测功能', color: '#f56565', timeAgo: '2小时前' }
]);

// 图表引用
const functionUsageChart = ref(null);
const aiChatChart = ref(null);
const contentEcosystemChart = ref(null);
const heatmap = ref(null);
const latestActivities = ref(null);

// 图表实例
let functionUsageChartInstance = null;
let aiChatChartInstance = null;
let contentEcosystemChartInstance = null;

// 颜色配置
const chartColors = {
  primary: '#667eea',
  secondary: '#764ba2',
  success: '#48bb78',
  warning: '#ed8936',
  danger: '#f56565'
};

// 初始化核心功能使用图表
const initFunctionUsageChart = () => {
  if (functionUsageChart.value) {
    if (functionUsageChartInstance) {
      functionUsageChartInstance.destroy();
    }
    const ctx = functionUsageChart.value.getContext('2d');
    let data;
    if (currentDateRange.value === 7) {
      data = [5200, 4800, 6500, 3200, 4100, 9800];
    } else if (currentDateRange.value === 30) {
      data = [12500, 9800, 15600, 7200, 8900, 23400];
    } else {
      data = [32500, 28900, 39800, 21500, 25600, 65400];
    }
    functionUsageChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['命理分析', '健康评估', '饮食推荐', '健康规划', '舌像检测', 'AI对话'],
        datasets: [{
          label: '日均使用次数',
          data: data,
          backgroundColor: [
            'rgba(102, 126, 234, 0.8)',
            'rgba(102, 126, 234, 0.8)',
            'rgba(72, 187, 120, 0.8)',
            'rgba(237, 137, 54, 0.8)',
            'rgba(245, 101, 101, 0.8)',
            'rgba(118, 75, 162, 0.8)'
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
                return value.toLocaleString();
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
    });
  }
};

// 初始化热力图
const initHeatmap = () => {
  if (heatmap.value) {
    const modules = ['命理', '健康', '饮食', '规划', 'AI'];
    heatmap.value.innerHTML = '';
    const days = currentDateRange.value;
    for (let i = 0; i < days; i++) {
      const cell = document.createElement('div');
      cell.className = 'heatmap-cell';
      const level = Math.floor(Math.random() * 5) + 1;
      const opacity = level * 0.2;
      cell.style.background = `rgba(102, 126, 234, ${opacity})`;
      cell.title = `第${i + 1}天 - ${modules[i % 5]}模块使用`;
      heatmap.value.appendChild(cell);
    }
  }
};

// 初始化AI对话使用图表
const initAIChatChart = () => {
  if (aiChatChart.value) {
    if (aiChatChartInstance) {
      aiChatChartInstance.destroy();
    }
    const ctx = aiChatChart.value.getContext('2d');
    let labels, chatData, durationData;
    if (currentDateRange.value === 7) {
      labels = ['1日', '2日', '3日', '4日', '5日', '6日', '7日'];
      chatData = [1200, 1400, 1350, 1500, 1650, 1800, 1750];
      durationData = [8.2, 9.1, 8.7, 10.2, 9.4, 11.5, 10.8];
    } else if (currentDateRange.value === 30) {
      labels = ['1日', '5日', '10日', '15日', '20日', '25日', '30日'];
      chatData = [4200, 4800, 5100, 4900, 5600, 6200, 5800];
      durationData = [8.5, 9.2, 8.8, 10.1, 9.5, 11.2, 10.5];
    } else {
      labels = ['1日', '15日', '30日', '45日', '60日', '75日', '90日'];
      chatData = [12500, 14200, 15300, 14800, 16700, 18500, 17600];
      durationData = [8.8, 9.5, 9.1, 10.3, 9.8, 11.6, 10.9];
    }
    aiChatChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '对话次数',
          data: chatData,
          borderColor: chartColors.success,
          backgroundColor: 'rgba(72, 187, 120, 0.1)',
          fill: true,
          tension: 0.4,
          yAxisID: 'y'
        }, {
          label: '平均会话长度(分钟)',
          data: durationData,
          borderColor: chartColors.warning,
          backgroundColor: 'transparent',
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
            }
          },
          y1: {
            type: 'linear',
            position: 'right',
            beginAtZero: true,
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
    });
  }
};

// 初始化内容生态分析图表
const initContentEcosystemChart = () => {
  if (contentEcosystemChart.value) {
    if (contentEcosystemChartInstance) {
      contentEcosystemChartInstance.destroy();
    }
    const ctx = contentEcosystemChart.value.getContext('2d');
    let labels, postData, interactionData;
    if (currentDateRange.value === 7) {
      labels = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      postData = [156, 189, 234, 198, 267, 312, 289];
      interactionData = [892, 1056, 1234, 1189, 1456, 1876, 1623];
    } else if (currentDateRange.value === 30) {
      labels = ['第1周', '第2周', '第3周', '第4周', '第5周'];
      postData = [654, 723, 812, 789, 856];
      interactionData = [3456, 3892, 4234, 4056, 4489];
    } else {
      labels = ['第1月', '第2月', '第3月'];
      postData = [2890, 3123, 3456];
      interactionData = [14567, 15892, 16789];
    }
    contentEcosystemChartInstance = new Chart(ctx, {
      type: 'line',
      data: {
        labels: labels,
        datasets: [{
          label: '发帖量',
          data: postData,
          borderColor: chartColors.primary,
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          fill: true,
          tension: 0.4
        }, {
          label: '互动量',
          data: interactionData,
          borderColor: chartColors.success,
          backgroundColor: 'rgba(72, 187, 120, 0.1)',
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
                return value.toLocaleString();
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
    });
  }
};

// 更新所有图表
const updateAllCharts = () => {
  initFunctionUsageChart();
  initHeatmap();
  initAIChatChart();
  initContentEcosystemChart();
};

// 导出报表
const exportReport = () => {
  ElMessage.info('报表导出中...');
  
  // 准备导出数据
  const reportData = {
    '日期范围': `${currentDateRange.value}天`,
    '导出时间': new Date().toLocaleString(),
    '注册用户总数': '128,456',
    '本月收入': '¥486,920',
    '日活跃用户': '45,892',
    '会员转化率': '23.4%'
  };
  
  // 核心功能使用数据
  const functionUsageData = {
    '功能': ['命理分析', '健康评估', '饮食推荐', '健康规划', '舌像检测', 'AI对话'],
    '日均使用次数': currentDateRange.value === 7 ? [5200, 4800, 6500, 3200, 4100, 9800] : 
                    currentDateRange.value === 30 ? [12500, 9800, 15600, 7200, 8900, 23400] : 
                    [32500, 28900, 39800, 21500, 25600, 65400]
  };
  
  // AI对话使用数据
  const aiChatData = {
    '日期': currentDateRange.value === 7 ? ['1日', '2日', '3日', '4日', '5日', '6日', '7日'] : 
            currentDateRange.value === 30 ? ['1日', '5日', '10日', '15日', '20日', '25日', '30日'] : 
            ['1日', '15日', '30日', '45日', '60日', '75日', '90日'],
    '对话次数': currentDateRange.value === 7 ? [1200, 1400, 1350, 1500, 1650, 1800, 1750] : 
                currentDateRange.value === 30 ? [4200, 4800, 5100, 4900, 5600, 6200, 5800] : 
                [12500, 14200, 15300, 14800, 16700, 18500, 17600],
    '平均会话长度(分钟)': currentDateRange.value === 7 ? [8.2, 9.1, 8.7, 10.2, 9.4, 11.5, 10.8] : 
                        currentDateRange.value === 30 ? [8.5, 9.2, 8.8, 10.1, 9.5, 11.2, 10.5] : 
                        [8.8, 9.5, 9.1, 10.3, 9.8, 11.6, 10.9]
  };
  
  // 内容生态数据
  const contentData = {
    '周期': currentDateRange.value === 7 ? ['周一', '周二', '周三', '周四', '周五', '周六', '周日'] : 
            currentDateRange.value === 30 ? ['第1周', '第2周', '第3周', '第4周', '第5周'] : 
            ['第1月', '第2月', '第3月'],
    '发帖量': currentDateRange.value === 7 ? [156, 189, 234, 198, 267, 312, 289] : 
            currentDateRange.value === 30 ? [654, 723, 812, 789, 856] : 
            [2890, 3123, 3456],
    '互动量': currentDateRange.value === 7 ? [892, 1056, 1234, 1189, 1456, 1876, 1623] : 
            currentDateRange.value === 30 ? [3456, 3892, 4234, 4056, 4489] : 
            [14567, 15892, 16789]
  };
  
  // 创建工作簿
  const wb = XLSX.utils.book_new();
  
  // 添加概览工作表
  const overviewSheet = XLSX.utils.json_to_sheet([reportData]);
  XLSX.utils.book_append_sheet(wb, overviewSheet, '概览');
  
  // 添加核心功能使用工作表
  const functionSheetData = [];
  for (let i = 0; i < functionUsageData.功能.length; i++) {
    functionSheetData.push({
      '功能': functionUsageData.功能[i],
      '日均使用次数': functionUsageData.日均使用次数[i]
    });
  }
  const functionSheet = XLSX.utils.json_to_sheet(functionSheetData);
  XLSX.utils.book_append_sheet(wb, functionSheet, '核心功能使用');
  
  // 添加AI对话使用工作表
  const aiChatSheetData = [];
  for (let i = 0; i < aiChatData.日期.length; i++) {
    aiChatSheetData.push({
      '日期': aiChatData.日期[i],
      '对话次数': aiChatData.对话次数[i],
      '平均会话长度(分钟)': aiChatData.平均会话长度(分钟)[i]
    });
  }
  const aiChatSheet = XLSX.utils.json_to_sheet(aiChatSheetData);
  XLSX.utils.book_append_sheet(wb, aiChatSheet, 'AI对话使用');
  
  // 添加内容生态工作表
  const contentSheetData = [];
  for (let i = 0; i < contentData.周期.length; i++) {
    contentSheetData.push({
      '周期': contentData.周期[i],
      '发帖量': contentData.发帖量[i],
      '互动量': contentData.互动量[i]
    });
  }
  const contentSheet = XLSX.utils.json_to_sheet(contentSheetData);
  XLSX.utils.book_append_sheet(wb, contentSheet, '内容生态');
  
  // 导出文件
  setTimeout(() => {
    XLSX.writeFile(wb, `数据看板报表_${currentDateRange.value}天_${new Date().toISOString().slice(0, 10)}.xlsx`);
    ElMessage.success('报表导出成功！');
  }, 1000);
};

// 数据备份
const backupData = () => {
  ElMessage.info('数据备份中...');
  setTimeout(() => {
    ElMessage.success('数据备份成功！');
  }, 2000);
};

// 生成随机活动数据
const generateActivityItem = () => {
  const users = ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十'];
  const actions = [
    '注册成功',
    '开通年度会员',
    '完成健康问卷',
    '发布健康心得帖子',
    '使用舌像检测功能',
    '查看健康报告',
    '分享健康文章',
    '邀请好友注册'
  ];
  const user = users[Math.floor(Math.random() * users.length)];
  const action = actions[Math.floor(Math.random() * actions.length)];
  const colors = ['linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%)', 'var(--success-color)', 'var(--warning-color)', 'var(--secondary-color)', 'var(--danger-color)'];
  const color = colors[Math.floor(Math.random() * colors.length)];
  const timeAgo = Math.floor(Math.random() * 120) + '分钟前';
  
  return {
    user,
    action,
    color,
    timeAgo
  };
};

// 加载更多活动
const loadMoreActivities = () => {
  for (let i = 0; i < 3; i++) {
    activities.value.push(generateActivityItem());
  }
};

// 导航到其他页面
const navigateTo = (page) => {
  ElMessage.info(`导航到${page}页面`);
};

// 滚动加载事件处理
let scrollListener = null;
const initScrollLoad = () => {
  if (latestActivities.value) {
    scrollListener = (e) => {
      const container = latestActivities.value;
      if (container.scrollTop + container.clientHeight >= container.scrollHeight - 100) {
        loadMoreActivities();
      }
    };
    latestActivities.value.addEventListener('scroll', scrollListener);
  }
};

// 生命周期钩子
onMounted(() => {
  initFunctionUsageChart();
  initHeatmap();
  initAIChatChart();
  initContentEcosystemChart();
  initScrollLoad();
});

onUnmounted(() => {
  // 清理图表实例
  if (functionUsageChartInstance) {
    functionUsageChartInstance.destroy();
  }
  if (aiChatChartInstance) {
    aiChatChartInstance.destroy();
  }
  if (contentEcosystemChartInstance) {
    contentEcosystemChartInstance.destroy();
  }
  // 移除滚动监听器
  if (latestActivities.value && scrollListener) {
    latestActivities.value.removeEventListener('scroll', scrollListener);
  }
});
</script>

<style scoped>
.dashboard-container {
  background-color: #f5f7fa;
}

/* Header */
.dashboard-header-card {
  margin-bottom: 20px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  font-size: 24px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  margin: 0;
}

.header-subtitle {
  font-size: 14px;
  color: var(--el-text-color-secondary);
  margin: 4px 0 0 0;
}

.header-actions {
  display: flex;
  gap: 16px;
  align-items: center;
}

/* Stats Grid */
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

.stat-icon.users {
  background-color: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.stat-icon.revenue {
  background-color: rgba(72, 187, 120, 0.1);
  color: #48bb78;
}

.stat-icon.active {
  background-color: rgba(237, 137, 54, 0.1);
  color: #ed8936;
}

.stat-icon.conversion {
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

/* Dashboard Grid */
.dashboard-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.chart-card {
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

.legend-color.danger {
  background-color: var(--el-color-danger);
}

.legend-text {
  font-size: 12px;
}

.chart-container {
  height: 300px;
  padding: 10px;
}

/* Heatmap */
.heatmap-info {
  font-size: 12px;
  color: var(--el-text-color-secondary);
  margin-bottom: 10px;
  padding: 0 10px;
}

.heatmap-container {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  padding: 0 10px;
}

.heatmap-cell {
  aspect-ratio: 1;
  border-radius: 4px;
  transition: opacity 0.2s ease;
}

.heatmap-weekdays {
  display: flex;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 11px;
  color: var(--el-text-color-tertiary);
  padding: 0 10px;
}

/* Bottom Grid */
.dashboard-bottom-grid {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

/* Activities */
.activities-card {
  background-color: var(--el-bg-color);
  box-shadow: var(--el-box-shadow-light);
}

.view-all-link {
  font-size: 13px;
  color: var(--el-color-primary);
  text-decoration: none;
}

.activities-container {
  max-height: 320px;
  overflow-y: auto;
  padding: 10px 0;
}

.activity-item {
  display: flex;
  gap: 16px;
  padding: 16px;
  border-bottom: 1px solid var(--el-border-color-light);
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 600;
  font-size: 14px;
  flex-shrink: 0;
}

.activity-content {
  flex: 1;
}

.activity-text {
  font-size: 14px;
  color: var(--el-text-color-primary);
  margin-bottom: 4px;
}

.activity-time {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

/* Quick Actions */
.quick-actions-container {
  display: flex;
  flex-direction: column;
  gap: 10px;
  padding: 10px 0;
}

.quick-action-btn {
  width: 100%;
  justify-content: flex-start;
  padding: 16px;
  background-color: var(--el-bg-color);
  border: 1px solid var(--el-border-color-light);
  border-radius: var(--el-border-radius-base);
  transition: all 0.3s ease;
}

.quick-action-btn:hover {
  background-color: var(--el-fill-color-light);
  border-color: var(--el-color-primary);
}

.quick-action-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
  margin-right: 16px;
}

.quick-action-icon.primary {
  background-color: rgba(102, 126, 234, 0.1);
  color: var(--el-color-primary);
}

.quick-action-icon.success {
  background-color: rgba(72, 187, 120, 0.1);
  color: var(--el-color-success);
}

.quick-action-icon.warning {
  background-color: rgba(237, 137, 54, 0.1);
  color: var(--el-color-warning);
}

.quick-action-icon.secondary {
  background-color: rgba(118, 75, 162, 0.1);
  color: var(--el-color-primary-light-4);
}

.quick-action-info {
  text-align: left;
}

.quick-action-title {
  font-size: 14px;
  color: var(--el-text-color-primary);
  font-weight: 500;
  margin-bottom: 4px;
}

.quick-action-desc {
  font-size: 12px;
  color: var(--el-text-color-tertiary);
}

/* Responsive */
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .dashboard-grid {
    grid-template-columns: 1fr;
  }
  
  .dashboard-bottom-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
  
  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .header-actions {
    width: 100%;
    flex-direction: column;
    align-items: stretch;
  }
}
</style>