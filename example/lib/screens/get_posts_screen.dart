import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

class GetPostsScreen extends StatefulWidget {
  const GetPostsScreen({super.key});

  @override
  State<GetPostsScreen> createState() => _GetPostsScreenState();
}

class _GetPostsScreenState extends State<GetPostsScreen> {
  final controller = ApiProviderController();
  int limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  void _fetchPosts() {
    ApiProvider.instance.get(
      '/posts',
      params: {'limit': '$limit'},
      controller: controller,
    );
  }

  List<dynamic> _extractPosts(ApiResponse? response) {
    final data = response?.data;
    if (data is Map) return data['posts'] as List? ?? [];
    if (data is List) return data;
    return [];
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GET & UI States')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text('Limit: $limit', style: Theme.of(context).textTheme.titleSmall),
                Expanded(
                  child: Slider(
                    value: limit.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '$limit',
                    onChanged: (v) => setState(() => limit = v.toInt()),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _fetchPosts,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Fetch'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Empty result'),
                  onPressed: () {
                    ApiProvider.instance.get(
                      '/posts',
                      params: {'limit': '0', 'skip': '999'},
                      controller: controller,
                    );
                  },
                ),
                ActionChip(
                  label: const Text('Trigger error'),
                  onPressed: () {
                    ApiProvider.instance.get(
                      '/nonexistent-endpoint',
                      controller: controller,
                    );
                  },
                ),
                ActionChip(
                  label: const Text('Reset to idle'),
                  onPressed: () => controller.idle(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ApiProviderUi(
              controller: controller,
              idleWidget: (_) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Press Fetch to load posts'),
                  ],
                ),
              ),
              loadingWidget: (_) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading posts...'),
                  ],
                ),
              ),
              successWidget: (_, response) {
                final posts = _extractPosts(response);
                if (posts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No posts found'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (_, i) {
                    final post = posts[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text('${post['id']}'),
                      ),
                      title: Text(
                        post['title'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        post['body'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
              errorWidget: (_, response) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(response?.message ?? 'Unknown error'),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _fetchPosts, child: const Text('Retry')),
                  ],
                ),
              ),
              emptyWidget: (_) => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No posts found'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
