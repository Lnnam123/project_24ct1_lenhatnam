import React, { useState, useEffect } from 'react';
import { FileSpreadsheet, Trash2 } from 'lucide-react';
import { ApiService, formatCurrency, formatDateTime } from '../services/api';

export default function TransactionsView({ showToast }) {
  const [transactions, setTransactions] = useState([]);
  const [type, setType] = useState('ALL');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadTransactions();
  }, [type]);

  const loadTransactions = async () => {
    setLoading(true);
    const data = await ApiService.getTransactions(100, type);
    setTransactions(data);
    setLoading(false);
  };

  const handleDelete = async (transId) => {
    if (!window.confirm(`Bạn có chắc muốn xoá giao dịch #${transId}?`)) return;
    try {
      await ApiService.deleteTransaction(transId);
      showToast(`Đã xoá giao dịch #${transId} thành công`, 'success');
      loadTransactions();
    } catch (e) {
      showToast('Lỗi khi xoá: ' + e.message, 'error');
    }
  };

  return (
    <div className="card">
      <div className="card-header">
        <div className="card-title">
          <FileSpreadsheet size={20} color="var(--success)" />
          <h3>Nhật ký giao dịch toàn hệ thống</h3>
        </div>
        <div>
          <select
            className="form-control"
            style={{ width: 190 }}
            value={type}
            onChange={(e) => setType(e.target.value)}
          >
            <option value="ALL">Tất cả giao dịch</option>
            <option value="EXPENSE">Chỉ khoản chi (Expense)</option>
            <option value="INCOME">Chỉ khoản thu (Income)</option>
            <option value="TRANSFER">Chuyển khoản (Transfer)</option>
          </select>
        </div>
      </div>

      <div className="table-responsive">
        <table className="modern-table">
          <thead>
            <tr>
              <th>Mã GD</th>
              <th>Người dùng</th>
              <th>Loại</th>
              <th>Số tiền</th>
              <th>Danh mục</th>
              <th>Ví</th>
              <th>Ngày giao dịch</th>
              <th>Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="8" style={{ textAlign: 'center', padding: '30px' }}>
                  Đang tải dữ liệu giao dịch...
                </td>
              </tr>
            ) : transactions.length === 0 ? (
              <tr>
                <td colSpan="8" style={{ textAlign: 'center', padding: '30px', color: 'var(--text-light)' }}>
                  Không tìm thấy giao dịch nào phù hợp
                </td>
              </tr>
            ) : (
              transactions.map(t => {
                const isExp = t.type === 'EXPENSE';
                const badgeClass = isExp ? 'badge-expense' : (t.type === 'INCOME' ? 'badge-income' : 'badge-transfer');
                const badgeText = isExp ? 'Chi tiêu' : (t.type === 'INCOME' ? 'Thu nhập' : 'Chuyển khoản');
                const prefix = isExp ? '-' : '+';
                const user = t.users?.full_name || 'Khách vãng lai';

                return (
                  <tr key={t.transaction_id}>
                    <td style={{ fontWeight: 700, color: 'var(--text-muted)', fontSize: 12 }}>#{t.transaction_id}</td>
                    <td>
                      <div style={{ fontWeight: 700, color: 'var(--text-main)' }}>{user}</div>
                      <div style={{ fontSize: 12, color: 'var(--text-muted)' }}>{t.users?.email || ''}</div>
                    </td>
                    <td><span className={`badge ${badgeClass}`}>{badgeText}</span></td>
                    <td style={{ fontWeight: 700, fontSize: 15, color: isExp ? 'var(--danger)' : 'var(--success)' }}>
                      {prefix}{formatCurrency(t.amount)}
                    </td>
                    <td>{t.categories?.name || 'Khác'}</td>
                    <td style={{ fontSize: 13, color: 'var(--text-muted)' }}>{t.wallets?.wallet_name || 'Ví tiền'}</td>
                    <td style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>{formatDateTime(t.transaction_date)}</td>
                    <td>
                      <button className="action-btn delete" title="Xoá giao dịch" onClick={() => handleDelete(t.transaction_id)}>
                        <Trash2 size={15} />
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
