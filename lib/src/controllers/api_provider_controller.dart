import 'package:easy_api_provider/src/models/api_response.dart';
import 'package:flutter/material.dart';

/// A callback signature for listening to [ApiProviderStatus] changes.
typedef ApiProviderListener = void Function(ApiProviderStatus status);

/// Represents the current status of an API operation.
enum ApiProviderStatus {
  /// No API operation is currently happening.
  idle,

  /// An API request is in progress.
  loading,

  /// The API request completed successfully.
  success,

  /// The API request resulted in an error.
  error,

  /// The API response was successful but contains no data.
  empty,
}

/// A controller that manages and notifies about changes in [ApiProviderStatus].
///
/// It is intended to be used with UI components to reflect API request states
/// such as loading, success, error, etc.
///
/// ### Example
///
/// ```dart
/// final controller = ApiProviderController();
///
/// // Use with ApiProvider:
/// ApiProvider.instance.get('/posts', controller: controller);
///
/// // Use with ApiProviderUi:
/// ApiProviderUi(
///   controller: controller,
///   successWidget: (context, response) => Text('${response?.data}'),
/// );
/// ```
class ApiProviderController extends ChangeNotifier {
  /// Creates a new [ApiProviderController] with an initial
  /// [ApiProviderStatus.idle] state.
  ApiProviderController();

  ApiProviderStatus _status = ApiProviderStatus.idle;
  ApiProviderStatus? _previousStatus;

  // P2: maps each public callback to its anonymous wrapper so we can remove it
  final _wrappedListeners = <ApiProviderListener, VoidCallback>{};

  /// The current status of the API.
  ApiProviderStatus get status => _status;

  /// The status immediately before the current one.
  ///
  /// Useful for conditional UI — e.g., showing a "previously loaded" state
  /// while a refresh is in progress.
  ApiProviderStatus? get previousStatus => _previousStatus;

  /// The API response associated with the current status, if any.
  ApiResponse? response;

  // ── Convenience getters ──────────────────────────────────────────────────

  /// Whether the controller is currently in the [ApiProviderStatus.loading] state.
  bool get isLoading => _status == ApiProviderStatus.loading;

  /// Whether the controller is currently in the [ApiProviderStatus.success] state.
  bool get isSuccess => _status == ApiProviderStatus.success;

  /// Whether the controller is currently in the [ApiProviderStatus.error] state.
  bool get isError => _status == ApiProviderStatus.error;

  /// Whether the controller is currently in the [ApiProviderStatus.empty] state.
  bool get isEmpty => _status == ApiProviderStatus.empty;

  /// Whether the controller is currently in the [ApiProviderStatus.idle] state.
  bool get isIdle => _status == ApiProviderStatus.idle;

  // ── State transitions ────────────────────────────────────────────────────

  /// Updates the current status and notifies listeners.
  void _setStatus(ApiProviderStatus newStatus) {
    _previousStatus = _status;
    _status = newStatus;
    notifyListeners();
  }

  /// Sets the status to [ApiProviderStatus.idle].
  void idle() => _setStatus(ApiProviderStatus.idle);

  /// Sets the status to [ApiProviderStatus.loading].
  void loading() => _setStatus(ApiProviderStatus.loading);

  /// Sets the status to [ApiProviderStatus.success] and stores the response.
  ///
  /// Automatically transitions to [ApiProviderStatus.empty] if [apiResponse]
  /// has no data (i.e. `data` is `null` or an empty [List] / [Map]).
  void success({ApiResponse? apiResponse}) {
    response = apiResponse;
    final data = apiResponse?.data;
    final hasData = data != null &&
        (data is! List || data.isNotEmpty) &&
        (data is! Map || data.isNotEmpty);
    _setStatus(hasData ? ApiProviderStatus.success : ApiProviderStatus.empty);
  }

  /// Sets the status to [ApiProviderStatus.error] and stores the response.
  void error({ApiResponse? apiResponse}) {
    response = apiResponse;
    _setStatus(ApiProviderStatus.error);
  }

  /// Sets the status to [ApiProviderStatus.empty].
  void empty() => _setStatus(ApiProviderStatus.empty);

  /// Resets the controller to [ApiProviderStatus.idle] and clears the
  /// stored [response].
  ///
  /// Useful for clearing state before a fresh request or on screen disposal.
  void reset() {
    response = null;
    _setStatus(ApiProviderStatus.idle);
  }

  // ── Listener management ──────────────────────────────────────────────────

  /// Attaches a listener to be called whenever the status changes.
  ///
  /// The [callback] receives the current [ApiProviderStatus] on every change.
  ///
  /// Calling [listen] with the same [callback] more than once is a no-op —
  /// the callback will only be registered once.
  ///
  /// Use [unlisten] to remove the callback when it is no longer needed.
  void listen(ApiProviderListener callback) {
    if (_wrappedListeners.containsKey(callback)) return;
    void wrapper() => callback(status);
    _wrappedListeners[callback] = wrapper;
    addListener(wrapper);
  }

  /// Removes a listener previously registered with [listen].
  ///
  /// If [callback] was not registered, this is a no-op.
  void unlisten(ApiProviderListener callback) {
    final wrapper = _wrappedListeners.remove(callback);
    if (wrapper != null) removeListener(wrapper);
  }

  @override
  void dispose() {
    _wrappedListeners.clear();
    super.dispose();
  }
}
