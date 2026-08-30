import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';
import '../mo_hinh/du_lieu.dart';

class ManHinhDoiMatKhau extends StatefulWidget {
  final NguoiDung nguoiDung;
  final Function(NguoiDung) onCapNhatNguoiDung;

  const ManHinhDoiMatKhau({
    super.key,
    required this.nguoiDung,
    required this.onCapNhatNguoiDung,
  });

  @override
  State<ManHinhDoiMatKhau> createState() => _ManHinhDoiMatKhauState();
}

class _ManHinhDoiMatKhauState extends State<ManHinhDoiMatKhau> {
  final _matKhauHienTaiController = TextEditingController();
  final _matKhauMoiController = TextEditingController();
  final _xacNhanMatKhauController = TextEditingController();

  bool _anMatKhauHienTai = true;
  bool _anMatKhauMoi = true;
  bool _anXacNhanMatKhau = true;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _matKhauHienTaiController.dispose();
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

  Future<void> _capNhatMatKhau() async {
    final mkHienTai = _matKhauHienTaiController.text;
    final mkMoi = _matKhauMoiController.text;
    final xacNhan = _xacNhanMatKhauController.text;

    if (mkHienTai.isEmpty || mkMoi.isEmpty || xacNhan.isEmpty) {
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

    if (mkHienTai == mkMoi) {
      _hienThongBao('Mật khẩu mới không được trùng với mật khẩu cũ.', isError: true);
      return;
    }

    setState(() => _dangXuLy = true);

    // Call database to update password
    final success = await DatabaseHelper.instance.changePassword(
      widget.nguoiDung.id,
      mkHienTai,
      mkMoi,
    );

    setState(() => _dangXuLy = false);

    if (success) {
      _hienThongBao('Đổi mật khẩu thành công!');
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      _hienThongBao('Mật khẩu hiện tại không chính xác hoặc lỗi hệ thống.', isError: true);
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
      backgroundColor: MauSac.surface,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Đổi mật khẩu',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPasswordField(
              label: 'Mật khẩu hiện tại',
              hint: 'Nhập mật khẩu hiện tại',
              controller: _matKhauHienTaiController,
              isObscure: _anMatKhauHienTai,
              onToggleVisibility: () => setState(() => _anMatKhauHienTai = !_anMatKhauHienTai),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
              controller: _matKhauMoiController,
              isObscure: _anMatKhauMoi,
              onToggleVisibility: () => setState(() => _anMatKhauMoi = !_anMatKhauMoi),
            ),
            const SizedBox(height: 24),
            _buildPasswordField(
              label: 'Xác nhận mật khẩu mới',
              hint: 'Nhập lại mật khẩu mới',
              controller: _xacNhanMatKhauController,
              isObscure: _anXacNhanMatKhau,
              onToggleVisibility: () => setState(() => _anXacNhanMatKhau = !_anXacNhanMatKhau),
            ),
            const SizedBox(height: 24),
            
            // Security Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: MauSac.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mật khẩu phải có ít nhất 8 ký tự.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: MauSac.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _dangXuLy ? null : _capNhatMatKhau,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MauSac.primary,
                  foregroundColor: MauSac.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _dangXuLy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: MauSac.surface,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Cập nhật mật khẩu',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
