// 页面切换功能
function switchPage(pageId) {
    // 隐藏所有页面
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => {
        page.classList.add('fadeOut');
        setTimeout(() => {
            page.classList.remove('active', 'fadeOut');
        }, 300);
    });
    
    // 显示目标页面
    const targetPage = document.getElementById(pageId);
    if (targetPage) {
        setTimeout(() => {
            targetPage.classList.add('active', 'fadeIn');
        }, 300);
    }
    
    // 更新底部导航栏状态
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.classList.remove('active');
    });
    
    // 找到对应的导航项并激活
    const correspondingNavItem = document.querySelector(`[onclick="switchPage('${pageId}')"]`);
    if (correspondingNavItem) {
        correspondingNavItem.classList.add('active');
    }
    
    // 如果是发布页面，特殊处理
    if (pageId === 'publish-post') {
        // 发布按钮不显示激活状态
    }
}

// 页面加载完成后执行
window.addEventListener('DOMContentLoaded', () => {
    // 初始化首页
    switchPage('home');
    
    // 绑定搜索栏功能
    bindSearchFunctionality();
    
    // 绑定发布帖子功能
    bindPublishFunctionality();
    
    // 绑定AI对话功能
    bindAIChatFunctionality();
    
    // 绑定会员页面功能
    bindMemberFunctionality();
    
    // 绑定个人设置功能
    bindProfileFunctionality();
    
    // 添加微交互效果
    addMicroInteractions();
});

// 搜索栏功能
function bindSearchFunctionality() {
    const searchInput = document.querySelector('.search-bar input');
    if (searchInput) {
        searchInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                const searchTerm = e.target.value.trim();
                if (searchTerm) {
                    alert(`搜索内容: ${searchTerm}`);
                    // 这里可以添加实际的搜索逻辑
                }
            }
        });
    }
}

// 发布帖子功能
function bindPublishFunctionality() {
    // 标题输入字数统计
    const titleInput = document.querySelector('#publish-post .title-input input');
    const charCount = document.querySelector('#publish-post .char-count');
    
    if (titleInput && charCount) {
        titleInput.addEventListener('input', (e) => {
            const length = e.target.value.length;
            charCount.textContent = `${length}/30`;
            checkPublishButtonStatus();
        });
    }
    
    // 内容输入监听
    const contentTextarea = document.querySelector('#publish-post .content-area textarea');
    if (contentTextarea) {
        contentTextarea.addEventListener('input', checkPublishButtonStatus);
    }
    
    // 标签添加功能
    const tagsInput = document.querySelector('#publish-post .tags-section input');
    const tagsList = document.querySelector('#publish-post .tags-list');
    
    if (tagsInput && tagsList) {
        tagsInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                const tagText = e.target.value.trim();
                if (tagText && tagText.startsWith('#')) {
                    addTag(tagText);
                    e.target.value = '';
                }
            }
        });
    }
    
    // 设置面板折叠/展开
    const settingsHeader = document.querySelector('.publish-settings .settings-header');
    const settingsContent = document.querySelector('.publish-settings .settings-content');
    const settingsToggle = document.querySelector('.publish-settings .settings-toggle');
    
    if (settingsHeader && settingsContent && settingsToggle) {
        settingsHeader.addEventListener('click', () => {
            settingsContent.classList.toggle('hidden');
            settingsToggle.classList.toggle('fa-chevron-down');
            settingsToggle.classList.toggle('fa-chevron-up');
        });
    }
}

// 添加标签
function addTag(tagText) {
    const tagsList = document.querySelector('#publish-post .tags-list');
    if (!tagsList) return;
    
    // 检查标签是否已存在
    const existingTags = Array.from(tagsList.querySelectorAll('.tag-item span'));
    if (existingTags.some(tag => tag.textContent === tagText)) {
        return;
    }
    
    const tagItem = document.createElement('div');
    tagItem.className = 'tag-item';
    tagItem.innerHTML = `
        <span>${tagText}</span>
        <i class="fas fa-times remove-tag"></i>
    `;
    
    // 绑定删除标签事件
    const removeButton = tagItem.querySelector('.remove-tag');
    removeButton.addEventListener('click', () => {
        tagsList.removeChild(tagItem);
    });
    
    tagsList.appendChild(tagItem);
}

