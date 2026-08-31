import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';

class ManHinhDatLaiMatKhau extends StatefulWidget {
  final String email;

  const ManHinhDatLaiMatKhau({
    super.key,
    required this.email,
  });

  @override
  State<ManHinhDatLaiMatKhau> createState() => _ManHinhDatLaiMatKhauState();
}

class _ManHinhDatLaiMatKhauState extends State<ManHinhDatLaiMatKhau> {
  final _matKhauMoiController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  bool _anMatKhauMoi = true;
  bool _anXacNhanMatKhau = true;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _matKhauMoiController.dispose();
    _xacNhanMatKhauController.dispose();
    super.dispose();
  }

  void _hienThongBao(String thongBao, {bool isError = false}) {
    if (!mounted) return;
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

  Future<void> _datLaiMatKhau() async {
    final mkMoi = _matKhauMoiController.text;
    final xacNhan = _xacNhanMatKhauController.text;

    if (mkMoi.isEmpty || xacNhan.isEmpty) {
      _hienThongBao('Vui lòng điền đầy đủ thông tin.', isError: true);
      return;
    }

    if (mkMoi.length < 8) {
      _hienThongBao('Mật khẩu mới phải có ít nhất 8 ký tự.', isError: true);
      return;
    }

    if (mkMoi != xacNhan) {
      _hienThongBao('Mật khẩu xác nhận không khớp.', isError: true);
      return;
    }

    setState(() => _dangXuLy = true);

    // Call database to update password
    final success = await DatabaseHelper.instance.resetPassword(
      widget.email,
      mkMoi,
    );

    setState(() => _dangXuLy = false);

    if (success) {
      _hienThongBao('Đặt lại mật khẩu thành công!');
      if (!mounted) return;
      // Trở về trang đăng nhập nhanh (màn hình gốc)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      _hienThongBao('Đã xảy ra lỗi khi đặt lại mật khẩu.', isError: true);
    }
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: MauSac.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: MauSac.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.manrope(color: MauSac.outline),
            filled: true,
            fillColor: MauSac.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: MauSac.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: MauSac.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: MauSac.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility : Icons.visibility_off,
                color: MauSac.outline,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đặt lại mật khẩu',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
              controller: _matKhauMoiController,
              isObscure: _anMatKhauMoi,
              onToggleVisibility: () {
                setState(() => _anMatKhauMoi = !_anMatKhauMoi);
              },
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Xác nhận mật khẩu mới',
              hint: 'Nhập lại mật khẩu mới',
              controller: _xacNhanMatKhauController,
              isObscure: _anXacNhanMatKhau,
              onToggleVisibility: () {
                setState(() => _anXacNhanMatKhau = !_anXacNhanMatKhau);
              },
            ),
            const SizedBox(height: 48),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _dangXuLy ? null : _datLaiMatKhau,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.primary,
                  foregroundColor: MauSac.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _dangXuLy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: MauSac.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'CẬP NHẬT MẬT KHẨU',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
