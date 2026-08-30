import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_24ct_lenhatnam/main.dart';

void main() {
  testWidgets('Kiểm tra ứng dụng Cointap khởi động vào màn hình Đăng nhập', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CointapApp());

    // Verify that our title is present.
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);

    // Verify registration navigation exists
    expect(find.text('Đăng ký ngay'), findsOneWidget);
  });
}
