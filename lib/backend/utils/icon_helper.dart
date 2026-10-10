import 'package:flutter/material.dart';

class BieuTuongItem {
  final String name;
  final String label;
  final String category;
  final IconData icon;
  final String tags;

  const BieuTuongItem({
    required this.name,
    required this.label,
    required this.category,
    required this.icon,
    this.tags = '',
  });
}

class BieuTuongNhom {
  final String id;
  final String label;

  const BieuTuongNhom({required this.id, required this.label});
}

class BieuTuongHelper {
  static const List<BieuTuongNhom> danhSachNhom = [
    BieuTuongNhom(id: 'ALL', label: 'Tất cả'),
    BieuTuongNhom(id: 'food', label: 'Ăn uống'),
    BieuTuongNhom(id: 'shopping', label: 'Mua sắm'),
    BieuTuongNhom(id: 'transport', label: 'Di chuyển'),
    BieuTuongNhom(id: 'housing', label: 'Nhà & Cước'),
    BieuTuongNhom(id: 'entertainment', label: 'Giải trí'),
    BieuTuongNhom(id: 'health', label: 'Sức khoẻ'),
    BieuTuongNhom(id: 'education', label: 'Học tập'),
    BieuTuongNhom(id: 'income', label: 'Thu nhập'),
    BieuTuongNhom(id: 'general', label: 'Khác'),
  ];

