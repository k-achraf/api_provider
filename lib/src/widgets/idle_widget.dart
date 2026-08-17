import 'package:flutter/material.dart';

/// Default idle state widget used by [ApiProviderUi] when no custom
/// [idleWidget] is provided.
///
/// Renders an empty [SizedBox] — invisible until a request is triggered.
class IdleWidget extends StatelessWidget {
  /// Creates the default [IdleWidget].
  const IdleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
