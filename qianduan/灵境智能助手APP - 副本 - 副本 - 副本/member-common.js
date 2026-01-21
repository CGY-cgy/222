// 页面加载动画
function initPageLoadAnimation(pageId) {
    const page = document.getElementById(pageId);
    if (page) {
        page.style.opacity = '0';
        page.style.transform = 'translateY(10px)';
        setTimeout(() => {
            page.style.transition = 'all 0.3s ease';
            page.style.opacity = '1';
            page.style.transform = 'translateY(0)';
        }, 100);
    }
}

// 初始化底部导航栏
function initBottomNavigation() {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', () => {
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
            
            // 根据data-page属性导航到相应页面
            const page = item.dataset.page;
            const pageMap = {
                'home': 'home.html',
                'ai-chat': 'ai-chat.html',
                'publish-post': 'publish-post.html',
                'member': 'member.html',
                'profile': 'profile.html'
            };
            
            if (page && pageMap[page]) {
                // 检查当前页面是否在子目录中
                const currentPath = window.location.pathname;
                const isInSubdirectory = currentPath.includes('/profile_modules/') || currentPath.includes('/ai_chat_modules/');
                
                // 根据当前位置设置正确的相对路径
                if (isInSubdirectory) {
                    window.location.href = '../' + pageMap[page];
                } else {
                    window.location.href = pageMap[page];
                }
            }
        });
    });
}

// 返回按钮功能
function initBackButton() {
    const backBtn = document.querySelector('.back-btn');
    if (backBtn) {
        backBtn.addEventListener('click', () => {
            window.history.back();
        });
    }
}

// 自动续费开关功能
function initAutoRenewalToggle() {
    const toggle = document.querySelector('.auto-renewal-toggle');
    if (toggle) {
        toggle.addEventListener('click', () => {
            toggle.classList.toggle('active');
        });
    }
}

// 套餐选择功能
function initPackageSelection() {
    const packageOptions = document.querySelectorAll('.package-option');
    const totalAmount = document.getElementById('totalAmount');
    
    if (packageOptions.length > 0 && totalAmount) {
        packageOptions.forEach(option => {
            option.addEventListener('click', () => {
                packageOptions.forEach(opt => opt.classList.remove('selected'));
                option.classList.add('selected');
                totalAmount.textContent = option.dataset.price;
            });
        });
    }
}

// 支付方式选择功能
function initPaymentSelection() {
    const paymentOptions = document.querySelectorAll('.payment-option');
    
    if (paymentOptions.length > 0) {
        paymentOptions.forEach(option => {
            option.addEventListener('click', () => {
                paymentOptions.forEach(opt => opt.classList.remove('selected'));
                option.classList.add('selected');
            });
        });
    }
}

// 页面初始化函数
function initPage(pageType) {
    // 页面加载动画
    initPageLoadAnimation('page-content');
    
    // 初始化底部导航
    initBottomNavigation();
    
    // 初始化返回按钮
    initBackButton();
    
    // 根据页面类型初始化特定功能
    switch (pageType) {
        case 'purchase':
            initPackageSelection();
            initPaymentSelection();
            initAutoRenewalToggle();
            break;
        case 'benefits':
            // 会员权益页面特定初始化
            break;
        case 'center':
            // 会员中心页面特定初始化
            break;
        default:
            // 首页特定初始化
            break;
    }
}

// 页面加载完成后执行初始化
document.addEventListener('DOMContentLoaded', () => {
    // 检测当前页面类型
    const currentPage = window.location.pathname.split('/').pop();
    let pageType = 'home';
    
    if (currentPage.includes('privileges')) {
        pageType = 'benefits';
    } else if (currentPage.includes('purchase')) {
        pageType = 'purchase';
    } else if (currentPage.includes('center')) {
        pageType = 'center';
    }
    
    // 初始化页面
    initPage(pageType);
});