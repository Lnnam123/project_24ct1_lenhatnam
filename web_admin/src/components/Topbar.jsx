import React from 'react';
import { RefreshCw, LogOut, Menu } from 'lucide-react';

export default function Topbar({ 
  title, 
  description, 
  onRefresh, 
  user, 
  onLogout,
  onToggleMenu
}) {
  return (
    <header className="topbar">
      <div className="topbar-left">
        {/* Nút menu toggle: trên desktop thu gọn/mở rộng sidebar; trên mobile mở/đóng drawer */}
        <button 
          className="btn-icon btn-menu-toggle" 
          onClick={onToggleMenu} 
          title="Thu gọn / Mở thanh menu"
        >
          <Menu size={20} />
        </button>

        <div className="page-title">
          <h2>{title}</h2>
          {description && <p>{description}</p>}
        </div>
      </div>

      <div className="topbar-right">
        <div className="system-badge">
          <div className="status-dot"></div>
          <span>Supabase Realtime</span>
        </div>
        <button className="btn-icon" onClick={onRefresh} title="Làm mới dữ liệu">
          <RefreshCw size={17} />
        </button>
        <button className="btn-topbar-logout" onClick={onLogout} title="Đăng xuất tài khoản">
          <LogOut size={16} />
          <span>Đăng xuất</span>
        </button>
      </div>
    </header>
  );
}
