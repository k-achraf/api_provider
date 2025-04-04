# api_provider

[![pub package](https://img.shields.io/pub/v/easy_api_provider.svg)](https://pub.dev/packages/easy_api_provider)
[![pub points](https://img.shields.io/pub/points/easy_api_provider?color=2E8B57&label=pub%20points)](https://pub.dev/packages/easy_api_provider/score)

<a href="https://thebsd.github.io/StandWithPalestine/" target="_blank">
  <img src="https://raw.githubusercontent.com/Safouene1/support-palestine-banner/master/StandWithPalestine.svg"/>
</a>
A Flutter package for making API requests easily with built-in caching, request retries, and error handling.

## Features

- Simple and easy-to-use API request handling
- Automatic caching for responses
- Request retries with exponential backoff
- Customizable headers and query parameters
- Support for GET, POST, PUT, DELETE, PATCH, DOWNLOAD and more

## Installation

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  api_provider: 1.0.0
```

Then, run:

```sh
flutter pub get
```

## Usage

### Import the package

```dart
import 'package:api_provider/easy_api_provider.dart';
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
    onResponse: (Response response){

    },
    onError: (DioException error){

    },
    onRequest: (RequestOptions options){

    },
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
      cancelToken: cancelToken,
      params: {
        'param1': 'value1',
      },
      progressCallback: (int c, int s){
    
      },
      requestOptions: Options()
  );
}
```

### Making a POST request

```dart
Future<void> sendData() async {
  final ApiResponse response = await ApiProvider.instance.post(
      '/example',
      cancelToken: cancelToken,
      params: {
        'param1': 'value1',
      },
      onSendProgress: (int c, int s){

      },
      onReceiveProgress: (int c, int s){

      },
      data: {
        'key': 'value'
      },
      requestOptions: Options()
  );
}
```

## **ApiResponse Class**
### **Description**
The `ApiResponse` class is used to encapsulate the results of network requests executed using Dio. It provides details about the success or failure of the request, retrieved data, and HTTP status code.

### **Properties:**
- `success` _(bool)_: Indicates whether the request was successful (`true`) or failed (`false`).
- `statusCode` _(int?)_: The HTTP response status code (`200`, `400`, `500`, etc.).
- `data` _(dynamic)_:
    - Contains the retrieved data when the request is successful (`response.data`).
    - Contains error details when the request fails (`error.response?.data`).
- `url` _(String?)_: The request URL.
- `message` _(String?)_: A descriptive message for debugging or logging purposes.

## **Using The UI Handler**
## Description
The `ApiProviderUi` is a widget that dynamically different UI states based on the API request status managed by `ApiProviderController`. it provides a structured way to handle various api states including:
- `idle`: The initial state before an API request is made
- `loading`: Displays a loading indicator or custom widget while the request is in progress
- `success`: shows the successful widget with response data
- `error`: displays the error widget with error data
- `empty`: shown when success response with empty data
- 
## How To Use
```dart
ApiProviderController controller = ApiProviderController();

ApiProviderUi(
  controller: controller,
  idleWidget: (context) => IdleWidget(),
  loadingWidget: (context) => LoadingWidget(),
  emptyWidget: (context) => EmptyWidget(),
  successWidget: (context, ApiResponse? response) => SuccessWidget(response),
  errorWidget: (context, ApiResponse? response) => ErrorWidget(response),
),
```

Then you can handle Ui states using controller:
```dart
controller.idle();
controller.loading();
controller.empty();
controller.success();
controller.error();
```

You can listen for status:
```dart
controller.listen((ApiProviderStatus status){
  print(status) //ApiProviderStatus.idle, ApiProviderStatus.loading, ApiProviderStatus.success, ApiProviderStatus.error, ApiProviderStatus.empty
});
```

## Handle api request, response automatically
You can automatically handle api request, response status by pass the controller to your request like this:
```dart
final ApiResponse response = await ApiProvider.instance.get(
  '/avatar/info',
  params: {'param': 'value'},
  controller: controller
);
```
So here the `ApiProvider` will handle the states for you
- Set the loading state before send the request
- Set the success state when receive success response and pass the `ApiResponse`
- Set the error state when receive error response and pass the `ApiResponse`

## Contributing
Contributions are welcome! Feel free to open issues or submit pull requests.

## License

This package is released under the MIT License. See [LICENSE](LICENSE) for details.
