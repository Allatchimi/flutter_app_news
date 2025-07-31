import 'package:app_news/screens/splash_screen.dart';
import 'package:app_news/services/notification_service.dart';
import 'package:app_news/utils/helper/hive_box.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

// Déclare cette clé globalement
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  // Initialisation Firebase
  await Firebase.initializeApp();
    // Affiche le token FCM dans la console
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    FirebaseMessaging.instance.getToken().then(print);
  } else {
    print('APNS token non disponible (simulateur ou refus utilisateur)');
  }
    
    // service notifiction initialisation 
    final notificationService = NotificationService();
    await notificationService.initialize();


    // Configuration des notifications
  const AndroidInitializationSettings androidSettings = 
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = 
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    ),
  );

  // Initialisation Hive
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  HiveBoxes.init();  

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