import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/widgets/response_viewer.dart';
import 'package:flutter/material.dart';

class InterceptorsScreen extends StatefulWidget {
  const InterceptorsScreen({super.key});

  @override
  State<InterceptorsScreen> createState() => _InterceptorsScreenState();
}

class _InterceptorsScreenState extends State<InterceptorsScreen> {
  final List<String> logs = [];
  ApiResponse? response;
  bool loading = false;

  void _log(String entry) {
    setState(() {
      logs.insert(
        0,
        '${DateTime.now().toLocal().toString().substring(11, 23)} $entry',
      );
      if (logs.length > 20) logs.removeLast();
    });
  }

  Future<void> _sendRequest() async {
    logs.clear();
    _log('>>> Re-initializing ApiProvider with interceptors...');

    ApiProvider.instance.init(
      ApiProviderConfig(
        'https://dummyjson.com',
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
        requestLogger: false,
        onRequest: (options) {
          _log('REQUEST: ${options.method} ${options.path}');
        },
        onResponse: (res) {
          _log('RESPONSE: ${res.statusCode} — ${res.data.runtimeType}');
        },
        onError: (error) {
          _log('ERROR: ${error.type} — ${error.message}');
        },
      ),
    );

    setState(() => loading = true);
    final result = await ApiProvider.instance.get('/posts/1');
    setState(() {
      response = result;
      loading = false;
    });
  }

  Future<void> _sendErrorRequest() async {
    logs.clear();
    _log('>>> Re-initializing ApiProvider with interceptors...');

    ApiProvider.instance.init(
      ApiProviderConfig(
        'https://dummyjson.com',
        contentType: 'application/json',
        headers: {'Accept': 'application/json'},
        requestLogger: false,
        onRequest: (options) {
          _log('REQUEST: ${options.method} ${options.path}');
        },
        onResponse: (res) {
          _log('RESPONSE: ${res.statusCode}');
        },
        onError: (error) {
          _log('ERROR: ${error.type} — ${error.message}');
        },
      ),
    );

    setState(() => loading = true);
    final result = await ApiProvider.instance.get('/nonexistent');
    setState(() {
      response = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interceptors')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'See onRequest, onResponse, and onError in action',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: loading ? null : _sendRequest,
                  child: const Text('GET /posts/1'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : _sendErrorRequest,
                  child: const Text('GET /nonexistent'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Interceptor Log:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child:
                logs.isEmpty
                    ? const Text(
                      'No logs yet. Send a request above.',
                      style: TextStyle(color: Colors.grey),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: logs.length,
                      itemBuilder:
                          (_, i) => Text(
                            logs[i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                    ),
          ),
          if (response != null) ...[
            const SizedBox(height: 16),
            ResponseViewer(response: response!),
          ],
        ],
      ),
    );
  }
}
