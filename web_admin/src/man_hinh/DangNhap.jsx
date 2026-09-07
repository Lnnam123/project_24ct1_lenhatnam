import React, { useState } from 'react';
import { supabase } from '../dich_vu/supabase';
import { 
  Lock, 
  User, 
  Eye, 
  EyeOff, 
  LogIn, 
  ShieldCheck, 
  Sparkles, 
  AlertCircle 
} from 'lucide-react';

export default function LoginView({ onLoginSuccess }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const saveSession = (userObj) => {
    const sessionData = JSON.stringify(userObj);
    if (rememberMe) {
      localStorage.setItem('cointap_admin_session', sessionData);
    } else {
      sessionStorage.setItem('cointap_admin_session', sessionData);
    }
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setErrorMsg('');

    const cleanUser = username.trim();
    const cleanPass = password.trim();

    if (!cleanUser || !cleanPass) {
      setErrorMsg('Vui lòng nhập đầy đủ Tên đăng nhập và Mật khẩu!');
      return;
    }

    setLoading(true);

    try {
      // 1. Kiểm tra xác thực trực tiếp từ Bảng riêng 'quan_tri_vien' trên Supabase
      const { data: adminUser } = await supabase
        .from('quan_tri_vien')
        .select('*')
        .eq('ten_dang_nhap', cleanUser)
        .eq('mat_khau', cleanPass)
        .maybeSingle();

      if (adminUser) {
        const userObj = {
          id: adminUser.ma_quan_tri ?? adminUser.id,
          username: adminUser.ten_dang_nhap ?? adminUser.username,
          name: adminUser.ho_ten || adminUser.full_name || adminUser.ten_dang_nhap || adminUser.username,
          email: adminUser.email || `${adminUser.ten_dang_nhap}@cointap.vn`,
          role: adminUser.vai_tro || adminUser.role || 'Administrator',
          loginAt: new Date().toISOString(),
        };
        saveSession(userObj);
        onLoginSuccess(userObj);
        return;
      }

      // 2. Kiểm tra danh sách admin được lưu trong local storage (nếu chưa chạy SQL tạo bảng trên Supabase)
      const localAdmins = JSON.parse(localStorage.getItem('cointap_local_admins') || '[]');
      const foundLocal = localAdmins.find(
        a => (a.username === cleanUser || a.email === cleanUser) && a.password_hash === cleanPass
      );
      if (foundLocal) {
        const userObj = {
          id: foundLocal.id,
          username: foundLocal.username,
          name: foundLocal.full_name || foundLocal.username,
          email: foundLocal.email || `${foundLocal.username}@cointap.vn`,
          role: foundLocal.role || 'Administrator',
          loginAt: new Date().toISOString(),
        };
        saveSession(userObj);
        onLoginSuccess(userObj);
        return;
      }

      // 3. Dự phòng tài khoản admin / admin mặc định
      if (cleanUser.toLowerCase() === 'admin' && cleanPass === 'admin') {
        const fallbackAdmin = {
          id: 1,
          username: 'admin',
          name: 'Quản Trị Viên Gốc',
          email: 'admin@cointap.vn',
          role: 'Super Admin',
          loginAt: new Date().toISOString(),
        };
        saveSession(fallbackAdmin);
        onLoginSuccess(fallbackAdmin);
        return;
      }


      // 3. Dự phòng Supabase Auth nếu đăng nhập bằng tài khoản Supabase Auth
      const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
        email: cleanUser,
        password: cleanPass,
      });

      if (!authError && authData?.user) {
        const authUser = {
          id: authData.user.id,
          email: authData.user.email,
          name: authData.user.user_metadata?.full_name || authData.user.email.split('@')[0],
          role: 'Admin',
          loginAt: new Date().toISOString(),
        };
        saveSession(authUser);
        onLoginSuccess(authUser);
        return;
      }

      setErrorMsg('Tên đăng nhập hoặc mật khẩu không chính xác! Vui lòng thử lại.');
    } catch (err) {
      setErrorMsg('Đã xảy ra lỗi khi đăng nhập: ' + (err.message || 'Không xác định'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-wrapper">
      {/* Background Animated Glows */}
      <div className="login-bg-glow glow-1"></div>
      <div className="login-bg-glow glow-2"></div>
      <div className="login-bg-glow glow-3"></div>

      <div className="login-card-container">
        {/* Brand Header */}
        <div className="login-header">
          <div className="login-logo-wrap">
            <img src="/icon.png" alt="CoinTap Logo" />
            <div className="logo-sparkle">
              <Sparkles size={16} />
            </div>
          </div>
          <h1 className="login-title">CoinTap Admin</h1>
          <p className="login-subtitle">Hệ thống Quản trị Tài chính & Dịch vụ Thông minh</p>
          <div className="login-badge">
            <ShieldCheck size={14} />
            <span>Cổng Quản Trị Cấp Cao</span>
          </div>
        </div>

        {/* Error Notification */}
        {errorMsg && (
          <div className="login-error-box">
            <AlertCircle size={18} />
            <span>{errorMsg}</span>
          </div>
        )}

        {/* Login Form */}
        <form className="login-form" onSubmit={handleLogin}>
          <div className="form-group">
            <label className="form-label">Tên Đăng Nhập</label>
            <div className="input-icon-wrap">
              <User className="input-icon" size={18} />
              <input
                type="text"
                className="form-control with-icon"
                placeholder="Nhập tên đăng nhập"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                autoComplete="username"
                autoFocus
              />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Mật khẩu</label>
            <div className="input-icon-wrap">
              <Lock className="input-icon" size={18} />
              <input
                type={showPassword ? 'text' : 'password'}
                className="form-control with-icon with-action"
                placeholder="Nhập mật khẩu"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                autoComplete="current-password"
              />
              <button
                type="button"
                className="input-action-btn"
                onClick={() => setShowPassword(!showPassword)}
                tabIndex="-1"
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <div className="form-options">
            <label className="remember-checkbox">
              <input
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
              />
              <span>Ghi nhớ phiên làm việc</span>
            </label>
          </div>

          <button 
            type="submit" 
            className="btn btn-primary login-btn"
            disabled={loading}
          >
            {loading ? (
              <>
                <div className="btn-spinner"></div>
                <span>Đang kiểm tra thông tin...</span>
              </>
            ) : (
              <>
                <LogIn size={18} />
                <span>Đăng Nhập Vào Hệ Thống</span>
              </>
            )}
          </button>
        </form>

        {/* Footer info */}
        <div className="login-footer">
          <span>CoinTap Platform © 2026 • Bảo mật kết nối Supabase SSL</span>
        </div>
      </div>
    </div>
  );
}
