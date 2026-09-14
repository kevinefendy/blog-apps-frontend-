import 'package:flutter/material.dart';

import 'screens/article_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artikel App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const ArticleListPage(),
    );
  }
}
