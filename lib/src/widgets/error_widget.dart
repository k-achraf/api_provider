import 'package:flutter/material.dart';

class ApiErrorWidget extends StatelessWidget {
  const ApiErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, color: const Color(0xFFFC6363), size: 50),
        const SizedBox(height: 20),
        Text('Error'),
      ],
    );
  }
}
