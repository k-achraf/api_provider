import 'package:easy_api_provider/easy_api_provider.dart';
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
class ApiProviderController extends ChangeNotifier {
  /// The current status of the API.
  ApiProviderStatus _status = ApiProviderStatus.idle;

  /// The current status of the API.
  ApiProviderStatus get status => _status;

  /// The API response associated with the current status, if any.
  ApiResponse? response;

  /// Updates the current status and notifies listeners.
  void _setStatus(ApiProviderStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  /// Sets the status to [ApiProviderStatus.idle].
  void idle() => _setStatus(ApiProviderStatus.idle);

  /// Sets the status to [ApiProviderStatus.loading].
  void loading() => _setStatus(ApiProviderStatus.loading);

  /// Sets the status to [ApiProviderStatus.success] and stores the response.
  void success({ApiResponse? apiResponse}) {
    response = apiResponse;
    _setStatus(ApiProviderStatus.success);
  }

  /// Sets the status to [ApiProviderStatus.error] and stores the response.
  void error({ApiResponse? apiResponse}) {
    response = apiResponse;
    _setStatus(ApiProviderStatus.error);
  }

  /// Sets the status to [ApiProviderStatus.empty].
  void empty() => _setStatus(ApiProviderStatus.empty);

  /// Attaches a listener to be called whenever the status changes.
  ///
  /// The [callback] receives the current status whenever it changes.
  void listen(ApiProviderListener callback) {
    addListener(() {
      callback.call(status);
    });
  }
}
