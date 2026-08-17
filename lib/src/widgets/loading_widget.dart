import 'package:flutter/material.dart';

/// Default loading state widget used by [ApiProviderUi] when no custom
/// [loadingWidget] is provided.
///
/// Displays a [CircularProgressIndicator] with a brief loading label.
class LoadingWidget extends StatelessWidget {
  /// Creates the default [LoadingWidget].
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(
          backgroundColor: Theme.of(context).canvasColor,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 20),
        const Text('Data loading ...'),
      ],
    );
  }
}
