import React, { useState, useEffect } from 'react';
import { 
  Tags, 
  Plus, 
  Edit, 
  Trash2, 
  Search, 
  Check, 
  Sparkles, 
  HelpCircle,
  Layers,
  User,
  ShieldCheck,
  Filter
} from 'lucide-react';
import Modal from '../components/Modal';
import { ApiService } from '../services/api';

// Danh mục icon Google Material Symbols / Icons phong phú & đa dạng
const GOOGLE_FONT_ICONS = [
  // 1. Ăn uống & Thực phẩm (Food & Drinks)
  { name: 'restaurant', label: 'Nhà hàng, quán ăn', category: 'food', tags: 'an uong, nha hang, food, meal, eat, restaurant' },
  { name: 'fastfood', label: 'Đồ ăn nhanh', category: 'food', tags: 'fastfood, burger, an nhanh, snack' },
  { name: 'local_cafe', label: 'Cà phê, trà sữa', category: 'food', tags: 'cafe, coffee, tra sua, quan nuoc, drink' },
  { name: 'local_bar', label: 'Bia, quán bar', category: 'food', tags: 'bar, bia, ruou, pub, party, beer' },
  { name: 'ramen_dining', label: 'Mì, bún, phở', category: 'food', tags: 'mi, pho, bun, ramen, noodle, soup' },
  { name: 'lunch_dining', label: 'Cơm trưa, đồ ăn', category: 'food', tags: 'com trua, bua an, lunch, rice' },
  { name: 'local_pizza', label: 'Bánh Pizza', category: 'food', tags: 'pizza, banh, tiec' },
  { name: 'bakery_dining', label: 'Bánh mì, bánh ngọt', category: 'food', tags: 'banh mi, bakery, bread, cake' },
  { name: 'icecream', label: 'Kem, tráng miệng', category: 'food', tags: 'kem, icecream, an vat, dessert' },
  { name: 'liquor', label: 'Rượu tiệc', category: 'food', tags: 'ruou, liquor, tiec tung' },

  // 2. Mua sắm & Tiêu dùng (Shopping)
  { name: 'shopping_cart', label: 'Xe đẩy siêu thị', category: 'shopping', tags: 'sieu thi, mua sam, cart, grocery' },
  { name: 'shopping_bag', label: 'Túi mua sắm', category: 'shopping', tags: 'mua sam, shopping, bag, clothes' },
  { name: 'storefront', label: 'Cửa hàng, tạp hoá', category: 'shopping', tags: 'cua hang, shop, tap hoa, store' },
  { name: 'checkroom', label: 'Quần áo, thời trang', category: 'shopping', tags: 'quan ao, thoi trang, fashion, clothes' },
  { name: 'diamond', label: 'Trang sức, vàng bạc', category: 'shopping', tags: 'trang suc, vang, kim cuong, luxury' },
  { name: 'card_giftcard', label: 'Quà tặng, mừng tuổi', category: 'shopping', tags: 'qua tang, gift, li xi, sinh nhat' },
  { name: 'inventory_2', label: 'Đồ đạc, kiện hàng', category: 'shopping', tags: 'don hang, shopee, lazada, ship, package' },

  // 3. Di chuyển & Xe cộ (Transportation)
  { name: 'directions_car', label: 'Ô tô, xe hơi', category: 'transport', tags: 'o to, xe hoi, car, oto, drive' },
  { name: 'two_wheeler', label: 'Xe máy, xe mô tô', category: 'transport', tags: 'xe may, moto, bike, motorbike' },
  { name: 'local_gas_station', label: 'Xăng xe, nhiên liệu', category: 'transport', tags: 'xang xe, gas, nhien lieu, petrol' },
  { name: 'directions_bus', label: 'Xe buýt, xe khách', category: 'transport', tags: 'xe buyt, bus, transit, xe khach' },
  { name: 'local_taxi', label: 'Taxi, Grab', category: 'transport', tags: 'taxi, grab, be, cuoc xe, ride' },
  { name: 'flight', label: 'Vé máy bay, du lịch', category: 'transport', tags: 'may bay, flight, ve, du lich, airplane' },
  { name: 'train', label: 'Tàu hoả, ga tàu', category: 'transport', tags: 'tau hoa, train, metro, duong sat' },
  { name: 'directions_bike', label: 'Xe đạp', category: 'transport', tags: 'xe dap, bicycle, the thao' },
  { name: 'car_repair', label: 'Sửa chữa xe', category: 'transport', tags: 'sua xe, bao duong, garage, fix' },

  // 4. Nhà ở & Sinh hoạt (Housing & Bills)
  { name: 'home', label: 'Nhà ở, tiền trọ', category: 'housing', tags: 'nha o, tien tro, phong tro, home, rent' },
  { name: 'apartment', label: 'Chung cư, căn hộ', category: 'housing', tags: 'chung cu, can ho, apartment, building' },
  { name: 'bolt', label: 'Tiền điện', category: 'housing', tags: 'tien dien, electric, power, nang luong' },
  { name: 'water_drop', label: 'Tiền nước', category: 'housing', tags: 'tien nuoc, water, sinh hoat' },
  { name: 'wifi', label: 'Mạng Internet, Wifi', category: 'housing', tags: 'wifi, internet, mang cap, 4g, 5g' },
  { name: 'phone_iphone', label: 'Điện thoại, thẻ cào', category: 'housing', tags: 'dien thoai, nap the, phone, cuoc goi' },
  { name: 'tv', label: 'Truyền hình, Netflix', category: 'housing', tags: 'tv, tivi, truyen hinh, netflix, subscription' },
  { name: 'receipt_long', label: 'Hoá đơn định kỳ', category: 'housing', tags: 'hoa don, receipt, bill, cuoc phi' },
  { name: 'cleaning_services', label: 'Dọn dẹp, vệ sinh', category: 'housing', tags: 've sinh, don nha, giat la, clean' },

  // 5. Giải trí & Sở thích (Entertainment)
  { name: 'sports_esports', label: 'Game, nạp game', category: 'entertainment', tags: 'game, choi game, nap game, esports' },
  { name: 'movie', label: 'Xem phim, rạp phim', category: 'entertainment', tags: 'phim, movie, rap chieu, cinema, film' },
  { name: 'music_note', label: 'Âm nhạc, Spotify', category: 'entertainment', tags: 'am nhac, nhac, music, song, spotify' },
  { name: 'fitness_center', label: 'Tập Gym, thể thao', category: 'entertainment', tags: 'gym, the hinh, workout, the thao' },
  { name: 'sports_soccer', label: 'Bóng đá, thể thao', category: 'entertainment', tags: 'bong da, football, soccer, the thao' },
  { name: 'celebration', label: 'Tiệc tùng, lễ hội', category: 'entertainment', tags: 'tiec, festival, party, sinh nhat' },
  { name: 'palette', label: 'Nghệ thuật, sở thích', category: 'entertainment', tags: 've, hoi hoa, art, hobby' },

  // 6. Y tế & Sức khoẻ (Health)
  { name: 'health_and_safety', label: 'Bảo hiểm, sức khoẻ', category: 'health', tags: 'bao hiem, suc khoe, an toan, health' },
  { name: 'medical_services', label: 'Khám bệnh, bác sĩ', category: 'health', tags: 'kham benh, bac si, y te, hospital, clinic' },
  { name: 'medication', label: 'Thuốc men, tiệm thuốc', category: 'health', tags: 'thuoc, pharmacy, duoc pham, pill' },
  { name: 'spa', label: 'Spa, làm đẹp, cắt tóc', category: 'health', tags: 'spa, lam dep, cat toc, massage, salon' },
  { name: 'dentistry', label: 'Nha khoa, răng hàm', category: 'health', tags: 'rang, nha khoa, dentist' },

  // 7. Giáo dục & Gia đình (Education & Family)
  { name: 'school', label: 'Trường học, học phí', category: 'education', tags: 'hoc tap, hoc phi, truong hoc, school, education' },
  { name: 'menu_book', label: 'Sách vở, tài liệu', category: 'education', tags: 'sach, vo, giao trinh, book, study' },
  { name: 'pets', label: 'Thú cưng, chó mèo', category: 'education', tags: 'thu cung, cho, meo, pet, dong vat' },
  { name: 'child_care', label: 'Con cái, trẻ nhỏ', category: 'education', tags: 'con cai, tre em, baby, bim sua' },

  // 8. Thu nhập & Đầu tư (Income)
  { name: 'payments', label: 'Tiền lương chính', category: 'income', tags: 'luong, payment, thu nhap, salary' },
  { name: 'attach_money', label: 'Tiền mặt, thu nhập', category: 'income', tags: 'tien, money, dollar, cash' },
  { name: 'savings', label: 'Tiết kiệm, heo đất', category: 'income', tags: 'tiet kiem, saving, heo dat, tich luy' },
  { name: 'trending_up', label: 'Đầu tư sinh lời, lãi', category: 'income', tags: 'dau tu, lai suat, invest, loi nhuan' },
  { name: 'account_balance', label: 'Ngân hàng, tài chính', category: 'income', tags: 'ngan hang, bank, tai khoan' },
  { name: 'currency_bitcoin', label: 'Tiền số, Crypto', category: 'income', tags: 'crypto, coin, bitcoin, blockchain' },
  { name: 'work', label: 'Thưởng công việc', category: 'income', tags: 'thuong, cong viec, job, bonus' },
  { name: 'more_time', label: 'Làm thêm, phụ cấp', category: 'income', tags: 'lam them, parttime, overtime, phu cap' },

  // 9. Khác (General)
  { name: 'category', label: 'Danh mục chung', category: 'general', tags: 'danh muc, chung, category' },
  { name: 'more_horiz', label: 'Khoản chi khác', category: 'general', tags: 'khac, more, others' },
  { name: 'star', label: 'Quan trọng, đặc biệt', category: 'general', tags: 'sao, star, uu tien' }
];

