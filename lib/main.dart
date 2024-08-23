import 'package:flutter/material.dart';
import 'package:test_test/screens/todo_page.dart';
void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: TodoListPage()
    );
  }
}

