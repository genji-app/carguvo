import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DefaultSplashScreen extends StatelessWidget {
  const DefaultSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CupertinoActivityIndicator(
          radius: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
