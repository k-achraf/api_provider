# easy_api_provider

[![pub package](https://img.shields.io/pub/v/easy_api_provider.svg)](https://pub.dev/packages/easy_api_provider)
[![pub points](https://img.shields.io/pub/points/easy_api_provider?color=2E8B57&label=pub%20points)](https://pub.dev/packages/easy_api_provider/score)

<div>
<a href="https://thebsd.github.io/StandWithPalestine/" target="_blank">
  <img src="https://raw.githubusercontent.com/Safouene1/support-palestine-banner/master/StandWithPalestine.svg"/>
</a>
</div>

<br /><br/>
A Flutter package providing a Dio-based HTTP client with built-in UI state management. Make API requests easily with automatic error handling and reactive UI updates.

## Features

- Simple and easy-to-use API request handling with Dio
- Customizable headers, timeouts, and query parameters
- Support for GET, POST, PUT, DELETE, PATCH, and DOWNLOAD
- Built-in UI state management (idle, loading, success, error, empty)
- Automatic request/response error handling — never throws exceptions
- Request/response logging with TalkerDioLogger
- Smooth animated transitions between UI states

## Requirements

- Dart SDK `>=3.0.0`
- Flutter >= 3.0.0

## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  easy_api_provider: ^2.0.0
```

Then, run:

```sh
flutter pub get
```

## Usage

### Import the package

```dart
import 'package:easy_api_provider/easy_api_provider.dart';
```

### Initialize the provider

```dart
void main() {
  ApiProvider.instance.init(ApiProviderConfig(
    'https://example.com/api',
    maxRedirects: 1,
    contentType: 'application/json',
    receiveTimeout: const Duration(seconds: 30),
    connectTimeout: const Duration(seconds: 30),
    responseType: ResponseType.json,
    headers: {
      'Accept': 'application/json'
    },
    onResponse: (Response response) {},
    onError: (DioException error) {},
    onRequest: (RequestOptions options) {},
    authorization: 'Bearer <Your bearer token>',
    extra: {
      'key': 'value'
    },
    listFormat: ListFormat.multi,
    requestLogger: true,
  ));
  runApp(const MyApp());
}
```

### Making a GET request

```dart
Future<void> fetchData() async {
  final ApiResponse response = await ApiProvider.instance.get(
    '/example',
    params: {
      'param1': 'value1',
    },
    progressCallback: (int c, int s) {},
    requestOptions: Options(),
  );

  if (response.success) {
    // Handle success
  } else {
    // Handle error
  }
}
```

### Making a POST request

```dart
Future<void> sendData() async {
  final ApiResponse response = await ApiProvider.instance.post(
    '/example',
    data: {'key': 'value'},
    params: {
      'param1': 'value1',
    },
    onSendProgress: (int c, int s) {},
    onReceiveProgress: (int c, int s) {},
    requestOptions: Options(),
  );
}
```

## ApiResponse Class

The `ApiResponse` class encapsulates the results of network requests executed using Dio.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `success` | `bool` | Whether the request was successful |
| `statusCode` | `int?` | HTTP status code (`200`, `400`, `500`, etc.) |
| `data` | `dynamic` | Response data on success, error details on failure |
| `url` | `String?` | The request URL |
| `message` | `String?` | Descriptive message for debugging |

## Using the UI Handler

The `ApiProviderUi` widget dynamically switches UI based on the API request status managed by `ApiProviderController`.

### States

| State | Description |
|-------|-------------|
| `idle` | Initial state before any API request |
| `loading` | Request is in progress |
| `success` | Request completed successfully |
| `error` | Request resulted in an error |
| `empty` | Successful response with no data |

### Setup

```dart
final controller = ApiProviderController();

ApiProviderUi(
  controller: controller,
  idleWidget: (context) => const IdleWidget(),
  loadingWidget: (context) => const LoadingWidget(),
  emptyWidget: (context) => const EmptyWidget(),
  successWidget: (context, response) => SuccessWidget(response),
  errorWidget: (context, response) => ErrorWidget(response),
)
```

### Manual state control

```dart
controller.idle();
controller.loading();
controller.empty();
controller.success();
controller.error();
```

### Listen for status changes

```dart
controller.listen((ApiProviderStatus status) {
  // ApiProviderStatus.idle, .loading, .success, .error, .empty
});
```

### Automatic state management

Pass a `controller` to any request method and the state is managed automatically:

```dart
final ApiResponse response = await ApiProvider.instance.get(
  '/users',
  controller: controller,
);
```

This automatically:
- Sets **loading** state before sending the request
- Sets **success** state with the `ApiResponse` on success
- Sets **error** state with the `ApiResponse` on failure

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This package is released under the MIT License. See [LICENSE](LICENSE) for details.
