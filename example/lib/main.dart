import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  ApiProvider.instance.init(
    ApiProviderConfig(
      'https://dummyjson.com',
      contentType: 'application/json',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
      requestLogger: true,
    ),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'easy_api_provider Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
