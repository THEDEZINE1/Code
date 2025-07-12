// import 'dart:developer';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// //import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class FirebaseApi {
//   static final FirebaseApi _instance = FirebaseApi._internal();
//
//   factory FirebaseApi() => _instance;
//
//   FirebaseApi._internal();
//
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//
//   // Local notifications plugin
//   // static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//   // FlutterLocalNotificationsPlugin();
//
//   // Initialize local notifications
//   static Future<void> initializeLocalNotifications() async {
//     // const AndroidInitializationSettings initializationSettingsAndroid =
//     // AndroidInitializationSettings('logo'); // Android icon
//     //
//     // const IOSInitializationSettings initializationSettingsIOS =
//     // IOSInitializationSettings(
//     //   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
//     // );
//     //
//     // const InitializationSettings initializationSettings = InitializationSettings(
//     //   android: initializationSettingsAndroid,
//     //   iOS: initializationSettingsIOS,
//     // );
//
//     // await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
//     //     onSelectNotification: onSelectNotification);
//   }
//
//   // Handle when a local notification is tapped
//   static Future onSelectNotification(String? payload) async {
//     log('Notification clicked: $payload');
//     // Handle notification click action
//   }
//
//   // Handle iOS local notification
//   static Future onDidReceiveLocalNotification(
//       int id, String? title, String? body, String? payload) async {
//     log('iOS Local Notification Received: $title - $body');
//     // Show dialog or redirect
//   }
//
//   Future<void> init(BuildContext context) async {
//     // Initialize local notifications
//     await initializeLocalNotifications();
//
//     // Retrieve FCM token
//     /*fcmToken = await _fcm.getToken();
//     log('FCM Token: $fcmToken');*/
//
//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         // _showNotification(message);  // Display notification
//       }
//     });
//
//     // Handle background messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Handle notification tap when app is terminated
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleNotificationClick(context, message);
//       }
//     });
//
//     // Handle notification tap when app is in the background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNotificationClick(context, message);
//     });
//   }
//
//   // Show a local notification
//   // Future<void> _showNotification(RemoteMessage message) async {
//   //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   //   AndroidNotificationDetails(
//   //     /*'your_channel_id',
//   //     'your_channel_name',*/
//   //     'sourcing_sathi',
//   //     'sourcing_sathi',
//   //     importance: Importance.max,
//   //     priority: Priority.high,
//   //     icon: 'logo', // Custom Android icon
//   //     color: Color(0xFF4F8647), // Background color
//   //
//   //   );
//
//     const IOSNotificationDetails iosPlatformChannelSpecifics =
//     IOSNotificationDetails();
//
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );
//
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       platformChannelSpecifics,
//       payload: 'Notification Payload',
//     );
//   }
//
//   // Handle notification click
//   void _handleNotificationClick(BuildContext context, RemoteMessage message) {
//     final notificationData = message.data;
//     debugPrint('notificationData: ${notificationData.toString()}');
//
//     Navigator.of(context).pushNamed('/notification');
//   }
// }
//
// // Background message handler
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   debugPrint('Handling a background message: ${message.notification!.title}');
// }
//
// /*class FirebaseApi {
//   static String? fcmToken; // Variable to store the FCM token
//
//   static final FirebaseApi _instance = FirebaseApi._internal();
//
//   factory FirebaseApi() => _instance;
//
//   FirebaseApi._internal();
//
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//
//   Future<void> init(BuildContext context) async {
//     // Requesting permission for notifications
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     debugPrint('User granted notifications permission: ${settings.authorizationStatus}');
//
//     // Retrieving the FCM token
//     fcmToken = await _fcm.getToken();
//     log('fcmToken: $fcmToken');
//
//     // Handling background messages using the specified handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     // Listening for incoming messages while the app is in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('Got a message whilst in the foreground!');
//       debugPrint('Message data: ${message.notification!.title.toString()}');
//
//       if (message.notification != null) {
//         if (message.notification!.title != null &&
//             message.notification!.body != null) {
//           final notificationData = message.data;
//           debugPrint('notificationData: ${notificationData.toString()}');
//
//         }
//       }
//     });
//
//     // Handling the initial message received when the app is launched from dead (killed state)
//     // When the app is killed and a new notification arrives when user clicks on it
//     // It gets the data to which screen to open
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleNotificationClick(context, message);
//       }
//     });
//
//     // Handling a notification click event when the app is in the background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint(
//           'onMessageOpenedApp: ${message.notification!.title.toString()}');
//       _handleNotificationClick(context, message);
//     });
//   }
//
//   // Handling a notification click event by navigating to the specified screen
//   void _handleNotificationClick(BuildContext context, RemoteMessage message) {
//     final notificationData = message.data;
//     debugPrint('notificationData: ${notificationData.toString()}');
//
//     Navigator.of(context).pushNamed('/notification');
//
//     *//*if (notificationData.containsKey('screen')) {
//       final screen = notificationData['screen'];
//       Navigator.of(context).pushNamed(screen);
//     }*//*
//   }
// }
//
// // Handler for background messages
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   debugPrint('Handling a background message: ${message.notification!.title}');
// }*/
