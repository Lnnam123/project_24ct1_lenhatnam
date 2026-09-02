import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../chu_de/mau_sac.dart';

class ManHinhDieuKhoan extends StatelessWidget {
  const ManHinhDieuKhoan({super.key});

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MauSac.onSurface,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: MauSac.onSurfaceVariant,
          height: 1.5,
        ),
      ),
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Điều khoản sử dụng',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MauSac.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cập nhật lần cuối: Tháng 09, 2026. Vui lòng đọc kỹ các điều khoản dưới đây trước khi sử dụng ứng dụng CoinTap.',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: MauSac.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionTitle('1. Chấp nhận điều khoản'),
            _buildParagraph('Bằng việc tải xuống, cài đặt và sử dụng ứng dụng CoinTap, bạn đồng ý bị ràng buộc bởi các Điều khoản sử dụng này. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản này, vui lòng không sử dụng ứng dụng của chúng tôi.'),
            _buildParagraph('CoinTap bảo lưu quyền cập nhật hoặc thay đổi các điều khoản này bất cứ lúc nào mà không cần thông báo trước. Việc bạn tiếp tục sử dụng ứng dụng sau khi có những thay đổi như vậy đồng nghĩa với việc bạn chấp nhận các điều khoản mới.'),
            const SizedBox(height: 24),
            
            _buildSectionTitle('2. Quyền sở hữu trí tuệ'),
            _buildParagraph('Tất cả nội dung, thiết kế, đồ họa, giao diện và mã nguồn của ứng dụng CoinTap đều thuộc bản quyền của chúng tôi hoặc các nhà cung cấp nội dung của chúng tôi và được bảo vệ bởi luật sở hữu trí tuệ.'),
            _buildParagraph('Bạn không được phép sao chép, phân phối, sửa đổi hoặc tạo ra các tác phẩm phái sinh từ bất kỳ phần nào của ứng dụng mà không có sự đồng ý bằng văn bản từ chúng tôi.'),
            const SizedBox(height: 24),

            _buildSectionTitle('3. Bảo mật thông tin'),
            _buildParagraph('CoinTap cam kết bảo vệ quyền riêng tư của bạn. Việc thu thập và sử dụng dữ liệu cá nhân của bạn được điều chỉnh bởi Chính sách Bảo mật của chúng tôi, mà bạn có thể tìm thấy trong phần cài đặt của ứng dụng.'),
            _buildParagraph('Mặc dù chúng tôi sử dụng các biện pháp bảo mật hợp lý để bảo vệ dữ liệu của bạn, không có phương thức truyền tải qua internet hoặc lưu trữ điện tử nào là an toàn 100%. Do đó, chúng tôi không thể đảm bảo an ninh tuyệt đối.'),
            const SizedBox(height: 24),

            const Divider(color: MauSac.borderSubtle),
            const SizedBox(height: 16),
            
            Center(
              child: Text(
                'Nếu bạn có bất kỳ câu hỏi nào về các Điều khoản này, vui lòng liên hệ với chúng tôi qua phần Hỗ trợ.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: MauSac.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
