import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../chu_de/mau_sac.dart';
import '../../backend/controllers/xu_ly_dang_ky.dart';
import 'dang_nhap.dart';

class ManHinhDangKy extends StatefulWidget {
  const ManHinhDangKy({super.key});

  @override
  State<ManHinhDangKy> createState() => _ManHinhDangKyState();
}

class _ManHinhDangKyState extends State<ManHinhDangKy> {
  // =========================================================================
  // [CƠ CHẾ ĐỒNG BỘ DỮ LIỆU TỪ GIAO DIỆN (DATA BINDING)]:
  // Khởi tạo các bộ điều khiển (TextEditingController) làm cầu nối:
  // Lắng nghe và tự động hứng toàn bộ ký tự người dùng gõ vào các ô nhập TextField trên UI
  // =========================================================================
  final _nameController = TextEditingController();       // Hứng dữ liệu ô Họ và tên
  final _emailController = TextEditingController();      // Hứng dữ liệu ô Email
  final _passwordController = TextEditingController();   // Hứng dữ liệu ô Mật khẩu
  final _confirmPasswordController = TextEditingController(); // Hứng dữ liệu ô Xác nhận mật khẩu
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // =========================================================================
  // [SƠ ĐỒ TUẦN TỰ - ĐĂNG KÝ]: BƯỚC 4 ĐẾN BƯỚC 14
  // =========================================================================
  /// - Bước 4: UI gửi yêu cầu đăng ký sang file xử lý riêng (XuLyDangKy).
  /// - Khối Alt [Xử lý đăng ký & Kiểm tra tài khoản tại Backend: Bước 5 đến 12]:
  ///   + Bước 5: XuLyDangKy gọi `checkEmailExists(email)` xuống DatabaseService.
  ///   + Bước 6: Supabase thực thi `SELECT email FROM nguoi_dung WHERE email = ?`.
  ///   + Bước 7: CSDL trả về kết quả kiểm tra (tồn tại / chưa tồn tại).
  ///   + Bước 8: DatabaseService trả kết quả về cho XuLyDangKy.
  ///   + Nhánh [Tài khoản chưa tồn tại: Cho phép tạo mới]:
  ///     * Bước 9: XuLyDangKy gọi `register()` -> Supabase thực thi `INSERT INTO nguoi_dung`.
  ///     * Bước 10: CSDL chèn bản ghi và tạo ví mặc định.
  ///     * Bước 11: CSDL trả về kết quả tạo thành công (ma_nguoi_dung).
  ///     * Bước 12: DatabaseService trả về đối tượng `NguoiDung` cho XuLyDangKy.
  ///   + Nhánh [Tài khoản đã tồn tại: Báo trùng lặp]:
  ///     * XuLyDangKy ném ngoại lệ lỗi ("Email đã tồn tại").
  /// - Bước 13: XuLyDangKy báo kết quả đăng ký về cho UI (Thành công / Thất bại).
  /// - Bước 14: UI điều hướng quay lại Màn hình Đăng nhập để người dùng đăng nhập.
  void _dangKy() async {
    // =========================================================================
    // [TRÍCH XUẤT DỮ LIỆU TỪ CONTROLLER]:
    // - .text: Rút toàn bộ chuỗi ký tự mà người dùng vừa gõ trong ô TextField tương ứng ra
    // - .trim(): Tự động loại bỏ các khoảng trắng thừa ở 2 đầu (VD: "  nam  " -> "nam")
    // =========================================================================
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra tính hợp lệ của dữ liệu đầu vào
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    // Kiểm tra mật khẩu xác nhận có khớp không
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // [BƯỚC 4]: Gửi toàn bộ thông tin sang file xử lý riêng (xu_ly_dang_ky.dart)
      final user = await XuLyDangKy.instance.xuLyDangKy(
        name: name,
        email: email,
        password: password,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      // [BƯỚC 13]: Báo đăng ký thành công lên giao diện người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
          backgroundColor: MauSac.success,
        ),
      );

      // [BƯỚC 14]: Điều hướng quay lại Màn hình Đăng nhập (ManHinhDangNhap)
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(email);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ManHinhDangNhap()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      final msg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $msg')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                  Text(
                    'Họ và tên',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // [CƠ CHẾ ĐẨY DỮ LIỆU VÀO _nameController]:
                  // Thuộc tính 'controller: _nameController' thiết lập liên kết tự động.
                  // Mỗi khi người dùng gõ phím vào ô này, Flutter lập tức đẩy ký tự vào _nameController.text
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'VD: Nguyễn Văn A',
                      hintStyle: GoogleFonts.manrope(
                        color: MauSac.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
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
                  // Tự động đồng bộ chuỗi ký tự email người dùng gõ vào thuộc tính _emailController.text
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
                      hintText: 'Tạo mật khẩu',
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
              const SizedBox(height: 20),

              // Confirm Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xác nhận mật khẩu',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // [CƠ CHẾ ĐẨY DỮ LIỆU VÀO _confirmPasswordController]:
                  // Tự động đồng bộ mật khẩu nhập lại vào thuộc tính _confirmPasswordController.text
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập lại mật khẩu',
                      hintStyle: GoogleFonts.manrope(
                        color: MauSac.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: MauSac.onSurfaceVariant,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        color: MauSac.onSurfaceVariant,
                        onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword,
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

              const SizedBox(height: 32),

              // =========================================================================
              // [SƠ ĐỒ TUẦN TỰ - ĐĂNG KÝ]: BƯỚC 3 & CƠ CHẾ GỬI DỮ LIỆU KHI NHẤN NÚT
              // Khi Khách hàng bấm nút "ĐĂNG KÝ":
              // 1. Sự kiện 'onPressed' được kích hoạt. Nếu đang tải (_isLoading = true), nút sẽ bị vô hiệu hóa (null).
              // 2. Dữ liệu từ 4 ô nhập liệu được trích xuất qua TextEditingController:
              //    - Họ tên: _nameController.text.trim()
              //    - Email: _emailController.text.trim()
              //    - Mật khẩu: _passwordController.text.trim()
              //    - Xác nhận mật khẩu: _confirmPasswordController.text.trim()
              // 3. Gửi toàn bộ dữ liệu này về hàm xử lý logic `_dangKy()` của State (Bước 4).
              // 4. Tại `_dangKy()`: Chuyển _isLoading = true
              //    kiểm tra hợp lệ, sau đó chuyển tiếp các tham số (name, email, password) xuống
              //    DatabaseService để kiểm tra trùng email và thực thi ghi dữ liệu vào CSDL Supabase.
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
                  onPressed: _isLoading ? null : _dangKy,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'ĐĂNG KÝ',
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
                    'Đã có tài khoản? ',
                    style: GoogleFonts.manrope(color: MauSac.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Đăng nhập',
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



