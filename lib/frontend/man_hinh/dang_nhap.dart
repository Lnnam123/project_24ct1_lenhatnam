import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../chu_de/mau_sac.dart';
import '../../backend/controllers/xu_ly_dang_nhap.dart';
import 'dang_ky.dart';
import '../../main.dart'; // To access ManHinhChinh (we will refactor this later if needed)

import 'dang_nhap_nhanh.dart';
import 'quen_mat_khau.dart';

class ManHinhDangNhap extends StatefulWidget {
  final bool allowRedirect;
  const ManHinhDangNhap({super.key, this.allowRedirect = true});

  @override
  State<ManHinhDangNhap> createState() => _ManHinhDangNhapState();
}

class _ManHinhDangNhapState extends State<ManHinhDangNhap> {
  // =========================================================================
  // [CƠ CHẾ ĐỒNG BỘ DỮ LIỆU TỪ GIAO DIỆN (DATA BINDING)]:
  // Khởi tạo các bộ điều khiển (TextEditingController) làm cầu nối:
  // Lắng nghe và tự động hứng toàn bộ ký tự người dùng gõ vào các ô nhập TextField trên UI
  // =========================================================================
  final _emailController = TextEditingController();      // Hứng dữ liệu ô Email
  final _passwordController = TextEditingController();   // Hứng dữ liệu ô Mật khẩu
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.allowRedirect) {
      _checkSavedUser();
    }
  }

  /// [Kiểm tra phiên đăng nhập đã lưu]:
  /// Đọc SharedPreferences xem đã lưu tài khoản trước đó chưa; nếu có sẽ điều hướng sang Đăng nhập nhanh bằng mã PIN/vân tay.
  void _checkSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getInt('saved_user_id');
    final savedUserName = prefs.getString('saved_user_name');
    final savedUserEmail = prefs.getString('saved_user_email');

    if (savedUserId != null &&
        savedUserName != null &&
        savedUserEmail != null) {
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

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - ĐĂNG NHẬP]: BƯỚC 4 ĐẾN BƯỚC 10 (KIỂM TRA TÀI KHOẢN ĐÚNG / SAI)
  // =========================================================================
  /// - Bước 4: Giao diện (UI) gọi hàm `_dangNhap()` trên State khi người dùng nhấn nút.
  /// - Khối Alt [Xử lý đăng nhập tại Backend: Bước 5 đến Bước 8]:
  ///   + Bước 5: State gọi `DatabaseService.instance.login(email, password)`.
  ///   + Bước 6: Supabase thực thi `SELECT * FROM nguoi_dung WHERE email=? AND mat_khau=?`.
  ///   + Bước 7: CSDL trả về kết quả xác thực.
  ///   + Nhánh Alt [Tài khoản đúng: Khớp Email & Mật khẩu]:
  ///     * Bước 8: Trả về đối tượng `NguoiDung`.
  ///   + Nhánh Alt [Tài khoản sai: Sai Email hoặc Mật khẩu]:
  ///     * Bước 8: Trả về kết quả `null` (Thông tin không chính xác).
  /// - Bước 9: State điều khiển UI báo kết quả đăng nhập (Thành công / Thất bại).
  /// - Bước 10: Điều hướng người dùng vào Màn hình chính hoặc hiển thị thông tin lỗi.
  void _dangNhap() async {
    // =========================================================================
    // [TRÍCH XUẤT DỮ LIỆU TỪ CONTROLLER]:
    // - .text: Rút toàn bộ chuỗi ký tự mà người dùng vừa gõ trong ô TextField tương ứng ra
    // - .trim(): Tự động loại bỏ các khoảng trắng thừa ở 2 đầu (VD: "  user@gmail.com  " -> "user@gmail.com")
    // =========================================================================
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Kiểm tra tính hợp lệ dữ liệu đầu vào
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // [BƯỚC 4]: Gửi yêu cầu đăng nhập sang file xử lý riêng (xu_ly_dang_nhap.dart)
      final user = await XuLyDangNhap.instance.xuLyDangNhap(
        email: email,
        password: password,
      );
      setState(() => _isLoading = false);

      // [BƯỚC 9 - Nhánh: Tài khoản đúng]
      if (user != null) {
        // Lưu phiên đăng nhập người dùng vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('saved_user_id', user.id);
        await prefs.setString('saved_user_name', user.hoTen);
        await prefs.setString('saved_user_email', user.email);

        if (!mounted) return;

        // [BƯỚC 10]: Điều hướng chuyển vào Màn hình chính (ManHinhChinh)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ManHinhChinh(nguoiDung: user)),
        );
      } else {
        // [BƯỚC 9 - Nhánh: Tài khoản sai] -> user == null
        if (!mounted) return;
        // [BƯỚC 10]: Báo thất bại và hiển thị SnackBar thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email hoặc mật khẩu không chính xác!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
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
                  Text(
                    'Email',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // [CƠ CHẾ ĐẨY DỮ LIỆU VÀO _emailController]:
                  // Thuộc tính 'controller: _emailController' thiết lập liên kết tự động.
                  // Mỗi khi người dùng gõ phím vào ô này, Flutter lập tức đẩy ký tự vào _emailController.text
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Nhập email của bạn',
                      hintStyle: GoogleFonts.manrope(
                        color: MauSac.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: MauSac.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: MauSac.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: MauSac.borderSubtle,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: MauSac.borderSubtle,
                        ),
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
                  Text(
                    'Mật khẩu',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // [CƠ CHẾ ĐẨY DỮ LIỆU VÀO _passwordController]:
                  // Tự động đồng bộ mật khẩu người dùng gõ vào thuộc tính _passwordController.text
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      hintStyle: GoogleFonts.manrope(
                        color: MauSac.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: MauSac.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        color: MauSac.onSurfaceVariant,
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      filled: true,
                      fillColor: MauSac.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: MauSac.borderSubtle,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: MauSac.borderSubtle,
                        ),
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
                      MaterialPageRoute(
                        builder: (_) => const ManHinhQuenMatKhau(),
                      ),
                    );
                  },
                  child: Text(
                    'Quên mật khẩu?',
                    style: GoogleFonts.manrope(
                      color: MauSac.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // =========================================================================
              // [SƠ ĐỒ TUẦN TỰ - ĐĂNG NHẬP]: BƯỚC 3
              // Khách hàng nhập Email, Mật khẩu & bấm nút "ĐĂNG NHẬP" -> Kích hoạt Bước 4 gọi _dangNhap()
              // =========================================================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _dangNhap,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'ĐĂNG NHẬP',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chưa có tài khoản? ',
                    style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final registeredEmail = await Navigator.push<String>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManHinhDangKy(),
                        ),
                      );
                      if (registeredEmail != null && registeredEmail.isNotEmpty) {
                        _emailController.text = registeredEmail;
                        _passwordController.clear();
                      }
                    },
                    child: Text(
                      'Đăng ký ngay',
                      style: GoogleFonts.manrope(
                        color: MauSac.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



