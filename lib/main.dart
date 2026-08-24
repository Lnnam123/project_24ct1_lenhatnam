import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Học phần CNPM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Trang chủ'),
    );
  }
}

// Chuyển thành StatelessWidget vì ứng dụng hiện tại chỉ hiển thị Text tĩnh,
// không cần thay đổi trạng thái (State) như lúc đếm số nữa.
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: const Center(
        // Hiển thị đoạn text theo yêu cầu ở giữa màn hình
        child: Text(
          'Chào các bạn khoá 24CT đến với học phần CNPM-DAU',
          textAlign: TextAlign.center, // Căn giữa chữ
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold, // In đậm
            color: Colors.black, // Đổi màu chữ
          ),
        ),
      ),
    );
  }
}
