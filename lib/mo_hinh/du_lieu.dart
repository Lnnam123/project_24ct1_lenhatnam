import 'package:flutter/material.dart';

enum LoaiGiaoDich { chiTieu, thuNhap, chuyenKhoan }

class NguoiDung {
  final int id;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String matKhau;
  final String avatarUrl;
  final String donViTienTe;

  NguoiDung({
    required this.id,
    required this.hoTen,
    required this.email,
    required this.soDienThoai,
    required this.matKhau,
    this.avatarUrl = '',
    this.donViTienTe = 'VND',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'full_name': hoTen,
      'email': email,
      'phone_number': soDienThoai,
      'password_hash': matKhau,
      'avatar_url': avatarUrl,
      'currency': donViTienTe,
    };
  }

  factory NguoiDung.fromMap(Map<String, dynamic> map) {
    return NguoiDung(
      id: map['user_id'],
      hoTen: map['full_name'],
      email: map['email'],
      soDienThoai: map['phone_number'] ?? '',
      matKhau: map['password_hash'],
      avatarUrl: map['avatar_url'] ?? '',
      donViTienTe: map['currency'] ?? 'VND',
    );
  }
}

class ViTien {
  final int id;
  final String tenVi;
  final String loaiVi;
  double soDu;
  final String? soTaiKhoan;
  final IconData icon;
  final Color mauSac;

  ViTien({
    required this.id,
    required this.tenVi,
    required this.loaiVi,
    required this.soDu,
    this.soTaiKhoan,
    required this.icon,
    required this.mauSac,
  });

  Map<String, dynamic> toMap(int userId) {
    return {
      'wallet_id': id,
      'user_id': userId,
      'wallet_name': tenVi,
      'wallet_type': loaiVi,
      'balance': soDu,
      'account_number': soTaiKhoan,
      'icon': icon.codePoint.toString(),
      'color': '#${mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }

  factory ViTien.fromMap(Map<String, dynamic> map) {
    // Basic mapping for Icon and Color
    IconData getIcon(String? iconName) {
      if (iconName == 'account_balance') return Icons.account_balance;
      if (iconName == 'credit_card') return Icons.credit_card;
      return Icons.payments;
    }

    Color getColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF004AC6);
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }

    return ViTien(
      id: map['wallet_id'],
      tenVi: map['wallet_name'],
      loaiVi: map['wallet_type'] ?? 'CASH',
      soDu: (map['balance'] as num?)?.toDouble() ?? 0.0,
      soTaiKhoan: map['account_number'],
      icon: getIcon(map['icon']),
      mauSac: getColor(map['color']),
    );
  }
}

class DanhMuc {
  final int id;
  final String ten;
  final LoaiGiaoDich loai;
  final IconData icon;
  final Color mauSac;

  DanhMuc({
    required this.id,
    required this.ten,
    required this.loai,
    required this.icon,
    required this.mauSac,
  });

  String get iconName {
    if (icon == Icons.shopping_cart) return 'shopping_cart';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.health_and_safety) return 'health_and_safety';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.flight) return 'flight';
    if (icon == Icons.payments) return 'payments';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.sports_esports) return 'sports_esports';
    if (icon == Icons.receipt_long) return 'receipt_long';
    return 'category';
  }

  Map<String, dynamic> toMap() {
    return {
      'category_id': id,
      'name': ten,
      'type': loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
      'icon': iconName,
      'color': '#${mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }

  factory DanhMuc.fromMap(Map<String, dynamic> map) {
    IconData getIcon(String? iconName) {
      if (iconName == 'restaurant') return Icons.restaurant;
      if (iconName == 'shopping_cart') return Icons.shopping_cart;
      if (iconName == 'directions_car') return Icons.directions_car;
      if (iconName == 'health_and_safety') return Icons.health_and_safety;
      if (iconName == 'movie') return Icons.movie;
      if (iconName == 'home') return Icons.home;
      if (iconName == 'school') return Icons.school;
      if (iconName == 'flight') return Icons.flight;
      if (iconName == 'sports_esports') return Icons.sports_esports;
      if (iconName == 'receipt_long') return Icons.receipt_long;
      if (iconName == 'payments') return Icons.payments;
      if (iconName == 'trending_up') return Icons.trending_up;
      return Icons.category;
    }

    Color getColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF712AE2);
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }

    return DanhMuc(
      id: map['category_id'] ?? map['id'],
      ten: map['name'] ?? map['ten'] ?? '',
      loai: map['type'] == 'INCOME' ? LoaiGiaoDich.thuNhap : LoaiGiaoDich.chiTieu,
      icon: getIcon(map['icon']),
      mauSac: getColor(map['color']),
    );
  }
}

class GiaoDich {
  final int? id; // Có thể null khi insert mới
  final String tieuDe;
  final double soTien;
  final LoaiGiaoDich loai;
  final DanhMuc danhMuc;
  final ViTien viTien;
  final DateTime ngay;
  final String? ghiChu;

  GiaoDich({
    this.id,
    required this.tieuDe,
    required this.soTien,
    required this.loai,
    required this.danhMuc,
    required this.viTien,
    required this.ngay,
    this.ghiChu,
  });

  Map<String, dynamic> toMap(int userId) {
    return {
      if (id != null) 'transaction_id': id,
      'user_id': userId,
      'wallet_id': viTien.id,
      'category_id': danhMuc.id,
      'amount': soTien,
      'type': loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
      'transaction_date': ngay.toIso8601String(),
      'note': tieuDe,
    };
  }

  factory GiaoDich.fromMap(Map<String, dynamic> map, DanhMuc danhMuc, ViTien viTien) {
    return GiaoDich(
      id: map['transaction_id'],
      tieuDe: map['note'] ?? '',
      soTien: (map['amount'] as num?)?.toDouble() ?? 0.0,
      loai: map['type'] == 'INCOME' ? LoaiGiaoDich.thuNhap : LoaiGiaoDich.chiTieu,
      danhMuc: danhMuc,
      viTien: viTien,
      ngay: DateTime.parse(map['transaction_date']),
      ghiChu: map['note'],
    );
  }
}

class NganSach {
  final int id;
  final double hanMuc;
  double daChi;
  final DateTime ngayBatDau;
  final DateTime ngayKetThuc;
  final DanhMuc? danhMuc;

  NganSach({
    required this.id,
    required this.hanMuc,
    required this.daChi,
    required this.ngayBatDau,
    required this.ngayKetThuc,
    this.danhMuc,
  });

  double get phanTram => hanMuc > 0 ? (daChi / hanMuc * 100).clamp(0, 100) : 0;
}

class ThongBao {
  final int id;
  final String tieuDe;
  final String noiDung;
  final String loai;
  final bool daDoc;
  final DateTime ngayTao;

  ThongBao({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.loai,
    required this.daDoc,
    required this.ngayTao,
  });

  factory ThongBao.fromMap(Map<String, dynamic> map) {
    return ThongBao(
      id: map['notification_id'],
      tieuDe: map['title'] ?? '',
      noiDung: map['message'] ?? '',
      loai: map['type'] ?? 'SYSTEM',
      daDoc: (map['is_read'] == 1),
      ngayTao: DateTime.parse(map['created_at']),
    );
  }
}
