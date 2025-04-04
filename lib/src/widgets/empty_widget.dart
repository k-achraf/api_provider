import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.cancel, color: Theme.of(context).primaryColor, size: 50),
        const SizedBox(height: 20),
        Text('Success'),
      ],
    );
  }
}
