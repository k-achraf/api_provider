import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:example/widgets/response_viewer.dart';
import 'package:flutter/material.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  ApiResponse? response;
  bool loading = false;
  int postId = 1;

  Future<void> _fetchPost() async {
    setState(() => loading = true);
    final result = await ApiProvider.instance.get('/posts/$postId');
    setState(() {
      response = result;
      loading = false;
    });
  }

  Future<void> _fetchWithParams() async {
    setState(() => loading = true);
    final result = await ApiProvider.instance.get(
      '/posts',
      params: {'limit': '3', 'skip': '0'},
    );
    setState(() {
      response = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GET Detail & Params')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Fetch a single post by ID',
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
              FilledButton(
                onPressed: loading ? null : _fetchPost,
                child: const Text('GET /posts/{id}'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: loading ? null : _fetchWithParams,
              child: const Text('GET /posts?limit=3&skip=0'),
            ),
          ),
          const SizedBox(height: 24),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (response != null)
            ResponseViewer(response: response!),
        ],
      ),
    );
  }
}
