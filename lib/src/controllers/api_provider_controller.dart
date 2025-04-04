import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

typedef ApiProviderListener = void Function(ApiProviderStatus status);
enum ApiProviderStatus {
  idle,
  loading,
  success,
  error,
  empty,
}

class ApiProviderController extends ChangeNotifier {
  ApiProviderStatus _status = ApiProviderStatus.idle;

  ApiProviderStatus get status => _status;
  ApiResponse? response;

  void _setStatus(ApiProviderStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void idle() => _setStatus(ApiProviderStatus.idle);
  void loading() => _setStatus(ApiProviderStatus.loading);
  void success({ApiResponse? apiResponse}){
    response = apiResponse;
    _setStatus(ApiProviderStatus.success);
  }
  void error({ApiResponse? apiResponse}){
    response = apiResponse;
    _setStatus(ApiProviderStatus.error);
  }
  void empty() => _setStatus(ApiProviderStatus.empty);

  void listen(ApiProviderListener callback){
    addListener((){
      callback.call(status);
    });
  }
}
