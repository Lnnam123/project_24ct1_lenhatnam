import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../chu_de/mau_sac.dart';

class TinNhan {
  final String noiDung;
  final bool laCuaToi;
  TinNhan({required this.noiDung, required this.laCuaToi});
}

class ManHinhTroLyAI extends StatefulWidget {
  const ManHinhTroLyAI({super.key});

  @override
  State<ManHinhTroLyAI> createState() => _ManHinhTroLyAIState();
}

class _ManHinhTroLyAIState extends State<ManHinhTroLyAI> {
  final TextEditingController _controller = TextEditingController();
  final List<TinNhan> _danhSachTinNhan = [];
  bool _dangNhanTin = false;

  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();

    // Lấy API Key từ file .env
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

    _model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: apiKey);
    _chatSession = _model.startChat();

    // Gửi tin nhắn chào mừng
    _danhSachTinNhan.add(
      TinNhan(
        noiDung: "Xin chào! Mình là trợ lý AI ảo của CoinTap. Bạn có câu hỏi nào về quản lý tài chính hay cách sử dụng ứng dụng không?",
        laCuaToi: false,
      ),
    );
  }

  Future<void> _guiTinNhan() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _danhSachTinNhan.insert(0, TinNhan(noiDung: text, laCuaToi: true));
      _dangNhanTin = true;
    });
    _controller.clear();

    try {
      final response = await _chatSession.sendMessage(Content.text(text));

      setState(() {
        _danhSachTinNhan.insert(
          0,
          TinNhan(
            noiDung: response.text ?? 'Xin lỗi, mình không hiểu ý bạn.',
            laCuaToi: false,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _danhSachTinNhan.insert(
          0,
          TinNhan(
            noiDung:
                'Đã có lỗi xảy ra. Hãy kiểm tra lại kết nối mạng hoặc nhập API Key vào source code.\nChi tiết lỗi: $e',
            laCuaToi: false,
          ),
        );
      });
    } finally {
      setState(() {
        _dangNhanTin = false;
      });
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trợ lý AI CoinTap',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: _danhSachTinNhan.length,
                itemBuilder: (context, index) {
                  final tn = _danhSachTinNhan[index];
                  return _buildChatBubble(tn);
                },
              ),
            ),

            if (_dangNhanTin)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: MauSac.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "AI đang suy nghĩ...",
                        style: GoogleFonts.manrope(
                          color: MauSac.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: MauSac.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_dangNhanTin,
                      style: GoogleFonts.manrope(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Hỏi AI điều gì đó...",
                        hintStyle: GoogleFonts.manrope(
                          color: MauSac.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: MauSac.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      onSubmitted: (_) => _guiTinNhan(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _dangNhanTin
                          ? MauSac.surfaceContainerHighest
                          : MauSac.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _dangNhanTin ? null : _guiTinNhan,
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

  Widget _buildChatBubble(TinNhan tn) {
    return Align(
      alignment: tn.laCuaToi ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: tn.laCuaToi ? MauSac.primary : MauSac.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(tn.laCuaToi ? 16 : 4),
            bottomRight: Radius.circular(tn.laCuaToi ? 4 : 16),
          ),
          border: tn.laCuaToi ? null : Border.all(color: MauSac.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          tn.noiDung,
          style: GoogleFonts.manrope(
            fontSize: 15,
            color: tn.laCuaToi ? Colors.white : MauSac.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
