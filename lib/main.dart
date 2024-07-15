import 'package:FashionTime/screens/pages/maintainence.dart';
import 'package:FashionTime/screens/pages/shared_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:FashionTime/screens/pages/CallConfirmation.dart';
import 'package:FashionTime/screens/pages/localView.dart';
import 'package:FashionTime/screens/pages/settings_pages/contact_screen.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'authentication/splash_screen.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;


GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  SharedPreferences preferences= await SharedPreferences.getInstance();
  String name= preferences.getString('name') == null ? "" :preferences.getString('name')!;
  int myId=int.parse(preferences.getString('id')!);
  FirebaseFirestore.instance.collection("callRoom").where("users",arrayContains: name).get().then((value){
    value.docs.forEach((element) {
      if(element.id.toString().split("_")[1] == name){
        print("inner if body remote");
        CallEvent call_event = CallEvent(sessionId:"19" ,
            callType: 1,
            callerId: 6,
            callerName: element.data()['sendersData']['name'],
            opponentsIds: {5}.toSet());
        ConnectycubeFlutterCallKit.instance.init(

          onCallAccepted: (CallEvent callEvent) async {
            await ConnectycubeFlutterCallKit.clearCallData(sessionId: "19");

          },
          onCallRejected: (CallEvent callEvent) async {
            await ConnectycubeFlutterCallKit.clearCallData(sessionId: "19");
          },

        );
        if(message.notification!.title == "Call") {
          ConnectycubeFlutterCallKit.showCallNotification(call_event);
          ConnectycubeFlutterCallKit.clearCallData(sessionId: '19');
        }
        //Get.to(CallConfirmation( Channelname: element.data()['chatRoomId'],CallerName: element.data()['sendersData']['name'],friendName: element.data()['sendersData']['name'],friendPic:element.data()['sendersData']['pic'] ,friendId: element.data()['sendersData']['id'],myId: element.data()['receiversData']['friend_id'],token:element.data()['receiversData']['token'],));
        //Navigator.push(context,MaterialPageRoute(builder: (context) =>  CallConfirmation( Channelname: element.data()['chatRoomId'],CallerName: element.data()['sendersData']['name'],friendName: element.data()['sendersData']['name'],friendPic:element.data()['sendersData']['pic'] ,friendId: element.data()['sendersData']['id'],myId: element.data()['receiversData']['friend_id'],token:element.data()['receiversData']['token'],)));
      }
    });
  });

  print("Message ==> ${message.notification!.body}");
}
class RouterManager {
  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    errorPageBuilder: (context, state) => const MaterialPage(child: Scaffold(body: Text('404 Not Found'))),
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => MyApp(),
      ),
      GoRoute(
        path: '/details/:postId',
        builder: (context, state) {
          // Extract the parameter value from the state
          final postId = state.pathParameters['postId'];
          // Use the parameter value in your widget
          return MyAppShare(postId: postId!);
        },
      ),
    ],
  );
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadFromPrefs();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  fireNotification();


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
     runApp(
       ChangeNotifierProvider(create: (_)=>themeNotifier,child: MyApp() ,)
           //MaterialApp.router(routerConfig: RouterManager.router)
        );
    // runApp( const MyApp());
  });
}


fireNotification() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print(preferences.getString("toggle").toString());
  await Firebase.initializeApp();

  if (!kIsWeb ){
    print("Notification is on");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (defaultTargetPlatform == TargetPlatform.android) {
      print("android detected");
      // Android-specific configurations
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      );
      print("channel created");
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      print("ios detected");
      // iOS-specific configurations
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    print("initial function working");
    if (message != null) {
      print(message.data.toString());
      print("print 1");
      print("Message Notification on ==> ${message.notification!.body}");
      // Handle initial message
    }
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("listen function");
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      print("Message Notification on ==> ${notification.body}");
      if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
        print("android");
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background', // Update with correct Android icon
            ),
          ),
        );
        print("notification received");
      } else if (defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb) {
        print("ios device deteced");
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            iOS: IOSNotificationDetails(
              subtitle: "hello",
            ),
          ),
        );
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published! ${message.notification!.body}');
    print("print 2");
    // Handle when the user taps on a notification to open the app
  });

  if (preferences.getString("toggle") == null) {
    print("Notification is null");
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  if (preferences.getString("toggle") == 1.toString()) {
    print("Notification is off");
    // Handle case where toggle is 1
    // ...
  }
}






// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<ThemeNotifier>(
//           create: (_) => ThemeNotifier(),
//         ),
//       ],
//       child: Consumer<ThemeNotifier>(
//         builder: (context, ThemeNotifier notifier, child) {
//           return MaterialApp(
//             navigatorKey: navigatorKey,
//             debugShowCheckedModeBanner:false,
//             title: 'Fashion Time',
//             theme: notifier.darkTheme == true ? dark : light,
//             home: const TempScreen(),
//             //home:PickupCall()
//           );
//         }
//       ),
//     );
//   }
// }
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return MaterialApp(
          navigatorKey: GlobalKey<NavigatorState>(),
          debugShowCheckedModeBanner: false,
          title: 'Fashion Time',
          theme: notifier.darkTheme ? dark : light,
           home: const TempScreen(),
          // home: MaintainenceScreen(),
        );
      },
    );
  }
}

