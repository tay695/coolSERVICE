import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showLocalNotification(message);
}

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configura handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Configura notificações locais
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Permissão
    await FirebaseMessaging.instance.requestPermission();

    // Handler de foreground
    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(message);
    });
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'os_channel',
      'Ordens de Serviço',
      channelDescription: 'Notificações de novas ordens de serviço',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      message.notification?.title ?? 'Nova OS',
      message.notification?.body ?? 'Você recebeu uma nova ordem de serviço',
      details,
    );
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }
  static Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
}) async {

  const androidDetails = AndroidNotificationDetails(
    'os_channel',
    'Ordens de Serviço',
    channelDescription: 'Notificações de novas ordens de serviço',
    importance: Importance.high,
    priority: Priority.high,
  );
  const details = NotificationDetails(android: androidDetails);

  await _localNotifications.show(
    1,
    title,
    body,
    details,
  );
}
}