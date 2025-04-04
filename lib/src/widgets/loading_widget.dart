import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularProgressIndicator(
          backgroundColor: Theme.of(context).canvasColor,
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 20,),
        Text('Data loading ...'),
      ],
    );
  }
}