  static const List<BieuTuongItem> danhSachBieuTuong = [
    // 1. Ăn uống & Thực phẩm (Food & Drinks)
    BieuTuongItem(name: 'restaurant', label: 'Nhà hàng, quán ăn', category: 'food', icon: Icons.restaurant, tags: 'an uong, nha hang, food, meal, eat'),
    BieuTuongItem(name: 'fastfood', label: 'Đồ ăn nhanh', category: 'food', icon: Icons.fastfood, tags: 'fastfood, burger, an nhanh, snack'),
    BieuTuongItem(name: 'local_cafe', label: 'Cà phê, trà sữa', category: 'food', icon: Icons.local_cafe, tags: 'cafe, coffee, tra sua, quan nuoc, drink'),
    BieuTuongItem(name: 'local_bar', label: 'Bia, quán bar', category: 'food', icon: Icons.local_bar, tags: 'bar, bia, ruou, pub, party, beer'),
    BieuTuongItem(name: 'ramen_dining', label: 'Mì, bún, phở', category: 'food', icon: Icons.ramen_dining, tags: 'mi, pho, bun, ramen, noodle, soup'),
    BieuTuongItem(name: 'lunch_dining', label: 'Cơm trưa, đồ ăn', category: 'food', icon: Icons.lunch_dining, tags: 'com trua, bua an, lunch, rice'),
    BieuTuongItem(name: 'local_pizza', label: 'Bánh Pizza', category: 'food', icon: Icons.local_pizza, tags: 'pizza, banh, tiec'),
    BieuTuongItem(name: 'bakery_dining', label: 'Bánh mì, bánh ngọt', category: 'food', icon: Icons.bakery_dining, tags: 'banh mi, bakery, bread, cake'),
    BieuTuongItem(name: 'icecream', label: 'Kem, tráng miệng', category: 'food', icon: Icons.icecream, tags: 'kem, icecream, an vat, dessert'),
    BieuTuongItem(name: 'liquor', label: 'Rượu tiệc', category: 'food', icon: Icons.liquor, tags: 'ruou, liquor, tiec tung'),

    // 2. Mua sắm & Tiêu dùng (Shopping)
    BieuTuongItem(name: 'shopping_cart', label: 'Xe đẩy siêu thị', category: 'shopping', icon: Icons.shopping_cart, tags: 'sieu thi, mua sam, cart, grocery'),
    BieuTuongItem(name: 'shopping_bag', label: 'Túi mua sắm', category: 'shopping', icon: Icons.shopping_bag, tags: 'mua sam, shopping, bag, clothes'),
    BieuTuongItem(name: 'storefront', label: 'Cửa hàng, tạp hoá', category: 'shopping', icon: Icons.storefront, tags: 'cua hang, shop, tap hoa, store'),
    BieuTuongItem(name: 'checkroom', label: 'Quần áo, thời trang', category: 'shopping', icon: Icons.checkroom, tags: 'quan ao, thoi trang, fashion, clothes'),
    BieuTuongItem(name: 'diamond', label: 'Trang sức, vàng bạc', category: 'shopping', icon: Icons.diamond, tags: 'trang suc, vang, kim cuong, luxury'),
    BieuTuongItem(name: 'card_giftcard', label: 'Quà tặng, mừng tuổi', category: 'shopping', icon: Icons.card_giftcard, tags: 'qua tang, gift, li xi, sinh nhat'),
    BieuTuongItem(name: 'inventory_2', label: 'Đồ đạc, kiện hàng', category: 'shopping', icon: Icons.inventory_2, tags: 'don hang, shopee, lazada, ship, package'),

    // 3. Di chuyển & Xe cộ (Transportation)
    BieuTuongItem(name: 'directions_car', label: 'Ô tô, xe hơi', category: 'transport', icon: Icons.directions_car, tags: 'o to, xe hoi, car, oto, drive'),
    BieuTuongItem(name: 'two_wheeler', label: 'Xe máy, xe mô tô', category: 'transport', icon: Icons.two_wheeler, tags: 'xe may, moto, bike, motorbike'),
    BieuTuongItem(name: 'local_gas_station', label: 'Xăng xe, nhiên liệu', category: 'transport', icon: Icons.local_gas_station, tags: 'xang xe, gas, nhien lieu, petrol'),
    BieuTuongItem(name: 'directions_bus', label: 'Xe buýt, xe khách', category: 'transport', icon: Icons.directions_bus, tags: 'xe buyt, bus, transit, xe khach'),
    BieuTuongItem(name: 'local_taxi', label: 'Taxi, Grab', category: 'transport', icon: Icons.local_taxi, tags: 'taxi, grab, be, cuoc xe, ride'),
    BieuTuongItem(name: 'flight', label: 'Vé máy bay, du lịch', category: 'transport', icon: Icons.flight, tags: 'may bay, flight, ve, du lich, airplane'),
    BieuTuongItem(name: 'train', label: 'Tàu hoả, ga tàu', category: 'transport', icon: Icons.train, tags: 'tau hoa, train, metro, duong sat'),
    BieuTuongItem(name: 'directions_bike', label: 'Xe đạp', category: 'transport', icon: Icons.directions_bike, tags: 'xe dap, bicycle, the thao'),
    BieuTuongItem(name: 'car_repair', label: 'Sửa chữa xe', category: 'transport', icon: Icons.car_repair, tags: 'sua xe, bao duong, garage, fix'),

    // 4. Nhà ở & Sinh hoạt (Housing & Bills)
    BieuTuongItem(name: 'home', label: 'Nhà ở, tiền trọ', category: 'housing', icon: Icons.home, tags: 'nha o, tien tro, phong tro, home, rent'),
    BieuTuongItem(name: 'apartment', label: 'Chung cư, căn hộ', category: 'housing', icon: Icons.apartment, tags: 'chung cu, can ho, apartment, building'),
    BieuTuongItem(name: 'bolt', label: 'Tiền điện', category: 'housing', icon: Icons.bolt, tags: 'tien dien, electric, power, nang luong'),
    BieuTuongItem(name: 'water_drop', label: 'Tiền nước', category: 'housing', icon: Icons.water_drop, tags: 'tien nuoc, water, sinh hoat'),
    BieuTuongItem(name: 'wifi', label: 'Mạng Internet, Wifi', category: 'housing', icon: Icons.wifi, tags: 'wifi, internet, mang cap, 4g, 5g'),
    BieuTuongItem(name: 'phone_iphone', label: 'Điện thoại, thẻ cào', category: 'housing', icon: Icons.phone_iphone, tags: 'dien thoai, nap the, phone, cuoc goi'),
    BieuTuongItem(name: 'tv', label: 'Truyền hình, Netflix', category: 'housing', icon: Icons.tv, tags: 'tv, tivi, truyen hinh, netflix, subscription'),
    BieuTuongItem(name: 'receipt_long', label: 'Hoá đơn định kỳ', category: 'housing', icon: Icons.receipt_long, tags: 'hoa don, receipt, bill, cuoc phi'),
    BieuTuongItem(name: 'cleaning_services', label: 'Dọn dẹp, vệ sinh', category: 'housing', icon: Icons.cleaning_services, tags: 've sinh, don nha, giat la, clean'),

    // 5. Giải trí & Sở thích (Entertainment)
    BieuTuongItem(name: 'sports_esports', label: 'Game, nạp game', category: 'entertainment', icon: Icons.sports_esports, tags: 'game, choi game, nap game, esports'),
    BieuTuongItem(name: 'movie', label: 'Xem phim, rạp phim', category: 'entertainment', icon: Icons.movie, tags: 'phim, movie, rap chieu, cinema, film'),
    BieuTuongItem(name: 'music_note', label: 'Âm nhạc, Spotify', category: 'entertainment', icon: Icons.music_note, tags: 'am nhac, nhac, music, song, spotify'),
    BieuTuongItem(name: 'fitness_center', label: 'Tập Gym, thể thao', category: 'entertainment', icon: Icons.fitness_center, tags: 'gym, the hinh, workout, the thao'),
    BieuTuongItem(name: 'sports_soccer', label: 'Bóng đá, thể thao', category: 'entertainment', icon: Icons.sports_soccer, tags: 'bong da, football, soccer, the thao'),
    BieuTuongItem(name: 'celebration', label: 'Tiệc tùng, lễ hội', category: 'entertainment', icon: Icons.celebration, tags: 'tiec, festival, party, sinh nhat'),
    BieuTuongItem(name: 'palette', label: 'Nghệ thuật, sở thích', category: 'entertainment', icon: Icons.palette, tags: 've, hoi hoa, art, hobby'),

    // 6. Y tế & Sức khoẻ (Health)
    BieuTuongItem(name: 'health_and_safety', label: 'Bảo hiểm, an toàn', category: 'health', icon: Icons.health_and_safety, tags: 'bao hiem, suc khoe, an toan, health'),
    BieuTuongItem(name: 'medical_services', label: 'Khám bệnh, bác sĩ', category: 'health', icon: Icons.medical_services, tags: 'kham benh, bac si, y te, hospital, clinic'),
    BieuTuongItem(name: 'medication', label: 'Thuốc men, tiệm thuốc', category: 'health', icon: Icons.medication, tags: 'thuoc, pharmacy, duoc pham, pill'),
    BieuTuongItem(name: 'spa', label: 'Spa, làm đẹp, cắt tóc', category: 'health', icon: Icons.spa, tags: 'spa, lam dep, cat toc, massage, salon'),

    // 7. Giáo dục & Gia đình (Education & Family)
    BieuTuongItem(name: 'school', label: 'Trường học, học phí', category: 'education', icon: Icons.school, tags: 'hoc tap, hoc phi, truong hoc, school, education'),
    BieuTuongItem(name: 'menu_book', label: 'Sách vở, tài liệu', category: 'education', icon: Icons.menu_book, tags: 'sach, vo, giao trinh, book, study'),
    BieuTuongItem(name: 'pets', label: 'Thú cưng, chó mèo', category: 'education', icon: Icons.pets, tags: 'thu cung, cho, meo, pet, dong vat'),
    BieuTuongItem(name: 'child_care', label: 'Con cái, trẻ nhỏ', category: 'education', icon: Icons.child_care, tags: 'con cai, tre em, baby, bim sua'),

    // 8. Thu nhập & Đầu tư (Income)
    BieuTuongItem(name: 'payments', label: 'Tiền lương chính', category: 'income', icon: Icons.payments, tags: 'luong, payment, thu nhap, salary'),
    BieuTuongItem(name: 'attach_money', label: 'Tiền mặt, thu nhập', category: 'income', icon: Icons.attach_money, tags: 'tien, money, dollar, cash'),
    BieuTuongItem(name: 'savings', label: 'Tiết kiệm, heo đất', category: 'income', icon: Icons.savings, tags: 'tiet kiem, saving, heo dat, tich luy'),
    BieuTuongItem(name: 'trending_up', label: 'Đầu tư sinh lời, lãi', category: 'income', icon: Icons.trending_up, tags: 'dau tu, lai suat, invest, loi nhuan'),
    BieuTuongItem(name: 'account_balance', label: 'Ngân hàng, tài chính', category: 'income', icon: Icons.account_balance, tags: 'ngan hang, bank, tai khoan'),
    BieuTuongItem(name: 'currency_bitcoin', label: 'Tiền số, Crypto', category: 'income', icon: Icons.currency_bitcoin, tags: 'crypto, coin, bitcoin, blockchain'),
    BieuTuongItem(name: 'work', label: 'Thưởng công việc', category: 'income', icon: Icons.work, tags: 'thuong, cong viec, job, bonus'),
    BieuTuongItem(name: 'more_time', label: 'Làm thêm, phụ cấp', category: 'income', icon: Icons.more_time, tags: 'lam them, parttime, overtime, phu cap'),

    // 9. Khác & Ví tiền
    BieuTuongItem(name: 'credit_card', label: 'Thẻ tín dụng', category: 'income', icon: Icons.credit_card, tags: 'the, card, credit, ngan hang'),
    BieuTuongItem(name: 'account_balance_wallet', label: 'Ví tiền mặt', category: 'income', icon: Icons.account_balance_wallet, tags: 'vi, vi tien, wallet'),
    BieuTuongItem(name: 'category', label: 'Danh mục chung', category: 'general', icon: Icons.category, tags: 'danh muc, chung, category'),
    BieuTuongItem(name: 'more_horiz', label: 'Khoản chi khác', category: 'general', icon: Icons.more_horiz, tags: 'khac, more, others'),
    BieuTuongItem(name: 'star', label: 'Quan trọng, đặc biệt', category: 'general', icon: Icons.star, tags: 'sao, star, uu tien'),
  ];

