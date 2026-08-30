import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

class UpdateService {
  // Thay đổi thông tin repo GitHub của bạn ở đây
  static const String githubOwner = 'Lnnam123';
  static const String githubRepo = 'appandroid';
  
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
  
  static void _taiVaCaiDatAPK(BuildContext context, String downloadUrl) {
    try {
      // Hiển thị dialog tiến trình
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return const _TienTrinhTaiXuong();
        }
      );
      
      // Bắt đầu tải và lắng nghe sự kiện
      OtaUpdate().execute(
        downloadUrl,
        destinationFilename: 'cointap_update.apk',
      ).listen(
        (OtaEvent event) {
          if (event.status == OtaStatus.DOWNLOADING) {
            // Có thể dùng event.value để biết % nếu cần update UI dialog (phức tạp hơn nên đang để spinner quay vô hạn)
            debugPrint('Đang tải: ${event.value}%');
          } else if (event.status == OtaStatus.INSTALLING) {
            // Đã tải xong, Android sẽ tự hiện bảng Cài đặt. Mình đóng dialog tiến trình.
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop(); 
            }
          } else if (event.status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
            if (context.mounted) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              _hienThongBaoSnackBar(context, 'Lỗi: Ứng dụng không được cấp quyền ghi bộ nhớ!', isError: true);
            }
          } else if (event.status != OtaStatus.DOWNLOADING) {
            // Các lỗi khác
            if (context.mounted) {
              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              _hienThongBaoSnackBar(context, 'Có lỗi trong quá trình cập nhật!', isError: true);
            }
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
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

class _TienTrinhTaiXuong extends StatelessWidget {
  const _TienTrinhTaiXuong();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MauSac.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: MauSac.primary),
            const SizedBox(height: 24),
            Text(
              'Đang tải xuống bản cập nhật...',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: MauSac.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng đợi. Trình cài đặt sẽ tự động bật khi tải xong.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: MauSac.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
