import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

// reference:
// https://www.geeksforgeeks.org/background-local-notifications-in-flutter/
// https://stackoverflow.com/questions/74577482/how-to-handle-tapping-local-notification-when-app-is-terminated-in-flutter

void main() async{

  // needed if you intend to initialize in the `main` function
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(

    // The top level function, aka callbackDispatcher
      callbackDispatcher,

      // If enabled it will post a notification whenever
      // the task is running. Handy for debugging tasks
      isInDebugMode: true
  );

  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
  print('payload=');
  String? payload = notificationAppLaunchDetails!.payload;
  print(payload);

  runApp(MyApp(payload ?? "what's your choice"));
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {

    // initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    // app_icon needs to be a added as a drawable
    // resource to the Android head project.
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = const IOSInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = InitializationSettings(android: android, iOS: IOS);
    flip.initialize(settings);
    _showNotificationWithDefaultSound(flip, inputData!["payload"]);
    return Future.value(true);
  });
}

Future _showNotificationWithDefaultSound(FlutterLocalNotificationsPlugin flip, String payload) async {

  // Show a notification after every 15 minute with the first
  // appearance happening a minute after invoking the method
  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high
  );
  var iOSPlatformChannelSpecifics = const IOSNotificationDetails();

  // initialise channel platform for both Android and iOS device.
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
  );
  await flip.show(0, 'GeeksforGeeks',
      'Your are one step away to connect with GeeksforGeeks',
      platformChannelSpecifics, payload: payload
  );
}

class MyApp extends StatelessWidget {
  String myTitle;
  MyApp(this.myTitle, {super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geeks Demo',
      theme: ThemeData(

        // This is the theme
        // of your application.
        primarySwatch: Colors.green,
      ),
      home: HomePage(myTitle),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage(this.title, {super.key});
  // This widget is the home page of your application.
  // It is stateful, meaning
  // that it has a State object (defined below)
  // that contains fields that affect
  // how it looks.

  // This class is the configuration for the state.
  // It holds the values (in this
  // case the title) provided by the parent
  // (in this case the App widget) and
  // used by the build method of the State.
  // Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called.
    // The Flutter framework has been optimized
    // to make rerunning build methods
    // fast, so that you can just rebuild
    // anything that needs updating rather
    // than having to individually change
    //instances of widgets.
    return Scaffold(
      appBar: AppBar(

        // Here we take the value from
        // the MyHomePage object that was created by
        // the App.build method, and use it
        // to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Padding(
          padding: const EdgeInsets.all(2.0),
          child: ElevatedButton(
              onPressed: () {
                Workmanager().registerOneOffTask(
                    "1",
                    "Workmanager test1",
                    initialDelay: const Duration(seconds: 7),
                    inputData: {'id': 1, 'payload': 'Taiwan'},
                    existingWorkPolicy: ExistingWorkPolicy.replace
                );
              },
              child: const Text("change title to Taiwan if the notification clicked"),
        )), Padding(
          padding: const EdgeInsets.all(2.0),
          child:  ElevatedButton(
            onPressed: () {
              Workmanager().registerOneOffTask(
                  "2",
                  "Workmanager test2",
                  initialDelay: const Duration(seconds: 7),
                  inputData: {'id': 2, 'payload': 'Japan'},
                  existingWorkPolicy: ExistingWorkPolicy.replace
              );
            },
            child: const Text("change title to Japan if the notification clicked"),
          ),
        )],
      ),
    );
  }
}