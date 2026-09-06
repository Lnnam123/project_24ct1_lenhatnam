import React, { useState, useEffect, useRef } from 'react';
import { Users, Wallet, ArrowRightLeft, Bot, TrendingUp, PieChart as PieIcon, Zap, Eye, EyeOff } from 'lucide-react';
import StatCard from '../components/StatCard';
import { ApiService, formatCurrency, formatDateTime } from '../services/api';

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  Filler
} from 'chart.js';
import { Line, Doughnut } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  Filler
);

export default function DashboardView({ onNavigate }) {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalWallets: 0,
    totalBalance: 0,
    totalTransactions: 0,
    totalAISessions: 0,
    transactions: []
  });
  const [loading, setLoading] = useState(true);
  const [hideBalance, setHideBalance] = useState(() => {
    return localStorage.getItem('cointap_hide_balance') === 'true';
  });
  const chartsGridRef = useRef(null);

  const toggleHideBalance = (e) => {
    e?.stopPropagation?.();
    setHideBalance((prev) => {
      const next = !prev;
      localStorage.setItem('cointap_hide_balance', String(next));
      return next;
    });
  };

  const loadData = async () => {
    setLoading(true);
    const data = await ApiService.getKPIStats();
    setStats(data);
    setLoading(false);
  };

  useEffect(() => {
    loadData();
  }, []);

  // Tự động lắng nghe thay đổi kích thước của khung chứa biểu đồ khi thu gọn/mở rộng sidebar
  useEffect(() => {
    if (!chartsGridRef.current) return;
    const observer = new ResizeObserver(() => {
      window.dispatchEvent(new Event('resize'));
    });
    observer.observe(chartsGridRef.current);
    return () => observer.disconnect();
  }, []);

  // 1. Dữ liệu Thu vs Chi theo 6 tháng
  const months = [];
  const incomeData = [0, 0, 0, 0, 0, 0];
  const expenseData = [0, 0, 0, 0, 0, 0];
  const now = new Date();
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    months.push(`Tháng ${d.getMonth() + 1}`);
  }

  (stats.transactions || []).forEach(t => {
    const tDate = new Date(t.transaction_date);
    const monthDiff = (now.getFullYear() - tDate.getFullYear()) * 12 + (now.getMonth() - tDate.getMonth());
    if (monthDiff >= 0 && monthDiff < 6) {
      const index = 5 - monthDiff;
      const amt = Number(t.amount) || 0;
      if (t.type === 'INCOME') incomeData[index] += amt;
      else if (t.type === 'EXPENSE') expenseData[index] += amt;
    }
  });

  const lineChartData = {
    labels: months,
    datasets: [
      {
        label: 'Chi tiêu',
        data: expenseData,
        borderColor: '#7C4DFF',
        backgroundColor: 'rgba(124, 77, 255, 0.12)',
        borderWidth: 3,
        fill: true,
        tension: 0.4,
        pointBackgroundColor: '#7C4DFF',
        pointRadius: 4
      },
      {
        label: 'Thu nhập',
        data: incomeData,
        borderColor: '#00C853',
        backgroundColor: 'rgba(0, 200, 83, 0.12)',
        borderWidth: 3,
        fill: true,
        tension: 0.4,
        pointBackgroundColor: '#00C853',
        pointRadius: 4
      }
    ]
  };

  const doughnutChartData = {
    labels: ['Ăn uống', 'Mua sắm', 'Di chuyển', 'Hóa đơn', 'Khác'],
    datasets: [{
      data: [35, 25, 18, 14, 8],
      backgroundColor: ['#7C4DFF', '#00B0FF', '#FFB300', '#FF5252', '#9C27B0'],
      borderWidth: 3,
      borderColor: '#ffffff'
    }]
  };

  const recentTransactions = (stats.transactions || []).slice(0, 5);

  return (
    <div>
      {/* 4 Thẻ KPI */}
      <div className="stats-grid">
        <StatCard
          title="Tổng người dùng đăng ký"
          value={loading ? '...' : stats.totalUsers.toLocaleString()}
          icon={Users}
          color="purple"
        />
        <StatCard
          title="Số dư lưu thông hệ thống"
          value={loading ? '...' : (hideBalance ? '••••••••' : formatCurrency(stats.totalBalance))}
          icon={Wallet}
          color="green"
          rightAction={
            <button
              type="button"
              onClick={toggleHideBalance}
              title={hideBalance ? 'Hiển thị số dư hệ thống' : 'Ẩn số dư hệ thống'}
              style={{
                background: 'rgba(0, 0, 0, 0.04)',
                border: '1px solid var(--border-color)',
                borderRadius: '8px',
                padding: '5px 8px',
                cursor: 'pointer',
                color: hideBalance ? 'var(--primary)' : 'var(--text-muted)',
                display: 'inline-flex',
                alignItems: 'center',
                gap: 5,
                fontSize: '12px',
                fontWeight: 600,
                transition: 'all 0.2s'
              }}
              onMouseEnter={(e) => {
                e.currentTarget.style.background = 'rgba(0, 74, 198, 0.08)';
                e.currentTarget.style.color = 'var(--primary)';
              }}
              onMouseLeave={(e) => {
                e.currentTarget.style.background = 'rgba(0, 0, 0, 0.04)';
                e.currentTarget.style.color = hideBalance ? 'var(--primary)' : 'var(--text-muted)';
              }}
            >
              {hideBalance ? <EyeOff size={16} /> : <Eye size={16} />}
              <span>{hideBalance ? 'Hiện' : 'Ẩn'}</span>
            </button>
          }
        />
        <StatCard
          title="Giao dịch ghi nhận"
          value={loading ? '...' : stats.totalTransactions.toLocaleString()}
          icon={ArrowRightLeft}
          color="blue"
        />
        <StatCard
          title="Phiên Trợ lý AI"
          value={loading ? '...' : stats.totalAISessions.toLocaleString()}
          icon={Bot}
          color="orange"
        />
      </div>

      {/* 2 Biểu đồ */}
      <div className="charts-grid" ref={chartsGridRef}>
        <div className="card">
          <div className="card-header">
            <div className="card-title">
              <TrendingUp size={20} color="var(--primary)" />
              <h3>Biến động Thu - Chi 6 tháng gần nhất</h3>
            </div>
          </div>
          <div className="chart-wrap">
            <Line
              data={lineChartData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                resizeDelay: 0,
                plugins: {
                  legend: { position: 'top', labels: { font: { family: 'Manrope', weight: '600' } } }
                },
                scales: {
                  y: {
                    grid: { color: 'rgba(237, 232, 245, 0.6)' },
                    ticks: {
                      callback: val => val >= 1000000 ? `${(val / 1000000).toFixed(1)}M` : `${val / 1000}k`
                    }
                  },
                  x: { grid: { display: false } }
                }
              }}
            />
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <div className="card-title">
              <PieIcon size={20} color="var(--info)" />
              <h3>Cơ cấu chi tiêu danh mục</h3>
            </div>
          </div>
          <div className="chart-wrap">
            <Doughnut
              data={doughnutChartData}
              options={{
                responsive: true,
                maintainAspectRatio: false,
                resizeDelay: 0,
                plugins: {
                  legend: { position: 'bottom', labels: { font: { family: 'Manrope', weight: '600' } } }
                },
                cutout: '70%'
              }}
            />
          </div>
        </div>
      </div>

      {/* Live Feed: 5 giao dịch gần đây */}
      <div className="card">
        <div className="card-header">
          <div className="card-title">
            <Zap size={20} color="var(--warning)" />
            <h3>Giao dịch mới nhất gần đây</h3>
          </div>
          <button className="btn btn-secondary btn-sm" onClick={() => onNavigate('transactions')}>
            Xem tất cả
          </button>
        </div>
        <div className="table-responsive">
          <table className="modern-table">
            <thead>
              <tr>
                <th>Người thực hiện</th>
                <th>Loại</th>
                <th>Số tiền</th>
                <th>Thời gian</th>
              </tr>
            </thead>
            <tbody>
              {recentTransactions.length === 0 ? (
                <tr>
                  <td colSpan="4" style={{ textAlign: 'center', padding: '24px', color: 'var(--text-light)' }}>
                    Chưa có giao dịch nào
                  </td>
                </tr>
              ) : (
                recentTransactions.map((t, idx) => {
                  const isExp = t.type === 'EXPENSE';
                  const badgeClass = isExp ? 'badge-expense' : (t.type === 'INCOME' ? 'badge-income' : 'badge-transfer');
                  const badgeText = isExp ? 'Chi tiêu' : (t.type === 'INCOME' ? 'Thu nhập' : 'Chuyển khoản');
                  return (
                    <tr key={idx}>
                      <td>
                        <div style={{ fontWeight: 700 }}>Giao dịch #{t.transaction_id || idx + 1}</div>
                      </td>
                      <td>
                        <span className={`badge ${badgeClass}`}>{badgeText}</span>
                      </td>
                      <td style={{ fontWeight: 700, color: isExp ? 'var(--danger)' : 'var(--success)' }}>
                        {isExp ? '-' : '+'}{formatCurrency(t.amount)}
                      </td>
                      <td style={{ fontSize: '12.5px', color: 'var(--text-muted)' }}>
                        {formatDateTime(t.transaction_date)}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
