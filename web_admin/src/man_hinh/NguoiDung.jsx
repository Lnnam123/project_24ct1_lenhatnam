import React, { useState, useEffect } from 'react';
import { 
  UserCheck, 
  Eye, 
  Trash2, 
  Search, 
  Lock, 
  Unlock, 
  PauseCircle, 
  PlayCircle, 
  ShieldAlert 
} from 'lucide-react';
import Modal from '../thanh_phan/HopThoai';
import ConfirmModal from '../thanh_phan/HopThoaiXacNhan';
import { ApiService, formatDateTime } from '../dich_vu/api';

export default function UsersView({ showToast }) {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  
  // Modal chi tiết user
  const [userDetails, setUserDetails] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  // Popup xác nhận thay thế window.confirm
  const [confirmState, setConfirmState] = useState({
    isOpen: false,
    title: '',
    message: '',
    type: 'danger',
    icon: null,
    confirmIcon: null,
    confirmText: 'Xác nhận',
    itemDetail: null,
    isLoading: false,
    action: null
  });

  useEffect(() => {
    let ignore = false;
    ApiService.getUsers().then(data => {
      if (!ignore) {
        setUsers(data);
        setLoading(false);
      }
    });
    return () => {
      ignore = true;
    };
  }, []);

  const loadUsers = async () => {
    setLoading(true);
    const data = await ApiService.getUsers(search);
    setUsers(data);
    setLoading(false);
  };

  const handleSearch = (e) => {
    setSearch(e.target.value);
  };

  const handleViewUser = async (userId) => {
    setIsModalOpen(true);
    setUserDetails(null);
    const details = await ApiService.getUserDetails(userId);
    setUserDetails(details);
  };

  const closeConfirm = () => {
    setConfirmState(prev => ({ ...prev, isOpen: false, isLoading: false }));
  };

  // Mở popup xác nhận thay đổi trạng thái
  const promptUpdateStatus = (userId, targetStatus, userName) => {
    let title = '';
    let message = '';
    let type = 'warning';
    let icon = PauseCircle;
    let confirmIcon = PauseCircle;
    let confirmText = 'Xác nhận';

    if (targetStatus === 'SUSPENDED') {
      title = 'Xác nhận tạm ngưng tài khoản';
      message = `Bạn có chắc muốn TẠM NGƯNG tài khoản "${userName}"?\nNgười dùng sẽ tạm thời bị chặn và không thể đăng nhập vào ứng dụng CoinTap.`;
      type = 'warning';
      icon = PauseCircle;
      confirmIcon = PauseCircle;
      confirmText = 'Tạm ngưng tài khoản';
    } else if (targetStatus === 'LOCKED') {
      title = 'Xác nhận khoá tài khoản';
      message = `Bạn có chắc muốn KHOÁ tài khoản "${userName}"?\nNgười dùng sẽ bị khoá quyền truy cập ứng dụng CoinTap.`;
      type = 'lock';
      icon = Lock;
      confirmIcon = Lock;
      confirmText = 'Khoá tài khoản';
    } else if (targetStatus === 'ACTIVE') {
      title = 'Xác nhận kích hoạt lại tài khoản';
      message = `Bạn có muốn MỞ LẠI / KÍCH HOẠT tài khoản "${userName}" hoạt động bình thường trên hệ thống CoinTap?`;
      type = 'success';
      icon = PlayCircle;
      confirmIcon = PlayCircle;
      confirmText = 'Kích hoạt ngay';
    }

    setConfirmState({
      isOpen: true,
      title,
      message,
      type,
      icon,
      confirmIcon,
      confirmText,
      itemDetail: (
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div className="admin-avatar" style={{ width: 32, height: 32, fontSize: 13 }}>
            {(userName || 'U')[0].toUpperCase()}
          </div>
          <div>
            <div style={{ fontWeight: 700 }}>{userName}</div>
            <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>Mã tài khoản: #{userId}</div>
          </div>
        </div>
      ),
      isLoading: false,
      action: async () => {
        setConfirmState(prev => ({ ...prev, isLoading: true }));
        try {
          await ApiService.updateUserStatus(userId, targetStatus);
          
          let successToast = `Đã cập nhật trạng thái người dùng thành công`;
          if (targetStatus === 'SUSPENDED') successToast = `Đã tạm ngưng tài khoản "${userName}"`;
          else if (targetStatus === 'LOCKED') successToast = `Đã khoá tài khoản "${userName}"`;
          else if (targetStatus === 'ACTIVE') successToast = `Đã kích hoạt lại tài khoản "${userName}" thành công`;

          showToast(successToast, 'success');

          // Cập nhật danh sách bảng
          setUsers(prev => prev.map(u => u.user_id === userId ? { ...u, status: targetStatus } : u));

          // Cập nhật thông tin modal chi tiết nếu đang mở
          setUserDetails(prev => {
            if (prev && prev.user?.user_id === userId) {
              return {
                ...prev,
                user: { ...prev.user, status: targetStatus }
              };
            }
            return prev;
          });

          closeConfirm();
        } catch (e) {
          showToast('Lỗi khi cập nhật trạng thái: ' + e.message, 'error');
          setConfirmState(prev => ({ ...prev, isLoading: false }));
        }
      }
    });
  };

  // Mở popup xác nhận xoá vĩnh viễn
  const promptDeleteUser = (userId, userName) => {
    if (userName === 'admin' || userId === 9) {
      showToast('Không thể xoá tài khoản Quản trị viên hệ thống!', 'error');
      return;
    }

    setConfirmState({
      isOpen: true,
      title: 'Xác nhận xoá tài khoản vĩnh viễn',
      message: `Bạn có chắc chắn muốn XOÁ VĨNH VIỄN tài khoản "${userName}"?\nToàn bộ dữ liệu tài chính cá nhân, ví và giao dịch liên quan sẽ bị xoá sạch khỏi hệ thống!`,
      type: 'danger',
      icon: Trash2,
      confirmIcon: Trash2,
      confirmText: 'Xoá vĩnh viễn',
      itemDetail: (
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div className="admin-avatar" style={{ width: 32, height: 32, fontSize: 13, background: '#FEE2E2', color: '#DC2626' }}>
            {(userName || 'U')[0].toUpperCase()}
          </div>
          <div>
            <div style={{ fontWeight: 700, color: '#DC2626' }}>{userName}</div>
            <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>Mã tài khoản: #{userId}</div>
          </div>
        </div>
      ),
      isLoading: false,
      action: async () => {
        setConfirmState(prev => ({ ...prev, isLoading: true }));
        try {
          await ApiService.deleteUser(userId);
          showToast(`Đã xoá người dùng "${userName}" vĩnh viễn`, 'success');
          closeConfirm();
          setIsModalOpen(false);
          loadUsers();
        } catch (e) {
          showToast('Lỗi khi xoá người dùng: ' + e.message, 'error');
          setConfirmState(prev => ({ ...prev, isLoading: false }));
        }
      }
    });
  };

  const renderStatusBadge = (status) => {
    const s = (status || 'ACTIVE').toUpperCase();
    if (s === 'LOCKED') {
      return <span className="badge badge-locked">Đã khoá</span>;
    }
    if (s === 'SUSPENDED') {
      return <span className="badge badge-suspended">Tạm ngưng</span>;
    }
    return <span className="badge badge-active">Đang hoạt động</span>;
  };

  const filteredUsers = users.filter(u => 
    (u.full_name || '').toLowerCase().includes(search.toLowerCase().trim()) ||
    (u.email || '').toLowerCase().includes(search.toLowerCase().trim()) ||
    (u.phone_number || '').includes(search.trim())
  );

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title">
          <UserCheck size={20} color="var(--primary)" />
          <h3>Danh sách tài khoản người dùng</h3>
        </div>
        <div className="search-box">
          <Search size={16} />
          <input
            type="text"
            placeholder="Tìm theo họ tên, email, SĐT..."
            value={search}
            onChange={handleSearch}
          />
        </div>
      </div>

      <div className="table-responsive">
        <table className="modern-table">
          <thead>
            <tr>
              <th>Người dùng</th>
              <th>Số điện thoại</th>
              <th>Trạng thái</th>
              <th>Ngày tham gia</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '30px' }}>
                  Đang tải danh sách người dùng...
                </td>
              </tr>
            ) : filteredUsers.length === 0 ? (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-light)' }}>
                  Không tìm thấy người dùng nào
                </td>
              </tr>
            ) : (
              filteredUsers.map(u => {
                const avatarHtml = u.avatar_url && u.avatar_url.startsWith('http')
                  ? <img src={u.avatar_url} alt="" style={{ width: 38, height: 38, borderRadius: '50%', objectFit: 'cover' }} />
                  : <div className="admin-avatar" style={{ width: 38, height: 38, fontSize: 14 }}>{(u.full_name || 'U')[0].toUpperCase()}</div>;

                const status = (u.status || 'ACTIVE').toUpperCase();

                return (
                  <tr key={u.user_id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                        {avatarHtml}
                        <div>
                          <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>{u.full_name || 'Người dùng'}</div>
                          <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{u.email}</div>
                        </div>
                      </div>
                    </td>
                    <td>{u.phone_number || 'Chưa cập nhật'}</td>
                    <td>{renderStatusBadge(status)}</td>
                    <td style={{ fontSize: 13, color: 'var(--text-muted)' }}>{formatDateTime(u.created_at)}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button 
                          className="action-btn" 
                          title="Xem thông tin chi tiết tài khoản" 
                          onClick={() => handleViewUser(u.user_id)}
                        >
                          <Eye size={16} />
                        </button>

                        {/* Nút Tạm ngưng hoặc Kích hoạt lại nếu đang tạm ngưng */}
                        {status === 'SUSPENDED' ? (
                          <button 
                            className="action-btn success" 
                            title="Mở lại trạng thái hoạt động" 
                            onClick={() => promptUpdateStatus(u.user_id, 'ACTIVE', u.full_name)}
                          >
                            <PlayCircle size={16} />
                          </button>
                        ) : (
                          <button 
                            className="action-btn warning" 
                            title="Tạm ngưng tài khoản" 
                            onClick={() => promptUpdateStatus(u.user_id, 'SUSPENDED', u.full_name)}
                          >
                            <PauseCircle size={16} />
                          </button>
                        )}

                        {/* Nút Khoá hoặc Mở khoá */}
                        {status === 'LOCKED' ? (
                          <button 
                            className="action-btn success" 
                            title="Mở khoá tài khoản" 
                            onClick={() => promptUpdateStatus(u.user_id, 'ACTIVE', u.full_name)}
                          >
                            <Unlock size={16} />
                          </button>
                        ) : (
                          <button 
                            className="action-btn delete" 
                            title="Khoá tài khoản" 
                            onClick={() => promptUpdateStatus(u.user_id, 'LOCKED', u.full_name)}
                          >
                            <Lock size={16} />
                          </button>
                        )}

                        {/* Nút Xoá vĩnh viễn */}
                        <button 
                          className="action-btn delete" 
                          title="Xoá vĩnh viễn tài khoản" 
                          onClick={() => promptDeleteUser(u.user_id, u.full_name)}
                        >
                          <Trash2 size={16} />
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

      {/* Modal chi tiết tài khoản người dùng */}
      <Modal isOpen={isModalOpen} title="Thông tin tài khoản người dùng" onClose={() => setIsModalOpen(false)}>
        {!userDetails ? (
          <div style={{ textAlign: 'center', padding: '30px' }}>Đang tải thông tin tài khoản...</div>
        ) : (
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20, paddingBottom: 16, borderBottom: '1px solid var(--border-color)' }}>
              <div className="admin-avatar" style={{ width: 54, height: 54, fontSize: 20 }}>
                {(userDetails.user?.full_name || 'U')[0].toUpperCase()}
              </div>
              <div>
                <h4 style={{ fontSize: 18, fontWeight: 800 }}>{userDetails.user?.full_name || 'Người dùng'}</h4>
                <p style={{ fontSize: 13, color: 'var(--text-muted)' }}>{userDetails.user?.email} • {userDetails.user?.phone_number || 'Chưa cập nhật SĐT'}</p>
              </div>
            </div>

            <div style={{ background: '#FAF7FE', padding: '14px 16px', borderRadius: 12, border: '1px solid var(--border-color)', marginBottom: 18 }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
                <div>
                  <span style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 600 }}>Mã tài khoản (User ID):</span>
                  <div style={{ fontSize: 14, fontWeight: 700, color: 'var(--text-main)', marginTop: 2 }}>#{userDetails.user?.user_id}</div>
                </div>
                <div>
                  <span style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 600 }}>Trạng thái tài khoản:</span>
                  <div style={{ marginTop: 4 }}>
                    {renderStatusBadge(userDetails.user?.status)}
                  </div>
                </div>
                <div>
                  <span style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 600 }}>Ngày đăng ký:</span>
                  <div style={{ fontSize: 13.5, fontWeight: 600, color: 'var(--text-main)', marginTop: 2 }}>
                    {formatDateTime(userDetails.user?.created_at)}
                  </div>
                </div>
                <div>
                  <span style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 600 }}>Loại tài khoản:</span>
                  <div style={{ fontSize: 13.5, fontWeight: 600, color: 'var(--primary)', marginTop: 2 }}>Người dùng CoinTap</div>
                </div>
              </div>
            </div>

            {/* Thao tác quản trị tài khoản */}
            <div style={{ 
              background: '#F8FAFC', 
              border: '1px solid var(--border-color)', 
              borderRadius: 12, 
              padding: '14px 16px', 
              marginBottom: 18 
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
                <ShieldAlert size={16} color="var(--primary)" />
                <span style={{ fontSize: 13, fontWeight: 700, color: 'var(--text-main)' }}>Thao tác quản trị tài khoản:</span>
              </div>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 10 }}>
                {/* Nút khôi phục hoạt động nếu đang bị tạm ngưng hoặc khoá */}
                {(userDetails.user?.status === 'SUSPENDED' || userDetails.user?.status === 'LOCKED') && (
                  <button 
                    className="btn btn-sm btn-success" 
                    style={{ 
                      display: 'inline-flex', 
                      alignItems: 'center', 
                      gap: 6,
                      fontWeight: 600
                    }}
                    onClick={() => promptUpdateStatus(userDetails.user?.user_id, 'ACTIVE', userDetails.user?.full_name)}
                  >
                    <PlayCircle size={15} /> Kích hoạt lại tài khoản
                  </button>
                )}

                {/* Nút Tạm ngưng nếu đang ACTIVE */}
                {userDetails.user?.status !== 'SUSPENDED' && (
                  <button 
                    className="btn btn-sm btn-warning" 
                    style={{ 
                      display: 'inline-flex', 
                      alignItems: 'center', 
                      gap: 6,
                      fontWeight: 600
                    }}
                    onClick={() => promptUpdateStatus(userDetails.user?.user_id, 'SUSPENDED', userDetails.user?.full_name)}
                  >
                    <PauseCircle size={15} /> Tạm ngưng tài khoản
                  </button>
                )}

                {/* Nút Khoá nếu chưa bị LOCKED */}
                {userDetails.user?.status !== 'LOCKED' && (
                  <button 
                    className="btn btn-sm btn-danger" 
                    style={{ 
                      display: 'inline-flex', 
                      alignItems: 'center', 
                      gap: 6,
                      fontWeight: 600
                    }}
                    onClick={() => promptUpdateStatus(userDetails.user?.user_id, 'LOCKED', userDetails.user?.full_name)}
                  >
                    <Lock size={15} /> Khoá tài khoản
                  </button>
                )}

                {/* Nút Xoá vĩnh viễn */}
                <button 
                  className="btn btn-sm" 
                  style={{ 
                    background: '#ffffff', 
                    color: 'var(--danger)', 
                    border: '1px solid var(--danger)',
                    display: 'inline-flex', 
                    alignItems: 'center', 
                    gap: 6,
                    fontWeight: 600,
                    marginLeft: 'auto'
                  }}
                  onClick={() => promptDeleteUser(userDetails.user?.user_id, userDetails.user?.full_name)}
                >
                  <Trash2 size={15} /> Xoá tài khoản vĩnh viễn
                </button>
              </div>
            </div>

            {/* Thông báo chính sách bảo mật quyền riêng tư tài chính */}
            <div style={{ 
              background: 'rgba(16, 185, 129, 0.08)', 
              border: '1px solid rgba(16, 185, 129, 0.25)', 
              borderRadius: 12, 
              padding: '14px 16px', 
              display: 'flex', 
              alignItems: 'flex-start', 
              gap: 12 
            }}>
              <div style={{ color: 'var(--success)', marginTop: 2 }}>
                <UserCheck size={20} />
              </div>
              <div style={{ fontSize: 12.5, color: '#065F46', lineHeight: 1.5 }}>
                <strong>Chính sách bảo mật quyền riêng tư:</strong> Toàn bộ số dư ví, danh mục chi tiêu và lịch sử giao dịch cá nhân của người dùng được mã hoá bảo mật. Hệ thống Quản trị viên chỉ quản lý trạng thái hoạt động của tài khoản mà không can thiệp vào dữ liệu tài chính riêng tư.
              </div>
            </div>
          </div>
        )}
      </Modal>

      {/* Popup Modal xác nhận hành động thay thế window.confirm */}
      <ConfirmModal
        isOpen={confirmState.isOpen}
        title={confirmState.title}
        message={confirmState.message}
        type={confirmState.type}
        icon={confirmState.icon}
        confirmIcon={confirmState.confirmIcon}
        confirmText={confirmState.confirmText}
        itemDetail={confirmState.itemDetail}
        isLoading={confirmState.isLoading}
        onConfirm={confirmState.action}
        onClose={closeConfirm}
      />
    </div>
  );
}
