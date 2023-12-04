part of 'main.dart';

late FirebaseMessaging _messaging;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationSettings settings = await _messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  InitializationSettings initializationSettings =
      const InitializationSettings();
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  String notificationMessage = '';
  if (notification != null) {
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(notification.body!);
    } catch (error) {
      log('exception parsing notification body: ${error.toString()}');
    }

    if (json != null) {
      AlertModel alert = AlertModel.fromJson(json);
      notificationMessage =
          '${alert.variable.tr()} ${_getCondition(alert.condition)} ${alert.value}';
    } else {
      notificationMessage = notification.body!;
    }
  }
}

String _getCondition(String condition) {
  switch (condition) {
    case 'greater':
      return ' > ';
    case 'greaterEqual':
      return ' >= ';
    case 'equal':
      return ' = ';
    case 'notEqual':
      return ' != ';
    case 'lesser':
      return ' < ';
    case 'lesserEqual':
      return ' <= ';
    default:
      return '';
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
