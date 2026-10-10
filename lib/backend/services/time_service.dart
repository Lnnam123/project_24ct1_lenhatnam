import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Dịch vụ lấy thời gian thực chuẩn qua Internet.
class TimeService {
  /// [getCurrentTime]: Lấy thời gian thực theo múi giờ Việt Nam (Asia/Ho_Chi_Minh) qua API.
  /// - Chống việc người dùng cố tình chỉnh giờ máy điện thoại để gian lận ghi đè lịch sử chi tiêu.
  /// - Tự động fallback về [DateTime.now()] nếu không có kết nối Internet.
  static Future<DateTime> getCurrentTime() async {
    try {
      final response = await http
          .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Ho_Chi_Minh'))
          .timeout(const Duration(seconds: 5));
          
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final datetimeStr = data['datetime'];
        return DateTime.parse(datetimeStr);
      } else {
        debugPrint('Failed to load internet time, falling back to local time.');
        return DateTime.now();
      }
    } catch (e) {
      debugPrint('Error loading internet time: $e');
      return DateTime.now();
    }
  }
}
