import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:FashionTime/screens/home_screen.dart';
import 'package:FashionTime/screens/pages/agora_chat_end.dart';
import 'package:FashionTime/screens/pages/channel_leave.dart';
import 'package:FashionTime/screens/pages/home_feed.dart';
import 'package:FashionTime/screens/pages/start_call.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../main.dart';
import '../../utils/constants.dart';
import 'package:flutter/services.dart';


class RemoteVideoScreen extends StatefulWidget {
  final String? Channelname;
  final String? CallerName;
  final String? friendPic;
  final String? token;
  const RemoteVideoScreen(
      {Key? key, this.Channelname, this.CallerName, this.friendPic,this.token})
      : super(key: key);

  @override
  State<RemoteVideoScreen> createState() => _RemoteVideoScreenState();
}

class _RemoteVideoScreenState extends State<RemoteVideoScreen> {
  late AgoraClient client;
  bool TextOverlay = true;
  bool isVideoEnable=false;

  @override
  void initState() {
    super.initState();
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "a51fa0c98b41430981703705373ce5de",
        channelName: widget.Channelname.toString(),
        username: widget.CallerName.toString(),
      ),
    );
    initAgora();
  }

  void initAgora() async {
    await client.initialize();
    client.engine.disableVideo();


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
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
                ]),
          ),
        ),
        backgroundColor: primary,
        title: Text(" Remote Video Call", style: TextStyle(fontFamily: 'Montserrat')),

      ),
      body:isVideoEnable?
      SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              layoutType: Layout.floating,
              client: client,
              enableHostControls: true,

            ),

            AgoraVideoButtons(
              client: client,
              addScreenSharing: false,
                disableVideoButtonChild:  Container(
                  height: 60,
                  width: 60,
                  child:
                  InkWell(
                      onTap: () {
                        setState(() {
                          isVideoEnable = !isVideoEnable;
                          if (isVideoEnable == true) {
                            client.engine.enableVideo();
                          } else {
                            client.engine.disableVideo();
                          }
                        });
                      },
                      child: Icon(Icons.videocam)),
                  // Center(
                  //   child: ElevatedButton(onPressed: () {
                  //     setState(() {
                  //       isVideoEnable=!isVideoEnable;
                  //       if(isVideoEnable==true){
                  //         client.engine.enableVideo();
                  //       }
                  //       else{
                  //         client.engine.disableVideo();
                  //
                  //       }
                  //
                  //     });
                  //
                  //   },style: ElevatedButton.styleFrom(shape: CircleBorder()), child: Center(child: Icon(Icons.videocam))),
                  // ),
                ),
              onDisconnect: (){
                if(client.users.isEmpty){
                  client.release();
                  Navigator.push(context,MaterialPageRoute(builder: (context) => DestroyChat(Channelname:widget.Channelname.toString()),));
                }
                else{
                  Navigator.push(context,MaterialPageRoute(builder: (context) => ChannelLeft(),));
                }
              },


            ),


          ],
        ),
      ):
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            ),
            SizedBox(height: 20,),
            Text(widget.CallerName.toString(),style: TextStyle(fontFamily: 'Montserrat')),

            SizedBox(height: 250,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Center(
                  child: ElevatedButton(onPressed: () {
                    setState(() {
                      isVideoEnable=!isVideoEnable;
                      client.engine.enableVideo();
                    });
                  }, child: Icon(Icons.videocam),),
                ),
                ElevatedButton(onPressed: () {
                  setState(() {
                    if(client.users.isEmpty){
                      client.release();
                      print("hellomynameissaqlain");
                      Navigator.push(context,MaterialPageRoute(builder: (context) => DestroyChat(Channelname: widget.Channelname.toString()),));
                    }
                    else if (client.users.isNotEmpty){
                      client.release();
                      Navigator.push(context,MaterialPageRoute(builder: (context) => ChannelLeft(),));
                    }
                  });
                }, child: Icon(Icons.call_end,color: Colors.red,),)

              ],
            )
          ],
        ),
      ),
    );
  }
}
