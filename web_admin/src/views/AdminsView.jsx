import React, { useState, useEffect } from 'react';
import { 
  ShieldCheck, 
  UserPlus, 
  Trash2, 
  Search, 
  Copy, 
  Check, 
  AlertTriangle,
  Lock,
  User,
  Mail,
  KeyRound,
  Eye,
  EyeOff
} from 'lucide-react';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import { ApiService, formatDateTime } from '../services/api';

export default function AdminsView({ showToast, currentUser }) {
  const [admins, setAdmins] = useState([]);
  const [loading, setLoading] = useState(true);
  const [tableMissing, setTableMissing] = useState(false);
  const [search, setSearch] = useState('');
  const [copied, setCopied] = useState(false);

  // Lấy thông tin admin đang đăng nhập trong phiên
  const sessionUser = currentUser || (() => {
    try {
      const local = localStorage.getItem('cointap_admin_session');
      if (local) return JSON.parse(local);
      const session = sessionStorage.getItem('cointap_admin_session');
      if (session) return JSON.parse(session);
    } catch (e) {
      return null;
    }
    return null;
  })();

  // Kiểm tra quyền Super Admin
  const isCurrentSuperAdmin = 
    sessionUser?.role === 'Super Admin' || 
    sessionUser?.username === 'admin' || 
    sessionUser?.id === 1;

  // Modal Thêm Admin
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    full_name: '',
    role: 'Administrator',
    email: ''
  });
  const [saving, setSaving] = useState(false);

  // Modal Khôi Phục Mật Khẩu & Vai Trò (Reset Password & Role)
  const [resetModalOpen, setResetModalOpen] = useState(false);
  const [resetTargetAdmin, setResetTargetAdmin] = useState(null);
  const [editFullName, setEditFullName] = useState('');
  const [editEmail, setEditEmail] = useState('');
  const [editRole, setEditRole] = useState('Administrator');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPasswordText, setShowPasswordText] = useState(false);
  const [resetting, setResetting] = useState(false);

  // Modal Xác Nhận Xoá Admin
  const [deleteTargetAdmin, setDeleteTargetAdmin] = useState(null);
  const [isDeletingAdmin, setIsDeletingAdmin] = useState(false);

  useEffect(() => {
    loadAdmins();
  }, []);

  const loadAdmins = async () => {
    setLoading(true);
    const res = await ApiService.getAdmins();
    if (res.tableMissing) {
      setTableMissing(true);
    } else {
      setTableMissing(false);
    }
    setAdmins(res.admins || []);
    setLoading(false);
  };

  const sqlCode = `-- Chạy lệnh này trên Supabase SQL Editor nếu chưa tạo bảng admins:
CREATE TABLE IF NOT EXISTS admins (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) DEFAULT 'Administrator',
    email VARCHAR(150),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO admins (username, password_hash, full_name, role, email)
VALUES ('admin', 'admin', 'Quản Trị Viên Gốc', 'Super Admin', 'admin@cointap.vn')
ON CONFLICT (username) DO NOTHING;

ALTER TABLE admins DISABLE ROW LEVEL SECURITY;`;

  const handleCopySql = () => {
    navigator.clipboard.writeText(sqlCode);
    setCopied(true);
    showToast('Đã sao chép lệnh SQL tạo bảng admins!', 'info');
    setTimeout(() => setCopied(false), 2500);
  };

  const handleOpenAddModal = () => {
    if (!isCurrentSuperAdmin) {
      showToast('Chỉ Super Admin mới có quyền thêm tài khoản quản trị viên mới!', 'error');
      return;
    }
    setFormData({
      username: '',
      password: '',
      full_name: '',
      role: 'Administrator',
      email: ''
    });
    setIsModalOpen(true);
  };

  const handleSaveAdmin = async (e) => {
    e.preventDefault();
    if (!isCurrentSuperAdmin) {
      showToast('Chỉ Super Admin mới có quyền tạo tài khoản quản trị viên!', 'error');
      return;
    }
    if (!formData.username.trim() || !formData.password.trim() || !formData.full_name.trim()) {
      showToast('Vui lòng điền đầy đủ Tên đăng nhập, Mật khẩu và Họ tên!', 'error');
      return;
    }

    setSaving(true);
    try {
      await ApiService.createAdmin(formData);
      showToast(`Đã tạo thành công quản trị viên "${formData.username}"`, 'success');
      setIsModalOpen(false);
      loadAdmins();
    } catch (err) {
      showToast('Lỗi khi tạo quản trị viên: ' + (err.message || 'Không xác định'), 'error');
    } finally {
      setSaving(false);
    }
  };

  // Mở modal khôi phục mật khẩu & sửa vai trò
  const handleOpenResetModal = (admin) => {
    const isSelf = (sessionUser?.id && sessionUser.id === admin.id) || 
                   (sessionUser?.username && sessionUser.username === admin.username);

    // Chỉ có Super Admin mới đổi thông tin cho admin khác
    if (!isCurrentSuperAdmin && !isSelf) {
      showToast('Chỉ Super Admin mới có quyền chỉnh sửa quản trị viên khác!', 'error');
      return;
    }

    setResetTargetAdmin(admin);
    setEditFullName(admin.full_name || '');
    setEditEmail(admin.email || '');
    setEditRole(admin.role || 'Super Admin');
    setNewPassword('');
    setConfirmPassword('');
    setShowPasswordText(false);
    setResetModalOpen(true);
  };

  // Lưu thông tin quản trị viên: Họ tên, Vai trò và Mật khẩu
  const handleSaveResetPassword = async (e) => {
    e.preventDefault();
    const isSelf = (sessionUser?.id && sessionUser.id === resetTargetAdmin.id) || 
                   (sessionUser?.username && sessionUser.username === resetTargetAdmin.username);

    // Kiểm tra quyền thực hiện
    if (!isCurrentSuperAdmin && !isSelf) {
      showToast('Chỉ Super Admin mới có quyền chỉnh sửa quản trị viên khác!', 'error');
      return;
    }

    if (!editFullName.trim()) {
      showToast('Họ và Tên quản trị viên không được để trống!', 'error');
      return;
    }

    const cleanPass = newPassword.trim();
    const isRoot = resetTargetAdmin.username === 'admin' || resetTargetAdmin.id === 1;
    
    // Chỉ Super Admin mới được quyền thay đổi vai trò; admin thường chỉ được đổi mật khẩu/họ tên cho chính mình
    const finalRole = isCurrentSuperAdmin 
      ? (isRoot ? 'Super Admin' : editRole)
      : resetTargetAdmin.role;

    if (cleanPass) {
      if (cleanPass.length < 4) {
        showToast('Mật khẩu mới phải có độ dài ít nhất 4 ký tự!', 'error');
        return;
      }
      if (cleanPass !== confirmPassword.trim()) {
        showToast('Xác nhận mật khẩu mới không trùng khớp!', 'error');
        return;
      }
    }

    setResetting(true);
    try {
      await ApiService.resetAdminPassword(
        resetTargetAdmin.id, 
        cleanPass || null, 
        finalRole, 
        editFullName.trim(), 
        editEmail.trim()
      );
      
      // Đồng bộ thông tin phiên làm việc nếu sửa chính mình
      try {
        ['cointap_admin_session'].forEach(key => {
          const raw = localStorage.getItem(key) || sessionStorage.getItem(key);
          if (raw) {
            const parsed = JSON.parse(raw);
            if (parsed.id === resetTargetAdmin.id || parsed.username === resetTargetAdmin.username) {
              parsed.full_name = editFullName.trim();
              parsed.name = editFullName.trim();
              if (editEmail.trim()) parsed.email = editEmail.trim();
              if (finalRole) parsed.role = finalRole;
              if (localStorage.getItem(key)) localStorage.setItem(key, JSON.stringify(parsed));
              if (sessionStorage.getItem(key)) sessionStorage.setItem(key, JSON.stringify(parsed));
            }
          }
        });
        window.dispatchEvent(new Event('cointap_user_updated'));
        window.dispatchEvent(new Event('storage'));
      } catch (errSession) {
        console.warn('Lỗi đồng bộ session:', errSession);
      }

      showToast(`Đã cập nhật thông tin cho "${editFullName.trim()}" thành công!`, 'success');

      setResetModalOpen(false);
      setResetTargetAdmin(null);
      loadAdmins();
    } catch (err) {
      showToast('Lỗi khi cập nhật: ' + (err.message || 'Không xác định'), 'error');
    } finally {
      setResetting(false);
    }
  };

  // Mở popup xác nhận xoá admin
  const handleRequestDeleteAdmin = (admin) => {
    if (!isCurrentSuperAdmin) {
      showToast('Chỉ Super Admin mới có quyền xoá tài khoản quản trị viên!', 'error');
      return;
    }
    if (admin.username === 'admin' || admin.id === 1) {
      showToast('Không được phép xoá tài khoản Quản trị viên gốc!', 'error');
      return;
    }
    setDeleteTargetAdmin(admin);
  };

  // Thực hiện xoá admin
  const handleConfirmDeleteAdmin = async () => {
    if (!deleteTargetAdmin) return;
    setIsDeletingAdmin(true);
    try {
      await ApiService.deleteAdmin(deleteTargetAdmin.id);
      showToast(`Đã xoá quản trị viên "${deleteTargetAdmin.username}" thành công`, 'success');
      setDeleteTargetAdmin(null);
      loadAdmins();
    } catch (err) {
      showToast('Lỗi khi xoá quản trị viên: ' + err.message, 'error');
    } finally {
      setIsDeletingAdmin(false);
    }
  };

  const filteredAdmins = admins.filter(a => 
    (a.username || '').toLowerCase().includes(search.toLowerCase().trim()) ||
    (a.full_name || '').toLowerCase().includes(search.toLowerCase().trim()) ||
    (a.email || '').toLowerCase().includes(search.toLowerCase().trim())
  );

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title">
          <ShieldCheck size={20} color="var(--primary)" />
          <h3>Danh Sách Quản Trị Viên Hệ Thống</h3>
        </div>

        <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
          <div className="search-box">
            <Search size={16} />
            <input 
              type="text" 
              placeholder="Tìm theo tên đăng nhập, họ tên..." 
              value={search} 
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          <button className="btn btn-primary" onClick={handleOpenAddModal}>
            <UserPlus size={16} />
            <span>Thêm Quản Trị Viên</span>
          </button>
        </div>
      </div>

      {tableMissing && (
        <div style={{ 
          background: '#FFFBEB', 
          border: '1.5px dashed #F59E0B', 
          padding: '16px 20px', 
          borderRadius: 14, 
          marginBottom: 24,
          display: 'flex',
          flexDirection: 'column',
          gap: 10
        }}>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 10 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
              <AlertTriangle size={20} color="#D97706" />
              <strong style={{ color: '#B45309', fontSize: 14 }}>
                Bảng 'admins' chưa có trên Supabase (Đang lưu tạm LocalStorage)
              </strong>
            </div>
            <button 
              onClick={handleCopySql} 
              className="btn btn-secondary btn-sm"
              style={{ background: '#FEF3C7', color: '#92400E', borderColor: '#FDE68A' }}
            >
              {copied ? <Check size={14} /> : <Copy size={14} />}
              <span>{copied ? 'Đã chép SQL' : 'Sao chép SQL tạo bảng'}</span>
            </button>
          </div>
          <p style={{ margin: 0, fontSize: 13, color: '#92400E', lineHeight: 1.5 }}>
            Để dữ liệu quản trị viên được lưu trữ vĩnh viễn trên Supabase, bạn hãy mở <strong>Supabase Dashboard → SQL Editor</strong> và dán đoạn mã SQL trên vào để chạy.
          </p>
        </div>
      )}

      <div className="table-responsive">
        <table className="modern-table">
          <thead>
            <tr>
              <th>Quản trị viên</th>
              <th>Tên đăng nhập</th>
              <th>Vai trò</th>
              <th>Email liên hệ</th>
              <th>Ngày tạo</th>
              <th style={{ textAlign: 'center' }}>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-light)' }}>
                  Đang tải danh sách quản trị viên...
                </td>
              </tr>
            ) : filteredAdmins.length === 0 ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-light)' }}>
                  Không tìm thấy quản trị viên nào
                </td>
              </tr>
            ) : (
              filteredAdmins.map(admin => {
                const isRoot = admin.username === 'admin' || admin.id === 1;
                const isSelf = (sessionUser?.id && sessionUser.id === admin.id) || 
                               (sessionUser?.username && sessionUser.username === admin.username);
                const canResetPassword = isCurrentSuperAdmin || isSelf;

                return (
                  <tr key={admin.id || admin.username}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        <div className="admin-avatar" style={{ 
                          width: 38, 
                          height: 38, 
                          fontSize: 14,
                          background: isRoot ? 'var(--primary)' : 'var(--secondary)'
                        }}>
                          {(admin.full_name || 'A')[0].toUpperCase()}
                        </div>
                        <div>
                          <div style={{ fontWeight: 700, color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: 6 }}>
                            <span>{admin.full_name}</span>
                            {isRoot && (
                              <span style={{ 
                                fontSize: 10, 
                                fontWeight: 700, 
                                background: 'var(--primary-light)', 
                                color: 'var(--primary)', 
                                padding: '2px 6px', 
                                borderRadius: 4 
                              }}>
                                Gốc
                              </span>
                            )}
                            {isSelf && (
                              <span style={{ 
                                fontSize: 10, 
                                fontWeight: 700, 
                                background: '#ECFDF5', 
                                color: '#059669', 
                                padding: '2px 6px', 
                                borderRadius: 4,
                                border: '1px solid #A7F3D0'
                              }}>
                                Bạn
                              </span>
                            )}
                          </div>
                        </div>
                      </div>
                    </td>
                    <td>
                      <code style={{ 
                        background: 'var(--primary-light)', 
                        color: 'var(--primary)', 
                        padding: '3px 8px', 
                        borderRadius: 6,
                        fontWeight: 700,
                        fontSize: 13
                      }}>
                        {admin.username}
                      </code>
                    </td>
                    <td>
                      <span className={`badge ${admin.role === 'Super Admin' ? 'badge-primary' : 'badge-active'}`} style={{
                        background: admin.role === 'Super Admin' ? '#EDE9FE' : '#EFF6FF',
                        color: admin.role === 'Super Admin' ? '#6D28D9' : '#1D4ED8',
                        border: `1px solid ${admin.role === 'Super Admin' ? '#DDD6FE' : '#DBEAFE'}`,
                        fontWeight: 700
                      }}>
                        {admin.role}
                      </span>
                    </td>
                    <td style={{ fontSize: 13, color: 'var(--text-muted)' }}>
                      {admin.email || `${admin.username}@cointap.vn`}
                    </td>
                    <td style={{ fontSize: 13, color: 'var(--text-muted)' }}>
                      {formatDateTime(admin.created_at)}
                    </td>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
                        {/* Nút Khôi Phục / Reset Mật Khẩu: Chỉ Super Admin mới đổi cho người khác */}
                        <button 
                          className="action-btn" 
                          title={
                            canResetPassword 
                              ? (isSelf ? "Đổi mật khẩu tài khoản của bạn" : `Khôi phục mật khẩu & vai trò cho ${admin.username}`)
                              : "Chỉ Super Admin mới có quyền đổi mật khẩu cho quản trị viên khác"
                          }
                          onClick={() => {
                            if (!canResetPassword) {
                              showToast('Chỉ Super Admin mới có quyền đổi mật khẩu cho quản trị viên khác!', 'error');
                              return;
                            }
                            handleOpenResetModal(admin);
                          }}
                          style={{ 
                            color: canResetPassword ? 'var(--primary)' : 'var(--text-light)',
                            opacity: canResetPassword ? 1 : 0.35,
                            cursor: canResetPassword ? 'pointer' : 'not-allowed'
                          }}
                        >
                          <KeyRound size={15} />
                        </button>

                        {/* Nút Xoá quản trị viên: Chỉ Super Admin mới được xoá admin khác, không xoá admin gốc */}
                        {!isRoot ? (
                          isCurrentSuperAdmin ? (
                            <button 
                              className="action-btn delete" 
                              title={`Xoá quản trị viên ${admin.username}`}
                              onClick={() => handleRequestDeleteAdmin(admin)}
                            >
                              <Trash2 size={15} />
                            </button>
                          ) : (
                            <button 
                              className="action-btn" 
                              disabled
                              title="Chỉ Super Admin mới có quyền xoá quản trị viên"
                              style={{ opacity: 0.35, cursor: 'not-allowed', color: 'var(--text-light)' }}
                            >
                              <Trash2 size={15} />
                            </button>
                          )
                        ) : (
                          <span style={{ fontSize: 11.5, color: 'var(--text-light)', fontStyle: 'italic', minWidth: 34, textAlign: 'center' }} title="Quản trị viên gốc không thể xoá">
                            (Cố định)
                          </span>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Modal 1: Thêm Quản Trị Viên Mới */}
      <Modal isOpen={isModalOpen} title="Thêm Quản Trị Viên Mới" onClose={() => setIsModalOpen(false)}>
        <form onSubmit={handleSaveAdmin} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>Tên Đăng Nhập (*)</label>
            <div className="input-icon-wrap">
              <User className="input-icon" size={17} />
              <input
                type="text"
                className="form-control with-icon"
                placeholder="VD: namlenhat, quantrivien2..."
                value={formData.username}
                onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>Mật Khẩu (*)</label>
            <div className="input-icon-wrap">
              <Lock className="input-icon" size={17} />
              <input
                type="password"
                className="form-control with-icon"
                placeholder="Nhập mật khẩu cho quản trị viên"
                value={formData.password}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                required
              />
            </div>
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>Họ và Tên (*)</label>
            <input
              type="text"
              className="form-control"
              placeholder="VD: Lê Nhật Nam"
              value={formData.full_name}
              onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
              required
            />
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>Vai Trò</label>
            <select
              className="form-control"
              value={formData.role}
              onChange={(e) => setFormData({ ...formData, role: e.target.value })}
            >
              <option value="Administrator">Administrator (Quản trị viên tiêu chuẩn)</option>
              <option value="Super Admin">Super Admin (Quản trị viên cấp cao nhất)</option>
            </select>
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>Email Liên Hệ</label>
            <div className="input-icon-wrap">
              <Mail className="input-icon" size={17} />
              <input
                type="email"
                className="form-control with-icon"
                placeholder="admin@gmail.com"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              />
            </div>
          </div>

          <div style={{ marginTop: 8, paddingTop: 14, borderTop: '1px solid var(--border-color)', display: 'flex', justifyContent: 'flex-end', gap: 10 }}>
            <button 
              type="button" 
              className="btn btn-secondary btn-sm" 
              onClick={() => setIsModalOpen(false)}
            >
              Huỷ bỏ
            </button>
            <button 
              type="submit" 
              className="btn btn-primary btn-sm" 
              disabled={saving}
            >
              <UserPlus size={15} />
              <span>{saving ? 'Đang lưu...' : 'Xác Nhận Tạo Quản Trị Viên'}</span>
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal 2: Khôi Phục Mật Khẩu & Phân Quyền Vai Trò */}
      <Modal 
        isOpen={resetModalOpen} 
        title={`Chỉnh Sửa Quản Trị Viên: ${resetTargetAdmin?.full_name || ''}`} 
        onClose={() => setResetModalOpen(false)}
      >
        {resetTargetAdmin && (
          <form onSubmit={handleSaveResetPassword} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Thông tin quản trị viên */}
            <div style={{ 
              background: '#F8FAFC', 
              borderRadius: 12, 
              padding: '14px 16px', 
              border: '1px solid var(--border-color)',
              display: 'flex',
              alignItems: 'center',
              gap: 12
            }}>
              <div 
                className="admin-avatar" 
                style={{ 
                  width: 42, 
                  height: 42, 
                  background: resetTargetAdmin.username === 'admin' ? 'var(--primary)' : 'var(--secondary)',
                  color: '#fff',
                  fontWeight: 800,
                  fontSize: 16
                }}
              >
                {(resetTargetAdmin.full_name || 'A')[0].toUpperCase()}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 800, color: 'var(--text-main)', fontSize: 14.5, display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span>{resetTargetAdmin.full_name}</span>
                  <span className={`badge ${resetTargetAdmin.role === 'Super Admin' ? 'badge-primary' : 'badge-active'}`} style={{
                    fontSize: 11,
                    fontWeight: 700,
                    padding: '1px 7px'
                  }}>
                    {resetTargetAdmin.role}
                  </span>
                </div>
                <div style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>
                  Tên đăng nhập: <strong style={{ color: 'var(--primary)' }}>{resetTargetAdmin.username}</strong>
                  {resetTargetAdmin.email ? ` • ${resetTargetAdmin.email}` : ''}
                </div>
              </div>
            </div>

            {/* Trường sửa Họ và Tên */}
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                Họ và Tên (*)
              </label>
              <div className="input-icon-wrap">
                <User className="input-icon" size={17} />
                <input
                  type="text"
                  className="form-control with-icon"
                  placeholder="Nhập họ và tên quản trị viên..."
                  value={editFullName}
                  onChange={(e) => setEditFullName(e.target.value)}
                  required
                />
              </div>
            </div>

            {/* Trường sửa Email Liên Hệ */}
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                Email Liên Hệ
              </label>
              <div className="input-icon-wrap">
                <Mail className="input-icon" size={17} />
                <input
                  type="email"
                  className="form-control with-icon"
                  placeholder="admin@cointap.vn"
                  value={editEmail}
                  onChange={(e) => setEditEmail(e.target.value)}
                />
              </div>
            </div>

            {/* Trường sửa Vai Trò */}
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                Vai Trò Quản Trị (*)
              </label>
              {resetTargetAdmin.username === 'admin' || resetTargetAdmin.id === 1 ? (
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                  padding: '9px 12px',
                  background: '#F1F5F9',
                  borderRadius: 8,
                  border: '1px solid var(--border-color)',
                  color: 'var(--text-main)'
                }}>
                  <ShieldCheck size={16} color="var(--primary)" />
                  <span style={{ fontWeight: 700, fontSize: 13 }}>Super Admin</span>
                  <span style={{ fontSize: 11.5, color: 'var(--text-muted)', fontStyle: 'italic', marginLeft: 'auto' }}>
                    (Cố định cho tài khoản gốc)
                  </span>
                </div>
              ) : !isCurrentSuperAdmin ? (
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 8,
                  padding: '9px 12px',
                  background: '#F1F5F9',
                  borderRadius: 8,
                  border: '1px solid var(--border-color)',
                  color: 'var(--text-main)'
                }}>
                  <ShieldCheck size={16} color="var(--primary)" />
                  <span style={{ fontWeight: 700, fontSize: 13 }}>{resetTargetAdmin.role}</span>
                  <span style={{ fontSize: 11.5, color: 'var(--text-muted)', fontStyle: 'italic', marginLeft: 'auto' }}>
                    (Chỉ Super Admin mới có quyền đổi vai trò)
                  </span>
                </div>
              ) : (
                <select
                  className="form-control"
                  value={editRole}
                  onChange={(e) => setEditRole(e.target.value)}
                  required
                >
                  <option value="Super Admin">Super Admin (Quản trị viên cấp cao nhất)</option>
                  <option value="Administrator">Administrator (Quản trị viên tiêu chuẩn)</option>
                </select>
              )}
            </div>

            {/* Mật khẩu mới */}
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                Mật Khẩu Mới <span style={{ fontWeight: 400, fontSize: 12, color: 'var(--text-muted)' }}>(Để trống nếu không muốn đổi mật khẩu)</span>
              </label>
              <div className="input-icon-wrap" style={{ position: 'relative' }}>
                <Lock className="input-icon" size={17} />
                <input
                  type={showPasswordText ? "text" : "password"}
                  className="form-control with-icon"
                  placeholder="Nhập mật khẩu mới (tối thiểu 4 ký tự)..."
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  autoFocus
                />
                <button
                  type="button"
                  onClick={() => setShowPasswordText(!showPasswordText)}
                  style={{
                    position: 'absolute',
                    right: 12,
                    top: '50%',
                    transform: 'translateY(-50%)',
                    background: 'transparent',
                    border: 'none',
                    color: 'var(--text-light)',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center'
                  }}
                  tabIndex="-1"
                >
                  {showPasswordText ? <EyeOff size={17} /> : <Eye size={17} />}
                </button>
              </div>
            </div>

            {/* Xác nhận mật khẩu mới (chỉ hiện khi có nhập mật khẩu mới) */}
            {newPassword.trim().length > 0 && (
              <div className="form-group" style={{ marginBottom: 0 }}>
                <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                  Xác Nhận Mật Khẩu Mới (*)
                </label>
                <div className="input-icon-wrap">
                  <Lock className="input-icon" size={17} />
                  <input
                    type={showPasswordText ? "text" : "password"}
                    className="form-control with-icon"
                    placeholder="Nhập lại mật khẩu mới để xác nhận..."
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                  />
                </div>
              </div>
            )}

            {/* Lưu ý bảo mật */}
            <div style={{ 
              background: '#FFFBEB', 
              border: '1px solid #FEF3C7', 
              borderRadius: 10, 
              padding: '10px 12px', 
              fontSize: 12, 
              color: '#B45309',
              display: 'flex',
              alignItems: 'center',
              gap: 8
            }}>
              <AlertTriangle size={16} style={{ flexShrink: 0 }} />
              <span>Thay đổi họ tên, vai trò và mật khẩu sẽ được áp dụng ngay lập tức trên toàn hệ thống.</span>
            </div>

            {/* Modal Actions */}
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 6, paddingTop: 14, borderTop: '1px solid var(--border-color)' }}>
              <button 
                type="button" 
                className="btn btn-secondary btn-sm" 
                onClick={() => setResetModalOpen(false)}
              >
                Huỷ bỏ
              </button>
              <button 
                type="submit" 
                className="btn btn-primary btn-sm" 
                disabled={resetting}
              >
                <KeyRound size={15} />
                <span>{resetting ? 'Đang lưu...' : 'Lưu Thay Đổi'}</span>
              </button>
            </div>
          </form>
        )}
      </Modal>

      {/* Modal 3: Popup Xác Nhận Xoá Quản Trị Viên */}
      <ConfirmModal
        isOpen={!!deleteTargetAdmin}
        title="Xác Nhận Xoá Quản Trị Viên"
        message="Bạn có chắc chắn muốn xoá tài khoản quản trị viên này khỏi hệ thống không? Dữ liệu sau khi xoá sẽ không thể khôi phục."
        itemDetail={
          deleteTargetAdmin && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
              <div><strong>Họ và tên:</strong> {deleteTargetAdmin.full_name}</div>
              <div><strong>Tên đăng nhập:</strong> {deleteTargetAdmin.username}</div>
              <div><strong>Vai trò:</strong> {deleteTargetAdmin.role}</div>
              <div><strong>Email:</strong> {deleteTargetAdmin.email}</div>
            </div>
          )
        }
        confirmText="Xác nhận xoá"
        cancelText="Huỷ bỏ"
        isDanger={true}
        isLoading={isDeletingAdmin}
        onConfirm={handleConfirmDeleteAdmin}
        onClose={() => setDeleteTargetAdmin(null)}
      />
    </div>
  );
}
