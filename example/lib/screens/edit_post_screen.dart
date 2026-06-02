import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/widgets/response_viewer.dart';
import 'package:flutter/material.dart';

class EditPostScreen extends StatefulWidget {
  const EditPostScreen({super.key});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _titleController = TextEditingController(text: 'Updated Title');
  final _bodyController = TextEditingController(text: 'Updated body content.');
  int postId = 1;

  ApiResponse? putResponse;
  ApiResponse? patchResponse;
  bool putLoading = false;
  bool patchLoading = false;

  Future<void> _putUpdate() async {
    setState(() => putLoading = true);
    final result = await ApiProvider.instance.put(
      '/posts/$postId',
      data: {
        'id': postId,
        'title': _titleController.text,
        'body': _bodyController.text,
        'userId': 1,
      },
    );
    setState(() {
      putResponse = result;
      putLoading = false;
    });
  }

  Future<void> _patchUpdate() async {
    setState(() => patchLoading = true);
    final result = await ApiProvider.instance.patch(
      '/posts/$postId',
      data: {
        'title': _titleController.text,
      },
    );
    setState(() {
      patchResponse = result;
      patchLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PUT & PATCH')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Compare PUT (full update) vs PATCH (partial update)',
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
                  items: List.generate(10, (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1}'),
                  )),
                  onChanged: (v) => setState(() => postId = v ?? 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Body',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: putLoading ? null : _putUpdate,
                  icon: putLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload, size: 16),
                  label: const Text('PUT'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: patchLoading ? null : _patchUpdate,
                  icon: patchLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit, size: 16),
                  label: const Text('PATCH'),
                ),
              ),
            ],
          ),
          if (putResponse != null) ...[
            const SizedBox(height: 16),
            Text('PUT Response:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ResponseViewer(response: putResponse!),
          ],
          if (patchResponse != null) ...[
            const SizedBox(height: 16),
            Text('PATCH Response:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ResponseViewer(response: patchResponse!),
          ],
        ],
      ),
    );
  }
}
