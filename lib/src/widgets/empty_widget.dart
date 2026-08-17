import 'package:flutter/material.dart';

/// Default empty state widget used by [ApiProviderUi] when no custom
/// [emptyWidget] is provided.
///
/// Displays a cancel icon and an "Empty" label using the theme's primary color.
class EmptyWidget extends StatelessWidget {
  /// Creates the default [EmptyWidget].
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.cancel, color: Theme.of(context).primaryColor, size: 50),
        const SizedBox(height: 20),
        const Text('Empty'),
      ],
    );
  }
}
