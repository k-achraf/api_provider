import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  ApiResponse? response;
  bool downloading = false;
  int received = 0;
  int total = 0;
  CancelToken? cancelToken;

  Future<void> _startDownload() async {
    cancelToken = CancelToken();
    setState(() {
      downloading = true;
      received = 0;
      total = 0;
      response = null;
    });

    final dir = Directory.systemTemp;
    final savePath = '${dir.path}/downloaded_photo.jpg';

    final result = await ApiProvider.instance.download(
      'https://picsum.photos/800/600',
      savePath,
      onReceiveProgress: (r, t) {
        setState(() {
          received = r;
          total = t;
        });
      },
      cancelToken: cancelToken,
    );

    setState(() {
      response = result;
      downloading = false;
    });
  }

  void _cancelDownload() {
    cancelToken?.cancel('User cancelled download');
    setState(() {
      downloading = false;
      response = ApiResponse(
        success: false,
        message: 'Download cancelled by user',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? received / total : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Download')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Download a file with progress tracking and cancel support',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          if (downloading) ...[
            LinearProgressIndicator(value: total > 0 ? progress : null),
            const SizedBox(height: 8),
            Text(
              total > 0
                  ? '${(progress * 100).toStringAsFixed(0)}% — ${(received / 1024).toStringAsFixed(0)} KB / ${(total / 1024).toStringAsFixed(0)} KB'
                  : 'Connecting...',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _cancelDownload,
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancel Download'),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: _startDownload,
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download Image (800x600)'),
            ),
          ],
          if (response != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    response!.success
                        ? Colors.green.withValues(alpha: 0.05)
                        : Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      response!.success
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    response!.success ? 'Download Complete' : 'Download Failed',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: response!.success ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (response!.message != null) Text(response!.message!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
