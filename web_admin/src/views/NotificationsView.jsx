import React, { useState, useEffect } from 'react';
import { 
  Bell, 
  BellRing, 
  Plus, 
  Search, 
  Trash2, 
  Eye, 
  Send, 
  Users, 
  User, 
  Layers, 
  Info, 
  AlertTriangle, 
  Sparkles, 
  CheckCircle2, 
  Clock, 
  Check,
  ShieldCheck,
  Smartphone
} from 'lucide-react';
import Modal from '../components/Modal';
import ConfirmModal from '../components/ConfirmModal';
import { ApiService } from '../services/api';

export default function NotificationsView({ showToast }) {
  const [notifications, setNotifications] = useState([]);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [typeFilter, setTypeFilter] = useState('ALL');

  // Modal State
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [viewingNotification, setViewingNotification] = useState(null);
  const [deletingNotification, setDeletingNotification] = useState(null);
  const [isDeleting, setIsDeleting] = useState(false);

  // Form State
  const [targetMode, setTargetMode] = useState('ALL'); // 'ALL' or 'SPECIFIC'
  const [selectedUserId, setSelectedUserId] = useState('');
  const [formType, setFormType] = useState('SYSTEM');
  const [formTitle, setFormTitle] = useState('');
  const [formContent, setFormContent] = useState('');
  const [sending, setSending] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const [notifsData, usersData] = await Promise.all([
        ApiService.getNotifications(),
        ApiService.getUsers()
      ]);
      setNotifications(notifsData || []);
      setUsers(usersData || []);
      if (usersData && usersData.length > 0) {
        setSelectedUserId(usersData[0].user_id.toString());
      }
    } catch (err) {
      showToast('Lỗi nạp danh sách thông báo: ' + err.message, 'error');
    } finally {
      setLoading(false);
    }
  };

  // Helper render badges cho từng loại thông báo
  const getTypeBadge = (type) => {
    switch (type) {
      case 'SYSTEM':
        return {
          label: 'Hệ thống',
          icon: Info,
          bg: '#eff6ff',
          color: '#2563eb',
          border: '#bfdbfe'
        };
      case 'WARNING':
        return {
          label: 'Cảnh báo',
          icon: AlertTriangle,
          bg: '#fff7ed',
          color: '#c2410c',
          border: '#ffedd5'
        };
      case 'PROMOTION':
        return {
          label: 'Khuyến mãi',
          icon: Sparkles,
          bg: '#faf5ff',
          color: '#7e22ce',
          border: '#f3e8ff'
        };
      case 'BUDGET_ALERT':
        return {
          label: 'Ngân sách',
          icon: BellRing,
          bg: '#fef2f2',
          color: '#dc2626',
          border: '#fecaca'
        };
      default:
        return {
          label: type || 'Khác',
          icon: Bell,
          bg: '#f1f5f9',
          color: '#475569',
          border: '#e2e8f0'
        };
    }
  };

  // Format Date
  const formatDateTime = (isoString) => {
    if (!isoString) return '--';
    try {
      const d = new Date(isoString);
      return d.toLocaleString('vi-VN', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch (e) {
      return isoString;
    }
  };

  // Mở popup xác nhận xoá thông báo
  const handleRequestDelete = (notif) => {
    setDeletingNotification(notif);
  };

  // Thực hiện xoá khi người dùng bấm Xác nhận trong popup
  const handleConfirmDelete = async () => {
    if (!deletingNotification) return;
    const id = deletingNotification.notification_id;
    setIsDeleting(true);
    try {
      await ApiService.deleteNotification(id);
      setNotifications(prev => prev.filter(n => n.notification_id !== id));
      if (viewingNotification && viewingNotification.notification_id === id) {
        setViewingNotification(null);
      }
      showToast(`Đã xoá thành công thông báo #${id}`, 'success');
      setDeletingNotification(null);
    } catch (err) {
      showToast('Lỗi xoá thông báo: ' + err.message, 'error');
    } finally {
      setIsDeleting(false);
    }
  };

  // Open Add Modal
  const handleOpenAddModal = () => {
    setFormTitle('');
    setFormContent('');
    setFormType('SYSTEM');
    setTargetMode('ALL');
    if (users.length > 0) {
      setSelectedUserId(users[0].user_id.toString());
    }
    setIsAddModalOpen(true);
  };

  // Submit Create Notification
  const handleSendNotification = async (e) => {
    e.preventDefault();
    if (!formTitle.trim() || !formContent.trim()) {
      showToast('Vui lòng nhập đầy đủ tiêu đề và nội dung', 'error');
      return;
    }

    if (targetMode === 'SPECIFIC' && !selectedUserId) {
      showToast('Vui lòng chọn người dùng nhận thông báo', 'error');
      return;
    }

    setSending(true);
    try {
      await ApiService.sendSystemNotification({
        title: formTitle.trim(),
        content: formContent.trim(),
        type: formType,
        userId: targetMode === 'SPECIFIC' ? selectedUserId : null
      });

      showToast(
        targetMode === 'SPECIFIC' 
          ? 'Đã gửi thông báo thành công tới người dùng được chọn!'
          : 'Đã phát thông báo thành công tới toàn bộ người dùng hệ thống!'
      );
      setIsAddModalOpen(false);
      // Tải lại danh sách
      await loadData();
    } catch (err) {
      showToast('Lỗi gửi thông báo: ' + err.message, 'error');
    } finally {
      setSending(false);
    }
  };

  // Filters logic
  const filteredNotifications = notifications.filter(n => {
    // 1. Lọc theo Loại
    if (typeFilter !== 'ALL' && n.type !== typeFilter) {
      return false;
    }

    // 2. Tìm kiếm theo SearchQuery
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      const matchTitle = n.title?.toLowerCase().includes(q);
      const matchContent = n.content?.toLowerCase().includes(q);
      const matchUserName = n.users?.full_name?.toLowerCase().includes(q);
      const matchUserEmail = n.users?.email?.toLowerCase().includes(q);
      const matchId = n.notification_id?.toString().includes(q);
      return matchTitle || matchContent || matchUserName || matchUserEmail || matchId;
    }

    return true;
  });

  // Đếm số lượng theo loại
  const countAll = notifications.length;
  const countSystem = notifications.filter(n => n.type === 'SYSTEM').length;
  const countWarning = notifications.filter(n => n.type === 'WARNING').length;
  const countPromotion = notifications.filter(n => n.type === 'PROMOTION').length;
  const countBudget = notifications.filter(n => n.type === 'BUDGET_ALERT').length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
      {/* Top Header Card */}
      <div className="card" style={{ padding: '20px 24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 16 }}>
          <div>
            <h2 style={{ fontSize: 20, fontWeight: 800, color: 'var(--text-main)', marginBottom: 4, display: 'flex', alignItems: 'center', gap: 10 }}>
              <BellRing size={22} color="var(--primary)" />
              Quản Lý Thông Báo Hệ Thống
            </h2>
            <p style={{ fontSize: 13.5, color: 'var(--text-muted)', margin: 0 }}>
              Giám sát toàn bộ thông báo đã gửi, lịch sử nhận tin và phát thông báo mới tới người dùng di động
            </p>
          </div>

          <div style={{ display: 'flex', gap: 12, alignItems: 'center', flexWrap: 'wrap' }}>
            <div className="search-box" style={{ width: 290 }}>
              <Search size={16} />
              <input
                type="text"
                placeholder="Tìm tiêu đề, nội dung, người nhận..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
            </div>

            <button className="btn btn-primary" onClick={handleOpenAddModal}>
              <Plus size={16} />
              <span>Thêm Thông Báo Mới</span>
            </button>
          </div>
        </div>

        {/* Segmented Filter Bar */}
        <div className="segmented-filter-bar" style={{ marginTop: 20 }}>
          <button
            className={`segmented-tab ${typeFilter === 'ALL' ? 'active' : ''}`}
            onClick={() => setTypeFilter('ALL')}
          >
            <Layers size={15} />
            <span>Tất cả</span>
            <span className="segmented-count">{countAll}</span>
          </button>
          <button
            className={`segmented-tab ${typeFilter === 'SYSTEM' ? 'active' : ''}`}
            onClick={() => setTypeFilter('SYSTEM')}
          >
            <Info size={15} />
            <span>Hệ thống (SYSTEM)</span>
            <span className="segmented-count">{countSystem}</span>
          </button>
          <button
            className={`segmented-tab ${typeFilter === 'WARNING' ? 'active' : ''}`}
            onClick={() => setTypeFilter('WARNING')}
          >
            <AlertTriangle size={15} />
            <span>Cảnh báo (WARNING)</span>
            <span className="segmented-count">{countWarning}</span>
          </button>
          <button
            className={`segmented-tab ${typeFilter === 'PROMOTION' ? 'active' : ''}`}
            onClick={() => setTypeFilter('PROMOTION')}
          >
            <Sparkles size={15} />
            <span>Khuyến mãi & Mẹo</span>
            <span className="segmented-count">{countPromotion}</span>
          </button>
          <button
            className={`segmented-tab ${typeFilter === 'BUDGET_ALERT' ? 'active' : ''}`}
            onClick={() => setTypeFilter('BUDGET_ALERT')}
          >
            <BellRing size={15} />
            <span>Cảnh báo ngân sách</span>
            <span className="segmented-count">{countBudget}</span>
          </button>
        </div>
      </div>

      {/* Table Card */}
      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <div className="table-responsive">
          <table className="modern-table">
            <thead>
              <tr>
                <th style={{ width: 70, textAlign: 'center' }}>ID</th>
                <th style={{ width: 140 }}>Loại</th>
                <th>Tiêu đề & Nội dung</th>
                <th style={{ width: 200 }}>Người nhận</th>
                <th style={{ width: 120 }}>Trạng thái</th>
                <th style={{ width: 150 }}>Thời gian gửi</th>
                <th style={{ width: 110, textAlign: 'center' }}>Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="7" style={{ textAlign: 'center', padding: '40px 20px', color: 'var(--text-light)' }}>
                    Đang tải danh sách thông báo từ hệ thống...
                  </td>
                </tr>
              ) : filteredNotifications.length === 0 ? (
                <tr>
                  <td colSpan="7" style={{ textAlign: 'center', padding: '50px 20px', color: 'var(--text-light)' }}>
                    <Bell size={40} style={{ opacity: 0.3, marginBottom: 12 }} />
                    <p style={{ fontSize: 15, fontWeight: 700, margin: 0, color: 'var(--text-muted)' }}>
                      Không tìm thấy thông báo nào
                    </p>
                    <p style={{ fontSize: 13, margin: '4px 0 0 0' }}>
                      {searchQuery ? 'Thử thay đổi từ khoá tìm kiếm hoặc chuyển bộ lọc' : 'Nhấn nút "+ Thêm Thông Báo Mới" để phát thông báo đầu tiên'}
                    </p>
                  </td>
                </tr>
              ) : (
                filteredNotifications.map((n) => {
                  const badge = getTypeBadge(n.type);
                  const BadgeIcon = badge.icon;
                  const userName = n.users?.full_name || `Người dùng #${n.user_id}`;
                  const userEmail = n.users?.email || '';

                  return (
                    <tr key={n.notification_id}>
                      <td style={{ textAlign: 'center', fontWeight: 700, color: 'var(--text-muted)', fontSize: 12 }}>
                        #{n.notification_id}
                      </td>
                      <td>
                        <span 
                          className="badge-notify-type" 
                          style={{ 
                            background: badge.bg, 
                            color: badge.color, 
                            borderColor: badge.border 
                          }}
                        >
                          <BadgeIcon size={13} />
                          {badge.label}
                        </span>
                      </td>
                      <td style={{ maxWidth: 320 }}>
                        <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 14, marginBottom: 2 }}>
                          {n.title}
                        </div>
                        <div 
                          style={{ 
                            fontSize: 12.5, 
                            color: 'var(--text-muted)',
                            whiteSpace: 'nowrap',
                            overflow: 'hidden',
                            textOverflow: 'ellipsis'
                          }}
                          title={n.content}
                        >
                          {n.content}
                        </div>
                      </td>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                          <div 
                            style={{ 
                              width: 28, 
                              height: 28, 
                              borderRadius: '50%', 
                              background: 'var(--primary-light)', 
                              color: 'var(--primary)',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              fontWeight: 700,
                              fontSize: 12,
                              flexShrink: 0
                            }}
                          >
                            {userName.charAt(0).toUpperCase()}
                          </div>
                          <div style={{ overflow: 'hidden' }}>
                            <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 13, textOverflow: 'ellipsis', overflow: 'hidden', whiteSpace: 'nowrap' }}>
                              {userName}
                            </div>
                            {userEmail && (
                              <div style={{ fontSize: 11.5, color: 'var(--text-muted)', textOverflow: 'ellipsis', overflow: 'hidden', whiteSpace: 'nowrap' }}>
                                {userEmail}
                              </div>
                            )}
                          </div>
                        </div>
                      </td>
                      <td>
                        {n.is_read ? (
                          <span className="badge-read-status read">
                            <Check size={12} /> Đã xem
                          </span>
                        ) : (
                          <span className="badge-read-status unread">
                            <Clock size={12} /> Chưa xem
                          </span>
                        )}
                      </td>
                      <td style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>
                        {formatDateTime(n.created_at)}
                      </td>
                      <td>
                        <div style={{ display: 'flex', justifyContent: 'center', gap: 6 }}>
                          <button 
                            className="action-btn" 
                            title="Xem chi tiết nội dung"
                            onClick={() => setViewingNotification(n)}
                          >
                            <Eye size={15} />
                          </button>
                          <button 
                            className="action-btn delete" 
                            title="Xoá thông báo"
                            onClick={() => handleRequestDelete(n)}
                          >
                            <Trash2 size={15} />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal 1: Thêm & Phát Thông Báo Mới */}
      <Modal
        isOpen={isAddModalOpen}
        title="Tạo & Phát Thông Báo Mới"
        onClose={() => setIsAddModalOpen(false)}
      >
        <form onSubmit={handleSendNotification} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          
          {/* Chọn đối tượng nhận */}
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ marginBottom: 8, display: 'block', fontWeight: 700, fontSize: 13.5 }}>
              Đối tượng nhận thông báo (*)
            </label>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12 }}>
              <div 
                onClick={() => setTargetMode('ALL')}
                style={{
                  padding: '12px 14px',
                  borderRadius: '10px',
                  border: targetMode === 'ALL' ? '2px solid var(--primary)' : '1px solid var(--border-color)',
                  background: targetMode === 'ALL' ? 'var(--primary-light)' : '#ffffff',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  transition: 'all 0.15s ease'
                }}
              >
                <Smartphone size={20} color={targetMode === 'ALL' ? 'var(--primary)' : 'var(--text-muted)'} />
                <div>
                  <div style={{ fontSize: 13.5, fontWeight: 700, color: targetMode === 'ALL' ? 'var(--primary)' : 'var(--text-main)' }}>
                    Toàn bộ người dùng
                  </div>
                  <div style={{ fontSize: 11.5, color: 'var(--text-muted)' }}>
                    Gửi đến {users.length} tài khoản trong hệ thống
                  </div>
                </div>
              </div>

              <div 
                onClick={() => setTargetMode('SPECIFIC')}
                style={{
                  padding: '12px 14px',
                  borderRadius: '10px',
                  border: targetMode === 'SPECIFIC' ? '2px solid var(--primary)' : '1px solid var(--border-color)',
                  background: targetMode === 'SPECIFIC' ? 'var(--primary-light)' : '#ffffff',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: 10,
                  transition: 'all 0.15s ease'
                }}
              >
                <User size={20} color={targetMode === 'SPECIFIC' ? 'var(--primary)' : 'var(--text-muted)'} />
                <div>
                  <div style={{ fontSize: 13.5, fontWeight: 700, color: targetMode === 'SPECIFIC' ? 'var(--primary)' : 'var(--text-main)' }}>
                    Gửi người dùng cụ thể
                  </div>
                  <div style={{ fontSize: 11.5, color: 'var(--text-muted)' }}>
                    Chọn 1 tài khoản đích nhận thông báo
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Chọn tài khoản cụ thể (nếu chọn SPECIFIC) */}
          {targetMode === 'SPECIFIC' && (
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
                Chọn tài khoản người dùng đích (*)
              </label>
              <select 
                className="form-control"
                value={selectedUserId}
                onChange={(e) => setSelectedUserId(e.target.value)}
                required
              >
                {users.map(u => (
                  <option key={u.user_id} value={u.user_id}>
                    {u.full_name || 'Người dùng'} - {u.email} (ID: #{u.user_id})
                  </option>
                ))}
              </select>
            </div>
          )}

          {/* Loại thông báo */}
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
              Loại thông báo (*)
            </label>
            <select
              className="form-control"
              value={formType}
              onChange={(e) => setFormType(e.target.value)}
              required
            >
              <option value="SYSTEM">Hệ thống & Cập nhật phiên bản (SYSTEM)</option>
              <option value="PROMOTION">Khuyến mãi & Lời khuyên tài chính (PROMOTION)</option>
              <option value="WARNING">Cảnh báo bảo mật & Bảo trì (WARNING)</option>
              <option value="BUDGET_ALERT">Cảnh báo chi tiêu & Ngân sách (BUDGET_ALERT)</option>
            </select>
          </div>

          {/* Tiêu đề */}
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
              Tiêu đề thông báo (*)
            </label>
            <input
              type="text"
              className="form-control"
              placeholder="VD: Cập nhật CoinTap phiên bản v1.5.0 mới..."
              value={formTitle}
              onChange={(e) => setFormTitle(e.target.value)}
              required
            />
          </div>

          {/* Nội dung */}
          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label" style={{ fontWeight: 700, fontSize: 13.5 }}>
              Nội dung chi tiết (*)
            </label>
            <textarea
              className="form-control"
              rows="4"
              placeholder="Nhập nội dung thông báo gửi đến trung tâm thông báo của ứng dụng di động..."
              value={formContent}
              onChange={(e) => setFormContent(e.target.value)}
              required
            />
          </div>

          {/* Actions */}
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 12, marginTop: 8, paddingTop: 14, borderTop: '1px solid var(--border-color)' }}>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={() => setIsAddModalOpen(false)}
            >
              Huỷ bỏ
            </button>
            <button
              type="submit"
              className="btn btn-primary"
              disabled={sending}
            >
              <Send size={16} />
              <span>{sending ? 'Đang phát thông báo...' : 'Phát Thông Báo'}</span>
            </button>
          </div>
        </form>
      </Modal>

      {/* Modal 2: Xem Chi Tiết Thông Báo */}
      <Modal
        isOpen={!!viewingNotification}
        title={`Chi tiết thông báo #${viewingNotification?.notification_id || ''}`}
        onClose={() => setViewingNotification(null)}
      >
        {viewingNotification && (() => {
          const badge = getTypeBadge(viewingNotification.type);
          const BadgeIcon = badge.icon;
          const user = viewingNotification.users;

          return (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
              {/* Status Header Bar */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: 10 }}>
                <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                  <span 
                    className="badge-notify-type" 
                    style={{ 
                      background: badge.bg, 
                      color: badge.color, 
                      borderColor: badge.border 
                    }}
                  >
                    <BadgeIcon size={13} />
                    {badge.label}
                  </span>

                  {viewingNotification.is_read ? (
                    <span className="badge-read-status read">
                      <Check size={12} /> Người dùng đã xem
                    </span>
                  ) : (
                    <span className="badge-read-status unread">
                      <Clock size={12} /> Chưa xem
                    </span>
                  )}
                </div>

                <div style={{ fontSize: 12.5, color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 4 }}>
                  <Clock size={14} />
                  <span>{formatDateTime(viewingNotification.created_at)}</span>
                </div>
              </div>

              {/* Người nhận info */}
              <div style={{ background: '#F8FAFC', padding: '12px 16px', borderRadius: 10, border: '1px solid var(--border-color)' }}>
                <div style={{ fontSize: 11.5, textTransform: 'uppercase', fontWeight: 700, color: 'var(--text-muted)', marginBottom: 6 }}>
                  Người nhận thông báo
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div 
                    style={{ 
                      width: 36, 
                      height: 36, 
                      borderRadius: '50%', 
                      background: 'var(--primary-light)', 
                      color: 'var(--primary)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontWeight: 800,
                      fontSize: 14
                    }}
                  >
                    {(user?.full_name || 'U').charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <div style={{ fontWeight: 800, color: 'var(--text-main)', fontSize: 14 }}>
                      {user?.full_name || `Người dùng #${viewingNotification.user_id}`}
                    </div>
                    <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                      {user?.email ? `${user.email} • ` : ''}User ID: #{viewingNotification.user_id}
                    </div>
                  </div>
                </div>
              </div>

              {/* Tiêu đề */}
              <div>
                <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: 'var(--text-muted)', marginBottom: 4, textTransform: 'uppercase' }}>
                  Tiêu đề thông báo
                </label>
                <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-main)' }}>
                  {viewingNotification.title}
                </div>
              </div>

              {/* Nội dung chi tiết */}
              <div>
                <label style={{ display: 'block', fontSize: 12, fontWeight: 700, color: 'var(--text-muted)', marginBottom: 6, textTransform: 'uppercase' }}>
                  Nội dung chi tiết
                </label>
                <div style={{ 
                  background: '#F8FAFC', 
                  padding: '16px', 
                  borderRadius: 10, 
                  border: '1px solid var(--border-color)',
                  fontSize: 14,
                  lineHeight: 1.6,
                  color: 'var(--text-main)',
                  whiteSpace: 'pre-wrap'
                }}>
                  {viewingNotification.content}
                </div>
              </div>

              {/* Action buttons */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: 14, borderTop: '1px solid var(--border-color)', marginTop: 6 }}>
                <button
                  type="button"
                  className="btn btn-danger btn-sm"
                  onClick={() => handleRequestDelete(viewingNotification)}
                >
                  <Trash2 size={15} />
                  <span>Xoá thông báo này</span>
                </button>

                <button
                  type="button"
                  className="btn btn-secondary btn-sm"
                  onClick={() => setViewingNotification(null)}
                >
                  Đóng
                </button>
              </div>
            </div>
          );
        })()}
      </Modal>

      {/* Modal 3: Popup Xác Nhận Xoá Thông Báo (Custom Confirm Popup) */}
      <ConfirmModal
        isOpen={!!deletingNotification}
        title="Xác Nhận Xoá Thông Báo"
        message="Bạn có chắc chắn muốn xoá thông báo này khỏi hệ thống không? Hành động này sẽ xoá dữ liệu vĩnh viễn và không thể khôi phục."
        itemDetail={
          deletingNotification && (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontWeight: 700, color: 'var(--primary)' }}>
                  Mã thông báo #{deletingNotification.notification_id}
                </span>
                <span style={{ fontSize: 11.5, color: 'var(--text-muted)' }}>
                  {formatDateTime(deletingNotification.created_at)}
                </span>
              </div>
              <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 13.5 }}>
                {deletingNotification.title}
              </div>
              <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>
                Người nhận: <strong>{deletingNotification.users?.full_name || `Người dùng #${deletingNotification.user_id}`}</strong>
                {deletingNotification.users?.email ? ` (${deletingNotification.users.email})` : ''}
              </div>
            </div>
          )
        }
        confirmText="Xác nhận xoá"
        cancelText="Huỷ bỏ"
        isDanger={true}
        isLoading={isDeleting}
        onConfirm={handleConfirmDelete}
        onClose={() => setDeletingNotification(null)}
      />
    </div>
  );
}
