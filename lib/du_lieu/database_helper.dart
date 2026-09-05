import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        // Lấy tất cả giao dịch chi tiêu để tự động tính daChi
        final txResponse = await _supabase
            .from('transactions')
            .select()
            .eq('user_id', userId)
            .eq('type', 'EXPENSE');

        return response.map<NganSach>((m) {
          DanhMuc? category;
          if (m['category_id'] != null) {
            try {
              category = danhSachDanhMuc.firstWhere((c) => c.id == m['category_id']);
            } catch (e) {
              // ignore
            }
          }
          
          final startDate = m['start_date'] != null ? DateTime.parse(m['start_date']) : DateTime.now();
          final endDate = m['end_date'] != null ? DateTime.parse(m['end_date']) : DateTime.now().add(const Duration(days: 30));
          
          double totalSpent = 0;
          for (var tx in txResponse) {
             final txDate = DateTime.parse(tx['transaction_date']);
             // Bao gồm cả ngày cuối cùng bằng cách so sánh Date
             final txDay = DateTime(txDate.year, txDate.month, txDate.day);
             final startDay = DateTime(startDate.year, startDate.month, startDate.day);
             final endDay = DateTime(endDate.year, endDate.month, endDate.day);
             
             if (!txDay.isBefore(startDay) && !txDay.isAfter(endDay)) {
               if (category == null || category.id == tx['category_id']) {
                  totalSpent += double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
               }
             }
          }

          return NganSach(
            id: m['budget_id'],
            hanMuc: double.tryParse(m['amount']?.toString() ?? '0') ?? 0.0,
            daChi: totalSpent,
            ngayBatDau: startDate,
            ngayKetThuc: endDate,
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

  // --- AI Chat History Methods ---
  Future<List<Map<String, dynamic>>> getAIChatMessages(int userId) async {
    // 1. Thử lấy từ Supabase
    try {
      final response = await _supabase
          .from('ai_chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final messages = response.map((m) => Map<String, dynamic>.from(m)).toList();
        // Cập nhật bộ nhớ đệm cục bộ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ai_chat_history_$userId', jsonEncode(messages));
        return messages;
      }
    } catch (e) {
      debugPrint('Supabase getAIChatMessages (dùng local cache): $e');
    }

    // 2. Fallback đọc từ SharedPreferences local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_chat_history_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        final decoded = jsonDecode(localJson) as List;
        return decoded.map((m) => Map<String, dynamic>.from(m)).toList();
      }
    } catch (e) {
      debugPrint('Local getAIChatMessages error: $e');
    }

    return [];
  }

  Future<void> insertAIChatMessage(int userId, String content, bool isUser, DateTime createdAt) async {
    final newMsg = {
      'user_id': userId,
      'content': content,
      'is_user': isUser,
      'created_at': createdAt.toIso8601String(),
    };

    // 1. Luôn lưu ngay vào SharedPreferences (đảm bảo không mất dữ liệu)
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_chat_history_$userId');
      List<dynamic> list = [];
      if (localJson != null && localJson.isNotEmpty) {
        list = jsonDecode(localJson) as List;
      }
      list.insert(0, newMsg);
      if (list.length > 100) {
        list = list.sublist(0, 100);
      }
      await prefs.setString('ai_chat_history_$userId', jsonEncode(list));
    } catch (e) {
      debugPrint('Lỗi lưu local AI chat: $e');
    }

    // 2. Đồng bộ lên Supabase nếu có bảng
    try {
      await _supabase.from('ai_chat_messages').insert(newMsg);
    } catch (e) {
      debugPrint('Lỗi insert Supabase AI chat (đã lưu local): $e');
    }
  }

  Future<void> clearAIChatMessages(int userId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_chat_history_$userId');
    } catch (e) {
      debugPrint('Lỗi clear local AI chat: $e');
    }

    // 2. Xóa Supabase
    try {
      await _supabase.from('ai_chat_messages').delete().eq('user_id', userId);
    } catch (e) {
      debugPrint('Lỗi clear Supabase AI chat: $e');
    }
  }

  // --- AI Conversations (Multi-session / Gemini-style) Methods ---
  Future<List<Map<String, dynamic>>> getAIConversations(int userId) async {
    // 1. Thử lấy từ Supabase
    try {
      final convResponse = await _supabase
          .from('ai_conversations')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      if (convResponse.isNotEmpty) {
        final List<Map<String, dynamic>> sessions = [];
        for (final conv in convResponse) {
          final sId = conv['session_id'].toString();
          final msgResponse = await _supabase
              .from('ai_chat_messages')
              .select()
              .eq('session_id', sId)
              .order('created_at', ascending: true);

          final convMap = Map<String, dynamic>.from(conv);
          convMap['messages'] = (msgResponse as List).map((m) => Map<String, dynamic>.from(m)).toList();
          sessions.add(convMap);
        }

        // Cập nhật bộ nhớ đệm cục bộ
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ai_sessions_$userId', jsonEncode(sessions));
        return sessions;
      }
    } catch (e) {
      debugPrint('Supabase getAIConversations (dùng local cache): $e');
    }

    // 2. Fallback đọc từ SharedPreferences local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        final decoded = jsonDecode(localJson) as List;
        return decoded.map((m) => Map<String, dynamic>.from(m)).toList();
      }
    } catch (e) {
      debugPrint('Local getAIConversations error: $e');
    }

    return [];
  }

  Future<void> saveAIConversation(int userId, Map<String, dynamic> sessionData) async {
    final sessionId = sessionData['session_id'].toString();

    // 1. Lưu ngay vào local SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      List<dynamic> list = [];
      if (localJson != null && localJson.isNotEmpty) {
        list = jsonDecode(localJson) as List;
      }
      final existingIndex = list.indexWhere((s) => s['session_id']?.toString() == sessionId);
      if (existingIndex >= 0) {
        list[existingIndex] = sessionData;
      } else {
        list.insert(0, sessionData);
      }
      await prefs.setString('ai_sessions_$userId', jsonEncode(list));
    } catch (e) {
      debugPrint('Lỗi lưu local AI conversation: $e');
    }

    // 2. Đồng bộ lên Supabase
    try {
      await _supabase.from('ai_conversations').upsert({
        'session_id': sessionId,
        'user_id': userId,
        'title': sessionData['title'] ?? 'Cuộc trò chuyện mới',
        'created_at': sessionData['created_at'],
        'updated_at': sessionData['updated_at'],
      });

      final messages = sessionData['messages'] as List?;
      if (messages != null && messages.isNotEmpty) {
        final lastMsg = messages.last;
        await _supabase.from('ai_chat_messages').insert({
          'session_id': sessionId,
          'user_id': userId,
          'content': lastMsg['content'],
          'is_user': lastMsg['is_user'],
          'created_at': lastMsg['created_at'],
        });
      }
    } catch (e) {
      debugPrint('Lỗi upsert Supabase AI conversation: $e');
    }
  }

  Future<void> deleteAIConversation(int userId, String sessionId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        List<dynamic> list = jsonDecode(localJson) as List;
        list.removeWhere((s) => s['session_id']?.toString() == sessionId);
        await prefs.setString('ai_sessions_$userId', jsonEncode(list));
      }
    } catch (e) {
      debugPrint('Lỗi delete local AI conversation: $e');
    }

    // 2. Xóa Supabase: Xóa tất cả tin nhắn con trước, sau đó xóa phiên trò chuyện chính
    try {
      await _supabase.from('ai_chat_messages').delete().eq('session_id', sessionId);
      await _supabase.from('ai_conversations').delete().eq('session_id', sessionId);
    } catch (e) {
      debugPrint('Lỗi delete Supabase AI conversation: $e');
    }
  }

  /// Đồng bộ danh sách tin nhắn còn lại sau khi xóa 1 hoặc nhiều tin nhắn nhỏ
  Future<void> syncAIConversationMessages(
    int userId,
    String sessionId,
    List<Map<String, dynamic>> remainingMessages,
  ) async {
    // 1. Cập nhật local
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('ai_sessions_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        List<dynamic> list = jsonDecode(localJson) as List;
        final index = list.indexWhere((s) => s['session_id']?.toString() == sessionId);
        if (index >= 0) {
          final session = Map<String, dynamic>.from(list[index]);
          session['messages'] = remainingMessages;
          session['updated_at'] = DateTime.now().toIso8601String();
          list[index] = session;
          await prefs.setString('ai_sessions_$userId', jsonEncode(list));
        }
      }
    } catch (e) {
      debugPrint('Lỗi sync local AI messages: $e');
    }

    // 2. Đồng bộ lên Supabase: Xóa sạch tin nhắn cũ của session và nạp lại danh sách mới
    try {
      await _supabase.from('ai_chat_messages').delete().eq('session_id', sessionId);
      if (remainingMessages.isNotEmpty) {
        final List<Map<String, dynamic>> records = remainingMessages.map((m) => {
          'session_id': sessionId,
          'user_id': userId,
          'content': m['content'],
          'is_user': m['is_user'] == true || m['is_user'] == 1,
          'created_at': m['created_at'],
        }).toList();
        await _supabase.from('ai_chat_messages').insert(records);
      }
      // Cập nhật updated_at cho phiên
      await _supabase.from('ai_conversations').update({
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('session_id', sessionId);
    } catch (e) {
      debugPrint('Lỗi sync Supabase AI messages: $e');
    }
  }

  Future<void> clearAllAIConversations(int userId) async {
    // 1. Xóa local
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('ai_sessions_$userId');
      await prefs.remove('ai_chat_history_$userId');
    } catch (e) {
      debugPrint('Lỗi clear local AI conversations: $e');
    }

    // 2. Xóa Supabase: Xóa tin nhắn con trước, sau đó xóa phiên
    try {
      await _supabase.from('ai_chat_messages').delete().eq('user_id', userId);
      await _supabase.from('ai_conversations').delete().eq('user_id', userId);
    } catch (e) {
      debugPrint('Lỗi clear Supabase AI conversations: $e');
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
      case 'health_and_safety': return Icons.health_and_safety;
      case 'home': return Icons.home;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'sports_esports': return Icons.sports_esports;
      case 'trending_up': return Icons.trending_up;
      case 'receipt_long': return Icons.receipt_long;
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
