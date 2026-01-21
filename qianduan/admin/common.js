// 全局配置
const AppConfig = {
    apiBaseUrl: '/api/v1',
    tokenKey: 'adminToken',
    userKey: 'adminUser',
    sessionTimeout: 3600000 // 1小时
};

// 工具函数
const Utils = {
    // 生成唯一ID
    generateId() {
        return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
    },
    
    // 格式化日期
    formatDate(date) {
        if (!(date instanceof Date)) {
            date = new Date(date);
        }
        return date.toLocaleString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit'
        });
    },
    
    // 显示通知
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-icon">${type === 'success' ? '✅' : type === 'error' ? '❌' : type === 'warning' ? '⚠️' : 'ℹ️'}</span>
                <span class="notification-text">${message}</span>
            </div>
            <button class="notification-close" onclick="this.parentElement.remove()">✕</button>
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.classList.add('show');
        }, 100);
        
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => {
                notification.remove();
            }, 300);
        }, 3000);
    },
    
    // 确认对话框
    confirm(message, callback) {
        const modal = document.createElement('div');
        modal.className = 'confirm-modal';
        modal.innerHTML = `
            <div class="confirm-content">
                <div class="confirm-header">
                    <h3>确认操作</h3>
                    <button class="confirm-close" onclick="this.parentElement.parentElement.parentElement.remove()">✕</button>
                </div>
                <div class="confirm-body">
                    <p>${message}</p>
                </div>
                <div class="confirm-footer">
                    <button class="btn btn-secondary confirm-cancel">取消</button>
                    <button class="btn btn-danger confirm-confirm">确认</button>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        setTimeout(() => {
            modal.classList.add('show');
        }, 100);
        
        modal.querySelector('.confirm-cancel').addEventListener('click', () => {
            modal.remove();
        });
        
        modal.querySelector('.confirm-confirm').addEventListener('click', () => {
            callback();
            modal.remove();
        });
    },
    
    // 加载状态管理
    showLoading(message = '加载中...') {
        const loading = document.createElement('div');
        loading.className = 'loading-overlay';
        loading.innerHTML = `
            <div class="loading-content">
                <div class="loading-spinner"></div>
                <p>${message}</p>
            </div>
        `;
        document.body.appendChild(loading);
    },
    
    hideLoading() {
        const loading = document.querySelector('.loading-overlay');
        if (loading) {
            loading.remove();
        }
    },
    
    // 深拷贝对象
    deepCopy(obj) {
        return JSON.parse(JSON.stringify(obj));
    },
    
    // 防抖函数
    debounce(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    }
};

// 认证系统
const Auth = {
    // 检查用户是否已登录
    checkAuth() {
        // 直接检查sessionStorage，不依赖AppConfig
        const token = sessionStorage.getItem('adminToken');
        const user = sessionStorage.getItem('adminUser');
        return token && user;
    },
    
    // 登录
    login(username, password) {
        // 这里应该是实际的API调用
        const validUsers = {
            'admin': 'admin123',
            'manager': 'manager123',
            'superadmin': 'super2024'
        };
        
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                if (validUsers[username] === password) {
                    const userData = {
                        username: username,
                        role: username === 'superadmin' ? 'superadmin' : username === 'admin' ? 'admin' : 'manager',
                        name: username === 'superadmin' ? '超级管理员' : username === 'admin' ? '管理员' : '经理',
                        loginTime: new Date().toISOString()
                    };
                    
                    // 直接设置sessionStorage，不依赖AppConfig
                    sessionStorage.setItem('adminToken', `token_${Utils.generateId()}`);
                    sessionStorage.setItem('adminUser', JSON.stringify(userData));
                    
                    resolve(userData);
                } else {
                    reject(new Error('用户名或密码错误'));
                }
            }, 500);
        });
    },
    
    // 退出登录
    logout() {
        // 直接清除sessionStorage，不依赖AppConfig
        sessionStorage.removeItem('adminToken');
        sessionStorage.removeItem('adminUser');
        localStorage.removeItem('rememberUser');
        window.location.href = 'login.html';
    },
    
    // 获取当前用户
    getCurrentUser() {
        // 直接获取sessionStorage，不依赖AppConfig
        const userStr = sessionStorage.getItem('adminUser');
        return userStr ? JSON.parse(userStr) : null;
    },
    
    // 检查权限
    hasPermission(requiredRole) {
        const user = this.getCurrentUser();
        if (!user) return false;
        
        const roles = ['user', 'manager', 'admin', 'superadmin'];
        return roles.indexOf(user.role) >= roles.indexOf(requiredRole);
    },
    
    // 自动过期处理
    setupAutoLogout() {
        const loginTime = sessionStorage.getItem('loginTime');
        if (loginTime) {
            const elapsed = Date.now() - new Date(loginTime).getTime();
            if (elapsed > AppConfig.sessionTimeout) {
                this.logout();
                Utils.showNotification('登录已过期，请重新登录', 'warning');
            }
        }
        
        // 每分钟检查一次
        setInterval(() => {
            const loginTime = sessionStorage.getItem('loginTime');
            if (loginTime) {
                const elapsed = Date.now() - new Date(loginTime).getTime();
                if (elapsed > AppConfig.sessionTimeout) {
                    this.logout();
                    Utils.showNotification('登录已过期，请重新登录', 'warning');
                }
            }
        }, 60000);
    }
};

// 导航系统
const Navigation = {
    // 初始化导航
    init() {
        // 设置当前页面的活动状态
        this.setActiveNavItem();
        
        // 退出登录事件
        document.querySelectorAll('.nav-item').forEach(item => {
            if (item.getAttribute('href') === 'login.html') {
                item.addEventListener('click', (e) => {
                    e.preventDefault();
                    Auth.logout();
                });
            }
        });
        
        // 页面切换动画
        document.querySelectorAll('a[href$=".html"]').forEach(link => {
            if (!link.classList.contains('external')) {
                link.addEventListener('click', (e) => {
                    const href = link.getAttribute('href');
                    if (href !== window.location.pathname.split('/').pop()) {
                        e.preventDefault();
                        this.navigateTo(href);
                    }
                });
            }
        });
    },
    
    // 设置活动导航项
    setActiveNavItem() {
        const currentPage = window.location.pathname.split('/').pop();
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
            if (item.getAttribute('href') === currentPage) {
                item.classList.add('active');
            }
        });
    },
    
    // 页面导航
    navigateTo(url) {
        document.body.classList.add('page-transition');
        setTimeout(() => {
            window.location.href = url;
        }, 300);
    },
    
    // 刷新当前页面
    refresh() {
        document.body.classList.add('page-transition');
        setTimeout(() => {
            window.location.reload();
        }, 300);
    }
};

// 数据管理系统
const DataManager = {
    // 模拟数据
    mockData: {
        users: [
            { id: 100001, name: '李晓明', phone: '138****1234', role: 'user', status: 'active', registerTime: '2024-01-15 09:30', lastLogin: '2024-12-27 14:25', membership: 'svip' },
            { id: 100002, name: '王芳', phone: '139****5678', role: 'user', status: 'active', registerTime: '2024-02-20 14:15', lastLogin: '2024-12-26 18:42', membership: 'vip' },
            { id: 100003, name: '张伟', phone: '136****9012', role: 'user', status: 'active', registerTime: '2024-03-10 08:45', lastLogin: '2024-12-27 10:18', membership: 'normal' },
            { id: 100004, name: '刘洋', phone: '137****3456', role: 'user', status: 'inactive', registerTime: '2024-04-05 16:30', lastLogin: '2024-12-25 22:15', membership: 'svip' },
            { id: 100005, name: '陈静', phone: '135****7890', role: 'user', status: 'banned', registerTime: '2024-05-18 11:20', lastLogin: '2024-12-27 08:55', membership: 'vip' }
        ],
        stats: {
            totalUsers: 128456,
            monthlyRevenue: 486920,
            dailyActive: 45892,
            conversionRate: 23.4,
            totalVisits: 1234567,
            systemAvailability: 99.99,
            blockedRequests: 12,
            pendingAlerts: 2
        },
        charts: {
            functionUsage: [12500, 9800, 15600, 7200, 8900, 23400],
            aiChat: [4200, 4800, 5100, 4900, 5600, 6200, 5800],
            contentTrend: [18234, 19876, 21543, 22345],
            revenueTrend: [986000, 1056000, 1123000, 1189000, 1234000, 1286450]
        }
    },
    
    // 获取用户列表
    getUsers(filters = {}) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                let users = [...this.mockData.users];
                
                // 应用过滤条件
                if (filters.id) {
                    users = users.filter(user => user.id.toString().includes(filters.id));
                }
                if (filters.phone) {
                    users = users.filter(user => user.phone.includes(filters.phone));
                }
                if (filters.nickname) {
                    users = users.filter(user => user.name.includes(filters.nickname));
                }
                if (filters.membership) {
                    users = users.filter(user => user.membership === filters.membership);
                }
                if (filters.status) {
                    users = users.filter(user => user.status === filters.status);
                }
                
                resolve(users);
            }, 300);
        });
    },
    
    // 获取统计数据
    getStats() {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                resolve(this.mockData.stats);
            }, 200);
        });
    },
    
    // 获取图表数据
    getChartData(type) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                resolve(this.mockData.charts[type] || []);
            }, 200);
        });
    },
    
    // 更新用户状态
    updateUserStatus(userId, status) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const user = this.mockData.users.find(u => u.id === userId);
                if (user) {
                    user.status = status;
                    resolve(user);
                } else {
                    reject(new Error('用户不存在'));
                }
            }, 300);
        });
    },
    
    // 重置用户密码
    resetUserPassword(userId) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                const user = this.mockData.users.find(u => u.id === userId);
                if (user) {
                    // 这里应该是实际的密码重置逻辑
                    resolve({ success: true, message: '密码已重置为默认密码: 123456' });
                } else {
                    reject(new Error('用户不存在'));
                }
            }, 300);
        });
    }
};

// 表单处理系统
const FormHandler = {
    // 初始化表单
    init() {
        // 表单验证
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', (e) => {
                if (!this.validate(form)) {
                    e.preventDefault();
                }
            });
        });
        
        // 输入实时验证
        document.querySelectorAll('input[required], select[required], textarea[required]').forEach(input => {
            input.addEventListener('input', () => {
                this.validateField(input);
            });
        });
        
        // 密码强度检测
        document.querySelectorAll('input[type="password"]').forEach(input => {
            input.addEventListener('input', () => {
                this.checkPasswordStrength(input);
            });
        });
    },
    
    // 验证表单
    validate(form) {
        let isValid = true;
        const fields = form.querySelectorAll('input[required], select[required], textarea[required]');
        
        fields.forEach(field => {
            if (!this.validateField(field)) {
                isValid = false;
            }
        });
        
        return isValid;
    },
    
    // 验证单个字段
    validateField(field) {
        const value = field.value.trim();
        const parent = field.parentElement;
        let error = '';
        
        // 清除之前的错误
        const existingError = parent.querySelector('.error-message');
        if (existingError) {
            existingError.remove();
        }
        
        if (!value) {
            error = '此字段为必填项';
        } else {
            // 根据字段类型进行验证
            if (field.type === 'email') {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(value)) {
                    error = '请输入有效的邮箱地址';
                }
            } else if (field.type === 'tel') {
                const phoneRegex = /^1[3-9]\d{9}$/;
                if (!phoneRegex.test(value)) {
                    error = '请输入有效的手机号码';
                }
            } else if (field.type === 'url') {
                const urlRegex = /^(https?:\/\/)?([\da-z.-]+)\.([a-z.]{2,6})([\/\w .-]*)*\/?$/;
                if (!urlRegex.test(value)) {
                    error = '请输入有效的URL地址';
                }
            }
        }
        
        if (error) {
            const errorElement = document.createElement('div');
            errorElement.className = 'error-message';
            errorElement.textContent = error;
            parent.appendChild(errorElement);
            field.classList.add('error');
            return false;
        } else {
            field.classList.remove('error');
            return true;
        }
    },
    
    // 检查密码强度
    checkPasswordStrength(input) {
        const value = input.value;
        const parent = input.parentElement;
        let strength = 0;
        let strengthText = '';
        let strengthClass = '';
        
        // 清除之前的强度指示器
        const existingStrength = parent.querySelector('.password-strength');
        if (existingStrength) {
            existingStrength.remove();
        }
        
        if (value.length >= 8) strength++;
        if (/[A-Z]/.test(value)) strength++;
        if (/[a-z]/.test(value)) strength++;
        if (/[0-9]/.test(value)) strength++;
        if (/[^A-Za-z0-9]/.test(value)) strength++;
        
        switch (strength) {
            case 0:
            case 1:
                strengthText = '弱';
                strengthClass = 'weak';
                break;
            case 2:
            case 3:
                strengthText = '中';
                strengthClass = 'medium';
                break;
            case 4:
            case 5:
                strengthText = '强';
                strengthClass = 'strong';
                break;
        }
        
        if (value) {
            const strengthElement = document.createElement('div');
            strengthElement.className = `password-strength ${strengthClass}`;
            strengthElement.innerHTML = `
                <div class="strength-label">密码强度：</div>
                <div class="strength-bar">
                    <div class="strength-fill" style="width: ${strength * 20}%"></div>
                </div>
                <div class="strength-text">${strengthText}</div>
            `;
            parent.appendChild(strengthElement);
        }
    }
};

// 图表系统
const ChartSystem = {
    charts: {},
    
    // 初始化图表
    init() {
        // 等待DOM加载完成
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => {
                this.renderCharts();
            });
        } else {
            this.renderCharts();
        }
    },
    
    // 渲染所有图表
    renderCharts() {
        // 功能使用图表
        const functionUsageCtx = document.getElementById('functionUsageChart');
        if (functionUsageCtx) {
            this.charts.functionUsage = new Chart(functionUsageCtx, {
                type: 'bar',
                data: {
                    labels: ['命理分析', '健康评估', '饮食推荐', '健康规划', '舌像检测', 'AI对话'],
                    datasets: [{
                        label: '日均使用次数',
                        data: DataManager.mockData.charts.functionUsage,
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
        
        // AI对话图表
        const aiChatCtx = document.getElementById('aiChatChart');
        if (aiChatCtx) {
            this.charts.aiChat = new Chart(aiChatCtx, {
                type: 'line',
                data: {
                    labels: ['1日', '5日', '10日', '15日', '20日', '25日', '30日'],
                    datasets: [{
                        label: '对话次数',
                        data: DataManager.mockData.charts.aiChat,
                        borderColor: '#48bb78',
                        backgroundColor: 'rgba(72, 187, 120, 0.1)',
                        fill: true,
                        tension: 0.4,
                        yAxisID: 'y'
                    }, {
                        label: '平均会话长度(分钟)',
                        data: [8.5, 9.2, 8.8, 10.1, 9.5, 11.2, 10.5],
                        borderColor: '#ed8936',
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
        
        // 内容生态图表
        const contentEcosystemCtx = document.getElementById('contentEcosystemChart');
        if (contentEcosystemCtx) {
            this.charts.contentEcosystem = new Chart(contentEcosystemCtx, {
                type: 'line',
                data: {
                    labels: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
                    datasets: [{
                        label: '发帖量',
                        data: [156, 189, 234, 198, 267, 312, 289],
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        fill: true,
                        tension: 0.4
                    }, {
                        label: '互动量',
                        data: [892, 1056, 1234, 1189, 1456, 1876, 1623],
                        borderColor: '#48bb78',
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
        
        // 收入趋势图表
        const revenueTrendCtx = document.getElementById('revenueTrendChart');
        if (revenueTrendCtx) {
            this.charts.revenueTrend = new Chart(revenueTrendCtx, {
                type: 'line',
                data: {
                    labels: ['1月', '2月', '3月', '4月', '5月', '6月'],
                    datasets: [{
                        label: '收入',
                        data: DataManager.mockData.charts.revenueTrend,
                        borderColor: '#667eea',
                        backgroundColor: 'rgba(102, 126, 234, 0.1)',
                        tension: 0.4,
                        fill: true
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
                            beginAtZero: false,
                            grid: {
                                color: 'rgba(0,0,0,0.05)'
                            },
                            ticks: {
                                callback: function(value) {
                                    return '¥' + (value / 10000) + '万';
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
    },
    
    // 更新图表数据
    updateChart(chartName, data) {
        if (this.charts[chartName]) {
            this.charts[chartName].data.datasets[0].data = data;
            this.charts[chartName].update();
        }
    }
};

// 页面特定功能
const PageSpecific = {
    // 登录页面
    login() {
        const loginForm = document.getElementById('loginForm');
        if (loginForm) {
            loginForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const username = document.getElementById('username').value.trim();
                const password = document.getElementById('password').value;
                const remember = document.getElementById('remember').checked;
                
                Utils.showLoading('登录中...');
                
                try {
                    const user = await Auth.login(username, password);
                    
                    if (remember) {
                        localStorage.setItem('rememberUser', username);
                    } else {
                        localStorage.removeItem('rememberUser');
                    }
                    
                    sessionStorage.setItem('loginTime', new Date().toISOString());
                    Navigation.navigateTo('dashboard.html');
                    Utils.showNotification('登录成功', 'success');
                } catch (error) {
                    Utils.showNotification(error.message, 'error');
                    document.getElementById('password').value = '';
                } finally {
                    Utils.hideLoading();
                }
            });
        }
    },
    
    // 用户管理页面
    users() {
        // 搜索功能
        const searchBtn = document.querySelector('button[onclick="searchUsers()"]');
        if (searchBtn) {
            searchBtn.addEventListener('click', async () => {
                const filters = {
                    id: document.getElementById('searchId').value.trim(),
                    phone: document.getElementById('searchPhone').value.trim(),
                    nickname: document.getElementById('searchNickname').value.trim(),
                    membership: document.getElementById('searchMemberStatus').value,
                    status: document.getElementById('searchAccountStatus').value
                };
                
                Utils.showLoading('搜索中...');
                try {
                    const users = await DataManager.getUsers(filters);
                    // 这里应该更新用户列表
                    Utils.showNotification(`找到 ${users.length} 个用户`, 'success');
                } catch (error) {
                    Utils.showNotification(error.message, 'error');
                } finally {
                    Utils.hideLoading();
                }
            });
        }
        
        // 重置搜索
        const resetBtn = document.querySelector('button[onclick="resetSearch()"]');
        if (resetBtn) {
            resetBtn.addEventListener('click', () => {
                document.getElementById('searchId').value = '';
                document.getElementById('searchPhone').value = '';
                document.getElementById('searchNickname').value = '';
                document.getElementById('searchMemberStatus').value = '';
                document.getElementById('searchAccountStatus').value = '';
            });
        }
    },
    
    // 数据看板页面
    dashboard() {
        // 初始化数据
        DataManager.getStats().then(stats => {
            // 更新统计卡片
            const statCards = document.querySelectorAll('.stat-card');
            const statKeys = ['totalUsers', 'monthlyRevenue', 'dailyActive', 'conversionRate'];
            statCards.forEach((card, index) => {
                if (statKeys[index]) {
                    const valueElement = card.querySelector('.stat-value');
                    if (valueElement) {
                        const value = stats[statKeys[index]];
                        if (statKeys[index] === 'monthlyRevenue') {
                            valueElement.textContent = `¥${value.toLocaleString()}`;
                        } else if (statKeys[index] === 'conversionRate') {
                            valueElement.textContent = `${value}%`;
                        } else {
                            valueElement.textContent = value.toLocaleString();
                        }
                    }
                }
            });
        });
        
        // 导出报表
        const exportBtn = document.querySelector('button[onclick="exportReport()"]');
        if (exportBtn) {
            exportBtn.addEventListener('click', exportReport);
        }
    },
    
    // 系统设置页面
    settings() {
        // 保存设置
        const saveBtn = document.querySelector('button[onclick*="保存设置"]');
        if (saveBtn) {
            saveBtn.addEventListener('click', () => {
                Utils.showNotification('设置已保存', 'success');
            });
        }
        
        // 清理缓存
        const clearCacheBtns = document.querySelectorAll('button:contains(清理)');
        clearCacheBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                Utils.confirm('确定要清理缓存吗？', () => {
                    Utils.showNotification('缓存清理完成', 'success');
                });
            });
        });
        
        // 切换开关功能
        document.querySelectorAll('.toggle-switch').forEach(toggle => {
            toggle.addEventListener('click', function() {
                this.classList.toggle('active');
            });
        });
        
        // 选择框变化效果
        document.querySelectorAll('.settings-card').forEach(card => {
            card.querySelectorAll('select').forEach(select => {
                select.addEventListener('change', function() {
                    this.style.borderColor = 'var(--success-color)';
                    setTimeout(() => {
                        this.style.borderColor = '';
                    }, 2000);
                });
            });
        });
    }
};



// 初始化系统
function initSystem() {
    // 检查认证
    const currentPage = window.location.pathname.split('/').pop();
    if (currentPage !== 'login.html' && !Auth.checkAuth()) {
        window.location.href = 'login.html';
        return;
    }
    
    // 设置自动登出
    Auth.setupAutoLogout();
    
    // 初始化导航
    Navigation.init();
    
    // 初始化表单处理
    FormHandler.init();
    
    // 初始化图表
    ChartSystem.init();
    
    // 初始化页面特定功能
    if (PageSpecific[currentPage.replace('.html', '')]) {
        PageSpecific[currentPage.replace('.html', '')]();
    }
    
    // 添加全局样式
    const style = document.createElement('style');
    style.textContent = `
        /* 通知样式 */
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 20px;
            background: var(--bg-primary);
            border-radius: var(--border-radius-md);
            box-shadow: var(--shadow-xl);
            border-left: 4px solid var(--info-color);
            z-index: 10000;
            opacity: 0;
            transform: translateX(100%);
            transition: all var(--transition-normal);
        }
        
        .notification.show {
            opacity: 1;
            transform: translateX(0);
        }
        
        .notification.success {
            border-left-color: var(--success-color);
        }
        
        .notification.error {
            border-left-color: var(--danger-color);
        }
        
        .notification.warning {
            border-left-color: var(--warning-color);
        }
        
        .notification-content {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .notification-icon {
            font-size: 18px;
        }
        
        .notification-text {
            font-size: 14px;
            color: var(--text-primary);
        }
        
        .notification-close {
            background: none;
            border: none;
            font-size: 16px;
            color: var(--text-tertiary);
            cursor: pointer;
            padding: 4px;
            border-radius: var(--border-radius-full);
            transition: all var(--transition-fast);
        }
        
        .notification-close:hover {
            background: var(--bg-tertiary);
            color: var(--text-primary);
        }
        
        /* 确认对话框样式 */
        .confirm-modal {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            opacity: 0;
            visibility: hidden;
            transition: all var(--transition-normal);
        }
        
        .confirm-modal.show {
            opacity: 1;
            visibility: visible;
        }
        
        .confirm-content {
            background: var(--bg-primary);
            border-radius: var(--border-radius-lg);
            box-shadow: var(--shadow-xl);
            max-width: 400px;
            width: 90%;
            transform: translateY(-20px);
            transition: transform var(--transition-normal);
        }
        
        .confirm-modal.show .confirm-content {
            transform: translateY(0);
        }
        
        .confirm-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: var(--spacing-lg);
            border-bottom: 1px solid var(--border-color);
        }
        
        .confirm-header h3 {
            margin: 0;
            font-size: 18px;
            color: var(--text-primary);
        }
        
        .confirm-close {
            background: none;
            border: none;
            font-size: 16px;
            color: var(--text-tertiary);
            cursor: pointer;
            padding: 4px;
            border-radius: var(--border-radius-full);
            transition: all var(--transition-fast);
        }
        
        .confirm-close:hover {
            background: var(--bg-tertiary);
            color: var(--text-primary);
        }
        
        .confirm-body {
            padding: var(--spacing-lg);
        }
        
        .confirm-body p {
            margin: 0;
            color: var(--text-secondary);
            line-height: 1.6;
        }
        
        .confirm-footer {
            display: flex;
            justify-content: flex-end;
            gap: var(--spacing-sm);
            padding: var(--spacing-lg);
            border-top: 1px solid var(--border-color);
        }
        
        /* 加载样式 */
        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(255, 255, 255, 0.9);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 10000;
        }
        
        .loading-content {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: var(--spacing-md);
        }
        
        .loading-spinner {
            width: 48px;
            height: 48px;
            border: 4px solid var(--border-color);
            border-top-color: var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }
        
        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
        
        .loading-content p {
            color: var(--text-secondary);
            font-size: 14px;
        }
        
        /* 表单错误样式 */
        .error-message {
            font-size: 12px;
            color: var(--danger-color);
            margin-top: 4px;
        }
        
        .error {
            border-color: var(--danger-color) !important;
        }
        
        /* 密码强度样式 */
        .password-strength {
            display: flex;
            align-items: center;
            gap: var(--spacing-sm);
            margin-top: var(--spacing-xs);
            font-size: 12px;
        }
        
        .strength-label {
            color: var(--text-tertiary);
        }
        
        .strength-bar {
            flex: 1;
            height: 4px;
            background: var(--bg-tertiary);
            border-radius: 2px;
            overflow: hidden;
        }
        
        .strength-fill {
            height: 100%;
            background: var(--danger-color);
            transition: width var(--transition-normal);
        }
        
        .strength-fill.medium {
            background: var(--warning-color);
        }
        
        .strength-fill.strong {
            background: var(--success-color);
        }
        
        .strength-text {
            color: var(--text-tertiary);
        }
        
        /* 页面过渡动画 */
        .page-transition {
            opacity: 0;
            transition: opacity var(--transition-normal);
        }
        
        /* 开关样式 */
        .toggle-switch {
            width: 50px;
            height: 26px;
            background: var(--bg-tertiary);
            border-radius: 13px;
            position: relative;
            cursor: pointer;
            transition: background-color var(--transition-normal);
        }
        
        .toggle-switch.active {
            background: var(--primary-color);
        }
        
        .toggle-switch::after {
            content: '';
            position: absolute;
            top: 3px;
            left: 3px;
            width: 20px;
            height: 20px;
            background: white;
            border-radius: 50%;
            transition: transform var(--transition-normal);
            box-shadow: var(--shadow-sm);
        }
        
        .toggle-switch.active::after {
            transform: translateX(24px);
        }
    `;
    document.head.appendChild(style);
}

// 启动系统
initSystem();