const PRESET_COLORS = [
  '#004AC6', // Royal Blue (CoinTap Main)
  '#712AE2', // Purple (CoinTap Accent)
  '#10B981', // Emerald Green
  '#F59E0B', // Amber
  '#EF4444', // Red
  '#14B8A6', // Teal
  '#EC4899', // Pink
  '#F97316', // Orange
  '#8B5CF6', // Violet
  '#06B6D4'  // Cyan
];

const ICON_GROUPS = [
  { id: 'ALL', label: 'Tất cả' },
  { id: 'food', label: 'Ăn uống' },
  { id: 'shopping', label: 'Mua sắm' },
  { id: 'transport', label: 'Di chuyển' },
  { id: 'housing', label: 'Nhà ở & Cước' },
  { id: 'entertainment', label: 'Giải trí' },
  { id: 'health', label: 'Sức khoẻ' },
  { id: 'income', label: 'Thu nhập' },
  { id: 'education', label: 'Học tập & Nhà' }
];

export default function CategoriesView({ showToast }) {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);

  // Tabs & Search filter on page
  const [scopeFilter, setScopeFilter] = useState('ALL'); // 'ALL' | 'SYSTEM' | 'USER' | 'EXPENSE' | 'INCOME'
  const [searchQuery, setSearchQuery] = useState('');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);
  const [formName, setFormName] = useState('');
  const [formType, setFormType] = useState('EXPENSE');
  const [formColor, setFormColor] = useState('#004AC6');
  const [formIcon, setFormIcon] = useState('restaurant');
  const [formIsSystem, setFormIsSystem] = useState(true);

  // Icon Picker Filter inside modal
  const [iconGroupFilter, setIconGroupFilter] = useState('ALL');
  const [iconSearch, setIconSearch] = useState('');

  useEffect(() => {
    loadCategories();
  }, []);

  const loadCategories = async () => {
    setLoading(true);
    const data = await ApiService.getCategories();
    setCategories(data);
    setLoading(false);
  };

  const handleOpenAdd = () => {
    setEditingCategory(null);
    setFormName('');
    setFormType('EXPENSE');
    setFormColor('#004AC6');
    setFormIcon('restaurant');
    setFormIsSystem(true);
    setIconGroupFilter('ALL');
    setIconSearch('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = (cat) => {
    setEditingCategory(cat);
    setFormName(cat.name);
    setFormType(cat.type);
    setFormColor(cat.color || '#004AC6');
    setFormIcon(cat.icon || 'category');
    setFormIsSystem(cat.user_id === null);
    setIconGroupFilter('ALL');
    setIconSearch('');
    setIsModalOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formName.trim()) {
      showToast('Vui lòng nhập tên danh mục', 'error');
      return;
    }

    try {
      const payload = {
        name: formName.trim(),
        type: formType,
        color: formColor,
        icon: formIcon,
        is_system: formIsSystem
      };

      if (editingCategory) {
        await ApiService.updateCategory(editingCategory.category_id, payload);
        showToast(`Đã cập nhật danh mục "${formName}"`, 'success');
      } else {
        await ApiService.addCategory(payload);
        showToast(`Đã thêm danh mục mới "${formName}"`, 'success');
      }
      setIsModalOpen(false);
      loadCategories();
    } catch (err) {
      showToast('Lỗi: ' + err.message, 'error');
    }
  };

  const handleDelete = async (cat) => {
    if (!window.confirm(`Bạn có chắc muốn xoá danh mục "${cat.name}"?`)) return;
    try {
      await ApiService.deleteCategory(cat.category_id);
      showToast(`Đã xoá danh mục "${cat.name}"`, 'success');
      loadCategories();
    } catch (err) {
      showToast('Lỗi khi xoá danh mục: ' + err.message, 'error');
    }
  };

  // Filter categories on screen
  const filteredCategories = categories.filter(c => {
    // 1. Filter by scope / type
    if (scopeFilter === 'SYSTEM' && c.user_id !== null) return false;
    if (scopeFilter === 'USER' && c.user_id === null) return false;
    if (scopeFilter === 'EXPENSE' && c.type !== 'EXPENSE') return false;
    if (scopeFilter === 'INCOME' && c.type !== 'INCOME') return false;

    // 2. Filter by search query
    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase().trim();
      const matchName = (c.name || '').toLowerCase().includes(q);
      const matchIcon = (c.icon || '').toLowerCase().includes(q);
      if (!matchName && !matchIcon) return false;
    }
    return true;
  });

  // Filter icons inside Modal picker
  const filteredIcons = GOOGLE_FONT_ICONS.filter(ic => {
    if (iconGroupFilter !== 'ALL' && ic.category !== iconGroupFilter) return false;
    if (iconSearch.trim()) {
      const q = iconSearch.toLowerCase().trim();
      return ic.name.includes(q) || ic.label.toLowerCase().includes(q) || ic.tags.includes(q);
    }
    return true;
  });

  const countSystem = categories.filter(c => c.user_id === null).length;
  const countUser = categories.filter(c => c.user_id !== null).length;
  const countExpense = categories.filter(c => c.type === 'EXPENSE').length;
  const countIncome = categories.filter(c => c.type === 'INCOME').length;

  return (
    <div className="card">
      {/* Header */}
      <div className="card-header" style={{ flexWrap: 'wrap', gap: 16 }}>
        <div className="card-title">
          <Tags size={22} color="var(--primary)" />
          <div>
            <h3>Quản Lý Danh Mục Thu & Chi</h3>
            <p style={{ fontSize: 13, color: 'var(--text-muted)', marginTop: 2 }}>
              Phân loại danh mục mặc định hệ thống và danh mục do người dùng tự tạo
            </p>
          </div>
        </div>

        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div className="search-box" style={{ width: 280 }}>
            <Search size={16} />
            <input 
              type="text" 
              placeholder="Tìm kiếm danh mục..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>

          <button className="btn btn-primary" onClick={handleOpenAdd}>
            <Plus size={16} />
            <span>Thêm Danh Mục Mới</span>
          </button>
        </div>
      </div>

      {/* Segmented Filter Bar */}
      <div className="segmented-filter-bar">
        <button
          className={`segmented-tab ${scopeFilter === 'ALL' ? 'active' : ''}`}
          onClick={() => setScopeFilter('ALL')}
        >
          <Layers size={15} />
          <span>Tất cả</span>
          <span className="segmented-count">{categories.length}</span>
        </button>
        <button
          className={`segmented-tab ${scopeFilter === 'SYSTEM' ? 'active' : ''}`}
          onClick={() => setScopeFilter('SYSTEM')}
        >
          <ShieldCheck size={15} />
          <span>Mặc định hệ thống</span>
          <span className="segmented-count">{countSystem}</span>
        </button>
        <button
          className={`segmented-tab ${scopeFilter === 'USER' ? 'active' : ''}`}
          onClick={() => setScopeFilter('USER')}
        >
          <User size={15} />
          <span>Người dùng thêm</span>
          <span className="segmented-count">{countUser}</span>
        </button>
        <button
          className={`segmented-tab ${scopeFilter === 'EXPENSE' ? 'active' : ''}`}
          onClick={() => setScopeFilter('EXPENSE')}
        >
          <span>🔴 Khoản Chi tiêu</span>
          <span className="segmented-count">{countExpense}</span>
        </button>
        <button
          className={`segmented-tab ${scopeFilter === 'INCOME' ? 'active' : ''}`}
          onClick={() => setScopeFilter('INCOME')}
        >
          <span>🟢 Khoản Thu nhập</span>
          <span className="segmented-count">{countIncome}</span>
        </button>
      </div>

      {/* Categories Grid Cards */}
      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-light)' }}>
          Đang tải danh mục từ cơ sở dữ liệu...
        </div>
      ) : filteredCategories.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '50px 20px', color: 'var(--text-light)' }}>
          <Tags size={40} style={{ opacity: 0.3, marginBottom: 10 }} />
          <p style={{ fontSize: 15, fontWeight: 600 }}>Không tìm thấy danh mục phù hợp</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(270px, 1fr))', gap: 18 }}>
          {filteredCategories.map(c => {
            const isExp = c.type === 'EXPENSE';
            const color = c.color || '#004AC6';
            const isSystem = c.user_id === null;

            return (
              <div key={c.category_id} className="category-card">
                {/* Single crisp colored stripe */}
                <div className="category-card-stripe" style={{ background: color }}></div>

                <div>
                  {/* Top row: Icon + Badges */}
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14 }}>
                    <div 
                      className="category-icon-box"
                      style={{ 
                        background: `${color}14`, 
                        color: color, 
                        boxShadow: `0 4px 12px ${color}1e`
                      }}
                    >
                      <span className="material-symbols-rounded" style={{ fontSize: 26 }}>
                        {c.icon || 'category'}
                      </span>
                    </div>

                    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 5 }}>
                      <span className={`badge-pill ${isExp ? 'expense' : 'income'}`}>
                        {isExp ? 'Chi tiêu' : 'Thu nhập'}
                      </span>
                      {isSystem ? (
                        <span className="badge-pill system">
                          Hệ thống
                        </span>
                      ) : (
                        <span className="badge-pill user">
                          User ID: {c.user_id}
                        </span>
                      )}
                    </div>
                  </div>

                  {/* Title & metadata */}
                  <h4 style={{ fontSize: 16, fontWeight: 800, color: 'var(--text-main)', marginBottom: 6 }}>
                    {c.name}
                  </h4>
                  
                  <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: 'var(--text-muted)' }}>
                    <span>Icon: <code style={{ color: color, fontWeight: 700 }}>{c.icon || 'category'}</code></span>
                    <span>•</span>
                    <span>Màu: <span style={{ fontFamily: 'monospace', fontWeight: 600 }}>{color}</span></span>
                  </div>
                </div>

                {/* Actions */}
                <div style={{ marginTop: 18, paddingTop: 14, borderTop: '1px solid #F1F5F9', display: 'flex', justifyContent: 'flex-end', gap: 8 }}>
                  <button className="card-action-btn edit" onClick={() => handleOpenEdit(c)}>
                    <Edit size={14} /> Sửa
                  </button>
                  <button className="card-action-btn delete" onClick={() => handleDelete(c)}>
                    <Trash2 size={14} /> Xoá
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}


      {/* Modal Thêm / Sửa Danh Mục Toàn Diện */}
      <Modal
        isOpen={isModalOpen}
        title={editingCategory ? `Chỉnh sửa danh mục "${editingCategory.name}"` : 'Thêm danh mục phân loại mới'}
        onClose={() => setIsModalOpen(false)}
      >
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 18 }}>
          
          {/* 1. Tên danh mục */}
          <div className="form-group">
            <label className="form-label">Tên danh mục (*)</label>
            <input
              type="text"
              className="form-control"
              placeholder="VD: Cà phê, Học phí, Đầu tư vàng..."
              value={formName}
              onChange={(e) => setFormName(e.target.value)}
              required
              autoFocus
            />
          </div>

          {/* 2. Loại danh mục & Phạm vi áp dụng */}
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 14 }}>
            <div className="form-group">
              <label className="form-label">Loại giao dịch (*)</label>
              <select
                className="form-control"
                value={formType}
                onChange={(e) => setFormType(e.target.value)}
                required
              >
                <option value="EXPENSE">Chi tiêu (Expense)</option>
                <option value="INCOME">Thu nhập (Income)</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label">Phạm vi áp dụng</label>
              <select
                className="form-control"
                value={formIsSystem ? 'SYSTEM' : 'CUSTOM'}
                onChange={(e) => setFormIsSystem(e.target.value === 'SYSTEM')}
              >
                <option value="SYSTEM">Mặc định hệ thống (Mọi người dùng)</option>
                <option value="CUSTOM">Danh mục tuỳ chỉnh (Người dùng)</option>
              </select>
            </div>
          </div>

          {/* 3. Màu sắc đại diện */}
          <div className="form-group">
            <label className="form-label">Màu sắc nhận diện</label>
            <div style={{ display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
              {PRESET_COLORS.map(c => (
                <button
                  type="button"
                  key={c}
                  onClick={() => setFormColor(c)}
                  style={{
                    width: 32,
                    height: 32,
                    borderRadius: '50%',
                    background: c,
                    border: formColor.toLowerCase() === c.toLowerCase() ? '3px solid #131B2E' : '2px solid #fff',
                    boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#fff',
                    transition: 'transform 0.15s ease'
                  }}
                >
                  {formColor.toLowerCase() === c.toLowerCase() && <Check size={14} />}
                </button>
              ))}
              <input
                type="color"
                value={formColor}
                onChange={(e) => setFormColor(e.target.value)}
                style={{ width: 36, height: 36, border: 'none', borderRadius: 8, cursor: 'pointer', background: 'transparent' }}
                title="Chọn màu tuỳ chỉnh"
              />
              <span style={{ fontSize: 13, fontFamily: 'monospace', color: 'var(--text-muted)', fontWeight: 600 }}>
                {formColor}
              </span>
            </div>
          </div>

          {/* 4. Kho Icon Google Font (Material Symbols) */}
          <div className="form-group">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <label className="form-label" style={{ marginBottom: 0 }}>
                Chọn biểu tượng (Google Font Icons)
              </label>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ fontSize: 12, color: 'var(--text-muted)' }}>Đang chọn:</span>
                <div style={{ 
                  display: 'inline-flex', 
                  alignItems: 'center', 
                  gap: 6, 
                  background: `${formColor}18`, 
                  color: formColor, 
                  padding: '3px 10px', 
                  borderRadius: 8,
                  fontWeight: 700,
                  fontSize: 13
                }}>
                  <span className="material-symbols-rounded" style={{ fontSize: 18 }}>{formIcon}</span>
                  <code>{formIcon}</code>
                </div>
              </div>
            </div>

            {/* Icon Search & Group Filter */}
            <div style={{ 
              background: '#F8FAFC', 
              border: '1px solid var(--border-color)', 
              borderRadius: 14, 
              padding: 12, 
              display: 'flex', 
              flexDirection: 'column', 
              gap: 10 
            }}>
              <div style={{ display: 'flex', gap: 10 }}>
                <div className="search-box" style={{ width: '100%' }}>
                  <Search size={16} />
                  <input
                    type="text"
                    placeholder="Tìm icon Google Font (VD: food, car, game, coffee, money...)"
                    value={iconSearch}
                    onChange={(e) => setIconSearch(e.target.value)}
                  />
                </div>
              </div>

              {/* Group filter tags */}
              <div style={{ display: 'flex', gap: 6, overflowX: 'auto', paddingBottom: 4 }}>
                {ICON_GROUPS.map(grp => (
                  <button
                    type="button"
                    key={grp.id}
                    onClick={() => setIconGroupFilter(grp.id)}
                    style={{
                      padding: '4px 10px',
                      fontSize: 11.5,
                      fontWeight: 600,
                      borderRadius: 8,
                      border: iconGroupFilter === grp.id ? '1px solid var(--primary)' : '1px solid var(--border-color)',
                      background: iconGroupFilter === grp.id ? 'var(--primary)' : '#ffffff',
                      color: iconGroupFilter === grp.id ? '#ffffff' : 'var(--text-main)',
                      cursor: 'pointer',
                      whiteSpace: 'nowrap',
                      transition: 'all 0.15s ease'
                    }}
                  >
                    {grp.label}
                  </button>
                ))}
              </div>

              {/* Icon Grid Picker */}
              <div style={{ 
                maxHeight: 180, 
                overflowY: 'auto', 
                display: 'grid', 
                gridTemplateColumns: 'repeat(auto-fill, minmax(44px, 1fr))', 
                gap: 8,
                padding: '4px 2px'
              }}>
                {filteredIcons.length === 0 ? (
                  <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '20px', color: 'var(--text-light)', fontSize: 13 }}>
                    Không tìm thấy icon nào phù hợp với từ khoá "{iconSearch}"
                  </div>
                ) : (
                  filteredIcons.map(ic => {
                    const isSelected = formIcon === ic.name;
                    return (
                      <button
                        type="button"
                        key={ic.name}
                        onClick={() => setFormIcon(ic.name)}
                        title={`${ic.label} (${ic.name})`}
                        style={{
                          width: 44,
                          height: 44,
                          borderRadius: 10,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          cursor: 'pointer',
                          background: isSelected ? formColor : '#ffffff',
                          color: isSelected ? '#ffffff' : 'var(--text-main)',
                          border: isSelected ? `2px solid ${formColor}` : '1px solid var(--border-color)',
                          boxShadow: isSelected ? `0 4px 10px ${formColor}40` : 'none',
                          transition: 'all 0.15s ease'
                        }}
                      >
                        <span className="material-symbols-rounded" style={{ fontSize: 24 }}>
                          {ic.name}
                        </span>
                      </button>
                    );
                  })
                )}
              </div>
            </div>
          </div>

          {/* Form Actions */}
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 12, marginTop: 8, paddingTop: 14, borderTop: '1px solid var(--border-color)' }}>
            <button type="button" className="btn btn-secondary" onClick={() => setIsModalOpen(false)}>
              Huỷ bỏ
            </button>
            <button type="submit" className="btn btn-primary">
              {editingCategory ? 'Cập Nhật Danh Mục' : 'Lưu Danh Mục Mới'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
