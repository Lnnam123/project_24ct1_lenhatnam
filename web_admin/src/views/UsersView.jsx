import React, { useState, useEffect } from 'react';
import { UserCheck, Eye, Trash2, Search } from 'lucide-react';
import Modal from '../components/Modal';
import { ApiService, formatCurrency, formatDateTime } from '../services/api';

export default function UsersView({ showToast }) {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(true);
  
  // Modal state
  const [selectedUser, setSelectedUser] = useState(null);
  const [userDetails, setUserDetails] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  useEffect(() => {
    loadUsers();
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

  const handleDeleteUser = async (userId, name) => {
    if (name === 'admin' || userId === 9) {
      showToast('Không thể xoá tài khoản Quản trị viên hệ thống!', 'error');
      return;
    }
    if (!window.confirm(`Bạn có chắc muốn xoá tài khoản "${name}"? Tất cả ví và giao dịch liên quan sẽ bị xoá vĩnh viễn!`)) {
      return;
    }
    try {
      await ApiService.deleteUser(userId);
      showToast(`Đã xoá người dùng "${name}" thành công`, 'success');
      loadUsers();
    } catch (e) {
      showToast('Lỗi khi xoá người dùng: ' + e.message, 'error');
    }
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
                    <td><span className="badge badge-active">Hoạt động</span></td>
                    <td style={{ fontSize: 13, color: 'var(--text-muted)' }}>{formatDateTime(u.created_at)}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 8 }}>
                        <button className="action-btn" title="Xem chi tiết ví & giao dịch" onClick={() => handleViewUser(u.user_id)}>
                          <Eye size={16} />
                        </button>
                        <button className="action-btn delete" title="Xoá người dùng" onClick={() => handleDeleteUser(u.user_id, u.full_name)}>
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

      {/* Modal chi tiết người dùng */}
      <Modal isOpen={isModalOpen} title="Chi tiết người dùng" onClose={() => setIsModalOpen(false)}>
        {!userDetails ? (
          <div style={{ textAlign: 'center', padding: '30px' }}>Đang tải thông tin chi tiết...</div>
        ) : (
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginBottom: 20, paddingBottom: 16, borderBottom: '1px solid var(--border-color)' }}>
              <div className="admin-avatar" style={{ width: 54, height: 54, fontSize: 20 }}>
                {(userDetails.user?.full_name || 'U')[0].toUpperCase()}
              </div>
              <div>
                <h4 style={{ fontSize: 18, fontWeight: 800 }}>{userDetails.user?.full_name}</h4>
                <p style={{ fontSize: 13, color: 'var(--text-muted)' }}>{userDetails.user?.email} • {userDetails.user?.phone_number || 'Không có SĐT'}</p>
              </div>
            </div>

            <h5 style={{ fontSize: 15, fontWeight: 700, marginBottom: 10 }}>Ví tiền ({userDetails.wallets.length})</h5>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: 12, marginBottom: 24 }}>
              {userDetails.wallets.map(w => (
                <div key={w.wallet_id} style={{ background: '#FAF7FE', padding: '12px 14px', borderRadius: 12, border: '1px solid var(--border-color)' }}>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', fontWeight: 600 }}>{w.wallet_name}</div>
                  <div style={{ fontSize: 16, fontWeight: 800, color: 'var(--primary)', marginTop: 4 }}>{formatCurrency(w.balance)}</div>
                </div>
              ))}
            </div>

            <h5 style={{ fontSize: 15, fontWeight: 700, marginBottom: 10 }}>Giao dịch gần đây ({userDetails.transactions.length})</h5>
            <div style={{ maxHeight: 220, overflowY: 'auto' }}>
              {userDetails.transactions.length === 0 ? (
                <p style={{ color: 'var(--text-light)', fontSize: 13 }}>Chưa có giao dịch nào</p>
              ) : (
                userDetails.transactions.map(t => (
                  <div key={t.transaction_id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '8px 0', borderBottom: '1px solid rgba(237,232,245,0.5)' }}>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 13 }}>{t.categories?.name || t.note || 'Giao dịch'}</div>
                      <div style={{ fontSize: '11.5px', color: 'var(--text-muted)' }}>{formatDateTime(t.transaction_date)}</div>
                    </div>
                    <div style={{ fontWeight: 700, color: t.type === 'EXPENSE' ? 'var(--danger)' : 'var(--success)' }}>
                      {t.type === 'EXPENSE' ? '-' : '+'}{formatCurrency(t.amount)}
                    </div>
                  </div>
                ))
              )}
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
