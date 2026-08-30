import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

import '../mo_hinh/du_lieu.dart';
import 'dang_nhap.dart';
import 'dang_nhap_nhanh.dart';
import 'quan_ly_danh_muc.dart';
import 'thong_tin_ca_nhan.dart';
import 'package:permission_handler/permission_handler.dart';
import 'doi_mat_khau.dart';
import '../dich_vu/update_service.dart';

class ManHinhCaiDat extends StatefulWidget {
  final NguoiDung nguoiDung;
  final List<DanhMuc> danhSachDanhMuc;
  final Function(DanhMuc danhMucMoi) onThemDanhMuc;
  final Function(DanhMuc danhMucSua) onCapNhatDanhMuc;
  final Function(int danhMucId) onXoaDanhMuc;
  final Function(NguoiDung)? onCapNhatNguoiDung;

  const ManHinhCaiDat({
    super.key,
    required this.nguoiDung,
    required this.danhSachDanhMuc,
    required this.onThemDanhMuc,
    required this.onCapNhatDanhMuc,
    required this.onXoaDanhMuc,
    this.onCapNhatNguoiDung,
  });

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  bool _batKhieuUngDung = true;

  ImageProvider _getAvatarProvider() {
    final path = widget.nguoiDung.avatarUrl;
    if (path.isEmpty) return const AssetImage('assets/images/default_avatar.png');
    if (path.startsWith('http')) return NetworkImage(path);
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    const colorErrorContainer = Color(0xFFFFDAD6);
    
    return Scaffold(
      backgroundColor: MauSac.background,
      appBar: AppBar(
        backgroundColor: MauSac.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Cài đặt',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MauSac.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: MauSac.surfaceContainerHigh,
                    backgroundImage: widget.nguoiDung.avatarUrl.isNotEmpty ? _getAvatarProvider() : null,
                    child: widget.nguoiDung.avatarUrl.isEmpty 
                        ? const Icon(Icons.person, color: MauSac.primary, size: 36)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nguoiDung.hoTen,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MauSac.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.nguoiDung.email,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: MauSac.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tài khoản Settings
            _buildSectionTitle('Tài khoản'),
            _buildSettingsGroup([
              _buildSettingsItem(
                icon: Icons.person,
                title: 'Thông tin cá nhân',
                onTap: () {
                  if (widget.onCapNhatNguoiDung != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ManHinhThongTinCaNhan(
                          nguoiDung: widget.nguoiDung,
                          onCapNhatNguoiDung: widget.onCapNhatNguoiDung!,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                icon: Icons.lock_outline,
                title: 'Đổi mật khẩu',
                onTap: () {
                  if (widget.onCapNhatNguoiDung != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ManHinhDoiMatKhau(
                          nguoiDung: widget.nguoiDung,
                          onCapNhatNguoiDung: widget.onCapNhatNguoiDung!,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildSettingsItem(
                icon: Icons.category,
                title: 'Quản lý danh mục thu/chi',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ManHinhQuanLyDanhMuc(
                        danhSachDanhMuc: widget.danhSachDanhMuc,
                        onThemDanhMuc: widget.onThemDanhMuc,
                        onCapNhatDanhMuc: widget.onCapNhatDanhMuc,
                        onXoaDanhMuc: widget.onXoaDanhMuc,
                      ),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.key,
                title: 'Đổi mật khẩu',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Ứng dụng Settings
            _buildSectionTitle('Ứng dụng'),
            _buildSettingsGroup([
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Thông báo',
                onTap: () async {
                  await openAppSettings();
                },
              ),
              _buildSettingsItem(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                trailingText: 'Tiếng Việt',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.payments,
                title: 'Tiền tệ',
                trailingText: 'VNĐ',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Bảo mật Settings
            _buildSectionTitle('Bảo mật'),
            _buildSettingsGroup([
              _buildSettingsItem(
                icon: Icons.lock,
                title: 'Khóa ứng dụng',
                subtitle: 'FaceID / PIN',
                isToggle: true,
                toggleValue: _batKhieuUngDung,
                onToggle: (val) {
                  setState(() {
                    _batKhieuUngDung = val;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),

            // Hỗ trợ & Thông tin Settings
            _buildSectionTitle('Hỗ trợ & Thông tin'),
            _buildSettingsGroup([
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Trung tâm trợ giúp',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.description,
                title: 'Điều khoản sử dụng',
                onTap: () {},
              ),
              _buildSettingsItem(
                icon: Icons.system_update,
                title: 'Kiểm tra cập nhật',
                onTap: () {
                  UpdateService.kiemTraCapNhat(context, hienThongBaoKhongCo: true);
                },
              ),
              _buildSettingsItem(
                icon: Icons.info,
                title: 'Phiên bản ứng dụng',
                trailingText: 'v1.0.2',
                showChevron: false,
              ),
            ]),
            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorErrorContainer,
                  foregroundColor: MauSac.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final savedUserId = prefs.getInt('saved_user_id');
                  final savedUserName = prefs.getString('saved_user_name');
                  final savedUserEmail = prefs.getString('saved_user_email');
                  
                  if (!context.mounted) return;
                  if (savedUserId != null && savedUserName != null && savedUserEmail != null) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => ManHinhDangNhapNhanh(
                          savedUserId: savedUserId,
                          savedUserName: savedUserName,
                          savedUserEmail: savedUserEmail,
                        ),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(
                  'Đăng xuất',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MauSac.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: MauSac.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MauSac.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx != children.length - 1) {
            return Column(
              children: [
                child,
                const Divider(height: 1, indent: 68, color: MauSac.borderSubtle),
              ],
            );
          }
          return child;
        }).toList(),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    bool showChevron = true,
    bool isToggle = false,
    bool toggleValue = false,
    ValueChanged<bool>? onToggle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isToggle ? () => onToggle?.call(!toggleValue) : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: MauSac.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: MauSac.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: MauSac.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: MauSac.onSurfaceVariant,
                      ),
                    ),
                  ]
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (isToggle)
              CupertinoSwitch(
                value: toggleValue,
                activeTrackColor: MauSac.primary,
                onChanged: onToggle,
              )
            else if (showChevron)
              const Icon(Icons.chevron_right, color: MauSac.outlineVariant),
          ],
        ),
      ),
    );
  }
}

