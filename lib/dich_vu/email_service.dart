import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/foundation.dart';

class EmailService {
  // Thay thế bằng địa chỉ Gmail của bạn
  static const String _emailNguoiGui = 'chatgptht123@gmail.com';

  // Thay thế bằng Mật khẩu ứng dụng (App Password) sinh từ tài khoản Google
  static const String _matKhauUngDung = 'qxzjaeenfcgdcwei';

  static Future<bool> guiMaOTP(String emailNhan, String maOTP) async {


    // Cấu hình SMTP server của Google
    final smtpServer = gmail(_emailNguoiGui, _matKhauUngDung);

    // Soạn email
    final message = Message()
      ..from = const Address(_emailNguoiGui, 'Hệ Thống Quản Lý Chi Tiêu')
      ..recipients.add(emailNhan)
      ..subject = 'Mã xác thực OTP của bạn'
      ..html =
          '''
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #2563eb;">Xác thực tài khoản</h2>
          <p>Xin chào,</p>
          <p>Bạn đã yêu cầu khôi phục mật khẩu. Dưới đây là mã OTP xác thực của bạn:</p>
          <div style="padding: 16px; background-color: #f3f4f6; text-align: center; border-radius: 8px; margin: 24px 0;">
            <strong style="font-size: 24px; letter-spacing: 4px; color: #111827;">$maOTP</strong>
          </div>
          <p>Mã này có hiệu lực trong vòng 5 phút. Vui lòng không chia sẻ mã này cho bất kỳ ai.</p>
          <p>Trân trọng,<br>Đội ngũ Hỗ trợ</p>
        </div>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Đã gửi email thành công: ${sendReport.toString()}');
      return true;
    } on MailerException catch (e) {
      debugPrint('Lỗi khi gửi email: ${e.toString()}');
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
