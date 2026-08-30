import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../chu_de/mau_sac.dart';
import '../du_lieu/database_helper.dart';
import '../mo_hinh/du_lieu.dart';
import 'dang_nhap.dart';
import '../main.dart'; // To access ManHinhChinh

class ManHinhDangNhapNhanh extends StatefulWidget {
  final int savedUserId;
  final String savedUserName;
  final String savedUserEmail;

  const ManHinhDangNhapNhanh({
    super.key,
    required this.savedUserId,
    required this.savedUserName,
    required this.savedUserEmail,
  });

  @override
  State<ManHinhDangNhapNhanh> createState() => _ManHinhDangNhapNhanhState();
}

class _ManHinhDangNhapNhanhState extends State<ManHinhDangNhapNhanh> {
  final _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      if (mounted) {
        setState(() {
          _canCheckBiometrics = canAuthenticate;
        });
        
        // Auto-trigger biometric on load (optional but nice UX)
        if (canAuthenticate) {
          _authenticate();
        }
      }
    } catch (e) {
      debugPrint('Lỗi kiểm tra sinh trắc: $e');
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      // Use the older signature for compatibility if AuthenticationOptions is undefined
      // Or if the flutter analyze complains, try the direct parameters.
      // Note: If using local_auth >= 2.0.0, options: const AuthenticationOptions(...) is correct.
      authenticated = await _auth.authenticate(
        localizedReason: 'Quét vân tay / khuôn mặt để đăng nhập',
        persistAcrossBackgrounding: true,
        biometricOnly: false,
      );
    } catch (e) {
      debugPrint('Lỗi sinh trắc học: $e');
    }

    if (authenticated) {
      _loginWithSavedData();
    }
  }

  void _loginWithSavedData() {
    final user = NguoiDung(
      id: widget.savedUserId,
      hoTen: widget.savedUserName,
      email: widget.savedUserEmail,
      soDienThoai: '',
      matKhau: '', 
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ManHinhChinh(nguoiDung: user)),
    );
  }

  void _dangNhap() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = await DatabaseHelper.instance.login(widget.savedUserEmail, password);

    setState(() => _isLoading = false);

    if (user != null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ManHinhChinh(nguoiDung: user)),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không chính xác!')),
      );
    }
  }

  void _logoutAndSwitchAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ManHinhDangNhap(allowRedirect: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // User Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: MauSac.primaryContainer,
                child: Text(
                  widget.savedUserName.isNotEmpty ? widget.savedUserName[0].toUpperCase() : 'U',
                  style: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: MauSac.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Xin chào, ${widget.savedUserName}!',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.savedUserEmail,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // Password Field
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
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MauSac.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _dangNhap,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('ĐĂNG NHẬP', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                  if (_canCheckBiometrics) ...[
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: MauSac.primary, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _authenticate,
                        child: const Icon(Icons.fingerprint, color: MauSac.primary, size: 32),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 48),
              
              // Switch Account
              TextButton(
                onPressed: _logoutAndSwitchAccount,
                child: Text(
                  'Đăng nhập bằng tài khoản khác',
                  style: GoogleFonts.manrope(
                    color: MauSac.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
