import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

import '../mo_hinh/du_lieu.dart';
import 'dang_nhap.dart';

class ManHinhCaiDat extends StatefulWidget {
  final NguoiDung nguoiDung;
  const ManHinhCaiDat({super.key, required this.nguoiDung});

  @override
  State<ManHinhCaiDat> createState() => _ManHinhCaiDatState();
}

class _ManHinhCaiDatState extends State<ManHinhCaiDat> {
  bool _batKhieuUngDung = true;

  @override
  Widget build(BuildContext context) {
    const colorSurfaceAlt = Color(0xFFF8FAFC);
    const colorErrorContainer = Color(0xFFFFDAD6);
    
    return Scaffold(
      backgroundColor: colorSurfaceAlt,
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
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: MauSac.surfaceContainerHigh,
                    child: Icon(Icons.person, color: MauSac.primary, size: 36),
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
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBE1FF), // primary-fixed
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, size: 14, color: MauSac.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: MauSac.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: MauSac.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Chức năng chỉnh sửa thông tin cá nhân')),
                        );
                      },
                      splashRadius: 24,
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
                onTap: () {},
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
                onTap: () {},
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
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
                    (route) => false,
                  );
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

