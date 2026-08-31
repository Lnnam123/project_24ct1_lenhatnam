import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../du_lieu/database_helper.dart';
import '../mo_hinh/du_lieu.dart';

class NotificationService {
  static const String githubOwner = 'Lnnam123';
  static const String githubRepo = 'project_24ct1_lenhatnam';

  static Future<void> dongBoThongBao(int userId) async {
    try {
      final db = DatabaseHelper.instance;
      
      // 1. Lấy danh sách thông báo hiện tại để check trùng lặp
      final existingNotifications = await db.getNotifications(userId);
      final existingTitles = existingNotifications.map((e) => e.tieuDe).toSet();
      
      // 2. Chào mừng
      if (!existingTitles.contains('Chào mừng!')) {
        await _checkWelcomeNotification(userId, db);
      }
      
      // 3. Kiểm tra ngân sách
      await _checkBudgetNotifications(userId, db, existingTitles);
      
      // 4. Kiểm tra cập nhật ứng dụng
      if (!existingTitles.contains('Cập nhật ứng dụng')) {
        await _checkAppUpdateNotification(userId, db);
      }
      
    } catch (e) {
      debugPrint('Lỗi dongBoThongBao: $e');
    }
  }

  static Future<void> _checkWelcomeNotification(int userId, DatabaseHelper db) async {
    try {
      final response = await Supabase.instance.client.from('users').select('created_at').eq('user_id', userId).single();
      final createdAt = response['created_at'] != null ? DateTime.parse(response['created_at']) : DateTime.now();
      
      await db.insertNotification(
        userId,
        'Chào mừng!',
        'Chào mừng bạn đến với Cointap.',
        'SYSTEM',
        createdAt: createdAt,
      );
    } catch (e) {
      debugPrint('Lỗi _checkWelcomeNotification: $e');
    }
  }

  static Future<void> _checkBudgetNotifications(int userId, DatabaseHelper db, Set<String> existingTitles) async {
    try {
      final wallets = await db.getWallets(userId);
      final categories = await db.getCategories(userId);
      final budgets = await db.getBudgets(userId, categories);
      final transactions = await db.getTransactions(userId, wallets, categories);
      
      for (var budget in budgets) {
        double totalSpent = 0;
        for (var tx in transactions) {
          if (tx.loai == LoaiGiaoDich.chiTieu &&
              (tx.ngay.isAfter(budget.ngayBatDau) || tx.ngay.isAtSameMomentAs(budget.ngayBatDau)) &&
              (tx.ngay.isBefore(budget.ngayKetThuc) || tx.ngay.isAtSameMomentAs(budget.ngayKetThuc))) {
            
            if (budget.danhMuc == null || budget.danhMuc!.id == tx.danhMuc.id) {
              totalSpent += tx.soTien;
            }
          }
        }
        
        if (budget.hanMuc > 0) {
          double percent = totalSpent / budget.hanMuc;
          if (percent >= 0.8) {
            final title = 'Ngân sách ${budget.danhMuc?.ten ?? "Tổng"} sắp hết';
            // Check if we already notified for this budget title
            if (!existingTitles.contains(title)) {
              String content = percent >= 1.0 
                  ? 'Bạn đã tiêu vượt quá ngân sách ${budget.danhMuc?.ten ?? "tổng"} tháng này. Hãy điều chỉnh chi tiêu!'
                  : 'Bạn đã tiêu hết ${(percent * 100).toInt()}% ngân sách ${budget.danhMuc?.ten ?? "tổng"} tháng này.';
              
              await db.insertNotification(
                userId,
                title,
                content,
                'BUDGET_ALERT',
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Lỗi _checkBudgetNotifications: $e');
    }
  }

  static Future<void> _checkAppUpdateNotification(int userId, DatabaseHelper db) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final url = Uri.parse('https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        
        List<int> p1 = latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        List<int> p2 = currentVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
        
        bool isNewer = false;
        for (int i = 0; i < p1.length && i < p2.length; i++) {
          if (p1[i] > p2[i]) {
            isNewer = true;
            break;
          } else if (p1[i] < p2[i]) {
            break;
          }
        }
        
        if (isNewer) {
          await db.insertNotification(
            userId,
            'Cập nhật ứng dụng',
            'Phiên bản mới $latestVersion đã sẵn sàng. Cập nhật ngay để trải nghiệm các tính năng mới!',
            'SYSTEM',
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi _checkAppUpdateNotification: $e');
    }
  }
}
