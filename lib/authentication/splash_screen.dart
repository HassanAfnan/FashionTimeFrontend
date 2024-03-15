import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FashionTime/authentication/login_screen.dart';
import 'package:FashionTime/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../animations/bottom_animation.dart';
import '../screens/pages/call/call_screen.dart';
import '../utils/constants.dart';

incomingCall() async {
  CallKitParams params= CallKitParams(
      id: "21232dgfgbcbgb",
      nameCaller: "Coding Is Life",
      appName: "Demo",
      avatar: "https://i.pravata.cc/100",
      handle: "123456",
      type: 0,
      textAccept: "Accept",
      textDecline: "Decline",
      // textMissedCall: "Missed call",
      // textCallback: "Call back",
      duration: 30000,
      extra: {'userId':"sdhsjjfhuwhf"},
      android: AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          // isShowCallback: false,
          // isShowMissedCallNotification: true,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: "#0955fa",
          backgroundUrl: "https://i.pravata.cc/500",
          actionColor: "#4CAF50",
          incomingCallNotificationChannelName: "Incoming call",
          missedCallNotificationChannelName: "Missed call"
      ),
      ios: IOSParams(
          iconName: "Call Demo",
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          ringtonePath: 'system_ringtone_default'
      )
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
        const Duration(seconds: 3), (){
      checkUser();
    });
     channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
    );
  }

  // startFirebaseListener() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   if(preferences.getString("name") != null) {
  //     String name = preferences.getString("name")!;
  //     print(name);
  //     FirebaseFirestore.instance.collection("callRoom").where(
  //         "users", arrayContains: name).snapshots().listen((value) {
  //       value.docs.forEach((element) {
  //         print(element.id.toString());
  //         if (element.id.split("_")[1] == name) {
  //           print(element["receiversData"]["name"]);
  //           print(element["receiversData"]["pic"]);
  //           print(element["receiversData"]["friend_id"]);// uid friend
  //           print(element.id);// channel name
  //           print(element["agoraToken"]); // agora token
  //           // Do remote user work
  //           Navigator.push(context, MaterialPageRoute(builder:(context) {
  //            return VideoScreen(Rtk: element['agoraToken'],RCn: element["chatRoomId"]);
  //           },
  //           ));
  //           //setCallListener(element["agoraToken"],element["chatRoomId"]);
  //         } else {
  //           print("Else Local");
  //         }
  //       });
  //     });
  //   }
  // }

  setCallListener(token,chatRoomId){
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      switch (event!.event) {
        case Event.actionCallIncoming:
        // TODO: received an incoming call
          incomingCall();
          break;
        case Event.actionCallStart:
        // TODO: started an outgoing call
        // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(
            token:token,
            channelId: chatRoomId,
          )));
        // TODO: accepted an incoming call
        // TODO: show screen calling in Flutter
          break;
        case Event.actionCallDecline:
        // TODO: declined an incoming call
          break;
        case Event.actionCallEnded:
        // TODO: ended an incoming/outgoing call
          break;
        case Event.actionCallTimeout:
        // TODO: missed an incoming call
          break;
        case Event.actionCallCallback:
        // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
        // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
        // TODO: only iOS
          break;
        case Event.actionCallToggleDmtf:
        // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
        // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
        // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
        // TODO: only iOS
          break;
        case Event.actionCallCustom:
        // TODO: for custom action
          break;
      }
    });
  }

  Future<void> checkUser() async{
    SharedPreferences  prefs = await SharedPreferences.getInstance();
    var sessionEmail = prefs.getString('token');
    if(sessionEmail != null){
      // Navigator.of(context).pop();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    } else {
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Login()));
    }
    // if (username != null) {
    //   FirebaseFirestore firestore = FirebaseFirestore.instance;
    //   CollectionReference collectionRef = firestore.collection('callroom');
    //   QuerySnapshot querySnapshot = await collectionRef.get();
    //
    //   for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
    //     var receiverData = documentSnapshot.data()!['receiversData'].toString();
    //     if (receiverData != null && receiverData['name'] == username) {
    //       Navigator.of(context).pop();
    //       Navigator.push(context, MaterialPageRoute(builder: (context) =>AddCallScreen ()));
    //       return;
    //     }
    //   }
    //
    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
    // } else {
    //   // Handle the case when 'id' is null
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondary,
        image: DecorationImage(
            image: AssetImage(
                "assets/background.jpg"
            ),
            fit: BoxFit.fill
        ),
      ),
      child: FadeIn(
        delay: Duration(microseconds: 2000),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15,),
              WidgetAnimator(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Image.asset("assets/logo2.png",height: MediaQuery.of(context).size.height * 0.4,
                        fit: BoxFit.fill,),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2,),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            height: 100,
            child: Column(
              children: [
                WidgetAnimator(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitCircle(color: ascent,size: 70,)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
