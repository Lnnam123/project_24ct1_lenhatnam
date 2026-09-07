import React from 'react';
import { AlertTriangle, Trash2, X, CheckCircle, PauseCircle, Lock, PlayCircle } from 'lucide-react';

export default function ConfirmModal({
  isOpen,
  title = 'Xác nhận hành động',
  message = 'Bạn có chắc chắn muốn thực hiện hành động này không?',
  itemDetail = null,
  confirmText = 'Xác nhận',
  cancelText = 'Huỷ bỏ',
  isDanger = true,
  type = null, // 'danger' | 'warning' | 'success' | 'info'
  icon: CustomIcon = null,
  confirmIcon: ConfirmCustomIcon = null,
  isLoading = false,
  onConfirm,
  onClose
}) {
  if (!isOpen) return null;

  // Xác định theme màu dựa trên type hoặc isDanger
  const effectiveType = type || (isDanger ? 'danger' : 'info');

  let headerBg = '#FEF2F2';
  let headerColor = '#EF4444';
  let headerBorder = '1px solid #FEE2E2';
  let confirmBtnClass = 'btn-danger';
  let DefaultIcon = AlertTriangle;

  if (effectiveType === 'warning') {
    headerBg = '#FFFBEB';
    headerColor = '#D97706';
    headerBorder = '1px solid #FDE68A';
    confirmBtnClass = 'btn-warning';
    DefaultIcon = PauseCircle;
  } else if (effectiveType === 'success') {
    headerBg = '#ECFDF5';
    headerColor = '#059669';
    headerBorder = '1px solid #A7F3D0';
    confirmBtnClass = 'btn-success';
    DefaultIcon = CheckCircle;
  } else if (effectiveType === 'info') {
    headerBg = '#EFF6FF';
    headerColor = '#2563EB';
    headerBorder = '1px solid #BFDBFE';
    confirmBtnClass = 'btn-primary';
    DefaultIcon = PlayCircle;
  } else if (effectiveType === 'lock') {
    headerBg = '#FEF2F2';
    headerColor = '#DC2626';
    headerBorder = '1px solid #FEE2E2';
    confirmBtnClass = 'btn-danger';
    DefaultIcon = Lock;
  }

  const RenderIcon = CustomIcon || DefaultIcon;

  return (
    <div className="modal-overlay" onClick={onClose} style={{ zIndex: 1100 }}>
      <div 
        className="modal-box" 
        onClick={(e) => e.stopPropagation()}
        style={{ maxWidth: 460, borderRadius: 16, overflow: 'hidden', boxShadow: '0 20px 40px rgba(0,0,0,0.2)' }}
      >
        <div style={{ padding: '24px 24px 20px 24px' }}>
          <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
            <div 
              style={{ 
                width: 48, 
                height: 48, 
                borderRadius: '50%', 
                background: headerBg, 
                color: headerColor,
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'center',
                flexShrink: 0,
                border: headerBorder
              }}
            >
              <RenderIcon size={24} />
            </div>

            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                <h3 style={{ fontSize: 17, fontWeight: 800, color: 'var(--text-main)', margin: 0 }}>
                  {title}
                </h3>
                <button 
                  className="action-btn" 
                  onClick={onClose}
                  style={{ width: 28, height: 28, border: 'none' }}
                >
                  <X size={16} />
                </button>
              </div>

              <p style={{ fontSize: 13.5, color: 'var(--text-muted)', margin: '0 0 12px 0', lineHeight: 1.5, whiteSpace: 'pre-line' }}>
                {message}
              </p>

              {itemDetail && (
                <div 
                  style={{ 
                    background: '#F8FAFC', 
                    borderRadius: 10, 
                    padding: '12px 14px', 
                    border: '1px solid var(--border-color)',
                    fontSize: 13,
                    color: 'var(--text-main)',
                    marginBottom: 8
                  }}
                >
                  {itemDetail}
                </div>
              )}
            </div>
          </div>
        </div>

        <div 
          style={{ 
            background: '#F8FAFC', 
            padding: '14px 24px', 
            display: 'flex', 
            justifyContent: 'flex-end', 
            gap: 10,
            borderTop: '1px solid var(--border-color)'
          }}
        >
          <button 
            type="button" 
            className="btn btn-secondary btn-sm" 
            onClick={onClose}
            disabled={isLoading}
          >
            {cancelText}
          </button>
          <button 
            type="button" 
            className={`btn ${confirmBtnClass} btn-sm`}
            onClick={onConfirm}
            disabled={isLoading}
            style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontWeight: 600 }}
          >
            {ConfirmCustomIcon ? (
              <ConfirmCustomIcon size={14} />
            ) : (
              effectiveType === 'danger' ? <Trash2 size={14} /> : null
            )}
            <span>{isLoading ? 'Đang xử lý...' : confirmText}</span>
          </button>
        </div>
      </div>
    </div>
  );
}
