import 'package:app_news/screens/common/splash_screen.dart';
import 'package:app_news/services/notification_service.dart';
import 'package:app_news/utils/helper/hive_box.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Affiche le token FCM (utile pour debug ou tests manuels)
  final apnsToken = await firebaseMessaging.getAPNSToken();
  if (apnsToken != null) {
    firebaseMessaging.getToken().then(debugPrint);
  } else {
    debugPrint('APNS token non disponible (simulateur ou refus utilisateur)');
  }

  // Hive
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  HiveBoxes.init();

  // NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "TCHAD NEWS",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
