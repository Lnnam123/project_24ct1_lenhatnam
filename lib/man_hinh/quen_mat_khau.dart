import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';
import '../dich_vu/email_service.dart';
import 'xac_thuc_otp.dart';

class ManHinhQuenMatKhau extends StatefulWidget {
  const ManHinhQuenMatKhau({super.key});

  @override
  State<ManHinhQuenMatKhau> createState() => _ManHinhQuenMatKhauState();
}

class _ManHinhQuenMatKhauState extends State<ManHinhQuenMatKhau> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  void _guiYeuCau() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập email của bạn.', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Kiểm tra email trong DB
    final exists = await DatabaseHelper.instance.checkEmailExists(email);
    
    if (!exists) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email không tồn tại trong hệ thống.', style: GoogleFonts.manrope()),
            backgroundColor: MauSac.error,
          ),
        );
      }
      return;
    }

    // Tạo mã OTP ngẫu nhiên 6 chữ số
    final otp = (100000 + math.Random().nextInt(900000)).toString();

    // Gửi email
    final sent = await EmailService.guiMaOTP(email, otp);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (sent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ManHinhXacThucOTP(email: email, otpGoc: otp),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra khi gửi email. Vui lòng thử lại.', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                'Quên mật khẩu',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Đừng lo lắng! Nhập email của bạn để nhận hướng dẫn đặt lại mật khẩu.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: MauSac.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              
              // Form
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Địa chỉ Email',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.manrope(fontSize: 14, color: MauSac.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Nhập email của bạn',
                      hintStyle: GoogleFonts.manrope(color: MauSac.outlineVariant),
                      prefixIcon: const Icon(Icons.mail_outline, color: MauSac.outline),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary, // Đổi sang màu primary cho nổi bật
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _guiYeuCau,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Gửi yêu cầu',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              ),
              
              const Spacer(),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: MauSac.primary,
                  ),
                  child: Text(
                    'Quay lại Đăng nhập',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
