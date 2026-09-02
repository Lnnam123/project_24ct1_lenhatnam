import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

class UpdateService {
  // Thay đổi thông tin repo GitHub của bạn ở đây
  static const String githubOwner = 'Lnnam123';
  static const String githubRepo = 'project_24ct1_lenhatnam';
  
  static Future<void> kiemTraCapNhat(BuildContext context, {bool hienThongBaoKhongCo = false}) async {
    try {
      // 1. Lấy version hiện tại của ứng dụng
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // 2. Gọi API GitHub để lấy release mới nhất
      final url = Uri.parse('https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', ''); // Bỏ chữ 'v' nếu có (vd: v1.0.1 -> 1.0.1)
        final releaseNotes = data['body'] as String? ?? 'Không có thông tin cập nhật.';
        
        // Tìm file APK trong danh sách assets
        String? apkDownloadUrl;
        final assets = data['assets'] as List;
        for (var asset in assets) {
          final name = asset['name'] as String;
          if (name.toLowerCase().endsWith('.apk')) {
            apkDownloadUrl = asset['browser_download_url'];
            break;
          }
        }
        
        // So sánh version
        if (_soSanhVersion(latestVersion, currentVersion) > 0 && apkDownloadUrl != null) {
          // Có phiên bản mới
          if (context.mounted) {
            _hienThiDialogCapNhat(context, latestVersion, releaseNotes, apkDownloadUrl);
          }
        } else {
          // Đã ở phiên bản mới nhất
          if (hienThongBaoKhongCo && context.mounted) {
            _hienThongBaoSnackBar(context, 'Bạn đang sử dụng phiên bản mới nhất!');
          }
        }
      } else if (response.statusCode == 404) {
        if (hienThongBaoKhongCo && context.mounted) {
          _hienThongBaoSnackBar(context, 'Chưa có bản cập nhật nào trên hệ thống.');
        }
      } else {
        if (hienThongBaoKhongCo && context.mounted) {
          _hienThongBaoSnackBar(context, 'Không thể kiểm tra cập nhật (Lỗi ${response.statusCode}).', isError: true);
        }
      }
    } catch (e) {
      debugPrint('Lỗi kiểm tra cập nhật: $e');
      if (hienThongBaoKhongCo && context.mounted) {
        _hienThongBaoSnackBar(context, 'Đã xảy ra lỗi: $e', isError: true);
      }
    }
  }
  
  static void _hienThiDialogCapNhat(BuildContext context, String versionMoi, String releaseNotes, String downloadUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: MauSac.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Bản cập nhật mới: $versionMoi',
            style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: MauSac.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chi tiết thay đổi:',
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: MauSac.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  releaseNotes,
                  style: GoogleFonts.manrope(fontSize: 14, color: MauSac.onSurfaceVariant),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Để sau', style: GoogleFonts.manrope(color: MauSac.outline)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _taiVaCaiDatAPK(context, downloadUrl);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.primary,
                foregroundColor: MauSac.surface,
              ),
              child: Text('Tải về & Cài đặt', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  static Future<void> _hienThiThongBaoTienTrinh(int id, int progress) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'update_channel',
      'Cập nhật ứng dụng',
      channelDescription: 'Thông báo tiến trình tải xuống bản cập nhật',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
      ongoing: true,
      icon: '@mipmap/ic_launcher',
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      id: id,
      title: 'Đang tải bản cập nhật...',
      body: '$progress%',
      notificationDetails: platformChannelSpecifics,
    );
  }

  static void _taiVaCaiDatAPK(BuildContext context, String downloadUrl) async {
    try {
      await _initNotifications();
      
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();

      int notificationId = 0;
      
      // Hiển thị thông báo ngay khi bắt đầu tải
      if (context.mounted) {
        _hienThongBaoSnackBar(context, 'Đang tải bản cập nhật trong nền. Vui lòng xem trên thanh thông báo.');
      }
      
      final stream = OtaUpdate().execute(
        downloadUrl,
        destinationFilename: 'cointap_update.apk',
      );
      
      stream.listen(
        (OtaEvent event) {
          if (event.status == OtaStatus.DOWNLOADING) {
            int progress = int.tryParse(event.value ?? '0') ?? 0;
            _hienThiThongBaoTienTrinh(notificationId, progress);
          } else if (event.status == OtaStatus.INSTALLING) {
            _notificationsPlugin.cancel(id: notificationId);
            if (context.mounted) {
              _hienThongBaoSnackBar(context, 'Tải xong, đang mở trình cài đặt...');
            }
          } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
            _notificationsPlugin.cancel(id: notificationId);
            if (context.mounted) {
              _hienThongBaoSnackBar(context, 'Lỗi: Ứng dụng không được cấp quyền ghi bộ nhớ!', isError: true);
            }
          } else if (event.status != OtaStatus.DOWNLOADING) {
            _notificationsPlugin.cancel(id: notificationId);
            if (context.mounted) {
              _hienThongBaoSnackBar(context, 'Lỗi cập nhật: ${event.status.toString()} - ${event.value}', isError: true);
            }
          }
        },
        onError: (error) {
          _notificationsPlugin.cancel(id: notificationId);
          if (context.mounted) {
            _hienThongBaoSnackBar(context, 'Lỗi tải xuống: $error', isError: true);
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        _hienThongBaoSnackBar(context, 'Lỗi khởi chạy tải xuống: $e', isError: true);
      }
    }
  }

  static void _hienThongBaoSnackBar(BuildContext context, String thongBao, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          thongBao,
          style: GoogleFonts.manrope(color: MauSac.surface),
        ),
        backgroundColor: isError ? MauSac.error : MauSac.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Hàm helper so sánh 2 chuỗi version, trả về > 0 nếu v1 > v2
  static int _soSanhVersion(String v1, String v2) {
    List<int> p1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> p2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < p1.length && i < p2.length; i++) {
      if (p1[i] > p2[i]) return 1;
      if (p1[i] < p2[i]) return -1;
    }
    return p1.length.compareTo(p2.length);
  }
}
