import 'package:expense_tracker/core/constants/firebase.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fireAuth.currentUser != null) {
        context.push('/home', extra: {'isSignup': true});
      } else {
        context.push('/loginAndSignup', extra: {'isSignup': false});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'My App',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
