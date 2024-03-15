//
// import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
//
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class CallScreen extends StatefulWidget {
  final String token;
  final String channelId;
  const CallScreen({Key? key, required this.token, required this.channelId}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int? _remoteUid;
  // late RtcEngine? _engine;

  @override
  void initState() {
    super.initState();
   // initAgora();
  }

  // Future<void> initAgora() async {
  //   // retrieve permissions
  //   await [Permission.microphone, Permission.camera].request();
  //
  //   //create the engine
  //   _engine = await RtcEngine.create("a51fa0c98b41430981703705373ce5de");
  //   await _engine!.enableVideo();
  //   _engine!.setEventHandler(
  //     RtcEngineEventHandler(
  //       joinChannelSuccess: (String channel, int uid, int elapsed) {
  //         print("local user $uid joined");
  //       },
  //       userJoined: (int uid, int elapsed) {
  //         print("remote user $uid joined");
  //         setState(() {
  //           _remoteUid = uid;
  //         });
  //       },
  //       userOffline: (int uid, UserOfflineReason reason) {
  //         print("remote user $uid left channel");
  //         setState(() {
  //           _remoteUid = null;
  //         });
  //       },
  //     ),
  //   );
  //
  //   await _engine!.joinChannel(null, "firstchannel", null, 0);
  // }

  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteVideo(),
          ),
          // Align(
          //   alignment: Alignment.topLeft,
          //   child: Container(
          //     width: 100,
          //     height: 100,
          //     child: Center(
          //       child: RtcLocalView.SurfaceView(),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    return Text("");
    // if (_remoteUid != null) {
    //   return RtcRemoteView.SurfaceView(uid: _remoteUid!);
    // } else {
    //   return Text(
    //     'Please wait for remote user to join',
    //     textAlign: TextAlign.center,
    //   );
    // }
  }
}