// 检查发布按钮状态
function checkPublishButtonStatus() {
    const titleInput = document.querySelector('#publish-post .title-input input');
    const contentTextarea = document.querySelector('#publish-post .content-area textarea');
    const publishBtn = document.querySelector('#publish-post .publish-btn');
    const finalPublishBtn = document.querySelector('#publish-post .final-publish-btn');
    
    if (titleInput && contentTextarea && publishBtn && finalPublishBtn) {
        const isTitleValid = titleInput.value.trim().length > 0;
        const isContentValid = contentTextarea.value.trim().length > 0;
        
        if (isTitleValid && isContentValid) {
            publishBtn.disabled = false;
            finalPublishBtn.disabled = false;
        } else {
            publishBtn.disabled = true;
            finalPublishBtn.disabled = true;
        }
    }
}

// AI对话功能
function bindAIChatFunctionality() {
    const sendBtn = document.querySelector('#ai-chat .send-btn');
    const chatInput = document.querySelector('#ai-chat .input-wrapper input');
    const chatMessages = document.querySelector('#ai-chat .chat-messages');
    const quickBtns = document.querySelectorAll('#ai-chat .quick-btn');
    
    // 发送按钮点击事件
    if (sendBtn && chatInput && chatMessages) {
        sendBtn.addEventListener('click', sendMessage);
        chatInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });
    }
    
    // 快捷提问按钮事件
    quickBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            chatInput.value = e.target.textContent;
            sendMessage();
        });
    });
    
    // AI风格切换
    const switchStyleBtn = document.querySelector('#ai-chat .switch-style-btn');
    if (switchStyleBtn) {
        switchStyleBtn.addEventListener('click', () => {
            alert('切换AI风格功能');
            // 这里可以添加实际的风格切换逻辑
        });
    }
}

// 发送消息
function sendMessage() {
    const chatInput = document.querySelector('#ai-chat .input-wrapper input');
    const chatMessages = document.querySelector('#ai-chat .chat-messages');
    
    if (!chatInput || !chatMessages) return;
    
    const messageText = chatInput.value.trim();
    if (!messageText) return;
    
    // 添加用户消息
    const userMessage = createMessageElement(messageText, 'user');
    chatMessages.appendChild(userMessage);
    
    // 清空输入框
    chatInput.value = '';
    
    // 滚动到底部
    chatMessages.scrollTop = chatMessages.scrollHeight;
    
    // 模拟AI回复
    setTimeout(() => {
        const aiResponse = getAIResponse(messageText);
        const aiMessage = createMessageElement(aiResponse, 'ai');
        chatMessages.appendChild(aiMessage);
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }, 1000);
}

