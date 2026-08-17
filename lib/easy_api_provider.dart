/// A Flutter package providing a Dio-based API client with automatic state
/// management, error handling, request logging, file downloads, and reactive
/// UI widgets.
///
/// ## Getting Started
///
/// Initialize the provider once (e.g., in `main.dart`):
///
/// ```dart
/// ApiProvider.instance.init(
///   ApiProviderConfig('https://api.example.com'),
/// );
/// ```
///
/// Then use [ApiProvider] to make requests and [ApiProviderController] +
/// [ApiProviderUi] to react to state changes in your widgets.
library;

export 'src/models/api_response.dart';
export 'src/models/api_provider_config.dart';
export 'src/resources/api_provider.dart';
export 'src/resources/api_provider_ui.dart';
export 'src/controllers/api_provider_controller.dart';
