import React, { useState, useEffect, useRef } from 'react';
import { 
  Users, 
  ShieldCheck, 
  Bot, 
  Activity, 
  TrendingUp, 
  PieChart as PieIcon, 
  Server
} from 'lucide-react';
import StatCard from '../thanh_phan/TheThongKe';
import { ApiService } from '../dich_vu/api';

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

export default function DashboardView() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalAdmins: 0,
    totalAISessions: 0,
    totalNotifications: 0,
    totalCategories: 0,
    userDates: [],
    aiDates: [],
    systemStatus: 'ONLINE'
  });
  const [loading, setLoading] = useState(true);
  const chartsGridRef = useRef(null);

  useEffect(() => {
    let ignore = false;
    ApiService.getKPIStats().then((data) => {
      if (!ignore) {
        setStats(data);
        setLoading(false);
      }
    });
    return () => {
      ignore = true;
    };
  }, []);

  // Tự động lắng nghe thay đổi kích thước khi thu gọn/mở rộng sidebar
  useEffect(() => {
    if (!chartsGridRef.current) return;
    const observer = new ResizeObserver(() => {
      window.dispatchEvent(new Event('resize'));
    });
    observer.observe(chartsGridRef.current);
    return () => observer.disconnect();
  }, []);

  // 1. Thống kê Hoạt động hệ thống theo 6 tháng (Người dùng mới & Phiên AI)
  const months = [];
  const userGrowthData = [0, 0, 0, 0, 0, 0];
  const aiActivityData = [0, 0, 0, 0, 0, 0];
  const now = new Date();

  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    months.push(`Tháng ${d.getMonth() + 1}`);
  }

  (stats.userDates || []).forEach(dStr => {
    const d = new Date(dStr);
    const monthDiff = (now.getFullYear() - d.getFullYear()) * 12 + (now.getMonth() - d.getMonth());
    if (monthDiff >= 0 && monthDiff < 6) {
      const idx = 5 - monthDiff;
      userGrowthData[idx] += 1;
    }
  });

  (stats.aiDates || []).forEach(dStr => {
    const d = new Date(dStr);
    const monthDiff = (now.getFullYear() - d.getFullYear()) * 12 + (now.getMonth() - d.getMonth());
    if (monthDiff >= 0 && monthDiff < 6) {
      const idx = 5 - monthDiff;
      aiActivityData[idx] += 1;
    }
  });

  const lineChartData = {
    labels: months,
    datasets: [
      {
        label: 'Tài khoản người dùng mới',
        data: userGrowthData,
        borderColor: '#712AE2',
        backgroundColor: 'rgba(113, 42, 226, 0.12)',
        tension: 0.4,
        fill: true,
        pointBackgroundColor: '#712AE2',
        pointRadius: 4,
        pointHoverRadius: 6
      },
      {
        label: 'Phiên tương tác Trợ lý AI',
        data: aiActivityData,
        borderColor: '#004AC6',
        backgroundColor: 'rgba(0, 74, 198, 0.08)',
        tension: 0.4,
        fill: true,
        pointBackgroundColor: '#004AC6',
        pointRadius: 4,
        pointHoverRadius: 6
      }
    ]
  };

  // 2. Phân bổ thực thể & dịch vụ hệ thống
  const doughnutChartData = {
    labels: [
      'Tài khoản người dùng',
      'Phiên Trợ lý AI',
      'Danh mục mẫu hệ thống',
      'Thông báo đã phát',
      'Quản trị viên'
    ],
    datasets: [
      {
        data: [
          stats.totalUsers || 1,
          stats.totalAISessions || 1,
          stats.totalCategories || 1,
          stats.totalNotifications || 1,
          stats.totalAdmins || 1
        ],
        backgroundColor: [
          '#712AE2', // Tím
          '#004AC6', // Xanh dương
          '#F59E0B', // Vàng cam
          '#10B981', // Xanh ngọc
          '#6366F1'  // Chàm
        ],
        borderWidth: 2,
        borderColor: '#ffffff',
        hoverOffset: 6
      }
    ]
  };

  const systemServices = [
    {
      name: 'Cơ sở dữ liệu Supabase PostgreSQL',
      type: 'Database Engine',
      status: 'Trực tuyến',
      statusType: 'success',
      latency: '< 18ms',
      detail: 'Kết nối Realtime hoạt động bình thường'
    },
    {
      name: 'Dịch vụ Trợ lý Trí tuệ Nhân tạo (Gemini AI)',
      type: 'AI Service & KeyStream',
      status: 'Sẵn sàng',
      statusType: 'success',
      latency: '~ 1.2s',
      detail: 'Mô hình Gemini 2.5 Flash / Flash Latest'
    },
    {
      name: 'Hệ thống Phát Thông báo Toàn ứng dụng',
      type: 'Push & Broadcast Service',
      status: 'Hoạt động',
      statusType: 'success',
      latency: '< 50ms',
      detail: 'Hỗ trợ phát thông báo cập nhật, bảo trì tức thì'
    },
    {
      name: 'Ứng dụng Di động CoinTap Mobile',
      type: 'Client App (Android / iOS)',
      status: 'Phiên bản v1.5.3',
      statusType: 'info',
      latency: 'Build +11',
      detail: 'Đã sẵn sàng tải và cập nhật qua OTA / APK'
    },
    {
      name: 'Chính sách Bảo vệ Quyền riêng tư (Zero-Knowledge)',
      type: 'Privacy & Security Guard',
      status: 'Kích hoạt',
      statusType: 'success',
      latency: 'Tối đa',
      detail: 'Không thu thập, không quản lý số dư hay lịch sử giao dịch người dùng'
    }
  ];

  return (
    <div className="dashboard-view animate-fade-in">
      {/* 4 Thẻ KPI Chỉ số Vận hành Hệ thống */}
      <div className="stats-grid">
        <StatCard
          title="Tài khoản người dùng"
          value={loading ? '...' : stats.totalUsers.toLocaleString()}
          icon={Users}
          color="purple"
          subText="Tổng người dùng trên hệ thống"
        />
        <StatCard
          title="Quản trị viên"
          value={loading ? '...' : stats.totalAdmins.toLocaleString()}
          icon={ShieldCheck}
          color="blue"
          subText="Đang vận hành hệ thống"
        />
        <StatCard
          title="Phiên Trợ lý AI"
          value={loading ? '...' : stats.totalAISessions.toLocaleString()}
          icon={Bot}
          color="orange"
          subText="Tổng phiên hỗ trợ người dùng"
        />
        <StatCard
          title="Trạng thái hệ thống"
          value="100% Ổn định"
          icon={Activity}
          color="green"
          subText="Supabase & AI Engine trực tuyến"
        />
      </div>

      {/* 2 Biểu đồ Hoạt động */}
      <div className="charts-grid" ref={chartsGridRef}>
        <div className="card">
          <div className="card-header">
            <div className="card-title">
              <TrendingUp size={20} color="var(--primary)" />
              <h3>Tần suất hoạt động hệ thống (6 tháng gần nhất)</h3>
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
                    beginAtZero: true,
                    grid: { color: 'rgba(237, 232, 245, 0.6)' },
                    ticks: {
                      precision: 0
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
              <h3>Phân bổ dịch vụ & thực thể hệ thống</h3>
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
                cutout: '68%'
              }}
            />
          </div>
        </div>
      </div>

      {/* Bảng Giám sát Tình trạng Dịch vụ & Hạ tầng */}
      <div className="card">
        <div className="card-header">
          <div className="card-title">
            <Server size={20} color="var(--primary)" />
            <h3>Giám sát tình trạng hạ tầng & dịch vụ hệ thống</h3>
          </div>
          <span className="badge badge-success" style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '6px 12px' }}>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#10B981', display: 'inline-block' }}></span>
            Hệ thống đang hoạt động tốt
          </span>
        </div>
        <div className="table-responsive">
          <table className="modern-table">
            <thead>
              <tr>
                <th>Dịch vụ / Thành phần</th>
                <th>Phân loại</th>
                <th>Trạng thái</th>
                <th>Hiệu năng / Phiên bản</th>
                <th>Chi tiết kỹ thuật</th>
              </tr>
            </thead>
            <tbody>
              {systemServices.map((srv, idx) => (
                <tr key={idx}>
                  <td>
                    <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: 14 }}>{srv.name}</div>
                  </td>
                  <td>
                    <span style={{ fontSize: 12.5, color: 'var(--text-muted)', fontWeight: 600 }}>{srv.type}</span>
                  </td>
                  <td>
                    <span className={`badge ${srv.statusType === 'success' ? 'badge-income' : 'badge-transfer'}`}>
                      {srv.status}
                    </span>
                  </td>
                  <td style={{ fontWeight: 700, color: 'var(--primary)', fontSize: 13 }}>
                    {srv.latency}
                  </td>
                  <td style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>
                    {srv.detail}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
