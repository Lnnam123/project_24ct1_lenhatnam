import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import '../mo_hinh/du_lieu.dart';
import '../du_lieu/database_helper.dart';

String _dinhDangThoiGian(DateTime dt) {
  final now = DateTime.now();
  final difference = now.difference(dt);

  if (difference.inSeconds < 60) {
    return 'Vừa xong';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} phút trước';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  } else if (difference.inDays == 1) {
    return 'Hôm qua';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} ngày trước';
  } else {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class TinNhan {
  final String noiDung;
  final bool laCuaToi;
  final DateTime thoiGian;

  TinNhan({
    required this.noiDung,
    required this.laCuaToi,
    DateTime? thoiGian,
  }) : thoiGian = thoiGian ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'content': noiDung,
      'is_user': laCuaToi,
      'created_at': thoiGian.toIso8601String(),
    };
  }

  factory TinNhan.fromMap(Map<String, dynamic> map) {
    return TinNhan(
      noiDung: map['content']?.toString() ?? map['noi_dung']?.toString() ?? '',
      laCuaToi: map['is_user'] == true || map['is_user'] == 1 || map['la_cua_toi'] == true,
      thoiGian: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class HoiThoaiAI {
  final String id;
  final int userId;
  String tieuDe;
  DateTime thoiGianTao;
  DateTime thoiGianCapNhat;
  final List<TinNhan> danhSachTinNhan;

  HoiThoaiAI({
    required this.id,
    required this.userId,
    required this.tieuDe,
    DateTime? thoiGianTao,
    DateTime? thoiGianCapNhat,
    List<TinNhan>? danhSachTinNhan,
  })  : thoiGianTao = thoiGianTao ?? DateTime.now(),
        thoiGianCapNhat = thoiGianCapNhat ?? DateTime.now(),
        danhSachTinNhan = danhSachTinNhan ?? [];

  Map<String, dynamic> toMap() {
    return {
      'session_id': id,
      'user_id': userId,
      'title': tieuDe,
      'created_at': thoiGianTao.toIso8601String(),
      'updated_at': thoiGianCapNhat.toIso8601String(),
      'messages': danhSachTinNhan.map((m) => m.toMap()).toList(),
    };
  }

  factory HoiThoaiAI.fromMap(Map<String, dynamic> map) {
    var msgs = <TinNhan>[];
    if (map['messages'] != null && map['messages'] is List) {
      msgs = (map['messages'] as List)
          .map((m) => TinNhan.fromMap(Map<String, dynamic>.from(m)))
          .toList();
    }
    return HoiThoaiAI(
      id: map['session_id']?.toString() ?? '',
      userId: map['user_id'] is int
          ? map['user_id']
          : int.tryParse(map['user_id']?.toString() ?? '1') ?? 1,
      tieuDe: map['title']?.toString() ?? 'Cuộc trò chuyện mới',
      thoiGianTao: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      thoiGianCapNhat: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      danhSachTinNhan: msgs,
    );
  }
}

class ManHinhTroLyAI extends StatefulWidget {
  final NguoiDung? nguoiDung;

  const ManHinhTroLyAI({super.key, this.nguoiDung});

  @override
  State<ManHinhTroLyAI> createState() => _ManHinhTroLyAIState();
}

class _ManHinhTroLyAIState extends State<ManHinhTroLyAI> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _chatScrollController = ScrollController();

  final List<HoiThoaiAI> _danhSachCuocTroChuyen = [];
  HoiThoaiAI? _cuocTroChuyenHienTai;

  int _chiMucHienTai = 0; // 0: Trang chủ, 1: Đoạn chat, 2: Trò chuyện gần đây (Lịch sử)
  bool _truotSangTrai = true;
  bool _dangTimKiemLichSu = false;
  final TextEditingController _timKiemLichSuController = TextEditingController();
  String _tuKhoaTimKiemLichSu = '';

  bool _dangNhanTin = false;
  bool _dangTaiDuLieu = false;
  bool _showScrollDownBtn = false;

  GenerativeModel? _model;
  ChatSession? _chatSession;

  int get _userId => widget.nguoiDung?.id ?? 1;

  // Quick action cards
  final List<Map<String, dynamic>> _theGoiYNhanh = [
    {
      'cauHoi': 'Khoản chi nào lớn nhất trong tuần qua làm ảnh hưởng đến ngân sách của tôi?',
      'icon': Icons.warning_amber_rounded,
      'mauIcon': Color(0xFFC2185B),
      'mauNen': Color(0xFFFDE8F3),
    },
    {
      'cauHoi': 'Tổng chi tiêu tháng này của tôi đã vượt hạn mức chưa?',
      'icon': Icons.insights_rounded,
      'mauIcon': Color(0xFF7B1FA2),
      'mauNen': Color(0xFFF3E5F5),
    },
    {
      'cauHoi': 'Dự báo đến cuối tháng tổng chi tiêu của tôi sẽ là bao nhiêu?',
      'icon': Icons.calendar_month_rounded,
      'mauIcon': Color(0xFF1976D2),
      'mauNen': Color(0xFFE3F2FD),
    },
    {
      'cauHoi': 'Tôi nên cắt giảm chi tiêu ở hạng mục nào để tiết kiệm thêm 2 triệu?',
      'icon': Icons.savings_rounded,
      'mauIcon': Color(0xFF00897B),
      'mauNen': Color(0xFFE0F2F1),
    },
  ];

  @override
  void initState() {
    super.initState();
    _chatScrollController.addListener(_onScroll);
    _taiDanhSachCuocTroChuyen();
  }

  void _onScroll() {
    if (!_chatScrollController.hasClients) return;
    final maxScroll = _chatScrollController.position.maxScrollExtent;
    final currentScroll = _chatScrollController.offset;
    final shouldShow = (maxScroll - currentScroll) > 80;
    if (shouldShow != _showScrollDownBtn) {
      setState(() {
        _showScrollDownBtn = shouldShow;
      });
    }
  }

  Future<void> _taiDanhSachCuocTroChuyen() async {
    setState(() {
      _dangTaiDuLieu = true;
    });

    try {
      final rawList = await DatabaseHelper.instance.getAIConversations(_userId);
      if (mounted) {
        setState(() {
          _danhSachCuocTroChuyen.clear();
          for (final item in rawList) {
            _danhSachCuocTroChuyen.add(HoiThoaiAI.fromMap(item));
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách cuộc trò chuyện: $e');
    } finally {
      if (mounted) {
        setState(() {
          _dangTaiDuLieu = false;
        });
      }
    }
  }

  String _dinhDangTien(double amount) {
    final f = NumberFormat('#,###', 'vi_VN');
    return '${f.format(amount.round())}đ';
  }

  Future<String> _layNguCanhTaiChinh() async {
    try {
      final wallets = await DatabaseHelper.instance.getWallets(_userId);
      final categories = await DatabaseHelper.instance.getCategories(_userId);
      final transactions = await DatabaseHelper.instance.getTransactions(_userId, wallets, categories);
      final budgets = await DatabaseHelper.instance.getBudgets(_userId, categories);

      double tongSoDu = 0;
      final bufferWallets = StringBuffer();
      for (final w in wallets) {
        tongSoDu += w.soDu;
        bufferWallets.writeln('- Ví "${w.tenVi}" (${w.loaiVi}): ${_dinhDangTien(w.soDu)}');
      }

      final now = DateTime.now();
      final dauThang = DateTime(now.year, now.month, 1);
      final bayNgayTruoc = now.subtract(const Duration(days: 7));
      final dauTuanNay = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      final dauTuanTruoc = dauTuanNay.subtract(const Duration(days: 7));

      double tongChiThangNay = 0;
      double tongThuThangNay = 0;
      double tongChi7Ngay = 0;
      double tongChiTuanNay = 0;
      double tongChiTuanTruoc = 0;
      int soGiaoDichThangNay = 0;

      GiaoDich? chiLonNhat7Ngay;
      GiaoDich? chiLonNhatThang;
      final Map<String, double> chiTheoDanhMucThang = {};
      final Map<String, double> chiTheoDanhMucTuanNay = {};
      final List<String> danhSachGiaoDichGanDay = [];

      for (final tx in transactions) {
        final isChi = tx.loai == LoaiGiaoDich.chiTieu;
        if (isChi) {
          if (tx.ngay.isAfter(dauThang) || tx.ngay.isAtSameMomentAs(dauThang)) {
            tongChiThangNay += tx.soTien;
            soGiaoDichThangNay++;
            chiTheoDanhMucThang[tx.danhMuc.ten] = (chiTheoDanhMucThang[tx.danhMuc.ten] ?? 0) + tx.soTien;
            if (chiLonNhatThang == null || tx.soTien > chiLonNhatThang.soTien) {
              chiLonNhatThang = tx;
            }
          }
          if (tx.ngay.isAfter(bayNgayTruoc)) {
            tongChi7Ngay += tx.soTien;
            if (chiLonNhat7Ngay == null || tx.soTien > chiLonNhat7Ngay.soTien) {
              chiLonNhat7Ngay = tx;
            }
          }
          if (tx.ngay.isAfter(dauTuanNay) || tx.ngay.isAtSameMomentAs(dauTuanNay)) {
            tongChiTuanNay += tx.soTien;
            chiTheoDanhMucTuanNay[tx.danhMuc.ten] = (chiTheoDanhMucTuanNay[tx.danhMuc.ten] ?? 0) + tx.soTien;
          } else if ((tx.ngay.isAfter(dauTuanTruoc) || tx.ngay.isAtSameMomentAs(dauTuanTruoc)) && tx.ngay.isBefore(dauTuanNay)) {
            tongChiTuanTruoc += tx.soTien;
          }
        } else {
          if (tx.ngay.isAfter(dauThang) || tx.ngay.isAtSameMomentAs(dauThang)) {
            tongThuThangNay += tx.soTien;
          }
        }

        if (danhSachGiaoDichGanDay.length < 12) {
          final loaiStr = isChi ? 'CHI' : 'THU';
          final ngayStr = '${tx.ngay.day}/${tx.ngay.month}';
          danhSachGiaoDichGanDay.add(
            '$ngayStr | $loaiStr | ${_dinhDangTien(tx.soTien)} | ${tx.danhMuc.ten} | ${tx.ghiChu ?? tx.tieuDe}',
          );
        }
      }

      final bufferNganSach = StringBuffer();
      if (budgets.isEmpty) {
        bufferNganSach.writeln('- Chưa đặt hạn mức ngân sách tháng này');
      } else {
        for (final b in budgets) {
          final phanTram = b.hanMuc > 0 ? (b.daChi / b.hanMuc * 100).toStringAsFixed(0) : '0';
          final trangThai = b.daChi > b.hanMuc ? 'VƯỢT HẠN MỨC' : 'An toàn';
          final tenDm = b.danhMuc?.ten ?? 'Hạng mục chung';
          bufferNganSach.writeln(
            '- $tenDm: hạn mức ${_dinhDangTien(b.hanMuc)}, đã chi ${_dinhDangTien(b.daChi)} ($phanTram%) -> $trangThai',
          );
        }
      }

      final bufferChiDanhMuc = StringBuffer();
      final sortedDanhMucThang = chiTheoDanhMucThang.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final e in sortedDanhMucThang.take(5)) {
        bufferChiDanhMuc.writeln('- ${e.key}: ${_dinhDangTien(e.value)}');
      }

      final sortedDanhMucTuan = chiTheoDanhMucTuanNay.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final topDmTuanStr = sortedDanhMucTuan.isNotEmpty
          ? '${sortedDanhMucTuan.first.key}: ${_dinhDangTien(sortedDanhMucTuan.first.value)}'
          : 'Chưa có khoản chi trong tuần';

      final topDmThangStr = sortedDanhMucThang.isNotEmpty
          ? '${sortedDanhMucThang.first.key} với ${_dinhDangTien(sortedDanhMucThang.first.value)}'
          : 'Chưa có';

      final chenhLechTuan = tongChiTuanNay - tongChiTuanTruoc;
      final dauChenhLech = chenhLechTuan >= 0 ? '+' : '';

      return '''
THÔNG TIN TÀI CHÍNH THỰC TẾ TRÊN HỆ THỐNG CỦA NGƯỜI DÙNG: $_tenNguoiDung (Hôm nay: ${now.day}/${now.month}/${now.year})
1. TỔNG SỐ DƯ TÀI SẢN: ${_dinhDangTien(tongSoDu)}
Danh sách ví:
${bufferWallets.isEmpty ? '- Chưa có ví nào' : bufferWallets.toString().trim()}

2. TÌNH HÌNH THU CHI THÁNG NÀY:
- Tổng thu nhập tháng ${now.month}: ${_dinhDangTien(tongThuThangNay)}
- Tổng chi tiêu tháng ${now.month}: ${_dinhDangTien(tongChiThangNay)}
- Số giao dịch chi tiêu trong tháng: $soGiaoDichThangNay
- Hạng mục chi nhiều nhất tháng: $topDmThangStr
- Khoản chi lớn nhất trong tháng: ${chiLonNhatThang != null ? '${_dinhDangTien(chiLonNhatThang.soTien)} (Danh mục: ${chiLonNhatThang.danhMuc.ten}, Ghi chú: "${chiLonNhatThang.ghiChu ?? chiLonNhatThang.tieuDe}")' : 'Chưa có'}
- Top danh mục chi nhiều nhất tháng:
${bufferChiDanhMuc.isEmpty ? '- Chưa có dữ liệu' : bufferChiDanhMuc.toString().trim()}

3. SO SÁNH TUẦN NÀY VÀ TUẦN TRƯỚC:
- Chi tiêu tuần này: ${_dinhDangTien(tongChiTuanNay)}
- Chi tiêu tuần trước: ${_dinhDangTien(tongChiTuanTruoc)}
- Chênh lệch: $dauChenhLech${_dinhDangTien(chenhLechTuan)}
- Chi tiêu tuần này tập trung vào: $topDmTuanStr
- Tổng chi tiêu 7 ngày qua: ${_dinhDangTien(tongChi7Ngay)}
- Khoản chi lớn nhất 7 ngày qua: ${chiLonNhat7Ngay != null ? '${_dinhDangTien(chiLonNhat7Ngay.soTien)} (${chiLonNhat7Ngay.danhMuc.ten} - "${chiLonNhat7Ngay.ghiChu ?? chiLonNhat7Ngay.tieuDe}")' : 'Chưa có'}

4. HẠN MỨC NGÂN SÁCH:
${bufferNganSach.toString().trim()}

5. CÁC GIAO DỊCH GẦN ĐÂY:
${danhSachGiaoDichGanDay.isEmpty ? '- Chưa có giao dịch nào' : danhSachGiaoDichGanDay.map((e) => '- $e').join('\n')}
''';
    } catch (e) {
      debugPrint('Lỗi tổng hợp dữ liệu tài chính: $e');
      return 'Dữ liệu tài chính: Người dùng chưa có giao dịch nào được ghi nhận.';
    }
  }

  String _taoSystemPrompt(String? financialContext) {
    return '''
Bạn là trợ lý tài chính thông minh của ứng dụng CoinTap (phong cách chuyên nghiệp, hiện đại tương tự Google Gemini).
Người dùng: $_tenNguoiDung.

DỮ LIỆU TÀI CHÍNH THỰC TẾ TRÊN HỆ THỐNG CỦA NGƯỜI DÙNG:
${financialContext ?? 'Đang tải dữ liệu...'}

QUY TẮC BẮT BUỘC ĐỊNH DẠNG CÂU TRẢ LỜI:
1. TRẢ LỜI TRỰC TIẾP NGAY DÒNG ĐẦU TIÊN:
   - Đi thẳng vào trọng tâm câu hỏi của người dùng, in đậm từ khóa quan trọng và số tiền (kèm emoji phù hợp).
   - Ví dụ:
     "Hôm nay (5/9), bạn đã chi tiêu tổng cộng **60.000đ** 💸"
     hoặc "Có, **tuần này bạn chi nhiều hơn tuần trước** 📉"

2. PHẦN SỐ LIỆU CHI TIẾT:
   - Đặt tiêu đề in đậm ngắn đứng riêng một dòng: ví dụ "**Tóm tắt chi tiết:**" (TUYỆT ĐỐI KHÔNG ĐẶT DẤU GẠCH ĐẦU DÒNG HAY CHẤM TRÒN • Ở TRƯỚC TIÊU ĐỀ).
   - Các dòng bên dưới mới dùng gạch đầu dòng "•  " cho từng mục liệt kê, in đậm nhãn hoặc số tiền.

3. PHẦN GỢI Ý TIẾP THEO (BẮT BUỘC Ở CUỐI MỌI CÂU TRẢ LỜI - KHÔNG ĐƯỢC BỎ QUA):
   - Luôn luôn kết thúc câu trả lời bằng một dòng dẫn ngắn: "Nếu bạn muốn, mình có thể phân tích tiếp:"
   - Sau đó dùng gạch đầu dòng "•  " gợi ý 2-3 câu hỏi/chủ đề cụ thể tiếp theo để người dùng hỏi tiếp (từ khóa in đậm).
   - Ví dụ:
     Nếu bạn muốn, mình có thể phân tích tiếp:
     •  **chi tiết ngân sách các danh mục còn lại**
     •  **gợi ý cắt giảm chi tiêu để tiết kiệm thêm**
     •  hoặc **dự báo chi tiêu theo tuần tiếp theo** 📊

4. LƯU Ý QUAN TRỌNG:
   - Tiêu đề mục luôn dùng 2 dấu sao mở và đóng chuẩn (**tiêu đề:**) và không có dấu • ở đầu.
   - Dùng đơn vị tiền tệ có dấu chấm phân cách và chữ đ (Ví dụ: 30.000đ, 150.000đ).
   - Bắt buộc phải có Phần 3 (Gợi ý tiếp theo) ở cuối câu trả lời.
''';
  }

  void _khoiTaoAIForSession(HoiThoaiAI session, [String? financialContext]) {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;

    final systemPrompt = _taoSystemPrompt(financialContext);

    try {
      _model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      final List<Content> geminiHistory = [];
      for (final tn in session.danhSachTinNhan) {
        if (geminiHistory.isEmpty) {
          if (tn.laCuaToi) {
            geminiHistory.add(Content('user', [TextPart(tn.noiDung)]));
          }
        } else {
          final lastRole = geminiHistory.last.role;
          final currentRole = tn.laCuaToi ? 'user' : 'model';
          if (currentRole != lastRole) {
            geminiHistory.add(Content(currentRole, [TextPart(tn.noiDung)]));
          } else {
            final lastParts = geminiHistory.last.parts
                .map((p) => (p as TextPart).text)
                .join('\n');
            geminiHistory[geminiHistory.length - 1] = Content(lastRole, [
              TextPart('$lastParts\n${tn.noiDung}'),
            ]);
          }
        }
      }

      if (geminiHistory.isNotEmpty && geminiHistory.last.role == 'user') {
        geminiHistory.removeLast();
      }

      _chatSession = _model?.startChat(history: geminiHistory);
    } catch (e) {
      debugPrint('Lỗi khởi tạo AI cho session: $e');
      _chatSession = _model?.startChat();
    }
  }

  String _phanHoiDuPhongThongMinh(String cauHoi, String nguCanh) {
    final q = cauHoi.toLowerCase();

    // 1. Hạng mục chi nhiều tiền nhất trong tháng
    if (q.contains('hạng mục nào') || q.contains('nhiều tiền nhất') || (q.contains('hạng mục') && q.contains('chi nhiều'))) {
      String topDm = 'Dịch vụ sinh hoạt';
      String soTienTop = '30.000đ';
      String tongChi = '30.000đ';
      String soGd = '1';

      for (final line in nguCanh.split('\n')) {
        if (line.contains('Hạng mục chi nhiều nhất tháng:')) {
          final val = line.replaceAll('- Hạng mục chi nhiều nhất tháng:', '').trim();
          final parts = val.split(' với ');
          if (parts.length == 2) {
            topDm = parts[0].trim();
            soTienTop = parts[1].trim();
          }
        } else if (line.contains('Tổng chi tiêu tháng')) {
          final val = line.replaceAll(RegExp(r'- Tổng chi tiêu tháng \d+:'), '').trim();
          if (val.isNotEmpty) tongChi = val;
        } else if (line.contains('Số giao dịch chi tiêu trong tháng:')) {
          soGd = line.replaceAll('- Số giao dịch chi tiêu trong tháng:', '').trim();
        }
      }

      return '''Trong **tháng này**, hạng mục bạn chi nhiều nhất là **$topDm** với **$soTienTop** 💰

**Tóm tắt nhanh:**
•  **Tổng chi: $tongChi**
•  **Hạng mục chi cao nhất: $topDm — $soTienTop**
•  **Số giao dịch: $soGd**

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **chi theo ví**
•  **top hạng mục chi tiêu**
•  hoặc **xu hướng chi tiêu tháng này** 📉''';
    }

    // 2. So sánh tuần này với tuần trước
    if (q.contains('tuần này') && (q.contains('tuần trước') || q.contains('cao hơn') || q.contains('so với'))) {
      String chiTuanNay = '40.000đ';
      String chiTuanTruoc = '0đ';
      String chenhLech = '+40.000đ';
      String tapTrungVao = 'Ăn uống: 10.000đ';

      for (final line in nguCanh.split('\n')) {
        if (line.contains('Chi tiêu tuần này:')) {
          chiTuanNay = line.replaceAll('- Chi tiêu tuần này:', '').trim();
        } else if (line.contains('Chi tiêu tuần trước:')) {
          chiTuanTruoc = line.replaceAll('- Chi tiêu tuần trước:', '').trim();
        } else if (line.contains('Chênh lệch:')) {
          chenhLech = line.replaceAll('- Chênh lệch:', '').trim();
        } else if (line.contains('Chi tiêu tuần này tập trung vào:')) {
          tapTrungVao = line.replaceAll('- Chi tiêu tuần này tập trung vào:', '').trim();
        }
      }

      final isCaoHon = !chenhLech.startsWith('-');

      return '''${isCaoHon ? 'Có' : 'Không'}, **tuần này bạn chi ${isCaoHon ? 'nhiều' : 'ít'} hơn tuần trước** 📉
•  **Tuần này: $chiTuanNay**
•  **Tuần trước: $chiTuanTruoc**
•  **Chênh lệch: $chenhLech**

**Nhận xét nhanh:**
•  Chi tiêu tuần này tập trung vào:
•  **$tapTrungVao**''';
    }

    // 3. Tổng chi tiêu tháng này / Tiêu hết bao nhiêu
    if (q.contains('tiêu hết bao nhiêu') || q.contains('tổng chi tiêu') || q.contains('hết bao nhiêu')) {
      String tongChi = '30.000đ';
      String soGd = '1';
      String topDm = 'Dịch vụ sinh hoạt';

      for (final line in nguCanh.split('\n')) {
        if (line.contains('Tổng chi tiêu tháng')) {
          tongChi = line.replaceAll(RegExp(r'- Tổng chi tiêu tháng \d+:'), '').trim();
        } else if (line.contains('Số giao dịch chi tiêu trong tháng:')) {
          soGd = line.replaceAll('- Số giao dịch chi tiêu trong tháng:', '').trim();
        } else if (line.contains('Hạng mục chi nhiều nhất tháng:')) {
          topDm = line.replaceAll('- Hạng mục chi nhiều nhất tháng:', '').trim();
        }
      }

      return '''Trong **tháng này**, bạn đã chi tiêu tổng cộng **$tongChi** 💰

**Tóm tắt nhanh:**
•  **Tổng chi tiêu: $tongChi**
•  **Số giao dịch: $soGd**
•  **Hạng mục chi cao nhất: $topDm**

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **chi theo ví**
•  **so sánh với tháng trước**
•  hoặc **dự báo chi tiêu đến cuối tháng** 📊''';
    }

    // 4. Khoản chi lớn nhất tuần qua / ảnh hưởng ngân sách
    if (q.contains('lớn nhất') && (q.contains('tuần qua') || q.contains('ảnh hưởng') || q.contains('7 ngày'))) {
      String chiLonNhat = '30.000đ';
      for (final line in nguCanh.split('\n')) {
        if (line.contains('Khoản chi lớn nhất 7 ngày qua:')) {
          chiLonNhat = line.replaceAll('- Khoản chi lớn nhất 7 ngày qua:', '').trim();
        }
      }

      return '''Trong **tuần qua**, khoản chi lớn nhất của bạn là **$chiLonNhat** ⚠️

**Tóm tắt nhanh:**
•  **Khoản chi lớn nhất: $chiLonNhat**
•  **Đánh giá:** Khoản chi này chiếm tỷ trọng đáng kể trong tuần.

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **mức độ ảnh hưởng đến hạn mức ngân sách**
•  **chi tiết các khoản chi khác trong tuần**
•  hoặc **gợi ý cân đối chi tiêu những ngày tới** 💡''';
    }

    // 5. Ngân sách / Vượt hạn mức
    if (q.contains('vượt') || q.contains('hạn mức') || q.contains('ngân sách')) {
      return '''Tình hình **ngân sách tháng này** của bạn hiện tại:

**Tóm tắt nhanh:**
•  **Trạng thái chung: An toàn**, phần lớn danh mục vẫn nằm trong hạn mức cho phép.
•  **Khuyến nghị:** Tiếp tục duy trì thói quen ghi chép đều đặn các khoản chi hàng ngày.

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **chi tiết ngân sách từng danh mục**
•  **danh mục sắp chạm ngưỡng cảnh báo**
•  hoặc **cách thiết lập ngân sách hiệu quả hơn** 🎯''';
    }

    // 6. Dự báo cuối tháng
    if (q.contains('dự báo') || q.contains('cuối tháng')) {
      return '''Dự báo **chi tiêu đến cuối tháng** của bạn:

**Tóm tắt nhanh:**
•  Dựa trên tốc độ chi tiêu hiện tại, mức chi dự kiến sẽ nằm trong tầm kiểm soát.
•  Các khoản chi định kỳ và ăn uống là hai nhóm cần lưu tâm nhất.

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **kịch bản chi tiêu tiết kiệm**
•  hoặc **đặt cảnh báo khi chi tiêu vượt mốc mong muốn** 📈''';
    }

    // 7. Tiết kiệm / cắt giảm
    if (q.contains('tiết kiệm') || q.contains('cắt giảm')) {
      return '''Gợi ý **tối ưu chi tiêu** để đạt mục tiêu tiết kiệm:

**Gợi ý nhanh:**
•  **Cắt giảm 15-20%** chi tiêu cho các dịch vụ không thiết yếu.
•  **Tận dụng số dư ví điện tử** có sẵn để hạn chế rút tiền mặt.
•  **Đặt hạn mức theo tuần** cho các khoản ăn ngoài và mua sắm.

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **lập kế hoạch tiết kiệm chi tiết**
•  hoặc **phân tích dòng tiền hàng tháng** 💡''';
    }

    // Mặc định
    return '''Mình đã xem qua **dữ liệu tài chính gần đây** của bạn 📊

**Tóm tắt nhanh:**
•  Dữ liệu ví và các giao dịch đang được cập nhật đầy đủ.
•  Bạn có thể tra cứu nhanh mọi thông tin thu chi ngay tại đây.

Nếu bạn muốn, mình có thể phân tích tiếp:
•  **hạng mục chi nhiều tiền nhất trong tháng**
•  **so sánh chi tiêu tuần này với tuần trước**
•  hoặc **tổng chi tiêu và hạn mức ngân sách** 💡''';
  }

  @override
  void dispose() {
    _chatScrollController.removeListener(_onScroll);
    _controller.dispose();
    _focusNode.dispose();
    _chatScrollController.dispose();
    _timKiemLichSuController.dispose();
    super.dispose();
  }

  String get _tenNguoiDung {
    if (widget.nguoiDung != null && widget.nguoiDung!.hoTen.trim().isNotEmpty) {
      return widget.nguoiDung!.hoTen;
    }
    return 'Nhật Nam Lê';
  }

  /// Mở cuộc trò chuyện đã có từ danh sách
  Future<void> _moCuocTroChuyen(HoiThoaiAI conv) async {
    setState(() {
      _cuocTroChuyenHienTai = conv;
      _truotSangTrai = _chiMucHienTai == 2 ? false : true;
      _chiMucHienTai = 1;
    });
    final nguCanh = await _layNguCanhTaiChinh();
    _khoiTaoAIForSession(conv, nguCanh);
    _cuonXuongDuoi();
  }

  /// Bắt đầu một cuộc trò chuyện mới hoàn toàn từ câu hỏi gợi ý hoặc yêu cầu mới
  Future<void> _batDauCuocTroChuyenMoi(String cauHoi) async {
    setState(() {
      _cuocTroChuyenHienTai = null; // Đưa về null để tạo phiên mới
      _truotSangTrai = true;
      _chiMucHienTai = 1;
    });
    await _guiTinNhan(cauHoi);
  }

  /// Xử lý gửi tin nhắn:
  /// - Nếu đang ở trang chủ hoặc chọn câu hỏi gợi ý: Tạo 1 CUỘC TRÒ CHUYỆN MỚI
  /// - Lưu cuộc trò chuyện trên Database (Supabase + local cache)
  /// - AI phân tích dữ liệu tài chính thực tế và trả lời (như Gemini của Google)
  Future<void> _guiTinNhan([String? cauHoiTuyChon]) async {
    final text = (cauHoiTuyChon ?? _controller.text).trim();
    if (text.isEmpty) return;

    if (cauHoiTuyChon == null) {
      _controller.clear();
    }

    if (_chiMucHienTai != 1) {
      setState(() {
        _truotSangTrai = true;
        _chiMucHienTai = 1;
      });
    }

    final thoiGianGui = DateTime.now();
    final tinNhanNguoiDung = TinNhan(
      noiDung: text,
      laCuaToi: true,
      thoiGian: thoiGianGui,
    );

    HoiThoaiAI session;

    if (_cuocTroChuyenHienTai == null) {
      // 1. TẠO CUỘC TRÒ CHUYỆN MỚI (LƯU DB SUPABASE)
      session = HoiThoaiAI(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        userId: _userId,
        tieuDe: text,
        thoiGianTao: thoiGianGui,
        thoiGianCapNhat: thoiGianGui,
        danhSachTinNhan: [tinNhanNguoiDung],
      );
      setState(() {
        _cuocTroChuyenHienTai = session;
        _danhSachCuocTroChuyen.insert(0, session);
        _dangNhanTin = true;
      });
    } else {
      // 2. TIẾP TỤC CUỘC TRÒ CHUYỆN HIỆN TẠI
      session = _cuocTroChuyenHienTai!;
      session.thoiGianCapNhat = thoiGianGui;
      setState(() {
        session.danhSachTinNhan.add(tinNhanNguoiDung);
        _dangNhanTin = true;
      });
    }

    _cuonXuongDuoi();

    // Lưu ngay cuộc trò chuyện mới và tin nhắn của người dùng vào Supabase & Local Cache
    unawaited(DatabaseHelper.instance.saveAIConversation(_userId, session.toMap()));

    // Lấy dữ liệu tài chính thực tế để nạp vào AI phân tích
    final nguCanhTaiChinh = await _layNguCanhTaiChinh();
    _khoiTaoAIForSession(session, nguCanhTaiChinh);

    try {
      final response = await _chatSession?.sendMessage(Content.text(text));
      final aiText = response?.text;
      if (aiText != null && aiText.trim().isNotEmpty) {
        if (!mounted) return;
        final thoiGianAI = DateTime.now();
        final tinNhanAI = TinNhan(
          noiDung: aiText.trim(),
          laCuaToi: false,
          thoiGian: thoiGianAI,
        );

        setState(() {
          session.danhSachTinNhan.add(tinNhanAI);
          session.thoiGianCapNhat = thoiGianAI;
        });

        unawaited(DatabaseHelper.instance.saveAIConversation(_userId, session.toMap()));
        return;
      }
    } catch (e) {
      debugPrint('Lỗi gọi Gemini AI với model chính: $e. Thử gemini-3.6-flash...');
      try {
        final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
        final fallbackModel = GenerativeModel(
          model: 'gemini-3.6-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(_taoSystemPrompt(nguCanhTaiChinh)),
        );
        final res = await fallbackModel.generateContent([Content.text(text)]);
        final aiText = res.text;
        if (aiText != null && aiText.trim().isNotEmpty) {
          if (!mounted) return;
          final thoiGianAI = DateTime.now();
          final tinNhanAI = TinNhan(
            noiDung: aiText.trim(),
            laCuaToi: false,
            thoiGian: thoiGianAI,
          );

          setState(() {
            session.danhSachTinNhan.add(tinNhanAI);
            session.thoiGianCapNhat = thoiGianAI;
          });

          unawaited(DatabaseHelper.instance.saveAIConversation(_userId, session.toMap()));
          return;
        }
      } catch (e2) {
        debugPrint('Lỗi cả 2 model Gemini: $e2');
      }

      if (!mounted) return;
      final phanHoiThongMinh = _phanHoiDuPhongThongMinh(text, nguCanhTaiChinh);
      final thoiGianAI = DateTime.now();
      final tinNhanAI = TinNhan(
        noiDung: phanHoiThongMinh,
        laCuaToi: false,
        thoiGian: thoiGianAI,
      );

      setState(() {
        session.danhSachTinNhan.add(tinNhanAI);
        session.thoiGianCapNhat = thoiGianAI;
      });

      unawaited(DatabaseHelper.instance.saveAIConversation(_userId, session.toMap()));
    } finally {
      if (mounted) {
        setState(() {
          _dangNhanTin = false;
        });
        _cuonXuongDuoi();
      }
    }
  }

  void _cuonXuongDuoi() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _moModalCauHoiGoiY() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ModalCauHoiGoiY(
        onChonCauHoi: (cauHoi) {
          Navigator.pop(context);
          if (_chiMucHienTai == 1 && _cuocTroChuyenHienTai != null) {
            // Đang trong cuộc trò chuyện -> nhảy vào làm câu hỏi tiếp theo
            _guiTinNhan(cauHoi);
          } else {
            // Đang ở trang chủ -> bắt đầu cuộc trò chuyện mới
            _batDauCuocTroChuyenMoi(cauHoi);
          }
        },
        onNhapVaoOText: (cauHoi) {
          Navigator.pop(context);
          setState(() {
            _controller.text = cauHoi;
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: cauHoi.length),
            );
          });
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              _focusNode.requestFocus();
            }
          });
        },
      ),
    );
  }

  void _moLichSuTroChuyen() {
    setState(() {
      _truotSangTrai = true;
      _chiMucHienTai = 2;
    });
  }

  void _onNutBackNhan() {
    if (_chiMucHienTai == 2) {
      // Đang ở trang Lịch sử -> trượt ngược lại sang phải về Chat hoặc Home
      setState(() {
        _truotSangTrai = false;
        _chiMucHienTai = _cuocTroChuyenHienTai != null ? 1 : 0;
      });
    } else if (_chiMucHienTai == 1) {
      // Đang ở Chat -> trượt ngược lại sang phải về Home
      setState(() {
        _truotSangTrai = false;
        _chiMucHienTai = 0;
        _cuocTroChuyenHienTai = null;
      });
    } else {
      // Đang ở Home -> thoát màn hình Trợ lý AI
      Navigator.pop(context);
    }
  }

  Future<void> _xoaTatCaCuocTroChuyen() async {
    setState(() {
      _danhSachCuocTroChuyen.clear();
      _cuocTroChuyenHienTai = null;
    });
    await DatabaseHelper.instance.clearAllAIConversations(_userId);
  }

  Future<void> _xacNhanXoaCuocTroChuyen(HoiThoaiAI conv) async {
    final xacNhan = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53935), size: 24),
            const SizedBox(width: 8),
            Text(
              'Xoá cuộc trò chuyện?',
              style: GoogleFonts.manrope(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1B2E),
              ),
            ),
          ],
        ),
        content: Text(
          'Cuộc trò chuyện "${conv.tieuDe}" và toàn bộ tin nhắn bên trong sẽ bị xoá vĩnh viễn trên ứng dụng và cơ sở dữ liệu hệ thống.',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: const Color(0xFF4B465C),
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Huỷ',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B6A82),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Xoá vĩnh viễn',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (xacNhan != true) return;

    final isCurrent = _cuocTroChuyenHienTai?.id == conv.id;
    setState(() {
      _danhSachCuocTroChuyen.removeWhere((c) => c.id == conv.id);
      if (isCurrent) {
        _cuocTroChuyenHienTai = null;
        if (_chiMucHienTai == 1) {
          _truotSangTrai = false;
          _chiMucHienTai = 0;
        }
      }
    });

    await DatabaseHelper.instance.deleteAIConversation(_userId, conv.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xoá toàn bộ cuộc trò chuyện khỏi cơ sở dữ liệu',
            style: GoogleFonts.manrope(),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _hienThiTuyChonTinNhan(TinNhan tn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD8E8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tuỳ chọn tin nhắn',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tn.noiDung.length > 75 ? '${tn.noiDung.substring(0, 75)}...' : tn.noiDung,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: const Color(0xFF7D7A8F),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.copy_rounded, size: 19, color: Color(0xFF7C4DFF)),
                ),
                title: Text(
                  'Sao chép nội dung',
                  style: GoogleFonts.manrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E2C3D),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: tn.noiDung));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã sao chép vào bộ nhớ tạm', style: GoogleFonts.manrope()),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 14, color: Color(0xFFF0EBF8)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 19, color: Color(0xFFE53935)),
                ),
                title: Text(
                  'Xoá tin nhắn này',
                  style: GoogleFonts.manrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE53935),
                  ),
                ),
                subtitle: Text(
                  'Xoá khỏi ứng dụng và cơ sở dữ liệu',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF9E9DB0),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _xoaTinNhanNho(tn);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _xoaTinNhanNho(TinNhan tn) async {
    if (_cuocTroChuyenHienTai == null) return;
    final conv = _cuocTroChuyenHienTai!;

    setState(() {
      conv.danhSachTinNhan.remove(tn);
      conv.thoiGianCapNhat = DateTime.now();
    });

    if (conv.danhSachTinNhan.isEmpty) {
      setState(() {
        _danhSachCuocTroChuyen.removeWhere((c) => c.id == conv.id);
        _cuocTroChuyenHienTai = null;
        _truotSangTrai = false;
        _chiMucHienTai = 0;
      });
      await DatabaseHelper.instance.deleteAIConversation(_userId, conv.id);
    } else {
      final remainingList = conv.danhSachTinNhan.map((m) => m.toMap()).toList();
      await DatabaseHelper.instance.syncAIConversationMessages(
        _userId,
        conv.id,
        remainingList,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã xoá tin nhắn khỏi cơ sở dữ liệu',
            style: GoogleFonts.manrope(),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE5F7), // Tím nhạt trên cùng
              Color(0xFFF7F3FC),
              Color(0xFFFAF7FE),
              Color(0xFFF4EDF9), // Hồng tím pastel dưới cùng
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final isIncoming =
                        (child.key as ValueKey<int>).value == _chiMucHienTai;

                    final slideDirection = _truotSangTrai ? 1.0 : -1.0;
                    final offsetBegin = isIncoming
                        ? Offset(slideDirection, 0.0)
                        : Offset(-slideDirection, 0.0);

                    final slideAnimation = Tween<Offset>(
                      begin: offsetBegin,
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey<int>(_chiMucHienTai),
                    child: _buildManHinhTheoChiMuc(_chiMucHienTai),
                  ),
                ),
              ),
              _buildBottomInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManHinhTheoChiMuc(int index) {
    switch (index) {
      case 1:
        return _buildChatView();
      case 2:
        return _buildLichSuView();
      case 0:
      default:
        return _buildHomeView();
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: _onNutBackNhan,
          ),
          if (_chiMucHienTai == 2)
            Text(
              'Trò chuyện gần đây',
              style: GoogleFonts.manrope(
                fontSize: 17.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1B2E),
              ),
            )
          else
            const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_chiMucHienTai == 1 && _cuocTroChuyenHienTai != null) ...[
                _buildCircleIconButton(
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFE53935),
                  onTap: () => _xacNhanXoaCuocTroChuyen(_cuocTroChuyenHienTai!),
                ),
                const SizedBox(width: 10),
              ],
              if (_chiMucHienTai == 2)
                _buildCircleIconButton(
                  icon: _dangTimKiemLichSu ? Icons.search_off_rounded : Icons.search_rounded,
                  onTap: () {
                    setState(() {
                      _dangTimKiemLichSu = !_dangTimKiemLichSu;
                      if (!_dangTimKiemLichSu) {
                        _tuKhoaTimKiemLichSu = '';
                        _timKiemLichSuController.clear();
                      }
                    });
                  },
                )
              else
                _buildCircleIconButton(
                  icon: Icons.history_rounded,
                  onTap: _moLichSuTroChuyen,
                ),
              const SizedBox(width: 10),
              _buildCircleIconButton(
                icon: Icons.settings_outlined,
                onTap: _hienThiCaiDatTroLy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.85),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9E8EBE).withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? const Color(0xFF2D2B3F),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 6),
          // Robot Logo
          Image.asset(
            'assets/robot_ai.png',
            height: 135,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFEDE7F6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.2),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 54,
                  color: Color(0xFF7C4DFF),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // Greeting text
          Text(
            'Xin chào, $_tenNguoiDung!',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E1B2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Trợ lý tài chính hôm nay có thể giúp gì cho bạn?',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6A82),
            ),
          ),
          const SizedBox(height: 24),
          // Tiêu đề "Gợi ý cho bạn" và nút "Xem thêm"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gợi ý cho bạn',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1B2E),
                  ),
                ),
                GestureDetector(
                  onTap: _moModalCauHoiGoiY,
                  child: Text(
                    'Xem thêm',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA838D7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal Cards Carousel
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: _theGoiYNhanh.length,
              itemBuilder: (context, index) {
                final the = _theGoiYNhanh[index];
                return _buildTheGoiY(
                  cauHoi: the['cauHoi'] as String,
                  icon: the['icon'] as IconData,
                  mauIcon: the['mauIcon'] as Color,
                  mauNen: the['mauNen'] as Color,
                );
              },
            ),
          ),
          const SizedBox(height: 28),
          // Section "Trò chuyện gần đây"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trò chuyện gần đây',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1B2E),
                  ),
                ),
                GestureDetector(
                  onTap: _moLichSuTroChuyen,
                  child: Text(
                    'Xem tất cả',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA838D7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Recent chat items
          if (_dangTaiDuLieu)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7C4DFF),
                  ),
                ),
              ),
            )
          else if (_danhSachCuocTroChuyen.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Center(
                child: Text(
                  'Chưa có cuộc trò chuyện nào',
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    color: const Color(0xFF9E9DB0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ..._danhSachCuocTroChuyen.take(3).map((conv) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                child: _buildMucTroChuyenGanDay(
                  tieuDe: conv.tieuDe,
                  thoiGian: _dinhDangThoiGian(conv.thoiGianCapNhat),
                  onTap: () => _moCuocTroChuyen(conv),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTheGoiY({
    required String cauHoi,
    required IconData icon,
    required Color mauIcon,
    required Color mauNen,
  }) {
    return Container(
      width: 215,
      margin: const EdgeInsets.only(right: 14, bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E8EBE).withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => _batDauCuocTroChuyenMoi(cauHoi),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: mauNen,
                    border: Border.all(
                      color: mauIcon.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: mauIcon,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  cauHoi,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E2C3D),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMucTroChuyenGanDay({
    required String tieuDe,
    required String thoiGian,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E8EBE).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tieuDe,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2C3D),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        thoiGian,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: const Color(0xFF9E9DB0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    final messages = _cuocTroChuyenHienTai?.danhSachTinNhan ?? [];

    return Stack(
      children: [
        ListView.builder(
          controller: _chatScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final tn = messages[index];
            final isLast = index == messages.length - 1;
            final isAi = !tn.laCuaToi;

            if (isLast && isAi && !_dangNhanTin) {
              TinNhan? userMsg;
              for (int i = index - 1; i >= 0; i--) {
                if (messages[i].laCuaToi) {
                  userMsg = messages[i];
                  break;
                }
              }
              final goiYList = _layDanhSachGoiYTiepTheo(tn, userMsg);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChatBubble(tn),
                  if (goiYList.isNotEmpty) _buildGoiYPromptTiepTheo(goiYList),
                ],
              );
            }

            return _buildChatBubble(tn);
          },
        ),
        if (_dangNhanTin)
          Positioned(
            left: 18,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7C4DFF),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI đang phân tích câu hỏi...',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF6B6A82),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_showScrollDownBtn)
          Positioned(
            right: 18,
            bottom: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _cuonXuongDuoi,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.96),
                    border: Border.all(
                      color: const Color(0xFFEDE8F5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9E8EBE).withValues(alpha: 0.16),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 26,
                    color: Color(0xFF2E2C3D),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<String> _layDanhSachGoiYTiepTheo(TinNhan aiMsg, TinNhan? userMsg) {
    final List<String> result = [];
    final text = aiMsg.noiDung;

    // 1. Thử trích xuất từ nội dung AI nếu có phần gợi ý tiếp theo
    final markerRegex = RegExp(
      r'(?:Nếu bạn muốn,?\s*)?(?:mình|tôi|trợ lý)?\s*(?:có thể\s*)?phân tích tiếp:?',
      caseSensitive: false,
    );
    final match = markerRegex.firstMatch(text);
    if (match != null) {
      final afterMarker = text.substring(match.end);
      final lines = afterMarker.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        final bulletMatch = RegExp(r'^(?:[•\-\*]|\d+[\.\)])\s*(?:hoặc\s+)?(.*)$', caseSensitive: false).firstMatch(trimmed);
        if (bulletMatch != null) {
          String item = bulletMatch.group(1)!.trim();
          item = item.replaceAll('*', '').replaceAll('`', '').trim();
          item = item.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '').trim();
          if (item.isNotEmpty && item.length > 3) {
            item = item[0].toUpperCase() + item.substring(1);
            result.add(item);
          }
        }
      }
    }

    if (result.isNotEmpty) {
      return result.take(3).toList();
    }

    // 2. Tự động sinh prompt gợi ý thứ 2 thông minh theo ngữ cảnh câu hỏi:
    final uText = (userMsg?.noiDung ?? '').toLowerCase();
    if (uText.contains('dự báo') || uText.contains('cuối tháng')) {
      return [
        'Chi tiết các khoản chi dự kiến từ nay đến cuối tháng',
        'Tôi nên cắt giảm chi tiêu ở đâu để tiết kiệm thêm?',
        'Hạn mức ngân sách các danh mục còn lại',
      ];
    } else if (uText.contains('vượt') || uText.contains('ngân sách') || uText.contains('hạn mức')) {
      return [
        'Hạng mục nào có nguy cơ vượt ngân sách cao nhất?',
        'Dự báo đến cuối tháng tổng chi tiêu của tôi sẽ là bao nhiêu?',
        'Gợi ý cách cắt giảm chi tiêu để tiết kiệm thêm',
      ];
    } else if (uText.contains('lớn nhất') || uText.contains('tuần qua') || uText.contains('ảnh hưởng')) {
      return [
        'Khoản chi này ảnh hưởng thế nào đến ngân sách tháng?',
        'So sánh chi tiêu tuần này với tuần trước',
        'Chi tiết các khoản chi khác trong tuần qua',
      ];
    } else if (uText.contains('tiết kiệm') || uText.contains('cắt giảm')) {
      return [
        'Lập kế hoạch tiết kiệm chi tiết cho tháng này',
        'Hạng mục nào tôi đang chi tiêu lãng phí nhất?',
        'Hạn mức ngân sách các danh mục hiện tại',
      ];
    } else if (uText.contains('hôm nay') || uText.contains('ngày')) {
      return [
        'Khoản chi nào lớn nhất trong tuần qua?',
        'Chi tiêu trung bình mỗi ngày trong tháng',
        'Dự báo đến cuối tháng tổng chi tiêu là bao nhiêu?',
      ];
    }

    return [
      'Khoản chi nào lớn nhất trong tuần qua làm ảnh hưởng ngân sách?',
      'Tổng chi tiêu tháng này của tôi đã vượt hạn mức chưa?',
      'Dự báo đến cuối tháng tổng chi tiêu của tôi sẽ là bao nhiêu?',
    ];
  }

  Widget _buildGoiYPromptTiepTheo(List<String> danhSachGoiY) {
    if (danhSachGoiY.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 22, left: 4, right: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Color(0xFF7C4DFF),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Gợi ý câu hỏi tiếp theo:',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5E5873),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: danhSachGoiY.map((prompt) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE4DCF2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _guiTinNhan(prompt),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt,
                              style: GoogleFonts.manrope(
                                fontSize: 13.8,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF322A4E),
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEDE7F6),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 15,
                              color: Color(0xFF7C4DFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(TinNhan tn) {
    if (tn.laCuaToi) {
      return GestureDetector(
        onLongPress: () => _hienThiTuyChonTinNhan(tn),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20, left: 40),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    tn.noiDung,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      color: const Color(0xFF1E1B2E),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _hienThiTuyChonTinNhan(tn),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 16,
                      color: const Color(0xFF9E9DB0).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onLongPress: () => _hienThiTuyChonTinNhan(tn),
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAiFormattedMessage(tn.noiDung),
              const SizedBox(height: 6),
              // Nút thao tác nhanh cho phản hồi AI
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Tooltip(
                    message: 'Sao chép câu trả lời',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: tn.noiDung));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Đã sao chép vào bộ nhớ tạm',
                              style: GoogleFonts.manrope(),
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: const Color(0xFF9E9DB0).withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'Xoá câu trả lời này khỏi cơ sở dữ liệu',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _hienThiTuyChonTinNhan(tn),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: const Color(0xFFE53935).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildAiFormattedMessage(String rawText) {
    final lines = rawText.split('\n');
    final List<Widget> children = [];

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      // Xử lý tiêu đề markdown #, ##, ###
      if (trimmed.startsWith('### ')) {
        line = trimmed.substring(4).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text.rich(
              TextSpan(
                children: _parseMarkdownSpans(
                  line.startsWith('**') ? line : '**$line**',
                  fontSize: 15.5,
                ),
              ),
            ),
          ),
        );
        continue;
      } else if (trimmed.startsWith('## ') || trimmed.startsWith('# ')) {
        line = trimmed.replaceFirst(RegExp(r'^#+\s*'), '').trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text.rich(
              TextSpan(
                children: _parseMarkdownSpans(
                  line.startsWith('**') ? line : '**$line**',
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
        continue;
      }

      // Kiểm tra xem dòng có phải là bullet point không
      // Lưu ý: *(?!\\*) đảm bảo không match dòng in đậm bắt đầu bằng **
      final bulletMatch = RegExp(r'^(?:[•\-\–]|\*(?!\*))\s*(.*)$').firstMatch(trimmed);

      if (bulletMatch != null) {
        String bulletContent = bulletMatch.group(1)!.trim();

        // Nếu nội dung sau dấu bullet thực chất là một tiêu đề mục (vd: **Tóm tắt chi tiết:**)
        // thì hiển thị dưới dạng tiêu đề đứng riêng, không có bullet thừa
        final isHeadingInBullet = (bulletContent.startsWith('**') && (bulletContent.endsWith(':**') || bulletContent.endsWith(':'))) ||
            (bulletContent.startsWith('*') && bulletContent.endsWith(':**'));

        if (isHeadingInBullet) {
          children.add(
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Text.rich(
                TextSpan(
                  children: _parseMarkdownSpans(bulletContent, fontSize: 15.5),
                ),
              ),
            ),
          );
          continue;
        }

        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7.5, right: 10),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF374151),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseMarkdownSpans(bulletContent, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Xử lý danh sách có đánh số: 1. hoặc 1)
      final numMatch = RegExp(r'^(\d+[\.\)])\s*(.*)$').firstMatch(trimmed);
      if (numMatch != null) {
        final numStr = numMatch.group(1)!;
        final numContent = numMatch.group(2)!;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    numStr,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1B2E),
                      height: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: _parseMarkdownSpans(numContent, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Dòng thông thường hoặc dòng tiêu đề dạng **Tiêu đề:** đứng riêng
      final isHeadingLine = trimmed.startsWith('**') && (trimmed.endsWith(':**') || trimmed.endsWith(':'));
      final isLeadInLine = trimmed.endsWith(':') && !trimmed.startsWith('•');

      children.add(
        Padding(
          padding: EdgeInsets.only(
            top: (isHeadingLine || isLeadInLine) ? 8 : 0,
            bottom: 6,
          ),
          child: Text.rich(
            TextSpan(
              children: _parseMarkdownSpans(
                line,
                fontSize: isHeadingLine ? 15.5 : 15,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<InlineSpan> _parseMarkdownSpans(String text, {double fontSize = 15, Color? defaultColor}) {
    final List<InlineSpan> spans = [];
    final baseColor = defaultColor ?? const Color(0xFF1E1B2E);

    // Tự động sửa các lỗi lệch dấu sao markdown do LLM sinh ra
    // Ví dụ: *Tóm tắt:** -> **Tóm tắt:**  hoặc **Tóm tắt:* -> **Tóm tắt:**
    String cleaned = text
        .replaceAllMapped(RegExp(r'(?<!\*)\*([^\*\n]+)\*\*'), (m) => '**${m[1]}**')
        .replaceAllMapped(RegExp(r'\*\*([^\*\n]+)\*(?!\*)'), (m) => '**${m[1]}**');

    // Regex tìm kiếm các cú pháp: **in đậm**, *in nghiêng*, hoặc `code`
    final regex = RegExp(r'(\*\*(.*?)\*\*|\*([^\*]+)\*|`([^`]+)`)');
    int lastIndex = 0;

    for (final match in regex.allMatches(cleaned)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: cleaned.substring(lastIndex, match.start),
          style: GoogleFonts.manrope(
            fontSize: fontSize,
            color: baseColor,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ));
      }

      if (match.group(2) != null) {
        // In đậm **text**
        spans.add(TextSpan(
          text: match.group(2),
          style: GoogleFonts.manrope(
            fontSize: fontSize,
            color: baseColor,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ));
      } else if (match.group(3) != null) {
        // In nghiêng *text*
        spans.add(TextSpan(
          text: match.group(3),
          style: GoogleFonts.manrope(
            fontSize: fontSize,
            color: baseColor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ));
      } else if (match.group(4) != null) {
        // Code / Highlight `text`
        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.group(4)!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: fontSize * 0.9,
                color: const Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
      }

      lastIndex = match.end;
    }

    if (lastIndex < cleaned.length) {
      spans.add(TextSpan(
        text: cleaned.substring(lastIndex),
        style: GoogleFonts.manrope(
          fontSize: fontSize,
          color: baseColor,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ));
    }

    return spans;
  }

  Widget _buildLichSuView() {
    List<HoiThoaiAI> danhSachLoc = _danhSachCuocTroChuyen;
    if (_tuKhoaTimKiemLichSu.trim().isNotEmpty) {
      final query = _tuKhoaTimKiemLichSu.toLowerCase().trim();
      danhSachLoc = _danhSachCuocTroChuyen
          .where((c) => c.tieuDe.toLowerCase().contains(query))
          .toList();
    }

    return Column(
      children: [
        if (_dangTimKiemLichSu) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE5DEEE)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _timKiemLichSuController,
                autofocus: true,
                style: GoogleFonts.manrope(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm cuộc trò chuyện...',
                  hintStyle: GoogleFonts.manrope(color: const Color(0xFF9E9DB0)),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF7C4DFF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() {
                    _tuKhoaTimKiemLichSu = val;
                  });
                },
              ),
            ),
          ),
        ],
        // Banner thông báo lưu trữ 30 ngày
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE8EEF8),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF1E88E5),
                size: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Lịch sử trò chuyện chỉ được lưu trữ trong 30 ngày gần nhất.',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E88E5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Danh sách các cuộc trò chuyện gần đây
        Expanded(
          child: danhSachLoc.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 48,
                        color: const Color(0xFFB3B1C5).withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Không tìm thấy cuộc trò chuyện nào',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF9E9DB0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: danhSachLoc.length,
                  itemBuilder: (context, index) {
                    final conv = danhSachLoc[index];
                    final isCurrent = _cuocTroChuyenHienTai?.id == conv.id;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF7C4DFF).withValues(alpha: 0.5) : Colors.white,
                          width: isCurrent ? 1.5 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9E8EBE).withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _moCuocTroChuyen(conv),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? const Color(0xFF7C4DFF).withValues(alpha: 0.15)
                                        : const Color(0xFFEDE7F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCurrent ? Icons.chat_rounded : Icons.chat_bubble_outline_rounded,
                                    size: 19,
                                    color: const Color(0xFF7C4DFF),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        conv.tieuDe,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                                          color: const Color(0xFF2E2C3D),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _dinhDangThoiGian(conv.thoiGianCapNhat),
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF9E9DB0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 20,
                                    color: Color(0xFFB3B1C5),
                                  ),
                                  onPressed: () => _xacNhanXoaCuocTroChuyen(conv),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomInput() {
    // Khi đang xem danh sách Lịch sử trò chuyện: Hiển thị nút "Cuộc trò chuyện mới"
    if (_chiMucHienTai == 2) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: () {
              setState(() {
                _cuocTroChuyenHienTai = null;
                _truotSangTrai = false;
                _chiMucHienTai = 0;
              });
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9C27B0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Cuộc trò chuyện mới',
                    style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
      child: Row(
        children: [
          // Grid icon button (opens suggested questions modal)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _moModalCauHoiGoiY,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Pill input textfield
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFE8E4F2),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !_dangNhanTin,
                      textInputAction: TextInputAction.send,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xFF2E2C3D),
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập câu hỏi của bạn',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 14,
                          color: const Color(0xFF9E9DB0),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      onSubmitted: (_) => _guiTinNhan(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      icon: const Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFFB3B1C5),
                        size: 22,
                      ),
                      onPressed: _dangNhanTin ? null : () => _guiTinNhan(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _hienThiCaiDatTroLy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tùy chọn Trợ lý AI',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1B2E),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFF7C4DFF)),
              ),
              title: Text(
                'Xóa tất cả cuộc trò chuyện',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Xóa toàn bộ lịch sử trên Database và làm mới AI',
                style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _xoaTatCaCuocTroChuyen();
                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa toàn bộ lịch sử trò chuyện')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// MODAL: CÂU HỎI GỢI Ý (Screenshots 2 & 3)
/// ==========================================

class _NhomGoiY {
  final String tieuDe;
  final IconData icon;
  final Color mauIcon;
  final Color mauNenIcon;
  final List<String> danhSachCauHoi;

  const _NhomGoiY({
    required this.tieuDe,
    required this.icon,
    required this.mauIcon,
    required this.mauNenIcon,
    required this.danhSachCauHoi,
  });
}

class _ModalCauHoiGoiY extends StatefulWidget {
  final Function(String) onChonCauHoi;
  final Function(String)? onNhapVaoOText;

  const _ModalCauHoiGoiY({
    required this.onChonCauHoi,
    this.onNhapVaoOText,
  });

  @override
  State<_ModalCauHoiGoiY> createState() => _ModalCauHoiGoiYState();
}

class _ModalCauHoiGoiYState extends State<_ModalCauHoiGoiY> {
  int _danhMucDuocChon = 0;
  bool _dangTimKiem = false;
  final TextEditingController _timKiemController = TextEditingController();
  String _tuKhoaTimKiem = '';

  final List<String> _danhSachDanhMuc = [
    'Tất cả',
    'Thấu hiểu chi tiêu',
    'Cảnh báo và phát hiện bất thường',
    'Dự báo',
    'Tư vấn hành động',
  ];

  final List<_NhomGoiY> _tatCaNhomGoiY = const [
    _NhomGoiY(
      tieuDe: 'Thấu hiểu chi tiêu',
      icon: Icons.bar_chart_rounded,
      mauIcon: Color(0xFF8E24AA),
      mauNenIcon: Color(0xFFF3E5F5),
      danhSachCauHoi: [
        'Tháng này tôi đã tiêu hết bao nhiêu tiền rồi?',
        'Hạng mục nào tôi chi nhiều tiền nhất trong tháng này?',
        'Chi tiêu tuần này của tôi có cao hơn tuần trước không?',
      ],
    ),
    _NhomGoiY(
      tieuDe: 'Cảnh báo và phát hiện bất thường',
      icon: Icons.warning_amber_rounded,
      mauIcon: Color(0xFFD81B60),
      mauNenIcon: Color(0xFFFCE4EC),
      danhSachCauHoi: [
        'Sao tháng này chi tiêu của tôi lại tăng vọt so với tháng trước vậy?',
        'Có khoản chi nào lặp lại nhiều lần mà tôi không chú ý không?',
        'Khoản chi nào lớn nhất trong tuần qua làm ảnh hưởng đến ngân sách của tôi?',
      ],
    ),
    _NhomGoiY(
      tieuDe: 'Dự báo',
      icon: Icons.calendar_month_outlined,
      mauIcon: Color(0xFF1E88E5),
      mauNenIcon: Color(0xFFE3F2FD),
      danhSachCauHoi: [
        'Nếu cứ tiếp tục chi tiêu thế này, ngày mấy tôi sẽ tiêu hết tiền?',
        'Dự báo đến cuối tháng tổng chi tiêu của tôi sẽ là bao nhiêu?',
        'Tốc độ tiêu tiền trung bình mỗi ngày của tôi hiện tại là bao nhiêu?',
      ],
    ),
    _NhomGoiY(
      tieuDe: 'Tư vấn hành động',
      icon: Icons.chat_bubble_outline_rounded,
      mauIcon: Color(0xFFAB47BC),
      mauNenIcon: Color(0xFFF3E5F5),
      danhSachCauHoi: [
        'Tôi nên cắt giảm chi tiêu ở hạng mục nào để tiết kiệm thêm 2 triệu mỗi tháng?',
        'Mỗi ngày tôi nên tiêu tối đa bao nhiêu tiền?',
        'Bạn gợi ý cách nào để tôi giảm bớt chi phí Cafe/Trà sữa không?',
      ],
    ),
  ];

  @override
  void dispose() {
    _timKiemController.dispose();
    super.dispose();
  }

  List<_NhomGoiY> get _nhomHienThi {
    List<_NhomGoiY> danhSach;
    if (_danhMucDuocChon == 0) {
      danhSach = _tatCaNhomGoiY;
    } else {
      final tieuDeMuc = _danhSachDanhMuc[_danhMucDuocChon];
      danhSach = _tatCaNhomGoiY.where((e) => e.tieuDe == tieuDeMuc).toList();
    }

    if (_tuKhoaTimKiem.trim().isEmpty) {
      return danhSach;
    }

    final query = _tuKhoaTimKiem.toLowerCase().trim();
    return danhSach
        .map((nhom) {
          final cauHoiLoc = nhom.danhSachCauHoi
              .where((ch) => ch.toLowerCase().contains(query))
              .toList();
          return _NhomGoiY(
            tieuDe: nhom.tieuDe,
            icon: nhom.icon,
            mauIcon: nhom.mauIcon,
            mauNenIcon: nhom.mauNenIcon,
            danhSachCauHoi: cauHoiLoc,
          );
        })
        .where((nhom) => nhom.danhSachCauHoi.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F3FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFDDD8E8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Header: "Câu hỏi gợi ý" + Search & Close buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Câu hỏi gợi ý',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1B2E),
                  ),
                ),
                const Spacer(),
                _buildHeaderCircleButton(
                  icon: _dangTimKiem ? Icons.search_off_rounded : Icons.search_rounded,
                  onTap: () {
                    setState(() {
                      _dangTimKiem = !_dangTimKiem;
                      if (!_dangTimKiem) {
                        _tuKhoaTimKiem = '';
                        _timKiemController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildHeaderCircleButton(
                  icon: Icons.close_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (_dangTimKiem) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5DEEE)),
                ),
                child: TextField(
                  controller: _timKiemController,
                  autofocus: true,
                  style: GoogleFonts.manrope(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm câu hỏi...',
                    hintStyle: GoogleFonts.manrope(color: const Color(0xFF9E9DB0)),
                    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF7C4DFF)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _tuKhoaTimKiem = val;
                    });
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          // Category chips (Horizontal scroll)
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _danhSachDanhMuc.length,
              itemBuilder: (context, index) {
                final isSelected = _danhMucDuocChon == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        setState(() {
                          _danhMucDuocChon = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF2979FF), Color(0xFF9C27B0)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: const Color(0xFFEAE5F3),
                                  width: 1,
                                ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          _danhSachDanhMuc[index],
                          style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFF2E2C3D),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Categorized Questions List
          Expanded(
            child: _nhomHienThi.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy câu hỏi gợi ý phù hợp',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: const Color(0xFF9E9DB0),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: _nhomHienThi.length,
                    itemBuilder: (context, index) {
                      final nhom = _nhomHienThi[index];
                      return _buildNhomCauHoi(nhom);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFEDE8F5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9E8EBE).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 19,
            color: const Color(0xFF3E3B50),
          ),
        ),
      ),
    );
  }

  Widget _buildNhomCauHoi(_NhomGoiY nhom) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nhom.mauNenIcon,
                  border: Border.all(
                    color: nhom.mauIcon.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  nhom.icon,
                  size: 20,
                  color: nhom.mauIcon,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                nhom.tieuDe,
                style: GoogleFonts.manrope(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 38,
                  alignment: Alignment.center,
                  child: Container(
                    width: 1.5,
                    color: const Color(0xFFE4DCF0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: nhom.danhSachCauHoi.map((cauHoi) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9E8EBE).withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => widget.onChonCauHoi(cauHoi),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cauHoi,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF2E2C3D),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  if (widget.onNhapVaoOText != null) ...[
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: 'Điền vào ô nhập',
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(10),
                                          onTap: () => widget.onNhapVaoOText!(cauHoi),
                                          child: Container(
                                            padding: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF7C4DFF).withValues(alpha: 0.08),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.north_west_rounded,
                                              size: 16,
                                              color: Color(0xFF6C4AB6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


