import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Topbar from './components/Topbar';
import DashboardView from './views/DashboardView';
import UsersView from './views/UsersView';
import AdminsView from './views/AdminsView';
import TransactionsView from './views/TransactionsView';
import CategoriesView from './views/CategoriesView';
import AILogsView from './views/AILogsView';
import NotificationsView from './views/NotificationsView';
import LoginView from './views/LoginView';
import { supabase } from './services/supabase';
import { CheckCircle, AlertCircle, Info } from 'lucide-react';

export default function App() {
  const [currentUser, setCurrentUser] = useState(() => {
    try {
      const local = localStorage.getItem('cointap_admin_session');
      if (local) return JSON.parse(local);
      const session = sessionStorage.getItem('cointap_admin_session');
      if (session) return JSON.parse(session);
    } catch (e) {
      console.error('Session load error:', e);
    }
    return null;
  });

  const [currentTab, setCurrentTab] = useState('dashboard');
  const [refreshTrigger, setRefreshTrigger] = useState(0);
  const [toasts, setToasts] = useState([]);

  // Sidebar collapse & mobile menu state
  const [isSidebarCollapsed, setIsSidebarCollapsed] = useState(() => {
    return localStorage.getItem('cointap_sidebar_collapsed') === 'true';
  });
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // Tự động đóng mobile drawer khi mở rộng cửa sổ về kích thước desktop
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 768) {
        setIsMobileMenuOpen(false);
      }
    };
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Tự động lắng nghe thay đổi thông tin người dùng (họ tên, vai trò)
  useEffect(() => {
    const handleUserUpdate = () => {
      try {
        const raw = localStorage.getItem('cointap_admin_session') || sessionStorage.getItem('cointap_admin_session');
        if (raw) {
          setCurrentUser(JSON.parse(raw));
        }
      } catch (e) {
        console.warn('Lỗi đọc cập nhật session:', e);
      }
    };
    window.addEventListener('storage', handleUserUpdate);
    window.addEventListener('cointap_user_updated', handleUserUpdate);
    return () => {
      window.removeEventListener('storage', handleUserUpdate);
      window.removeEventListener('cointap_user_updated', handleUserUpdate);
    };
  }, []);

  // Tự động kích hoạt căn chỉnh lại kích thước biểu đồ khi sidebar chuyển đổi trạng thái
  useEffect(() => {
    const timers = [
      setTimeout(() => window.dispatchEvent(new Event('resize')), 50),
      setTimeout(() => window.dispatchEvent(new Event('resize')), 150),
      setTimeout(() => window.dispatchEvent(new Event('resize')), 300),
      setTimeout(() => window.dispatchEvent(new Event('resize')), 500),
    ];
    return () => timers.forEach(clearTimeout);
  }, [isSidebarCollapsed]);

  const toggleSidebarCollapse = () => {
    setIsSidebarCollapsed((prev) => {
      const next = !prev;
      localStorage.setItem('cointap_sidebar_collapsed', String(next));
      return next;
    });
  };

  const handleToggleMenu = () => {
    if (window.innerWidth <= 768) {
      setIsMobileMenuOpen((prev) => !prev);
    } else {
      toggleSidebarCollapse();
    }
  };

  const closeMobileMenu = () => {
    setIsMobileMenuOpen(false);
  };

  const titleMap = {
    dashboard: { title: 'Tổng Quan Hệ Thống', desc: 'Số liệu thống kê thời gian thực và phân tích dòng tiền' },
    users: { title: 'Quản Lý Người Dùng', desc: 'Danh sách tài khoản, trạng thái và quản lý dữ liệu người dùng' },
    admins: { title: 'Quản Lý Quản Trị Viên', desc: 'Danh sách và phân quyền tài khoản quản trị hệ thống' },
    transactions: { title: 'Giám Sát Giao Dịch', desc: 'Toàn bộ biến động dòng tiền thu - chi trên toàn hệ thống' },
    categories: { title: 'Danh Mục Mặc Định', desc: 'Quản lý các nhóm chi tiêu & thu nhập dùng chung cho hệ thống' },

    ai_logs: { title: 'Giám Sát Trợ Lý AI', desc: 'Nhật ký các cuộc hội thoại và câu hỏi tư vấn tài chính của người dùng' },
    notifications: { title: 'Quản Lý Thông Báo', desc: 'Quản lý lịch sử thông báo hệ thống và phát thông báo mới tới người dùng di động' }
  };

  const showToast = (message, type = 'success') => {
    const id = Date.now();
    setToasts((prev) => [...prev, { id, message, type }]);
    setTimeout(() => {
      setToasts((prev) => prev.filter((t) => t.id !== id));
    }, 3500);
  };

  const handleRefresh = () => {
    setRefreshTrigger((prev) => prev + 1);
    showToast('Đang làm mới dữ liệu hệ thống...', 'info');
  };

  const handleLoginSuccess = (userObj) => {
    setCurrentUser(userObj);
    showToast(`Chào mừng trở lại, ${userObj.name || 'Quản trị viên'}!`, 'success');
  };

  const handleLogout = async () => {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      console.warn('Sign out warning:', e);
    }
    localStorage.removeItem('cointap_admin_session');
    sessionStorage.removeItem('cointap_admin_session');
    setCurrentUser(null);
    showToast('Đã đăng xuất thành công khỏi hệ thống quản trị', 'info');
  };

  // If user is not authenticated, show Login View
  if (!currentUser) {
    return (
      <>
        <LoginView onLoginSuccess={handleLoginSuccess} />
        {/* Global Toast Container */}
        <div className="toast-container">
          {toasts.map((t) => {
            const Icon = t.type === 'success' ? CheckCircle : t.type === 'error' ? AlertCircle : Info;
            return (
              <div key={t.id} className={`toast ${t.type}`}>
                <Icon size={18} />
                <span>{t.message}</span>
              </div>
            );
          })}
        </div>
      </>
    );
  }

  const headerInfo = titleMap[currentTab] || { title: 'CoinTap Admin', desc: '' };

  return (
    <div className="app-container">
      {/* Mobile Backdrop Overlay */}
      {isMobileMenuOpen && (
        <div className="mobile-backdrop" onClick={closeMobileMenu} />
      )}

      {/* Sidebar */}
      <Sidebar 
        currentTab={currentTab} 
        onSelectTab={(tab) => {
          setCurrentTab(tab);
          closeMobileMenu();
        }} 
        user={currentUser}
        onLogout={handleLogout}
        isCollapsed={isSidebarCollapsed}
        onToggleCollapse={toggleSidebarCollapse}
        isMobileOpen={isMobileMenuOpen}
        onCloseMobile={closeMobileMenu}
      />

      {/* Main Content */}
      <div className={`main-content ${isSidebarCollapsed ? 'sidebar-collapsed' : ''}`}>
        <Topbar
          title={headerInfo.title}
          description={headerInfo.desc}
          onRefresh={handleRefresh}
          user={currentUser}
          onLogout={handleLogout}
          onToggleMenu={handleToggleMenu}
        />

        <div className="page-container">
          {currentTab === 'dashboard' && <DashboardView key={refreshTrigger} onNavigate={setCurrentTab} />}
          {currentTab === 'users' && <UsersView key={refreshTrigger} showToast={showToast} />}
          {currentTab === 'admins' && <AdminsView key={refreshTrigger} showToast={showToast} currentUser={currentUser} />}
          {currentTab === 'transactions' && <TransactionsView key={refreshTrigger} showToast={showToast} />}
          {currentTab === 'categories' && <CategoriesView key={refreshTrigger} showToast={showToast} />}
          {currentTab === 'ai_logs' && <AILogsView key={refreshTrigger} showToast={showToast} />}
          {currentTab === 'notifications' && <NotificationsView key={refreshTrigger} showToast={showToast} />}
        </div>
      </div>

      {/* Toasts */}
      <div className="toast-container">
        {toasts.map((t) => {
          const Icon = t.type === 'success' ? CheckCircle : t.type === 'error' ? AlertCircle : Info;
          return (
            <div key={t.id} className={`toast ${t.type}`}>
              <Icon size={18} />
              <span>{t.message}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

