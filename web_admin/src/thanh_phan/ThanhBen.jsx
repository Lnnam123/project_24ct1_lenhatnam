import React from 'react';
import { 
  PieChart, 
  Users, 
  Shapes, 
  Bot, 
  Bell,
  LogOut,
  ShieldCheck,
  ChevronLeft,
  ChevronRight,
  X
} from 'lucide-react';

export default function Sidebar({ 
  currentTab, 
  onSelectTab, 
  user, 
  onLogout,
  isCollapsed,
  onToggleCollapse,
  isMobileOpen,
  onCloseMobile
}) {
  const navItems = [
    { id: 'dashboard', label: 'Tổng quan hệ thống', icon: PieChart, section: 'Tổng quan' },
    { id: 'users', label: 'Tài khoản người dùng', icon: Users, section: 'Quản trị hệ thống' },
    { id: 'admins', label: 'Quản trị viên', icon: ShieldCheck },
    { id: 'categories', label: 'Danh mục mẫu hệ thống', icon: Shapes },
    { id: 'ai_logs', label: 'Giám sát Trợ lý AI', icon: Bot, section: 'Dịch vụ & Vận hành' },
    { id: 'notifications', label: 'Thông báo hệ thống', icon: Bell },
  ];

  let currentSection = null;

  const isDesktopCollapsed = isCollapsed && !isMobileOpen;

  return (
    <aside className={`sidebar ${isDesktopCollapsed ? 'collapsed' : ''} ${isMobileOpen ? 'mobile-open' : ''}`}>
      <div className="sidebar-header">
        <div 
          className="brand-logo-wrap" 
          onClick={onToggleCollapse}
          style={{ cursor: 'pointer' }}
          title={isDesktopCollapsed ? "Bấm để mở rộng menu" : "CoinTap Portal"}
        >
          <img src="/icon.png" alt="CoinTap Logo" />
        </div>

        <div className="brand-title">
          <h1>CoinTap</h1>
          <span>Admin Portal</span>
        </div>

        {/* Nút đóng X trên Mobile */}
        <button
          className="btn-toggle-sidebar mobile-close-btn"
          onClick={onCloseMobile}
          title="Đóng menu"
        >
          <X size={18} />
        </button>

        {/* Nút thu gọn / mở rộng mũi tên trên Desktop */}
        <button 
          className="btn-toggle-sidebar desktop-toggle-btn" 
          onClick={onToggleCollapse} 
          title={isDesktopCollapsed ? "Mở rộng thanh menu" : "Thu gọn thanh menu"}
        >
          {isDesktopCollapsed ? <ChevronRight size={16} /> : <ChevronLeft size={16} />}
        </button>
      </div>

      <nav className="sidebar-nav">
        {navItems.map((item) => {
          const showSection = item.section && item.section !== currentSection;
          if (showSection) currentSection = item.section;
          const Icon = item.icon;
          const isActive = currentTab === item.id;

          return (
            <React.Fragment key={item.id}>
              {showSection && (
                <>
                  <div className="nav-label">{item.section}</div>
                  <div className="nav-divider" title={item.section} />
                </>
              )}
              <button
                className={`nav-item ${isActive ? 'active' : ''}`}
                onClick={() => onSelectTab(item.id)}
                title={item.label}
              >
                <Icon size={20} />
                <span className="nav-text">{item.label}</span>
              </button>
            </React.Fragment>
          );
        })}
      </nav>

      <div className="sidebar-footer">
        <div 
          className="admin-avatar" 
          title={`${user?.full_name || user?.name || 'Administrator'} (${user?.role || 'Admin'})`}
        >
          {(user?.full_name || user?.name || 'A').charAt(0).toUpperCase()}
        </div>
        <div className="admin-info">
          <h4>{user?.full_name || user?.name || 'Administrator'}</h4>
          <p>{user?.role || 'Quản trị viên'}</p>
        </div>
        <button 
          className="btn-sidebar-logout" 
          onClick={onLogout} 
          title="Đăng xuất khỏi hệ thống"
        >
          <LogOut size={16} />
        </button>
      </div>
    </aside>
  );
}