class MyAppShare extends StatelessWidget {
  final String postId;

  MyAppShare({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, child) {
        return MaterialApp(
          navigatorKey: GlobalKey<NavigatorState>(),
          debugShowCheckedModeBanner: false,
          title: 'Fashion Time',
          theme: notifier.darkTheme ? dark : light,
          home: SharePost(postId: postId),
        );
      },
    );
  }
}
// class MyAppShare extends StatelessWidget {
//   String postId;
//    MyAppShare({super.key,required this.postId});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<ThemeNotifier>(
//           create: (_) => ThemeNotifier(),
//         ),
//       ],
//       child: Consumer<ThemeNotifier>(
//           builder: (context, ThemeNotifier notifier, child) {
//             return MaterialApp(
//               navigatorKey: navigatorKey,
//               debugShowCheckedModeBanner:false,
//               title: 'Fashion Time',
//               theme: notifier.darkTheme == true ? dark : light,
//               home: SharePost(postId: postId),
//               //home:PickupCall()
//             );
//           }
//       ),
//     );
//   }
// }
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       routerDelegate: router.routerDelegate,
//       routeInformationParser: router.routeInformationParser,
//     );
//   }
// }

class TempScreen extends StatefulWidget {
  const TempScreen({super.key});

  @override
  State<TempScreen> createState() => _TempScreenState();
}

class _TempScreenState extends State<TempScreen> {
  String name="";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetCachedData();

  }

  GetCachedData()async{
    SharedPreferences preferences= await SharedPreferences.getInstance();
    name= preferences.getString('name') == null ? "" :preferences.getString('name')!;
    print(name);
    FirestoreListenter();
  }


  FirestoreListenter(){
    // showDialog(
    //     context: context,
    //     builder: (context) =>
    //         AlertDialog(
    //           backgroundColor: primary,
    //           title: Text("Fashion Time", style: TextStyle(color: ascent,
    //               fontFamily: 'Montserrat',
    //               fontWeight: FontWeight.bold),),
    //           content: Text("Entered in Firestore listener", style: TextStyle(
    //               color: ascent, fontFamily: 'Montserrat'),),
    //           actions: [
    //             TextButton(
    //               child: Text("Okay", style: TextStyle(
    //                   color: ascent, fontFamily: 'Montserrat')),
    //               onPressed: () {
    //                 setState(() {
    //                   Navigator.pop(context);
    //                 });
    //               },
    //             ),
    //           ],
    //         )
    // );
    // FirebaseFirestore.instance.collection("callRoom").where("users",arrayContains: name).get().then((value){
    //   value.docs.forEach((element) {
    //     if(element.id.toString().split("_")[1] == name){
    //       print("inner if body remote");
    //       //Get.to(CallConfirmation( Channelname: element.data()['chatRoomId'],CallerName: element.data()['sendersData']['name'],friendName: element.data()['sendersData']['name'],friendPic:element.data()['sendersData']['pic'] ,friendId: element.data()['sendersData']['id'],myId: element.data()['receiversData']['friend_id'],token:element.data()['receiversData']['token'],));
    //       //Navigator.push(context,MaterialPageRoute(builder: (context) =>  CallConfirmation( Channelname: element.data()['chatRoomId'],CallerName: element.data()['sendersData']['name'],friendName: element.data()['sendersData']['name'],friendPic:element.data()['sendersData']['pic'] ,friendId: element.data()['sendersData']['id'],myId: element.data()['receiversData']['friend_id'],token:element.data()['receiversData']['token'],)));
    //     }
    //   });
    // });
    FirebaseFirestore.instance.collection("callRoom").where("users",arrayContains: name).snapshots().listen((event) {
      if(event.docs.length <= 0){
        print("outer if body");

        Navigator.push(context,MaterialPageRoute(builder: (context) => const SplashScreen()));
      }else {
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              if(change.doc.id.toString().split("_")[1] == name){
                print("inner if body remote");

                Navigator.push(context,MaterialPageRoute(builder: (context) =>  CallConfirmation( Channelname: change.doc.data()!['chatRoomId'],CallerName: change.doc.data()!['sendersData']['name'],friendName: change.doc.data()!['sendersData']['name'],friendPic:change.doc.data()!['sendersData']['pic'] ,friendId: change.doc.data()!['sendersData']['id'],myId: change.doc.data()!['receiversData']['friend_id'],token:change.doc.data()!['receiversData']['token'],)));
              }
              else if(change.doc.id.toString().split("_")[0] == name){
                print("inner else if body local");

              }
              else {
                print("inner else");

                Navigator.push(context,MaterialPageRoute(builder: (context) => const SplashScreen()));
              }
              print("New City: ${change.doc.data()}");
              break;
            case DocumentChangeType.modified:
              print("Modified City: ${change.doc.data()}");
              break;
            case DocumentChangeType.removed:
              print("Removed City: ${change.doc.data()}");
              break;
          }
        }
      }
    }
    );
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text(""),);
  }
}



