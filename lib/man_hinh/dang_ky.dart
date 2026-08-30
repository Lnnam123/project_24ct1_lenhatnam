import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';
import '../main.dart'; 

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _dangKy() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await DatabaseHelper.instance.register(name, email, password);
      
      setState(() => _isLoading = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: MauSac.success),
      );

      // Chuyển tới màn hình chính với user mới tạo
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ManHinhChinh(nguoiDung: user)),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: Có thể email đã tồn tại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Đăng ký tài khoản',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo tài khoản để quản lý chi tiêu của bạn',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Họ và tên', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.bold, color: MauSac.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'VD: Nguyễn Văn A',
                      hintStyle: GoogleFonts.manrope(color: MauSac.onSurfaceVariant.withValues(alpha: 0.5)),
                      prefixIcon: const Icon(Icons.person_outline, color: MauSac.onSurfaceVariant),
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
                      hintText: 'Tạo mật khẩu',
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
              
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _dangKy,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('ĐĂNG KÝ', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đã có tài khoản? ', style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text('Đăng nhập', style: GoogleFonts.manrope(color: MauSac.primary, fontWeight: FontWeight.bold)),
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
