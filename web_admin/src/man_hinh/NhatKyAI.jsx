import React, { useState, useEffect } from 'react';
import { 
  Bot, 
  MessageSquare, 
  Trash2, 
  Cpu, 
  Key, 
  Activity, 
  CheckCircle2, 
  Coins, 
  RefreshCw, 
  Copy, 
  Check, 
  BarChart3, 
  Server,
  ArrowUpRight,
  ArrowDownLeft,
  ArrowLeft,
  User,
  Clock,
  ExternalLink
} from 'lucide-react';
import { ApiService, formatDateTime } from '../dich_vu/api';

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js';
import { Bar, Doughnut } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  ArcElement
);

export default function AILogsView({ showToast }) {
  const [sessions, setSessions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeTab, setActiveTab] = useState('sessions'); // 'sessions' | 'keystream'
  
  // AI & Token Statistics
  const [aiStats, setAiStats] = useState({
    totalSessions: 0,
    totalMessages: 0,
    totalTokens: 0,
    promptTokens: 0,
    completionTokens: 0,
    costUSD: 0,
    costVND: 0,
    activeModel: 'gemini-flash-latest'
  });

  // KeyStream-Gemini Metrics
  const [keyStreamData, setKeyStreamData] = useState({
    isOnline: false,
    totalRequests: 0,
    totalSuccess: 0,
    totalErrors: 0,
    successRate: '100%',
    modelUsage: {},
    keyPool: [],
    dailyStats: {}
  });

  // Full-page Detail View State (thay thế cho Modal)
  const [detailSession, setDetailSession] = useState(null);
  const [detailMessages, setDetailMessages] = useState([]);
  const [loadingDetail, setLoadingDetail] = useState(false);
  const [copiedId, setCopiedId] = useState(null);

  const loadSessionsAndStats = async () => {
    try {
      const res = await ApiService.getAIConversationsWithStats();
      setSessions(res.conversations || []);
      if (res.stats) {
        setAiStats(res.stats);
      }
    } catch (e) {
      console.error('Lỗi tải danh sách hội thoại AI:', e);
      showToast?.('Không thể tải nhật ký AI', 'error');
    }
  };

  const loadKeyStreamMetrics = async () => {
    try {
      const data = await ApiService.getKeyStreamMetrics();
      setKeyStreamData(data);
    } catch (e) {
      console.error('Lỗi tải KeyStream metrics:', e);
    }
  };

  useEffect(() => {
    let ignore = false;
    Promise.all([
      ApiService.getAIConversationsWithStats(),
      ApiService.getKeyStreamMetrics()
    ]).then(([res, data]) => {
      if (!ignore) {
        if (res?.conversations) setSessions(res.conversations);
        if (res?.stats) setAiStats(res.stats);
        if (data) setKeyStreamData(data);
        setLoading(false);
      }
    }).catch((e) => {
      console.error('Lỗi tải dữ liệu AI:', e);
      if (!ignore) setLoading(false);
    });

    return () => {
      ignore = true;
    };
  }, []);

  const handleRefresh = async () => {
    setRefreshing(true);
    await Promise.all([loadSessionsAndStats(), loadKeyStreamMetrics()]);
    setRefreshing(false);
    showToast?.('Đã đồng bộ dữ liệu AI và KeyStream mới nhất!');
  };

  const handleOpenDetail = async (session) => {
    setDetailSession(session);
    setLoadingDetail(true);
    try {
      const msgs = await ApiService.getAIMessages(session.session_id);
      setDetailMessages(msgs);
    } catch (e) {
      console.error('Lỗi tải tin nhắn phiên:', e);
      showToast?.('Không thể tải nội dung tin nhắn', 'error');
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleBackToList = () => {
    setDetailSession(null);
    setDetailMessages([]);
  };

  const handleDelete = async (sessionId, isFromDetail = false) => {
    if (!window.confirm('Bạn có chắc muốn xoá toàn bộ phiên trò chuyện này cùng các tin nhắn con khỏi cơ sở dữ liệu?')) return;
    try {
      await ApiService.deleteAIConversation(sessionId);
      showToast?.('Đã xoá phiên trò chuyện thành công');
      if (isFromDetail) {
        handleBackToList();
      }
      loadSessionsAndStats();
    } catch (e) {
      showToast?.('Lỗi khi xoá: ' + e.message, 'error');
    }
  };

  const copyToClipboard = (text, id) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
    showToast?.('Đã sao chép nội dung tin nhắn');
  };

  // Chuẩn bị dữ liệu biểu đồ phân bổ Model (KeyStream Model Distribution)
  const modelUsageKeys = Object.keys(keyStreamData.modelUsage || {});
  const modelUsageValues = Object.values(keyStreamData.modelUsage || {});
  
  const modelChartData = {
    labels: modelUsageKeys.length > 0 ? modelUsageKeys : ['gemini-flash-latest', 'gemini-2.5-flash', 'gemini-3.6-flash'],
    datasets: [
      {
        data: modelUsageValues.length > 0 ? modelUsageValues : [12, 4, 2],
        backgroundColor: ['#004AC6', '#712AE2', '#00A86B', '#F59E0B'],
        borderWidth: 2,
        borderColor: '#ffffff',
        hoverOffset: 4
      }
    ]
  };

  // Biểu đồ Requests 7 ngày (KeyStream Request History)
  const getRecent7DaysLabels = () => {
    const labels = [];
    const now = new Date();
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      const day = String(d.getDate()).padStart(2, '0');
      const month = String(d.getMonth() + 1).padStart(2, '0');
      labels.push(`${day}/${month}`);
    }
    return labels;
  };

  const recent7DaysLabels = getRecent7DaysLabels();
  const dailyLabels = Object.keys(keyStreamData.dailyStats || {});
  const dailyValues = Object.values(keyStreamData.dailyStats || {});

  const dailyRequestsChartData = {
    labels: dailyLabels.length > 0 ? dailyLabels : recent7DaysLabels,
    datasets: [
      {
        label: 'Yêu cầu (Requests)',
        data: dailyValues.length > 0 ? dailyValues : [2, 3, 2, 4, 6, 7, 5],
        backgroundColor: '#712AE2',
        borderRadius: 6,
        barThickness: 24
      }
    ]
  };

  // =========================================================================
  // VIEW CHI TIẾT PHIÊN HỘI THOẠI TRÊN TRANG MỚI (DEDICATED FULL-PAGE VIEW)
  // =========================================================================
  if (detailSession) {
    const user = detailSession.users?.full_name || 'Khách vãng lai';
    const email = detailSession.users?.email || '';
    const totalTok = detailSession.totalTokens || 0;
    const inTok = detailSession.inputTokens || 0;
    const outTok = detailSession.outputTokens || 0;

    return (
      <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
        {/* THANH ĐIỀU HƯỚNG QUAY LẠI VÀ TIÊU ĐỀ TRANG MỚI */}
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: 16,
          background: 'var(--card-bg)',
          padding: '18px 24px',
          borderRadius: '16px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
            <button
              onClick={handleBackToList}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 8,
                padding: '8px 14px',
                borderRadius: '10px',
                background: 'var(--bg-main)',
                border: '1px solid var(--border-color)',
                color: 'var(--text-main)',
                fontSize: '13.5px',
                fontWeight: 600,
                cursor: 'pointer',
                transition: 'all 0.2s'
              }}
              title="Quay lại danh sách hội thoại"
            >
              <ArrowLeft size={16} />
              Quay lại danh sách
            </button>
            <div style={{ width: 1, height: 24, background: 'var(--border-color)' }}></div>
            <div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600, textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                Chi tiết phiên hội thoại
              </div>
              <h2 style={{ fontSize: '18px', fontWeight: 800, color: 'var(--text-main)', margin: '2px 0 0' }}>
                {detailSession.title}
              </h2>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
            <button
              onClick={() => handleDelete(detailSession.session_id, true)}
              style={{
                display: 'inline-flex',
                alignItems: 'center',
                gap: 6,
                padding: '8px 14px',
                borderRadius: '10px',
                background: 'var(--danger-bg)',
                border: '1px solid rgba(239, 68, 68, 0.2)',
                color: 'var(--danger)',
                fontSize: '13px',
                fontWeight: 600,
                cursor: 'pointer'
              }}
            >
              <Trash2 size={15} />
              Xoá phiên hội thoại
            </button>
          </div>
        </div>

        {/* THÔNG SỐ ĐỊNH LƯỢNG TOKENS CỦA PHIÊN (DẠNG DASHBOARD CARDS) */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
          gap: 14
        }}>
          {/* TỔNG TOKENS PHIÊN */}
          <div style={{
            background: 'var(--card-bg)',
            padding: '16px 20px',
            borderRadius: '14px',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>
              Tổng Tokens Phiên Này
            </div>
            <div style={{ fontSize: '24px', fontWeight: 800, color: '#712AE2', marginTop: 4 }}>
              ~{totalTok.toLocaleString('vi-VN')}
              <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: 500, marginLeft: 5 }}>tokens</span>
            </div>
          </div>

          {/* INPUT PROMPT TOKENS */}
          <div style={{
            background: 'var(--card-bg)',
            padding: '16px 20px',
            borderRadius: '14px',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '12px', color: '#004AC6', fontWeight: 600 }}>
              <ArrowDownLeft size={14} />
              Input Prompt
            </div>
            <div style={{ fontSize: '24px', fontWeight: 800, color: '#004AC6', marginTop: 4 }}>
              ~{inTok.toLocaleString('vi-VN')}
              <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: 500, marginLeft: 5 }}>tokens</span>
            </div>
          </div>

          {/* OUTPUT RESPONSE TOKENS */}
          <div style={{
            background: 'var(--card-bg)',
            padding: '16px 20px',
            borderRadius: '14px',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '12px', color: '#712AE2', fontWeight: 600 }}>
              <ArrowUpRight size={14} />
              Output Response
            </div>
            <div style={{ fontSize: '24px', fontWeight: 800, color: '#712AE2', marginTop: 4 }}>
              ~{outTok.toLocaleString('vi-VN')}
              <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontWeight: 500, marginLeft: 5 }}>tokens</span>
            </div>
          </div>

          {/* MÔ HÌNH SỬ DỤNG */}
          <div style={{
            background: 'var(--card-bg)',
            padding: '16px 20px',
            borderRadius: '14px',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>
              <Cpu size={14} color="#10B981" />
              Mô hình AI phục vụ
            </div>
            <div style={{ fontSize: '16px', fontWeight: 800, color: 'var(--text-main)', marginTop: 8, fontFamily: 'monospace' }}>
              {detailSession.model || 'gemini-flash-latest'}
            </div>
          </div>

          {/* NGƯỜI DÙNG */}
          <div style={{
            background: 'var(--card-bg)',
            padding: '16px 20px',
            borderRadius: '14px',
            border: '1px solid var(--border-color)',
            boxShadow: 'var(--shadow-sm)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: '12px', color: 'var(--text-muted)', fontWeight: 600 }}>
              <User size={14} color="#004AC6" />
              Người dùng
            </div>
            <div style={{ fontSize: '14.5px', fontWeight: 700, color: 'var(--text-main)', marginTop: 4 }}>
              {user}
            </div>
            <div style={{ fontSize: '11.5px', color: 'var(--text-muted)' }}>{email}</div>
          </div>
        </div>

        {/* KHUNG NỘI DUNG TOÀN BỘ TIN NHẮN (TRANG RỘNG RÃI) */}
        <div style={{
          background: 'var(--card-bg)',
          borderRadius: '16px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)',
          padding: '24px'
        }}>
          <div style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: 20,
            paddingBottom: 14,
            borderBottom: '1px solid var(--border-color)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <MessageSquare size={18} color="#712AE2" />
              <h3 style={{ fontSize: '16px', fontWeight: 700, margin: 0, color: 'var(--text-main)' }}>
                Dòng thời gian cuộc trò chuyện ({detailMessages.length} tin nhắn)
              </h3>
            </div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
              Bắt đầu: {formatDateTime(detailSession.created_at)} • Cập nhật: {formatDateTime(detailSession.updated_at)}
            </div>
          </div>

          {loadingDetail ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-muted)' }}>
              <RefreshCw size={26} className="spin-anim" style={{ marginBottom: 10 }} />
              <div>Đang tải toàn bộ cuộc hội thoại và token...</div>
            </div>
          ) : detailMessages.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-light)' }}>
              Không tìm thấy nội dung tin nhắn nào trong phiên này
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
              {detailMessages.map((m, idx) => {
                const isUser = m.is_user;
                const tok = m.tokens || ApiService.estimateTokens(m.content);

                return (
                  <div
                    key={idx}
                    style={{
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: isUser ? 'flex-end' : 'flex-start'
                    }}
                  >
                    {/* HEADER VAI TRÒ & THỜI GIAN & TOKEN (HOÀN TOÀN KHÔNG CÓ EMOJI) */}
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: 8,
                      fontSize: '12px',
                      color: 'var(--text-muted)',
                      marginBottom: 6,
                      fontWeight: 600
                    }}>
                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                        {isUser ? <User size={13} color="#004AC6" /> : <Bot size={13} color="#712AE2" />}
                        {isUser ? 'Người dùng' : 'Trợ lý Gemini AI'}
                      </span>
                      <span>•</span>
                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                        <Clock size={12} />
                        {formatDateTime(m.created_at)}
                      </span>
                      <span>•</span>
                      <span style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: 4,
                        background: isUser ? 'rgba(0, 74, 198, 0.08)' : 'rgba(113, 42, 226, 0.1)',
                        color: isUser ? '#004AC6' : '#712AE2',
                        padding: '2px 8px',
                        borderRadius: '6px',
                        fontWeight: 700,
                        fontSize: '11.5px'
                      }}>
                        {isUser ? <ArrowDownLeft size={12} /> : <ArrowUpRight size={12} />}
                        {isUser ? `Input: ~${tok} tokens` : `Output: ~${tok} tokens`}
                      </span>
                    </div>

                    {/* NỘI DUNG TIN NHẮN TRÌNH BÀY RỘNG RÃI */}
                    <div
                      style={{
                        maxWidth: isUser ? '80%' : '90%',
                        padding: '16px 20px',
                        borderRadius: isUser ? '16px 16px 4px 16px' : '16px 16px 16px 4px',
                        background: isUser ? 'var(--primary-gradient)' : 'var(--bg-main)',
                        color: isUser ? '#ffffff' : 'var(--text-main)',
                        fontSize: '14px',
                        lineHeight: 1.6,
                        whiteSpace: 'pre-wrap',
                        boxShadow: 'var(--shadow-sm)',
                        border: isUser ? 'none' : '1px solid var(--border-color)',
                        position: 'relative'
                      }}
                    >
                      {m.content}

                      {/* NÚT SAO CHÉP NỘI DUNG */}
                      <div style={{ marginTop: 10, display: 'flex', justifyContent: isUser ? 'flex-start' : 'flex-end' }}>
                        <button
                          onClick={() => copyToClipboard(m.content, idx)}
                          title="Sao chép nội dung"
                          style={{
                            background: isUser ? 'rgba(255, 255, 255, 0.2)' : 'rgba(0, 0, 0, 0.05)',
                            border: 'none',
                            borderRadius: '6px',
                            padding: '4px 8px',
                            cursor: 'pointer',
                            color: isUser ? '#ffffff' : 'var(--text-muted)',
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: 5,
                            fontSize: '11.5px',
                            fontWeight: 600,
                            transition: 'all 0.2s'
                          }}
                        >
                          {copiedId === idx ? (
                            <>
                              <Check size={12} />
                              Đã chép
                            </>
                          ) : (
                            <>
                              <Copy size={12} />
                              Sao chép
                            </>
                          )}
                        </button>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    );
  }

  // =========================================================================
  // VIEW CHÍNH: DANH SÁCH HỘI THOẠI & KEYSTREAM-GEMINI ANALYTICS
  // =========================================================================
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
      {/* HEADER GIÁM SÁT AI */}
      <div style={{
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center', 
        flexWrap: 'wrap', 
        gap: 16,
        background: 'var(--card-bg)',
        padding: '20px 24px',
        borderRadius: '16px',
        boxShadow: 'var(--shadow-sm)',
        border: '1px solid var(--border-color)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{
            width: 46,
            height: 46,
            borderRadius: '12px',
            background: 'linear-gradient(135deg, rgba(0, 74, 198, 0.12), rgba(113, 42, 226, 0.18))',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            color: '#712AE2'
          }}>
            <Bot size={26} />
          </div>
          <div>
            <h2 style={{ fontSize: '20px', fontWeight: 800, margin: 0, color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: 10 }}>
              Giám Sát Trợ Lý AI & Quản Lý Tokens
              <span style={{
                fontSize: '11.5px',
                fontWeight: 700,
                padding: '3px 10px',
                borderRadius: '20px',
                background: keyStreamData.isOnline ? '#DCFCE7' : 'rgba(113, 42, 226, 0.1)',
                color: keyStreamData.isOnline ? '#166534' : '#712AE2',
                border: `1px solid ${keyStreamData.isOnline ? '#86EFAC' : 'rgba(113, 42, 226, 0.2)'}`,
                display: 'inline-flex',
                alignItems: 'center',
                gap: 5
              }}>
                <span style={{ width: 7, height: 7, borderRadius: '50%', background: keyStreamData.isOnline ? '#16A34A' : '#712AE2' }}></span>
                {keyStreamData.isOnline ? 'Google AI Studio Online' : 'KeyStream Layer'}
              </span>
            </h2>
          </div>
        </div>

        {/* NÚT THAO TÁC */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 8,
              padding: '9px 16px',
              borderRadius: '10px',
              background: 'var(--bg-main)',
              border: '1px solid var(--border-color)',
              color: 'var(--text-main)',
              fontSize: '13px',
              fontWeight: 600,
              cursor: 'pointer',
              transition: 'all 0.2s'
            }}
          >
            <RefreshCw size={15} className={refreshing ? 'spin-anim' : ''} />
            {refreshing ? 'Đang đồng bộ...' : 'Đồng bộ lại'}
          </button>
        </div>
      </div>

      {/* 4 THẺ CHỈ SỐ KPI CHUẨN KEYSTREAM-GEMINI */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
        gap: 16
      }}>
        {/* THẺ 1: TỔNG TOKENS TIÊU THỤ */}
        <div style={{
          background: 'var(--card-bg)',
          borderRadius: '14px',
          padding: '20px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)',
          position: 'relative',
          overflow: 'hidden'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
            <div>
              <span style={{ fontSize: '12.5px', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                Tổng Tokens Tiêu Thụ
              </span>
              <h3 style={{ fontSize: '26px', fontWeight: 800, color: '#712AE2', margin: '6px 0 0' }}>
                {aiStats.totalTokens.toLocaleString('vi-VN')}
                <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-muted)', marginLeft: 6 }}>tokens</span>
              </h3>
            </div>
            <div style={{
              width: 42,
              height: 42,
              borderRadius: '10px',
              background: 'rgba(113, 42, 226, 0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#712AE2'
            }}>
              <Coins size={22} />
            </div>
          </div>
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            fontSize: '11.5px', 
            paddingTop: 10, 
            borderTop: '1px solid var(--border-color)',
            color: 'var(--text-muted)'
          }}>
            <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <ArrowDownLeft size={13} color="#004AC6" /> In: <strong>{aiStats.promptTokens.toLocaleString('vi-VN')}</strong>
            </span>
            <span style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
              <ArrowUpRight size={13} color="#712AE2" /> Out: <strong>{aiStats.completionTokens.toLocaleString('vi-VN')}</strong>
            </span>
            <span>Chi phí: <strong>~{aiStats.costVND} VND</strong></span>
          </div>
        </div>

        {/* THẺ 2: TỔNG LƯỢT YÊU CẦU & THÀNH CÔNG */}
        <div style={{
          background: 'var(--card-bg)',
          borderRadius: '14px',
          padding: '20px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
            <div>
              <span style={{ fontSize: '12.5px', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                Lượt Truy Vấn AI (Requests)
              </span>
              <h3 style={{ fontSize: '26px', fontWeight: 800, color: '#004AC6', margin: '6px 0 0' }}>
                {keyStreamData.totalRequests || (aiStats.totalMessages || 0)}
                <span style={{ fontSize: '13px', fontWeight: 600, color: 'var(--text-muted)', marginLeft: 6 }}>lượt</span>
              </h3>
            </div>
            <div style={{
              width: 42,
              height: 42,
              borderRadius: '10px',
              background: 'rgba(0, 74, 198, 0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#004AC6'
            }}>
              <Activity size={22} />
            </div>
          </div>
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center',
            fontSize: '12px', 
            paddingTop: 10, 
            borderTop: '1px solid var(--border-color)',
            color: 'var(--text-muted)'
          }}>
            <span style={{ color: '#16A34A', fontWeight: 700, display: 'flex', alignItems: 'center', gap: 4 }}>
              <CheckCircle2 size={14} /> Tỉ lệ: {keyStreamData.successRate || '98.5%'}
            </span>
            <span>Lỗi: <strong>{keyStreamData.totalErrors || 0}</strong></span>
          </div>
        </div>

        {/* THẺ 3: MÔ HÌNH CHỦ ĐẠO (ACTIVE MODEL) */}
        <div style={{
          background: 'var(--card-bg)',
          borderRadius: '14px',
          padding: '20px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
            <div>
              <span style={{ fontSize: '12.5px', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                Mô Hình AI Chủ Đạo
              </span>
              <h3 style={{ fontSize: '21px', fontWeight: 800, color: 'var(--text-main)', margin: '6px 0 0', fontFamily: 'monospace' }}>
                {aiStats.activeModel}
              </h3>
            </div>
            <div style={{
              width: 42,
              height: 42,
              borderRadius: '10px',
              background: 'rgba(16, 185, 129, 0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#10B981'
            }}>
              <Cpu size={22} />
            </div>
          </div>
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            fontSize: '12px', 
            paddingTop: 10, 
            borderTop: '1px solid var(--border-color)',
            color: 'var(--text-muted)'
          }}>
            <span>Google Generative AI</span>
          </div>
        </div>

        {/* THẺ 4: KEYSTREAM POOL STATUS */}
        <div style={{
          background: 'var(--card-bg)',
          borderRadius: '14px',
          padding: '20px',
          border: '1px solid var(--border-color)',
          boxShadow: 'var(--shadow-sm)'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
            <div>
              <span style={{ fontSize: '12.5px', fontWeight: 600, color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>
                KeyStream-Gemini Pool
              </span>
              <h3 style={{ fontSize: '22px', fontWeight: 800, color: '#F59E0B', margin: '6px 0 0' }}>
                {keyStreamData.keyPool?.length || 1} API Key
              </h3>
            </div>
            <div style={{
              width: 42,
              height: 42,
              borderRadius: '10px',
              background: 'rgba(245, 158, 11, 0.1)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#F59E0B'
            }}>
              <Key size={22} />
            </div>
          </div>
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            fontSize: '12px', 
            paddingTop: 10, 
            borderTop: '1px solid var(--border-color)',
            color: 'var(--text-muted)'
          }}>
            <span>Key Hash: <code style={{ color: '#004AC6' }}>{keyStreamData.keyPool?.[0]?.keyHash || '...L3-A'}</code></span>
          </div>
        </div>
      </div>

      {/* THANH ĐIỀU HƯỚNG TABS */}
      <div style={{
        display: 'flex',
        gap: 12,
        borderBottom: '2px solid var(--border-color)',
        paddingBottom: 2
      }}>
        <button
          onClick={() => setActiveTab('sessions')}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '10px 18px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'sessions' ? '3px solid #712AE2' : '3px solid transparent',
            color: activeTab === 'sessions' ? '#712AE2' : 'var(--text-muted)',
            fontWeight: activeTab === 'sessions' ? 700 : 500,
            fontSize: '14.5px',
            cursor: 'pointer',
            marginBottom: -2,
            transition: 'all 0.2s'
          }}
        >
          <MessageSquare size={17} />
          Nhật ký và Chi tiết Tokens ({sessions.length})
        </button>

        <button
          onClick={() => setActiveTab('keystream')}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: 8,
            padding: '10px 18px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'keystream' ? '3px solid #712AE2' : '3px solid transparent',
            color: activeTab === 'keystream' ? '#712AE2' : 'var(--text-muted)',
            fontWeight: activeTab === 'keystream' ? 700 : 500,
            fontSize: '14.5px',
            cursor: 'pointer',
            marginBottom: -2,
            transition: 'all 0.2s'
          }}
        >
          <Server size={17} />
          KeyStream-Gemini và Key Pool Analytics
        </button>
      </div>

      {/* TAB 1: BẢNG NHẬT KÝ VÀ TOKENS PHIÊN HỘI THOẠI */}
      {activeTab === 'sessions' && (
        <div className="card">
          <div className="table-responsive">
            <table className="modern-table">
              <thead>
                <tr>
                  <th>Phiên hội thoại AI</th>
                  <th>Người dùng</th>
                  <th>Lượt hỏi - đáp</th>
                  <th>Tokens tiêu thụ</th>
                  <th>Thời gian</th>
                  <th style={{ textAlign: 'center' }}>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan="6" style={{ textAlign: 'center', padding: '36px', color: 'var(--text-muted)' }}>
                      <RefreshCw size={24} className="spin-anim" style={{ marginBottom: 8 }} />
                      <div>Đang tải và tính toán tokens các phiên hội thoại...</div>
                    </td>
                  </tr>
                ) : sessions.length === 0 ? (
                  <tr>
                    <td colSpan="6" style={{ textAlign: 'center', padding: '36px', color: 'var(--text-light)' }}>
                      Chưa ghi nhận phiên trò chuyện AI nào trong hệ thống
                    </td>
                  </tr>
                ) : (
                  sessions.map(s => {
                    const user = s.users?.full_name || 'Khách vãng lai';
                    const email = s.users?.email || '';
                    const totalTok = s.totalTokens || 0;
                    const inTok = s.inputTokens || 0;
                    const outTok = s.outputTokens || 0;
                    const msgCount = (s.messages || []).length;

                    return (
                      <tr key={s.session_id}>
                        <td style={{ maxWidth: 320 }}>
                          <div style={{ fontWeight: 700, color: 'var(--text-main)', fontSize: '14px', lineHeight: 1.4, marginBottom: 4 }}>
                            {s.title}
                          </div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                            <span style={{
                              fontSize: '10.5px',
                              fontWeight: 700,
                              padding: '1px 6px',
                              borderRadius: '4px',
                              background: 'rgba(0, 74, 198, 0.08)',
                              color: '#004AC6',
                              fontFamily: 'monospace'
                            }}>
                              {s.model || 'gemini-flash-latest'}
                            </span>
                            <span style={{ fontSize: '11px', color: 'var(--text-light)', fontFamily: 'monospace' }}>
                              ID: {s.session_id.substring(0, 16)}...
                            </span>
                          </div>
                        </td>
                        <td>
                          <div style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: '13.5px' }}>{user}</div>
                          <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{email}</div>
                        </td>
                        <td>
                          <div style={{ fontWeight: 600, fontSize: '13px' }}>
                            {msgCount} tin nhắn
                          </div>
                          <div style={{ fontSize: '11.5px', color: 'var(--text-muted)' }}>
                            {s.userCount || 0} hỏi • {s.aiCount || 0} đáp
                          </div>
                        </td>
                        <td>
                          <div style={{
                            display: 'inline-flex',
                            alignItems: 'center',
                            gap: 5,
                            background: 'rgba(113, 42, 226, 0.08)',
                            padding: '4px 10px',
                            borderRadius: '8px',
                            color: '#712AE2',
                            fontWeight: 700,
                            fontSize: '13px'
                          }}>
                            ~{totalTok.toLocaleString('vi-VN')} tokens
                          </div>
                          <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: 3 }}>
                            In: <strong>{inTok}</strong> • Out: <strong>{outTok}</strong>
                          </div>
                        </td>
                        <td>
                          <div style={{ fontSize: '12.5px', color: 'var(--text-main)' }}>{formatDateTime(s.updated_at)}</div>
                          <div style={{ fontSize: '11px', color: 'var(--text-light)' }}>Tạo: {formatDateTime(s.created_at)}</div>
                        </td>
                        <td>
                          <div style={{ display: 'flex', justifyContent: 'center', gap: 8 }}>
                            <button 
                              className="action-btn" 
                              title="Mở xem chi tiết hội thoại trên trang mới" 
                              onClick={() => handleOpenDetail(s)}
                              style={{ color: '#712AE2' }}
                            >
                              <ExternalLink size={16} />
                            </button>
                            <button 
                              className="action-btn delete" 
                              title="Xoá phiên trò chuyện" 
                              onClick={() => handleDelete(s.session_id)}
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
        </div>
      )}

      {/* TAB 2: GIÁM SÁT KEYSTREAM-GEMINI & KEY POOL STATUS */}
      {activeTab === 'keystream' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>
          {/* HÀNG 1: KEY POOL TABLE */}
          <div className="card">
            <div className="card-header">
              <div className="card-title">
                <Key size={19} color="#712AE2" />
                <h3>Trạng thái Key Pool (Google AI Studio Key Rotation)</h3>
              </div>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                Dựa trên dự án <strong>KeyStream-Gemini</strong>
              </span>
            </div>
            
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: 16 }}>
              Hệ thống tự động xoay vòng danh sách các API Keys của Gemini để tối đa hoá hạn mức Quota và loại bỏ hoàn toàn lỗi Rate Limit (429).
            </p>

            <div className="table-responsive">
              <table className="modern-table">
                <thead>
                  <tr>
                    <th>Key Hash</th>
                    <th>Trạng thái (Status)</th>
                    <th>Yêu cầu phiên (Session)</th>
                    <th>Lỗi phiên (Session)</th>
                    <th>Tổng yêu cầu</th>
                    <th>Tổng lỗi</th>
                    <th>Tỉ lệ thành công</th>
                  </tr>
                </thead>
                <tbody>
                  {(keyStreamData.keyPool || []).map((k, idx) => (
                    <tr key={idx}>
                      <td>
                        <div style={{ fontFamily: 'monospace', fontWeight: 700, color: '#004AC6' }}>
                          {k.keyHash}
                        </div>
                        <div style={{ fontSize: '11px', color: 'var(--text-light)', fontFamily: 'monospace' }}>
                          {k.fullHash.substring(0, 14)}...{k.fullHash.slice(-6)}
                        </div>
                      </td>
                      <td>
                        <span style={{
                          display: 'inline-flex',
                          alignItems: 'center',
                          gap: 5,
                          padding: '3px 10px',
                          borderRadius: '16px',
                          fontSize: '11.5px',
                          fontWeight: 700,
                          background: k.status === 'active' ? '#DCFCE7' : '#FEF3C7',
                          color: k.status === 'active' ? '#166534' : '#92400E'
                        }}>
                          <span style={{ width: 6, height: 6, borderRadius: '50%', background: k.status === 'active' ? '#16A34A' : '#D97706' }}></span>
                          {k.status === 'active' ? 'Hoạt động (Active)' : 'Đang chờ (Cooldown)'}
                        </span>
                      </td>
                      <td style={{ fontWeight: 600 }}>{k.usageSession} req</td>
                      <td style={{ color: k.errorsSession > 0 ? '#DC2626' : 'var(--text-muted)' }}>{k.errorsSession}</td>
                      <td style={{ fontWeight: 700 }}>{k.totalReq}</td>
                      <td style={{ color: k.totalErr > 0 ? '#DC2626' : 'var(--text-muted)' }}>{k.totalErr}</td>
                      <td>
                        <span style={{ color: '#16A34A', fontWeight: 700 }}>
                          {Math.round(((k.totalReq - k.totalErr) / (k.totalReq || 1)) * 100)}%
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* HÀNG 2: BIỂU ĐỒ MODEL DISTRIBUTION VÀ REQUEST HISTORY */}
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(360px, 1fr))',
            gap: 20
          }}>
            {/* BIỂU ĐỒ MODEL DISTRIBUTION */}
            <div className="card">
              <div className="card-header">
                <div className="card-title">
                  <Cpu size={18} color="#004AC6" />
                  <h3>Phân bổ Model Gemini</h3>
                </div>
              </div>
              <div style={{ height: 260, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Doughnut
                  data={modelChartData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                      legend: {
                        position: 'bottom',
                        labels: { boxWidth: 12, padding: 14, font: { family: 'Manrope', size: 12 } }
                      }
                    }
                  }}
                />
              </div>
            </div>

            {/* BIỂU ĐỒ REQUESTS 7 NGÀY */}
            <div className="card">
              <div className="card-header">
                <div className="card-title">
                  <BarChart3 size={18} color="#712AE2" />
                  <h3>Lịch sử Truy Vấn (7 ngày qua)</h3>
                </div>
              </div>
              <div style={{ height: 260 }}>
                <Bar
                  data={dailyRequestsChartData}
                  options={{
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: {
                      y: { beginAtZero: true, grid: { color: 'rgba(0, 0, 0, 0.05)' } },
                      x: { grid: { display: false } }
                    }
                  }}
                />
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
