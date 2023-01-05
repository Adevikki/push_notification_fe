import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:push_notification_fe/model/push_notification_model.dart';
import 'package:push_notification_fe/notification_badge.dart';
import 'package:push_notification_fe/widgets/textfield.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? mtoken = "";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _messaging;
  PushNotification? _notificationInfo;
  late int _totalNotifications;
  TextEditingController username = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController body = TextEditingController();

  @override
  void initState() {
    requestAndRegisterNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        _totalNotifications++;
      });
    });

    _totalNotifications = 0;
    super.initState();
    // requestPermission();
    // getToken();
    // initInfo();
  }

  // initInfo() {
  //   var androidInitialize =
  //       const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iOSInitialize = const DarwinInitializationSettings();
  //   var initializationsSettings = InitializationSettings( android: androidInitialize, iOS: iOSInitialize);
  // flutterLocalNotificationsPlugin.initialize(InitializationSettings()).then((value) async {
  //     if (value!.didNotificationLaunchApp) {
  //       if (value.notificationResponse?.payload != null) {
  //         // do something
  //       }
  // }}}

  // void getToken() async {
  //   await FirebaseMessaging.instance.getToken().then(
  //     (token) {
  //       setState(() {
  //         mtoken = token;
  //         print('My token is $mtoken');
  //       });
  //       saveToken(token!);
  //     },
  //   );
  // }

  // void saveToken(String token) async {
  //   await FirebaseFirestore.instance.collection('UserTokens').doc('User2').set({
  //     'token': token,
  //   });
  // }

  // void requestPermission() async {
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     print('User granted permission');
  //   } else if (settings.authorizationStatus ==
  //       AuthorizationStatus.provisional) {
  //     print('User granted provisional permission');
  //   } else {
  //     print('User declined or has not accept permission');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
              'App for capturing Firebase Push Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          NotificationBadge(
            totalNotifications: _totalNotifications,
          ),
          const SizedBox(height: 16.0),
          _notificationInfo != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITLE: ${_notificationInfo!.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'BODY: ${_notificationInfo!.body}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
      // body: Padding(
      //   padding: const EdgeInsets.all(20.0),
      //   child: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         AppTextField(
      //           controller: username,
      //         ),
      //         AppTextField(
      //           controller: title,
      //         ),
      //         AppTextField(
      //           controller: body,
      //         ),
      //         GestureDetector(
      //           onTap: () {
      //             String name = username.text.trim();
      //             String titleText = title.text;
      //             String bodyText = body.text;
      //           },
      //           child: Container(
      //             margin: const EdgeInsets.all(20),
      //             height: 40,
      //             width: 200,
      //             decoration: BoxDecoration(
      //               color: Colors.red,
      //               borderRadius: BorderRadius.circular(20),
      //               boxShadow: [
      //                 BoxShadow(
      //                   color: Colors.redAccent.withOpacity(0.5),
      //                 ),
      //               ],
      //             ),
      //             child: const Center(child: Text('Enter')),
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  void requestAndRegisterNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      String? token = await _messaging!.getToken();
      if (kDebugMode) {
        print("The token is ${token!}");
      }
      saveToken(token!);
      // For handling the received notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );

        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        showSimpleNotification(
          Text(_notificationInfo!.title!),
          leading: NotificationBadge(totalNotifications: _totalNotifications),
          subtitle: Text(_notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('UserTokens')
        .doc('User12')
        .set({
      'token': token,
    });
  }
}
