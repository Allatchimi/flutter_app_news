import 'dart:async';

import 'package:app_news/screens/home_screen.dart';
import 'package:app_news/screens/onboarding_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/app_constants.dart';
import 'package:app_news/utils/helper/data_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  DataHandler dataHandler = DataHandler();

  String doneOnboarding = "";
  String setdoneOnboarding = "";

  void readData() async {
    doneOnboarding = await dataHandler.getStringValue(
      AppConstants.doneOnboarding,
    );

    setState(() {
      setdoneOnboarding = doneOnboarding;
    });
  }

  @override
  void initState() {
    super.initState();
    readData();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => setdoneOnboarding == "true"
              ? HomeScreen()
              : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to TCHAD NEWS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 100),
            //CircularProgressIndicator(),
            CupertinoActivityIndicator(),
          ],
        ),
      ),
    );
  }
}
