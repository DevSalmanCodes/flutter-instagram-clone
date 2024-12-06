import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotficationChannels {

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Comment Channel

  Future<void> showCommentNotification(RemoteMessage message) async {
    final channelId = 'comments_channel';
    AndroidNotificationChannel commentChannel = AndroidNotificationChannel(
        channelId, 'Comments',
        importance: Importance.max);
    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(commentChannel);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelId, commentChannel.name,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            ticker: 'ticker',
            importance: Importance.high);
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await localNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails);
  }

//  Post Channel

  Future<void> showPostNotification(RemoteMessage message) async {
    final postChannelId = 'posts_channel';
    final postChannelName = 'Posts';
    AndroidNotificationChannel poststChannel = AndroidNotificationChannel(
        postChannelId, postChannelName,
        importance: Importance.max);
    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(poststChannel);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(postChannelId, poststChannel.name,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
            ticker: 'ticker',
            importance: Importance.high);
    DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    await localNotificationsPlugin.show(
        0,
        message.notification!.title.toString(),
        message.notification!.body.toString(),
        notificationDetails);
  }
}
