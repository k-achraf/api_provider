import 'dart:convert';

import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

class ResponseViewer extends StatelessWidget {
  final ApiResponse response;
  final bool showFullData;

  const ResponseViewer({
    required this.response,
    this.showFullData = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: response.success
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: response.success
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(context, 'Status',
            response.success ? 'SUCCESS' : 'ERROR',
            response.success ? Colors.green : Colors.red),
          if (response.statusCode != null)
            _buildRow(context, 'HTTP Code', '${response.statusCode}'),
          if (response.url != null)
            _buildRow(context, 'URL', response.url!),
          if (response.message != null)
            _buildRow(context, 'Message', response.message!),
          if (showFullData && response.data != null) ...[
            const SizedBox(height: 12),
            Text(
              'Response Data:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatData(response.data),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontFamily: value.startsWith('http') ? null : 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatData(dynamic data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }
}