// 创建消息元素
function createMessageElement(text, type) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}-message`;
    messageDiv.innerHTML = `
        <div class="message-content">
            <p>${text}</p>
        </div>
    `;
    return messageDiv;
}

// 模拟AI回复
function getAIResponse(userMessage) {
    const responses = [
        "感谢您的提问！我正在思考这个问题...",
        "这是一个很好的问题！让我为您解答。",
        "根据我的分析，您可能需要了解以下信息...",
        "我理解您的需求，让我为您提供帮助。",
        "这个问题很有趣，让我深入思考一下..."
    ];
    
    // 随机返回一个回复
    return responses[Math.floor(Math.random() * responses.length)];
}

// 会员页面功能
function bindMemberFunctionality() {
    // 套餐选择
    const packageCards = document.querySelectorAll('.package-card');
    const selectBtns = document.querySelectorAll('.select-package-btn');
    
    packageCards.forEach(card => {
        card.addEventListener('click', () => {
            // 移除所有卡片的选中状态
            packageCards.forEach(c => c.classList.remove('selected'));
            // 添加当前卡片的选中状态
            card.classList.add('selected');
        });
    });
    
    selectBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation(); // 防止冒泡
            const packageCard = btn.closest('.package-card');
            // 移除所有卡片的选中状态
            packageCards.forEach(c => c.classList.remove('selected'));
            // 添加当前卡片的选中状态
            packageCard.classList.add('selected');
            
            const packageName = packageCard.querySelector('.package-header h3').textContent;
            alert(`选择了${packageName}`);
        });
    });
    
    // 支付方式选择
    const paymentOptions = document.querySelectorAll('.payment-option');
    paymentOptions.forEach(option => {
        option.addEventListener('click', () => {
            // 移除所有选项的选中状态
            paymentOptions.forEach(opt => opt.classList.remove('selected'));
            // 添加当前选项的选中状态
            option.classList.add('selected');
        });
    });
    
    // 自动续费开关
    const autoRenewToggle = document.querySelector('#auto-renew');
    if (autoRenewToggle) {
        autoRenewToggle.addEventListener('change', (e) => {
            const isChecked = e.target.checked;
            alert(`自动续费已${isChecked ? '开启' : '关闭'}`);
        });
    }
}

// 个人设置功能
function bindProfileFunctionality() {
    // 头像编辑
    const editAvatarBtn = document.querySelector('.edit-avatar-btn');
    if (editAvatarBtn) {
        editAvatarBtn.addEventListener('click', () => {
            alert('更换头像功能');
            // 这里可以添加实际的头像上传逻辑
        });
    }
    
    // 个人信息项点击
    const infoItems = document.querySelectorAll('.info-item');
    infoItems.forEach(item => {
        item.addEventListener('click', () => {
            const text = item.querySelector('span').textContent;
            alert(`${text}功能`);
            // 这里可以添加实际的功能逻辑
        });
    });
    
    // 安全设置项点击
    const securityItems = document.querySelectorAll('.security-item');
    securityItems.forEach(item => {
        item.addEventListener('click', () => {
            const text = item.querySelector('span').textContent;
            if (text === '注销账号') {
                if (confirm('确定要注销账号吗？此操作不可恢复。')) {
                    alert('账号注销功能');
                    // 这里可以添加实际的注销逻辑
                }
            } else {
                alert(`${text}功能`);
                // 这里可以添加实际的功能逻辑
            }
        });
    });
    
    // 隐私设置开关
    const toggleSwitches = document.querySelectorAll('.toggle-switch input');
    toggleSwitches.forEach(toggleSwitch => {
        toggleSwitch.addEventListener('change', (e) => {
            const permission = e.target.id.replace('-permission', '');
            const isChecked = e.target.checked;
            console.log(`${permission}权限已${isChecked ? '开启' : '关闭'}`);
            // 这里可以添加实际的权限管理逻辑
        });
    });
    
    // 隐私协议和用户协议
    const privacyItems = document.querySelectorAll('.privacy-item span');
    privacyItems.forEach(item => {
        if (item.textContent === '隐私协议' || item.textContent === '用户协议') {
            item.parentElement.addEventListener('click', () => {
                alert(`${item.textContent}查看功能`);
                // 这里可以添加实际的协议查看逻辑
            });
        }
    });
}

// 添加微交互效果
function addMicroInteractions() {
    // 按钮悬停和点击效果
    const buttons = document.querySelectorAll('button, .nav-item, .function-item, .recipe-card, .kanban-card, .post-card, .info-item, .security-item, .privacy-item');
    
    buttons.forEach(button => {
        // 鼠标进入效果
        button.addEventListener('mouseenter', () => {
            button.style.transform = 'translateY(-2px)';
            button.style.transition = 'transform 0.2s ease';
        });
        
        // 鼠标离开效果
        button.addEventListener('mouseleave', () => {
            button.style.transform = 'translateY(0)';
        });
        
        // 点击效果
        button.addEventListener('click', (e) => {
            // 如果是链接或有特定处理的按钮，不添加点击动画
            if (e.target.tagName === 'A' || e.target.hasAttribute('href') || e.target.closest('.publish-icon')) {
                return;
            }
            
            button.style.transform = 'scale(0.95)';
            setTimeout(() => {
                button.style.transform = 'scale(1)';
            }, 100);
        });
    });
    
    // 滚动时的视差效果
    const banner = document.querySelector('.festival-banner');
    if (banner) {
        window.addEventListener('scroll', () => {
            const scrollPosition = window.scrollY;
            banner.style.backgroundPositionY = `${scrollPosition * 0.5}px`;
        });
    }
    
    // 搜索栏聚焦效果
    const searchInput = document.querySelector('.search-bar input');
    if (searchInput) {
        searchInput.addEventListener('focus', () => {
            searchInput.parentElement.style.boxShadow = '0 0 0 3px rgba(52, 152, 219, 0.1)';
        });
        
        searchInput.addEventListener('blur', () => {
            searchInput.parentElement.style.boxShadow = 'none';
        });
    }
    
    // 输入框聚焦效果
    const inputs = document.querySelectorAll('input, textarea');
    inputs.forEach(input => {
        input.addEventListener('focus', () => {
            input.parentElement.style.boxShadow = '0 0 0 3px rgba(52, 152, 219, 0.1)';
        });
        
        input.addEventListener('blur', () => {
            input.parentElement.style.boxShadow = 'none';
        });
    });
    
    // 卡片悬停效果增强
    const cards = document.querySelectorAll('.recipe-card, .kanban-card, .post-card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', () => {
            card.style.boxShadow = '0 8px 16px rgba(0, 0, 0, 0.1)';
            card.style.transition = 'box-shadow 0.3s ease, transform 0.3s ease';
        });
        
        card.addEventListener('mouseleave', () => {
            card.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.05)';
        });
    });
}

// 模拟数据加载
function simulateDataLoading(element) {
    if (!element) return;
    
    // 显示加载状态
    element.innerHTML = '<div class="loading"></div>';
    
    // 模拟加载时间
    setTimeout(() => {
        // 恢复原始内容
        element.innerHTML = '<p>加载完成！</p>';
    }, 1500);
}

// 下拉刷新功能（简化版）
function enablePullToRefresh() {
    const pages = document.querySelectorAll('.page');
    let startY = 0;
    let isRefreshing = false;
    
    pages.forEach(page => {
        page.addEventListener('touchstart', (e) => {
            if (page.scrollTop === 0) {
                startY = e.touches[0].clientY;
            }
        });
        
        page.addEventListener('touchmove', (e) => {
            if (page.scrollTop === 0 && !isRefreshing) {
                const currentY = e.touches[0].clientY;
                const diff = currentY - startY;
                
                if (diff > 50) {
                    e.preventDefault();
                    // 显示刷新提示
                    console.log('下拉刷新...');
                }
            }
        });
        
        page.addEventListener('touchend', (e) => {
            if (page.scrollTop === 0 && !isRefreshing) {
                const currentY = e.changedTouches[0].clientY;
                const diff = currentY - startY;
                
                if (diff > 100) {
                    isRefreshing = true;
                    console.log('执行刷新...');
                    
                    // 模拟刷新过程
                    setTimeout(() => {
                        console.log('刷新完成');
                        isRefreshing = false;
                    }, 1500);
                }
            }
        });
    });
}

// 无限滚动功能
function enableInfiniteScroll() {
    const postList = document.querySelector('.post-list');
    if (!postList) return;
    
    let isLoading = false;
    
    window.addEventListener('scroll', () => {
        if (isLoading) return;
        
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
        const scrollHeight = document.documentElement.scrollHeight;
        const clientHeight = document.documentElement.clientHeight;
        
        // 当滚动到距离底部200px时加载更多
        if (scrollHeight - scrollTop - clientHeight < 200) {
            loadMorePosts();
        }
    });
    
    function loadMorePosts() {
        isLoading = true;
        
        // 添加加载指示器
        const loadingIndicator = document.createElement('div');
        loadingIndicator.className = 'loading-indicator';
        loadingIndicator.innerHTML = '<div class="loading"></div><p>加载更多...</p>';
        postList.appendChild(loadingIndicator);
        
        // 模拟加载过程
        setTimeout(() => {
            // 创建新帖子
            for (let i = 0; i < 2; i++) {
                const newPost = createPostElement();
                postList.appendChild(newPost);
            }
            
            // 移除加载指示器
            postList.removeChild(loadingIndicator);
            isLoading = false;
        }, 1500);
    }
}

// 创建帖子元素
function createPostElement() {
    const postDiv = document.createElement('div');
    postDiv.className = 'post-card';
    postDiv.innerHTML = `
        <div class="post-header">
            <div class="user-info">
                <div class="user-avatar"></div>
                <div class="user-details">
                    <div class="user-name">用户${Math.floor(Math.random() * 1000)}</div>
                    <div class="post-time">${Math.floor(Math.random() * 24)}小时前</div>
                </div>
            </div>
        </div>
        <div class="post-content">
            <p>这是一条新的社区动态，分享我的生活感悟和健康经验...</p>
            <div class="post-image"></div>
        </div>
        <div class="post-footer">
            <div class="post-stats">
                <span class="like-count"><i class="fas fa-heart"></i> ${Math.floor(Math.random() * 300)}</span>
                <span class="comment-count"><i class="fas fa-comment"></i> ${Math.floor(Math.random() * 100)}</span>
            </div>
            <button class="view-full-btn">查看全文</button>
        </div>
    `;
    
    return postDiv;
}

// 初始化无限滚动
enableInfiniteScroll();

// 初始化下拉刷新（移动端）
enablePullToRefresh();