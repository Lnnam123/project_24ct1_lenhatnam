import 'package:flutter/material.dart';
import '../tien_ich/bieu_tuong_helper.dart';

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
      'ma_nguoi_dung': id,
      'ho_ten': hoTen,
      'email': email,
      'so_dien_thoai': soDienThoai,
      'mat_khau': matKhau,
      'anh_dai_dien': avatarUrl,
      'don_vi_tien_te': donViTienTe,
    };
  }

  factory NguoiDung.fromMap(Map<String, dynamic> map) {
    return NguoiDung(
      id: map['ma_nguoi_dung'] ?? map['user_id'],
      hoTen: map['ho_ten'] ?? map['full_name'] ?? '',
      email: map['email'] ?? '',
      soDienThoai: map['so_dien_thoai'] ?? map['phone_number'] ?? '',
      matKhau: map['mat_khau'] ?? map['password_hash'] ?? '',
      avatarUrl: map['anh_dai_dien'] ?? map['avatar_url'] ?? '',
      donViTienTe: map['don_vi_tien_te'] ?? map['currency'] ?? 'VND',
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
      'ma_vi': id,
      'ma_nguoi_dung': userId,
      'ten_vi': tenVi,
      'loai_vi': loaiVi,
      'so_du': soDu,
      'account_number': soTaiKhoan,
      'bieu_tuong': icon.codePoint.toString(),
      'mau_sac': '#${mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }

  factory ViTien.fromMap(Map<String, dynamic> map) {
    Color getColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF004AC6);
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }

    return ViTien(
      id: map['ma_vi'] ?? map['wallet_id'],
      tenVi: map['ten_vi'] ?? map['wallet_name'] ?? '',
      loaiVi: map['loai_vi'] ?? map['wallet_type'] ?? 'CASH',
      soDu: ((map['so_du'] ?? map['balance']) as num?)?.toDouble() ?? 0.0,
      soTaiKhoan: map['so_tai_khoan'] ?? map['account_number'],
      icon: BieuTuongHelper.layIcon(map['bieu_tuong'] ?? map['icon']),
      mauSac: getColor(map['mau_sac'] ?? map['color']),
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

  String get iconName => BieuTuongHelper.layTenIcon(icon);

  Map<String, dynamic> toMap() {
    return {
      'ma_danh_muc': id,
      'ten_danh_muc': ten,
      'loai_danh_muc': loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
      'bieu_tuong': iconName,
      'mau_sac': '#${mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }

  factory DanhMuc.fromMap(Map<String, dynamic> map) {
    Color getColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFF712AE2);
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    }

    return DanhMuc(
      id: map['ma_danh_muc'] ?? map['category_id'] ?? map['id'],
      ten: map['ten_danh_muc'] ?? map['name'] ?? map['ten'] ?? '',
      loai: (map['loai_danh_muc'] ?? map['type']) == 'INCOME' ? LoaiGiaoDich.thuNhap : LoaiGiaoDich.chiTieu,
      icon: BieuTuongHelper.layIcon(map['bieu_tuong'] ?? map['icon']),
      mauSac: getColor(map['mau_sac'] ?? map['color']),
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
      if (id != null) 'ma_giao_dich': id,
      'ma_nguoi_dung': userId,
      'ma_vi': viTien.id,
      'ma_danh_muc': danhMuc.id,
      'so_tien': soTien,
      'loai_giao_dich': loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
      'ngay_giao_dich': ngay.toIso8601String(),
      'ghi_chu': tieuDe,
    };
  }

  factory GiaoDich.fromMap(Map<String, dynamic> map, DanhMuc danhMuc, ViTien viTien) {
    return GiaoDich(
      id: map['ma_giao_dich'] ?? map['transaction_id'],
      tieuDe: map['ghi_chu'] ?? map['note'] ?? '',
      soTien: ((map['so_tien'] ?? map['amount']) as num?)?.toDouble() ?? 0.0,
      loai: (map['loai_giao_dich'] ?? map['type']) == 'INCOME' ? LoaiGiaoDich.thuNhap : LoaiGiaoDich.chiTieu,
      danhMuc: danhMuc,
      viTien: viTien,
      ngay: DateTime.parse(map['ngay_giao_dich'] ?? map['transaction_date']),
      ghiChu: map['ghi_chu'] ?? map['note'],
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
      id: map['ma_thong_bao'] ?? map['notification_id'],
      tieuDe: map['tieu_de'] ?? map['title'] ?? '',
      noiDung: map['noi_dung'] ?? map['content'] ?? map['message'] ?? '',
      loai: map['loai_thong_bao'] ?? map['type'] ?? 'SYSTEM',
      daDoc: (map['da_doc'] == true || map['da_doc'] == 1 || map['is_read'] == true || map['is_read'] == 1),
      ngayTao: DateTime.parse(map['ngay_tao'] ?? map['created_at']),
    );
  }
}
