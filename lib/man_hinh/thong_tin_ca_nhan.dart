import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../mo_hinh/du_lieu.dart';
import '../chu_de/mau_sac.dart';

class ManHinhThongTinCaNhan extends StatefulWidget {
  final NguoiDung nguoiDung;
  final Function(NguoiDung) onCapNhatNguoiDung;

  const ManHinhThongTinCaNhan({
    super.key,
    required this.nguoiDung,
    required this.onCapNhatNguoiDung,
  });

  @override
  State<ManHinhThongTinCaNhan> createState() => _ManHinhThongTinCaNhanState();
}

class _ManHinhThongTinCaNhanState extends State<ManHinhThongTinCaNhan> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _avatarPath = '';
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.nguoiDung.hoTen);
    _emailController = TextEditingController(text: widget.nguoiDung.email);
    _phoneController = TextEditingController(text: widget.nguoiDung.soDienThoai);
    _avatarPath = widget.nguoiDung.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _chonAnh() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarPath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi truy cập thư viện ảnh')),
        );
      }
    }
  }

  void _luuThayDoi() async {
    final hoTen = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (hoTen.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Họ tên và Email không được để trống')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedUser = NguoiDung(
        id: widget.nguoiDung.id,
        hoTen: hoTen,
        email: email,
        soDienThoai: phone,
        matKhau: widget.nguoiDung.matKhau,
        avatarUrl: _avatarPath,
        donViTienTe: widget.nguoiDung.donViTienTe,
      );

      await widget.onCapNhatNguoiDung(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin thành công'), backgroundColor: MauSac.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: MauSac.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  ImageProvider _getAvatarProvider() {
    if (_avatarPath.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    if (_avatarPath.startsWith('http')) {
      return NetworkImage(_avatarPath);
    }
    return FileImage(File(_avatarPath));
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
          icon: const Icon(Icons.arrow_back, color: MauSac.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cài đặt',
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
          children: [
            const SizedBox(height: 12),
            Text(
              'Thông tin cá nhân',
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MauSac.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quản lý hồ sơ và bảo mật của bạn',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: MauSac.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MauSac.surface, width: 4),
                      color: MauSac.surfaceContainerHighest,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _avatarPath.isEmpty
                          ? const Icon(Icons.person, size: 80, color: MauSac.outline)
                          : Image(
                              image: _getAvatarProvider(),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _chonAnh,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MauSac.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: MauSac.surface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          color: MauSac.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: MauSac.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: MauSac.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Họ và tên',
                    icon: Icons.person,
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'Email',
                    icon: Icons.mail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    label: 'Số điện thoại',
                    icon: Icons.call,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MauSac.primary,
                        foregroundColor: MauSac.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _luuThayDoi,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
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
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: MauSac.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.manrope(
            fontSize: 16,
            color: MauSac.onSurface,
            fontWeight: keyboardType == TextInputType.phone ? FontWeight.w500 : FontWeight.normal,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: MauSac.outline),
            filled: true,
            fillColor: MauSac.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          ),
        ),
      ],
    );
  }
}
