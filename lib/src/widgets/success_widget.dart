import 'package:flutter/material.dart';

/// Default success state widget used by [ApiProviderUi] when no custom
/// [successWidget] is provided.
///
/// Displays a green check-circle icon with a "Success" label.
class SuccessWidget extends StatelessWidget {
  /// Creates the default [SuccessWidget].
  const SuccessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Color(0xFF3FAE2A), size: 50),
        SizedBox(height: 20),
        Text('Success'),
      ],
    );
  }
}
