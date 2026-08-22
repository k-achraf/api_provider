import 'package:example/screens/auth_screen.dart';
import 'package:example/screens/create_post_screen.dart';
import 'package:example/screens/delete_post_screen.dart';
import 'package:example/screens/download_screen.dart';
import 'package:example/screens/edit_post_screen.dart';
import 'package:example/screens/get_posts_screen.dart';
import 'package:example/screens/interceptors_screen.dart';
import 'package:example/screens/post_detail_screen.dart';
import 'package:example/widgets/feature_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('easy_api_provider'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Explore all features',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Each screen demonstrates a different feature using DummyJSON API.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              FeatureCard(
                title: 'GET & UI States',
                subtitle:
                    'ApiProviderUi with idle, loading, success, error, empty',
                icon: Icons.list_alt,
                color: Colors.blue,
                onTap: () => _push(context, const GetPostsScreen()),
              ),
              FeatureCard(
                title: 'GET Detail',
                subtitle: 'Single resource with query parameters',
                icon: Icons.article,
                color: Colors.teal,
                onTap: () => _push(context, const PostDetailScreen()),
              ),
              FeatureCard(
                title: 'POST Create',
                subtitle: 'Create a new post with request body',
                icon: Icons.add_circle,
                color: Colors.green,
                onTap: () => _push(context, const CreatePostScreen()),
              ),
              FeatureCard(
                title: 'PUT & PATCH',
                subtitle: 'Full and partial update comparison',
                icon: Icons.edit,
                color: Colors.orange,
                onTap: () => _push(context, const EditPostScreen()),
              ),
              FeatureCard(
                title: 'DELETE',
                subtitle: 'Delete with confirmation dialog',
                icon: Icons.delete,
                color: Colors.red,
                onTap: () => _push(context, const DeletePostScreen()),
              ),
              FeatureCard(
                title: 'Download',
                subtitle: 'File download with progress tracking',
                icon: Icons.download,
                color: Colors.purple,
                onTap: () => _push(context, const DownloadScreen()),
              ),
              FeatureCard(
                title: 'Interceptors',
                subtitle: 'onRequest, onResponse, onError callbacks',
                icon: Icons.settings_ethernet,
                color: Colors.brown,
                onTap: () => _push(context, const InterceptorsScreen()),
              ),
              FeatureCard(
                title: 'Auth & Config',
                subtitle: 'setAuthorisation, setBaseUrl, CancelToken',
                icon: Icons.admin_panel_settings,
                color: Colors.indigo,
                onTap: () => _push(context, const AuthScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
