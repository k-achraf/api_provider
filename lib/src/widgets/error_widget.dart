import 'package:flutter/material.dart';

/// Default error state widget used by [ApiProviderUi] when no custom
/// [errorWidget] is provided.
///
/// Displays a red error icon with a short label.
class ApiErrorWidget extends StatelessWidget {
  /// Creates the default [ApiErrorWidget].
  const ApiErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.error, color: Color(0xFFFC6363), size: 50),
        SizedBox(height: 20),
        Text('Error'),
      ],
    );
  }
}
