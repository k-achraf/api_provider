import 'package:flutter/material.dart';

class SuccessWidget extends StatelessWidget {
  const SuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: const Color(0xFF3FAE2A), size: 50),
        const SizedBox(height: 20),
        Text('Success'),
      ],
    );
  }
}
