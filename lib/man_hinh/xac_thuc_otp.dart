import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';
import '../dich_vu/email_service.dart';
import 'dat_lai_mat_khau.dart';

class ManHinhXacThucOTP extends StatefulWidget {
  final String email;
  final String otpGoc;

  const ManHinhXacThucOTP({super.key, required this.email, required this.otpGoc});

  @override
  State<ManHinhXacThucOTP> createState() => _ManHinhXacThucOTPState();
}

class _ManHinhXacThucOTPState extends State<ManHinhXacThucOTP> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool? _isOtpCorrect;
  
  late String _currentOtp;
  int _countdown = 60;
  Timer? _timer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otpGoc;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0 || _isSending) return;
    
    setState(() => _isSending = true);
    
    final newOtp = (100000 + math.Random().nextInt(900000)).toString();
    final sent = await EmailService.guiMaOTP(widget.email, newOtp);
    
    if (!mounted) return;
    setState(() => _isSending = false);
    
    if (sent) {
      setState(() {
        _currentOtp = newOtp;
        _countdown = 60;
      });
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi lại mã OTP mới!', style: GoogleFonts.manrope()), backgroundColor: MauSac.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi gửi email.', style: GoogleFonts.manrope()), backgroundColor: MauSac.error),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _xacNhan() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      if (otp == _currentOtp) {
        setState(() => _isOtpCorrect = true);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ManHinhDatLaiMatKhau(email: widget.email),
            ),
          );
        });
      } else {
        setState(() => _isOtpCorrect = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mã OTP không chính xác.', style: GoogleFonts.manrope()),
            backgroundColor: MauSac.error,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập đủ 6 chữ số.', style: GoogleFonts.manrope()),
          backgroundColor: MauSac.error,
        ),
      );
    }
  }

  Color _getBorderColor() {
    if (_isOtpCorrect == true) return MauSac.success;
    if (_isOtpCorrect == false) return MauSac.error;
    return MauSac.borderSubtle;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MauSac.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Xác thực email',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: MauSac.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chúng tôi đã gửi mã 6 chữ số đến email của bạn',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: MauSac.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              // OTP Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLength: 1,
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: MauSac.onSurface,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor(), width: _isOtpCorrect != null ? 1.5 : 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _getBorderColor(), width: _isOtpCorrect != null ? 1.5 : 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _isOtpCorrect == null ? MauSac.primary : _getBorderColor(), width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        if (_isOtpCorrect != null) {
                          setState(() => _isOtpCorrect = null);
                        }
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              
              Center(
                child: Text(
                  'Nhập mã bạn nhận được qua email',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: MauSac.outlineVariant,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _xacNhan,
                  child: Text(
                    'Xác nhận',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Resend Action
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bạn chưa nhận được mã? ',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: MauSac.onSurfaceVariant,
                    ),
                  ),
                  _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: MauSac.primary),
                        )
                      : GestureDetector(
                          onTap: _countdown > 0 ? null : _resendOtp,
                          child: Text(
                            _countdown > 0 ? 'Gửi lại ($_countdown' 's)' : 'Gửi lại',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _countdown > 0 ? MauSac.outline : MauSac.primary,
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
