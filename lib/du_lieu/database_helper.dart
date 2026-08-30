import 'dart:convert';
import 'package:http/http.dart' as http;
import '../mo_hinh/du_lieu.dart';
import 'package:flutter/material.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Dùng IP này để kết nối tới localhost từ Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  DatabaseHelper._init();

  // --- Auth Methods ---
  Future<NguoiDung?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NguoiDung(
          id: data['id'],
          hoTen: data['name'],
          email: data['email'],
          soDienThoai: '',
          matKhau: '',
        );
      }
    } catch (e) {
      debugPrint('Lỗi login: $e');
    }
    return null;
  }

  Future<NguoiDung> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NguoiDung(
        id: data['id'],
        hoTen: data['name'],
        email: data['email'],
        soDienThoai: '',
        matKhau: '',
      );
    } else {
      throw Exception('Đăng ký thất bại');
    }
  }

  // --- Data Methods ---
  Future<List<ViTien>> getWallets(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/wallets/$userId'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((m) => ViTien(
          id: m['id'],
          tenVi: m['name'],
          loaiVi: 'CASH',
          soDu: double.tryParse(m['balance']?.toString() ?? '0') ?? 0.0,
          icon: Icons.account_balance_wallet,
          mauSac: const Color(0xFF10B981),
        )).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getWallets: $e');
    }
    return [];
  }

  Future<List<DanhMuc>> getCategories() async {
    // Trả về danh mục cứng vì Node.js chưa có bảng Category để đơn giản hóa
    return [
      DanhMuc(id: 1, ten: 'Ăn uống', loai: LoaiGiaoDich.chiTieu, icon: Icons.restaurant, mauSac: const Color(0xFFEF4444)),
      DanhMuc(id: 2, ten: 'Mua sắm', loai: LoaiGiaoDich.chiTieu, icon: Icons.shopping_cart, mauSac: const Color(0xFFF59E0B)),
      DanhMuc(id: 3, ten: 'Lương', loai: LoaiGiaoDich.thuNhap, icon: Icons.payments, mauSac: const Color(0xFF10B981)),
    ];
  }

  Future<List<ThongBao>> getNotifications(int userId) async {
    // Tạm thời trả về Mock cho UI Thông báo
    return [
      ThongBao(id: 1, tieuDe: 'Chào mừng!', noiDung: 'Chào mừng bạn đến với Cointap.', loai: 'SYSTEM', daDoc: false, ngayTao: DateTime.now())
    ];
  }

  Future<void> markNotificationAsRead(int notificationId) async {}

  Future<List<GiaoDich>> getTransactions(int userId, List<ViTien> wallets, List<DanhMuc> categories) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions/$userId'));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((m) {
          final wallet = wallets.firstWhere((w) => w.id == m['wallet_id'], orElse: () => wallets.first);
          final cat = categories.firstWhere((c) => c.loai == (m['type'] == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap), orElse: () => categories.first);
          
          return GiaoDich(
            id: m['id'],
            tieuDe: m['note'] ?? 'Giao dịch',
            soTien: double.tryParse(m['amount']?.toString() ?? '0') ?? 0.0,
            loai: m['type'] == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
            danhMuc: cat,
            viTien: wallet,
            ngay: DateTime.tryParse(m['date']) ?? DateTime.now(),
            ghiChu: m['note'],
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getTransactions: $e');
    }
    return [];
  }

  Future<NganSach> getBudget(int userId) async {
    return NganSach(id: 1, hanMuc: 5000000, daChi: 0, ngayBatDau: DateTime.now(), ngayKetThuc: DateTime.now());
  }

  Future<void> insertTransaction(GiaoDich tx, int userId) async {
    await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'wallet_id': tx.viTien.id,
        'category_id': tx.danhMuc.id,
        'amount': tx.soTien,
        'type': tx.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'date': tx.ngay.toIso8601String(),
        'note': tx.tieuDe,
      }),
    );
  }

  Future<void> insertWallet(ViTien wallet, int userId) async {
    // Map Material icon code point back to a string identifier if needed,
    // or just store string name. We will just hardcode 'account_balance_wallet'
    // in backend string format or save icon code. Here we send icon name.
    String iconName = 'account_balance_wallet';
    if (wallet.icon == Icons.credit_card) iconName = 'credit_card';
    if (wallet.icon == Icons.savings) iconName = 'savings';
    
    // Map color
    String colorHex = '#${wallet.mauSac.value.toRadixString(16).substring(2).toUpperCase()}';
    
    await http.post(
      Uri.parse('$baseUrl/wallets'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'wallet_name': wallet.tenVi,
        'wallet_type': wallet.loaiVi,
        'balance': wallet.soDu,
        'icon': iconName,
        'color': colorHex,
      }),
    );
  }
}

