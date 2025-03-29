import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

void main() {
  ApiProvider.instance.init(
    ApiProviderConfig(
      'https://example.com/api',
      maxRedirects: 1,
      contentType: 'application/json',
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      onResponse: (response) {
        print(response);
      },
      onError: (error) {
        print(error);
      },
      onRequest: (options) {
        print(options);
      },
      authorization: 'Bearer <Your bearer token>',
      extra: {'key': 'value'},
      requestLogger: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Api Handler Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Get data'),
              onPressed: () async {
                final ApiResponse response = await ApiProvider.instance.get(
                  '/example',
                  params: {'param': 'value'},
                );

                if (response.success) {
                  print('Success response');
                  print(response.data);
                } else {
                  print('Error response');
                  print(response.data);
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: Text('Send data'),
              onPressed: () async {
                final ApiResponse response = await ApiProvider.instance.post(
                  '/example',
                  data: {'key': 'value'},
                );

                if (response.success) {
                  print('Success response');
                  print(response.data);
                } else {
                  print('Error response');
                  print(response.data);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
