import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../mo_hinh/du_lieu.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  final _supabase = Supabase.instance.client;

  DatabaseHelper._init();

  // --- Auth Methods ---
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('Lỗi check email: $e');
      return false;
    }
  }

  Future<NguoiDung?> login(String email, String password) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .eq('password_hash', password)
          .maybeSingle();

      if (response != null) {
        return NguoiDung(
          id: response['user_id'],
          hoTen: response['full_name'],
          email: response['email'],
          soDienThoai: '',
          matKhau: '',
        );
      }
    } catch (e) {
      debugPrint('Lỗi login: $e');
    }
    return null;
  }

  Future<bool> changePassword(int userId, String oldPassword, String newPassword) async {
    try {
      // Xác minh mật khẩu cũ trước khi đổi
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', userId)
          .eq('password_hash', oldPassword)
          .maybeSingle();

      if (response == null) {
        return false; // Mật khẩu cũ không đúng
      }

      // Cập nhật mật khẩu mới
      await _supabase
          .from('users')
          .update({'password_hash': newPassword})
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('Lỗi đổi mật khẩu: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      await _supabase
          .from('users')
          .update({'password_hash': newPassword})
          .eq('email', email);
      return true;
    } catch (e) {
      debugPrint('Lỗi đặt lại mật khẩu: $e');
      return false;
    }
  }

  Future<NguoiDung> register(String name, String email, String password) async {
    try {
      // Postgres duplicate entry error will throw an exception
      final response = await _supabase
          .from('users')
          .insert({
            'full_name': name,
            'email': email,
            'password_hash': password,
          })
          .select()
          .single();

      final userId = response['user_id'];

      // Tạo ví mặc định
      await _supabase.from('wallets').insert({
        'user_id': userId,
        'wallet_name': 'Ví Tiền Mặt',
        'wallet_type': 'CASH',
        'balance': 0,
        'icon': 'payments',
        'color': '#10B981',
      });

      return NguoiDung(
        id: userId,
        hoTen: name,
        email: email,
        soDienThoai: '',
        matKhau: '',
      );
    } catch (e) {
      debugPrint('Lỗi register: $e');
      if (e.toString().contains('23505') || e.toString().contains('duplicate key')) {
        throw Exception('Email đã tồn tại');
      }
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  Future<void> updateUser(NguoiDung user) async {
    try {
      await _supabase.from('users').update({
        'full_name': user.hoTen,
        'email': user.email,
        'phone_number': user.soDienThoai,
        'avatar_url': user.avatarUrl,
      }).eq('user_id', user.id);
    } catch (e) {
      debugPrint('Lỗi updateUser: $e');
      throw Exception('Cập nhật thông tin thất bại: $e');
    }
  }

  // --- Data Methods ---
  Future<List<ViTien>> getWallets(int userId) async {
    try {
      final response = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .eq('is_active', true);

      return (response as List).map((m) => ViTien(
        id: m['wallet_id'],
        tenVi: m['wallet_name'],
        loaiVi: m['wallet_type'] ?? 'CASH',
        soDu: double.tryParse(m['balance']?.toString() ?? '0') ?? 0.0,
        icon: _getIconFromString(m['icon']),
        mauSac: _getColorFromString(m['color']),
      )).toList();
    } catch (e) {
      debugPrint('Lỗi getWallets: $e');
    }
    return [];
  }

  Future<List<DanhMuc>> getCategories([int? userId]) async {
    try {
      var query = _supabase.from('categories').select();
      if (userId != null) {
        query = query.or('user_id.eq.$userId,user_id.is.null');
      } else {
        query = query.filter('user_id', 'is', null);
      }

      final response = await query;
      
      if ((response as List).isNotEmpty) {
        return response.map((m) => DanhMuc(
          id: m['category_id'],
          ten: m['name'],
          loai: m['type'] == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
          icon: _getIconFromString(m['icon']),
          mauSac: _getColorFromString(m['color']),
        )).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getCategories: $e');
    }

    return [
      DanhMuc(id: 1, ten: 'Ăn uống', loai: LoaiGiaoDich.chiTieu, icon: Icons.restaurant, mauSac: const Color(0xFFEF4444)),
      DanhMuc(id: 2, ten: 'Mua sắm', loai: LoaiGiaoDich.chiTieu, icon: Icons.shopping_cart, mauSac: const Color(0xFFF59E0B)),
      DanhMuc(id: 3, ten: 'Lương', loai: LoaiGiaoDich.thuNhap, icon: Icons.payments, mauSac: const Color(0xFF10B981)),
      DanhMuc(id: 4, ten: 'Di chuyển', loai: LoaiGiaoDich.chiTieu, icon: Icons.directions_car, mauSac: const Color(0xFF2563EB)),
      DanhMuc(id: 5, ten: 'Giải trí', loai: LoaiGiaoDich.chiTieu, icon: Icons.movie, mauSac: const Color(0xFF712AE2)),
    ];
  }

  Future<void> insertCategory(DanhMuc category, int userId) async {
    try {
      final colorHex = '#${category.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      await _supabase.from('categories').insert({
        'user_id': userId,
        'name': category.ten,
        'type': category.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'icon': category.iconName,
        'color': colorHex,
      });
    } catch (e) {
      debugPrint('Lỗi insertCategory: $e');
    }
  }

  Future<void> updateCategory(DanhMuc category) async {
    try {
      final colorHex = '#${category.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      await _supabase.from('categories').update({
        'name': category.ten,
        'type': category.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'icon': category.iconName,
        'color': colorHex,
      }).eq('category_id', category.id);
    } catch (e) {
      debugPrint('Lỗi updateCategory: $e');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await _supabase.from('categories').delete().eq('category_id', categoryId);
    } catch (e) {
      debugPrint('Lỗi deleteCategory: $e');
    }
  }

  Future<List<ThongBao>> getNotifications(int userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((m) {
        return ThongBao(
          id: m['notification_id'],
          tieuDe: m['title'],
          noiDung: m['content'],
          loai: m['type'],
          daDoc: m['is_read'] ?? false,
          ngayTao: m['created_at'] != null ? DateTime.parse(m['created_at']) : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi getNotifications: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _supabase.from('notifications').update({'is_read': true}).eq('notification_id', notificationId);
    } catch (e) {
      debugPrint('Lỗi markNotificationAsRead: $e');
    }
  }

  Future<void> insertNotification(int userId, String title, String content, String type, {DateTime? createdAt}) async {
    try {
      final Map<String, dynamic> data = {
        'user_id': userId,
        'title': title,
        'content': content,
        'type': type,
      };
      if (createdAt != null) {
        data['created_at'] = createdAt.toIso8601String();
      }
      await _supabase.from('notifications').insert(data);
    } catch (e) {
      debugPrint('Lỗi insertNotification: $e');
    }
  }

  Future<List<GiaoDich>> getTransactions(int userId, List<ViTien> wallets, List<DanhMuc> categories) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('transaction_date', ascending: false)
          .order('transaction_id', ascending: false);

      return (response as List).map((m) {
        final wallet = wallets.firstWhere((w) => w.id == m['wallet_id'], orElse: () => wallets.first);
        final cat = categories.firstWhere(
          (c) => c.id == m['category_id'],
          orElse: () => categories.firstWhere(
            (c) => c.loai == (m['type'] == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap),
            orElse: () => categories.first,
          ),
        );
        
        return GiaoDich(
          id: m['transaction_id'],
          tieuDe: m['note'] ?? 'Giao dịch',
          soTien: double.tryParse(m['amount']?.toString() ?? '0') ?? 0.0,
          loai: m['type'] == 'EXPENSE' ? LoaiGiaoDich.chiTieu : LoaiGiaoDich.thuNhap,
          danhMuc: cat,
          viTien: wallet,
          ngay: m['transaction_date'] != null ? DateTime.parse(m['transaction_date']) : DateTime.now(),
          ghiChu: m['note'],
        );
      }).toList();
    } catch (e) {
      debugPrint('Lỗi getTransactions: $e');
    }
    return [];
  }

  Future<List<NganSach>> getBudgets(int userId, List<DanhMuc> danhSachDanhMuc) async {
    try {
      final response = await _supabase
          .from('budgets')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      if (response.isNotEmpty) {
        return response.map<NganSach>((m) {
          DanhMuc? category;
          if (m['category_id'] != null) {
            try {
              category = danhSachDanhMuc.firstWhere((c) => c.id == m['category_id']);
            } catch (e) {
              // ignore
            }
          }
          
          return NganSach(
            id: m['budget_id'],
            hanMuc: double.tryParse(m['amount']?.toString() ?? '0') ?? 0.0,
            daChi: 0, // daChi will be calculated in main.dart
            ngayBatDau: m['start_date'] != null ? DateTime.parse(m['start_date']) : DateTime.now(),
            ngayKetThuc: m['end_date'] != null ? DateTime.parse(m['end_date']) : DateTime.now().add(const Duration(days: 30)),
            danhMuc: category,
          );
        }).toList();
      }
    } catch (e) {
      debugPrint('Lỗi getBudgets: $e');
    }
    return [];
  }

  Future<void> updateBudget(NganSach nganSach, int userId) async {
    try {
      if (nganSach.id == 0) {
        // Insert
        await _supabase.from('budgets').insert({
          'user_id': userId,
          'category_id': nganSach.danhMuc?.id,
          'amount': nganSach.hanMuc,
          'start_date': nganSach.ngayBatDau.toIso8601String(),
          'end_date': nganSach.ngayKetThuc.toIso8601String(),
        });
      } else {
        // Update
        await _supabase.from('budgets').update({
          'category_id': nganSach.danhMuc?.id,
          'amount': nganSach.hanMuc,
        }).eq('budget_id', nganSach.id);
      }
    } catch (e) {
      debugPrint('Lỗi updateBudget: $e');
      rethrow;
    }
  }

  Future<void> deleteBudget(int budgetId) async {
    try {
      await _supabase.from('budgets').delete().eq('budget_id', budgetId);
    } catch (e) {
      debugPrint('Lỗi deleteBudget: $e');
      rethrow;
    }
  }

  Future<void> insertTransaction(GiaoDich tx, int userId) async {
    try {
      await _supabase.from('transactions').insert({
        'user_id': userId,
        'wallet_id': tx.viTien.id,
        'category_id': tx.danhMuc.id,
        'amount': tx.soTien,
        'type': tx.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'transaction_date': tx.ngay.toIso8601String(),
        'note': tx.tieuDe,
      });
    } catch (e) {
      debugPrint('Lỗi insertTransaction: $e');
    }
  }

  Future<void> updateTransaction(GiaoDich tx) async {
    try {
      await _supabase.from('transactions').update({
        'wallet_id': tx.viTien.id,
        'category_id': tx.danhMuc.id,
        'amount': tx.soTien,
        'type': tx.loai == LoaiGiaoDich.chiTieu ? 'EXPENSE' : 'INCOME',
        'transaction_date': tx.ngay.toIso8601String(),
        'note': tx.tieuDe,
      }).eq('transaction_id', tx.id!);
    } catch (e) {
      debugPrint('Lỗi updateTransaction: $e');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    try {
      await _supabase.from('transactions').delete().eq('transaction_id', transactionId);
    } catch (e) {
      debugPrint('Lỗi deleteTransaction: $e');
    }
  }

  Future<void> updateTransactionCategory(int transactionId, int categoryId) async {
    try {
      await _supabase.from('transactions').update({
        'category_id': categoryId,
      }).eq('transaction_id', transactionId);
    } catch (e) {
      debugPrint('Lỗi updateTransactionCategory: $e');
    }
  }

  Future<void> insertWallet(ViTien wallet, int userId) async {
    try {
      String iconName = 'account_balance_wallet';
      if (wallet.icon == Icons.credit_card) iconName = 'credit_card';
      if (wallet.icon == Icons.savings) iconName = 'savings';
      
      String colorHex = '#${wallet.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      
      await _supabase.from('wallets').insert({
        'user_id': userId,
        'wallet_name': wallet.tenVi,
        'wallet_type': wallet.loaiVi,
        'balance': wallet.soDu,
        'icon': iconName,
        'color': colorHex,
      });
    } catch (e) {
      debugPrint('Lỗi insertWallet: $e');
    }
  }

  Future<void> updateWallet(ViTien wallet) async {
    try {
      String iconName = 'account_balance_wallet';
      if (wallet.icon == Icons.credit_card) iconName = 'credit_card';
      if (wallet.icon == Icons.savings) iconName = 'savings';
      
      String colorHex = '#${wallet.mauSac.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
      
      await _supabase.from('wallets').update({
        'wallet_name': wallet.tenVi,
        'wallet_type': wallet.loaiVi,
        'balance': wallet.soDu,
        'icon': iconName,
        'color': colorHex,
      }).eq('wallet_id', wallet.id);
    } catch (e) {
      debugPrint('Lỗi updateWallet: $e');
    }
  }

  Future<void> deleteWallet(int walletId) async {
    try {
      await _supabase.from('wallets').update({'is_active': false}).eq('wallet_id', walletId);
    } catch (e) {
      debugPrint('Lỗi deleteWallet: $e');
    }
  }

  // --- Helper Methods ---
  IconData _getIconFromString(String? iconName) {
    if (iconName == null) return Icons.category;
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'payments': return Icons.payments;
      case 'attach_money': return Icons.attach_money;
      case 'directions_car': return Icons.directions_car;
      case 'movie': return Icons.movie;
      case 'more_time': return Icons.more_time;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'credit_card': return Icons.credit_card;
      case 'savings': return Icons.savings;
      default: return Icons.category;
    }
  }

  Color _getColorFromString(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.black;
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor'; 
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
