import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:FashionTime/screens/pages/home_feed.dart';
import 'package:FashionTime/screens/pages/localView.dart';
import 'package:FashionTime/screens/pages/remoteView.dart';
import 'package:FashionTime/utils/constants.dart';
import

'package:flutter/material.dart';
import

'package:flutter_spinkit/flutter_spinkit.dart';
import

'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:permission_handler/permission_handler.dart';

class CallConfirmation extends StatefulWidget {
  final String? Channelname;
  final String? CallerName;
  final String? friendPic;
  final String? friendName;
  final String? token;
  final String? friendId;
  final String? myId;
  const CallConfirmation({
    Key? key,
    this.friendName,
    this.Channelname,
    this.CallerName,
    this.friendPic,
    this.token,
    this.friendId,
    this.myId,
  }) : super(key: key);

  @override
  State<CallConfirmation> createState() => _CallConfirmationState();
}

class _CallConfirmationState extends State<CallConfirmation> {

  void callnotify(int calleeid, String CallerName, int callerid,
      String channelName, friendToken) {
    CallEvent call_event = CallEvent(sessionId: friendToken,
        callType: 1,
        callerId: callerid,
        callerName: CallerName,
        opponentsIds: {calleeid}.toSet());

    ConnectycubeFlutterCallKit.instance.init(

      onCallAccepted: (CallEvent callEvent) async {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            VideoScreen(Channelname: channelName, CallerName: CallerName),));
        await ConnectycubeFlutterCallKit.clearCallData(sessionId: friendToken);
        // the call was accepted
      },
      onCallRejected: (CallEvent callEvent) async {
        await ConnectycubeFlutterCallKit.clearCallData(sessionId: friendToken);
      },


    );
    @pragma('vm:entry-point')
    Future<void> onCallAcceptedWhenTerminated(CallEvent callEvent) async {
      Navigator.push(context, MaterialPageRoute(builder: (context) =>
          VideoScreen(Channelname: widget.Channelname.toString(),
              CallerName: widget.friendName.toString()),));
      await ConnectycubeFlutterCallKit.clearCallData(
          sessionId: widget.token.toString());
    };

    @pragma('vm:entry-point')
    Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
      await ConnectycubeFlutterCallKit.clearCallData(sessionId: "6");
    };
    ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated =
        onCallRejectedWhenTerminated;
    ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated =
        onCallAcceptedWhenTerminated;
    ConnectycubeFlutterCallKit.showCallNotification(call_event);


    print("callnotified");
    print("opponent id $calleeid");
    print("session id is $friendToken");
  }

  @override
  void initState() {
    super.initState();
    // Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //     VideoScreen(Channelname: widget.Channelname.toString(),
    //         CallerName: widget.friendName.toString()),));
    // CallEvent call_event = CallEvent(sessionId:"7" ,
    //     callType: 1,
    //     callerId: 1,
    //     callerName: "afnan",
    //     opponentsIds: {2}.toSet());
    //
    // ConnectycubeFlutterCallKit.instance.init(
    //
    //   onCallAccepted: (CallEvent callEvent) async {
    //     Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //         VideoScreen(Channelname: widget.Channelname.toString(), CallerName: widget.friendName.toString()),));
    //     await ConnectycubeFlutterCallKit.clearCallData(sessionId: "7");
    //     // the call was accepted
    //   },
    //   onCallRejected: (CallEvent callEvent) async {
    //     await ConnectycubeFlutterCallKit.clearCallData(sessionId: "7");
    //   },
    //
    //
    //
    // );
    // @pragma('vm:entry-point')
    // Future<void> onCallAcceptedWhenTerminated(CallEvent callEvent) async {
    //   Navigator.push(context, MaterialPageRoute(builder: (context) =>
    //       VideoScreen(Channelname: widget.Channelname.toString(),
    //           CallerName: widget.friendName.toString()),));
    //   await ConnectycubeFlutterCallKit.clearCallData(sessionId: widget.token.toString());
    // };
    //
    // @pragma('vm:entry-point')
    // Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
    //   await ConnectycubeFlutterCallKit.clearCallData(sessionId: "6");
    // };
    // ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated=onCallRejectedWhenTerminated;
    // ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated=onCallAcceptedWhenTerminated;
    // ConnectycubeFlutterCallKit.showCallNotification(call_event);
    //
    // callnotify(int.parse(widget.myId.toString()), widget.friendName.toString(),
    //     int.parse(widget.friendId.toString()), widget.Channelname.toString(),"7");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])),
        ),
        backgroundColor: primary,
        title: Text(
          "Calling ${widget.friendName.toString()}",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(120))
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(120)),
              child: CachedNetworkImage(
                imageUrl: widget.friendPic.toString(),
                imageBuilder: (context, imageProvider) => Container(
                  height:200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(120)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
                errorWidget: (context, url, error) => ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,)
                ),
              ),
            )
        )
        ,
        SizedBox(
          height: 20,
          width: 20,
        ),
        Center(
          child: Text(widget.friendName.toString()),
        ),
      ]),

        bottomNavigationBar: BottomAppBar(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                stops: [0.0, 0.99],
                tileMode: TileMode.clamp,
                colors: <Color>[
                  secondary,
                  primary,
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        VideoScreen(Channelname: widget.Channelname.toString(),
                            CallerName: widget.friendName.toString()),));
                    print('Phone button pressed');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.phone_outlined, color: Colors.red),
                  onPressed: () {
                    Navigator.pop(context,DatabaseMethods().endCallRoom(widget.Channelname.toString()));
                    print('Phone declined button pressed');
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}