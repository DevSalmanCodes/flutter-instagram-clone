// ignore_for_file: unused_local_variable

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/screens/comment_screen.dart';

import 'channels/notification_channels.dart';

class NotificationServices {
  NotficationChannels notficationChannels = NotficationChannels();
  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  void initilize() {
    firebaseInit();
    handleState();
  }

  Future<String?> getToken() async {
    return await messaging.getToken();
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      badge: true,
      alert: true,
      carPlay: true,
      provisional: true,
    );
  }

  firebaseInit() async {
    FirebaseMessaging.onMessage.listen((message) {
      initLocalNotification();

      if (message.data['android_channel_id'] == 'comments_channel') {
        notficationChannels.showCommentNotification(message);
      } else {
        notficationChannels.showPostNotification(message);
      }
      handleMessage(message);
    });
  }

  Future<void> handleState() async {
    FirebaseMessaging.onBackgroundMessage((message) async {
      handleMessage(message);
    });
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(message);
    });
  }

  Future<void> initLocalNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: darwinInitializationSettings);

    await localNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  handleMessage(RemoteMessage message) async {
    try {
      if (message.data.isNotEmpty && message.data.containsKey('postId')) {
        final postId = message.data['postId'];
        if (message.data.containsKey('collection') &&
            message.data['collection'] == 'reels') {
          Get.to(() => CommentScreen(
              postId: postId, collection: FirestoreConstants.reelCollection));
        } else {
          Get.to(() => CommentScreen(
              postId: postId, collection: FirestoreConstants.postsCollection));
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
