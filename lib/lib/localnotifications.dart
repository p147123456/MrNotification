import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifications{
  static final LocalNotifications instance = LocalNotifications._internal();
  factory LocalNotifications() {
    return instance;
  }
  LocalNotifications._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  LocalNotificationsListener _localNotificationsListener;

  init(){
    flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification:  (String payload) async {
          if (payload != null) {
            if(_localNotificationsListener!=null)
              _localNotificationsListener.onEnter();
          }
        });
  }
  setListener(LocalNotificationsListener listener){
    _localNotificationsListener = listener;
  }
  show(String title,String content) async{
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.max,importance: Importance.max
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, title, content, platform,
        payload: 'onEnter');
  }
}

class LocalNotificationsListener{
  void onEnter(){}
}
