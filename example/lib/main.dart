import 'package:easy_api_provider/easy_api_provider.dart';
import 'package:flutter/material.dart';

void main() {
  ApiProvider.instance.init(
    ApiProviderConfig(
      'https://api.sampleapis.com',
      maxRedirects: 1,
      contentType: 'application/json',
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      onResponse: (response) {},
      onError: (error) {},
      onRequest: (options) {},
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
      debugShowCheckedModeBanner: false,
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
  ApiProviderController controller = ApiProviderController();

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
            ApiProviderUi(controller: controller),
            ElevatedButton(
              child: Text('Get data'),
              onPressed: () async {
                final ApiResponse response = await ApiProvider.instance.get(
                  '/avatar/info',
                  params: {'param': 'value'},
                  controller: controller,
                );

                if (response.success) {
                } else {}
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: Text('Send data'),
              onPressed: () async {
                final ApiResponse response = await ApiProvider.instance.post(
                  '/example',
                  data: {'key': 'value'},
                  controller: controller,
                );

                if (response.success) {
                } else {}
              },
            ),
          ],
        ),
      ),
    );
  }
}
