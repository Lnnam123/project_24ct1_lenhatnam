import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';
import 'dang_ky.dart';
import '../main.dart'; // To access ManHinhChinh (we will refactor this later if needed)

import 'dang_nhap_nhanh.dart';
import 'quen_mat_khau.dart';

class ManHinhDangNhap extends StatefulWidget {
  final bool allowRedirect;
  const ManHinhDangNhap({super.key, this.allowRedirect = true});

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.allowRedirect) {
      _checkSavedUser();
    }
  }

  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('saved_user_id');
    final savedUserName = prefs.getString('saved_user_name');
    final savedUserEmail = prefs.getString('saved_user_email');

    if (savedUserId != null && savedUserName != null && savedUserEmail != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ManHinhDangNhapNhanh(
            savedUserId: savedUserId,
            savedUserName: savedUserName,
            savedUserEmail: savedUserEmail,
          ),
        ),
      );
    }
  }

  void _dangNhap() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseHelper.instance.login(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saved_user_id', user.id);
      await prefs.setString('saved_user_name', user.hoTen);
      await prefs.setString('saved_user_email', user.email);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ManHinhChinh(nguoiDung: user)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc mật khẩu không chính xác!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Đăng nhập',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quản lý tài chính thông minh cùng Cointap',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: MauSac.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Nhập email của bạn',
                      hintStyle: GoogleFonts.manrope(color: MauSac.onSurfaceVariant.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.mail_outline, color: MauSac.onSurfaceVariant),
                      filled: true,
                      fillColor: MauSac.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mật khẩu', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: MauSac.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      hintStyle: GoogleFonts.manrope(color: MauSac.onSurfaceVariant.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.lock_outline, color: MauSac.onSurfaceVariant),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        color: MauSac.onSurfaceVariant,
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: MauSac.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: MauSac.borderSubtle),
                      ),
                    ),
                  ),
                ],
              ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManHinhQuenMatKhau()),
                    );
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: GoogleFonts.manrope(color: MauSac.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _dangNhap,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('ĐĂNG NHẬP', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa có tài khoản? ', style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhDangKy()));
                    },
                    child: Text('Đăng ký ngay', style: GoogleFonts.manrope(color: MauSac.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