  static final Map<String, IconData> _mapNameToIcon = {
    for (var item in danhSachBieuTuong) item.name: item.icon,
  };

  static final Map<int, String> _mapCodePointToName = {
    for (var item in danhSachBieuTuong) item.icon.codePoint: item.name,
  };

  /// Lấy IconData từ chuỗi tên biểu tượng (như 'receipt_long', 'restaurant')
  static IconData layIcon(String? iconName) {
    if (iconName == null || iconName.trim().isEmpty) {
      return Icons.category;
    }
    final clean = iconName.trim().toLowerCase();
    if (_mapNameToIcon.containsKey(clean)) {
      return _mapNameToIcon[clean]!;
    }
    // Fallback theo tên tương đương
    if (clean.contains('bill') || clean.contains('receipt') || clean.contains('invoice')) {
      return Icons.receipt_long;
    }
    if (clean.contains('food') || clean.contains('eat') || clean.contains('dining')) {
      return Icons.restaurant;
    }
    if (clean.contains('shop') || clean.contains('cart')) {
      return Icons.shopping_cart;
    }
    if (clean.contains('car') || clean.contains('transport')) {
      return Icons.directions_car;
    }
    if (clean.contains('game')) {
      return Icons.sports_esports;
    }
    if (clean.contains('money') || clean.contains('cash') || clean.contains('salary')) {
      return Icons.payments;
    }
    return Icons.category;
  }

  /// Lấy tên chuỗi biểu tượng từ IconData (để lưu vào database)
  static String layTenIcon(IconData icon) {
    if (_mapCodePointToName.containsKey(icon.codePoint)) {
      return _mapCodePointToName[icon.codePoint]!;
    }
    return 'category';
  }

  /// Danh sách tất cả IconData duy nhất
  static List<IconData> get danhSachTatCaIcon {
    return danhSachBieuTuong.map((e) => e.icon).toList();
  }

  /// Lấy nhãn hiển thị tiếng Việt của biểu tượng
  static String layNhanIcon(IconData icon) {
    for (var item in danhSachBieuTuong) {
      if (item.icon.codePoint == icon.codePoint) {
        return item.label;
      }
    }
    return 'Biểu tượng';
  }
}
