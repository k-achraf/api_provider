import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/widgets/response_viewer.dart';
import 'package:flutter/material.dart';

class DeletePostScreen extends StatefulWidget {
  const DeletePostScreen({super.key});

  @override
  State<DeletePostScreen> createState() => _DeletePostScreenState();
}

class _DeletePostScreenState extends State<DeletePostScreen> {
  ApiResponse? response;
  bool loading = false;
  int postId = 1;

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text('Delete post #$postId?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => loading = true);
    final result = await ApiProvider.instance.delete('/posts/$postId');
    setState(() {
      response = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DELETE')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Delete a post with confirmation',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Post ID:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<int>(
                  initialValue: postId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: List.generate(
                    10,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                  ),
                  onChanged: (v) => setState(() => postId = v ?? 1),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: loading ? null : _deletePost,
                icon:
                    loading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.delete, size: 18),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                label: const Text('DELETE'),
              ),
            ],
          ),
          if (response != null) ...[
            const SizedBox(height: 24),
            ResponseViewer(response: response!),
          ],
        ],
      ),
    );
  }
}
