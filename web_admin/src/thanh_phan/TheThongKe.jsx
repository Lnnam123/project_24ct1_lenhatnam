import React from 'react';

export default function StatCard({ title, value, icon: Icon, color, badgeText, rightAction }) {
  return (
    <div className="stat-card">
      <div className="stat-header">
        <div className={`stat-icon ${color}`}>
          <Icon size={22} />
        </div>
        {rightAction ? rightAction : (badgeText && <span className="stat-badge">{badgeText}</span>)}
      </div>
      <div>
        <div className="stat-value" style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
          <span>{value}</span>
        </div>
        <div className="stat-label">{title}</div>
      </div>
    </div>
  );
}
