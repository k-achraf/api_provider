import 'package:dio/dio.dart';
import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/widgets/response_viewer.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  ApiResponse? response;
  bool loading = false;
  String currentAuth = 'None';
  CancelToken? activeToken;

  void _setAuth(String token) {
    ApiProvider.instance.setAuthorisation(token);
    setState(() => currentAuth = token);
  }

  void _clearAuth() {
    ApiProvider.instance.setAuthorisation(null);
    setState(() => currentAuth = 'None');
  }

  void _changeBaseUrl() {
    ApiProvider.instance.setBaseUrl('https://dummyjson.com');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base URL reset to dummyjson.com')),
    );
  }

  Future<void> _fetchWithCancel() async {
    activeToken?.cancel('New request started');
    activeToken = CancelToken();

    setState(() => loading = true);
    final result = await ApiProvider.instance.get(
      '/posts',
      params: {'limit': '5'},
      cancelToken: activeToken,
    );
    setState(() {
      response = result;
      loading = false;
    });
  }

  void _cancelRequest() {
    activeToken?.cancel('Cancelled by user');
    setState(() {
      loading = false;
      response = ApiResponse(
        success: false,
        message: 'Request cancelled by user',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth & Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Auth section
          Text(
            'Authorization Header',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Current: $currentAuth',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: () => _setAuth('Bearer my_token_123'),
                child: const Text('Set Bearer Token'),
              ),
              OutlinedButton(
                onPressed: _clearAuth,
                child: const Text('Clear Auth'),
              ),
              OutlinedButton(
                onPressed: () => _setAuth('Basic dXNlcjpwYXNz'),
                child: const Text('Set Basic Auth'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Base URL section
          Text('Base URL', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Change the base URL at runtime with setBaseUrl()',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _changeBaseUrl,
            child: const Text('Reset to DummyJSON'),
          ),
          const SizedBox(height: 24),

          // Cancel token section
          Text('Cancel Token', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Cancel an in-flight request using CancelToken',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: loading ? null : _fetchWithCancel,
                  child: const Text('Send GET'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? _cancelRequest : null,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
          if (loading) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(),
          ],
          if (response != null) ...[
            const SizedBox(height: 24),
            ResponseViewer(response: response!),
          ],
        ],
      ),
    );
  }
}
