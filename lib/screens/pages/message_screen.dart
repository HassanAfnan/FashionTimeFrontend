import 'dart:convert';

import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../animations/bottom_animation.dart';
import '../../models/messages_model.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as https;

import 'friend_profile.dart';


class MessageScreen extends StatefulWidget {
  final String friendId;
  final String chatRoomId;
  final String name;
  final String pic;
  final String email;
  final String fcm;
  final bool isBlocked;
  const MessageScreen({Key? key, required this.name, required this.pic, required this.email, required this.chatRoomId, required this.fcm, required this.isBlocked, required this.friendId}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final _controller = ScrollController();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
  List<String> backgrounds = [
    ' ',
    'assets/bg1.jpg',
    'assets/bg2.jpg',
    'assets/bg3.jpg',
    'assets/bg4.jpg',
    'assets/bg5.jpg',
    'assets/bg6.jpg',
    'assets/bg7.jpg',
    'assets/bg8.jpg',
    'assets/bg9.jpg',
    'assets/bg10.jpg',
    'assets/bg11.jpg',
    'assets/bg12.jpg'
  ];

  int ind = 0;

  String name = "";
  String pic = "";

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name = preferences.getString("name")!;
    pic = preferences.getString("pic")!;
    print(name);
    print(pic);
    getIndex();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
     setState(() {
       ind = int.parse(prefs.getString("index") == null ?"0":prefs.getString("index").toString());
     });
     getUserInfogetChats();
  }


  addMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      //_controller.jumpTo(_controller.position.maxScrollExtent);
      sendNotification(name!,messageEditingController.text,widget.fcm);
      setState(() {
        messageEditingController.text = "";
      });
      FocusScope.of(context).unfocus();
    }
  }

  sendNotification(String name,String message,String token) async {
    print("Entered");
    print("1- "+name);
    //print("2- "+widget.person_name!.toString());
    var body = jsonEncode(<String, dynamic>{
      "to": token,
      "notification": {
        "title": name,
        "body": message,
        "mutable_content": true,
        "sound": "Tri-tone"
      },
      "data": {
        "url": "https://www.w3schools.com/w3images/avatar2.png",
        "dl": "<deeplink action on tap of notification>"
      }
    });

    https.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAIgQSOH0:APA91bGZExBIg_hZuaqTYeCMB2ulE_iiRXY8kTYH6MqEpimm6WIshqH6GAhoor1MGnGl2dDbvJqWNRzEGBm_17Kd6-vS-BHZD31HZu_EFCKs5cOQh8EJzpKP2ayJicozOU4csM528EBy',
      },
      body: body,
    ).then((value1){
      print(value1.body.toString());
    });
  }

  getUserInfogetChats(){
    DatabaseMethods().getChats(widget.chatRoomId!).then((val) {
      setState(() {
        chats = val;
      });
    });
  }



  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot){
        return snapshot.hasData ?  ListView.builder(
            controller: _controller,
            itemCount: (snapshot.data! as QuerySnapshot).docs.length,
            itemBuilder: (context, index){
              return MessageTile(
                message: (snapshot.data! as QuerySnapshot).docs[index]["message"],
                sendByMe: name! == (snapshot.data! as QuerySnapshot).docs[index]["sendBy"],
                url: (snapshot.data! as QuerySnapshot).docs[index]["image"],
                chatRoomId: widget.chatRoomId!,
                docId: (snapshot.data! as QuerySnapshot).docs[index].id,
                time:(snapshot.data! as QuerySnapshot).docs[index]["time"]
              );
            }) : Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
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
                    ])
            ),),
          actions: [
            IconButton(onPressed:(){
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context,setState) {
                    return AlertDialog(
                      title: new Text('Select Background'),
                      content: Container(
                        height: 300,
                        width: 450,
                        child: GridView.builder(
                          shrinkWrap: true,
                          itemCount: backgrounds.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10
                          ),
                          itemBuilder: (BuildContext context, int index){
                            return backgrounds[index] == " " ? WidgetAnimator(
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString("index",index.toString());
                                  setState(() {
                                    ind = index;
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(10)),
                                        color: Colors.white
                                    ),
                                    child: Center(child: ind == index ? Icon(Icons.check,color: primary,size: 40,) : const Text("")),
                                  ),
                                ),
                              ),
                            ) : WidgetAnimator(
                              GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  prefs.setString("index",index.toString());
                                  setState(() {
                                    ind = index;
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                            backgrounds[index]
                                        )
                                      ),
                                    ),
                                    child: Center(child: ind == index ? const Icon(Icons.check,color: ascent,size: 40,) : Container(
                                      color: Colors.transparent,
                                    )),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop();
                            Navigator.pop(context);// dismisses only the dialog and returns nothing
                          },
                          child: new Text('OK'),
                        ),
                      ],
                    );
                  }
                ),
              );
            }, icon: const Icon(Icons.imagesearch_roller_sharp))
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: "ABC",
                child: GestureDetector(
                  onTap: (){
                     Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(username: widget.name,id: widget.friendId,)));
                  },
                   child: Container(
                     decoration: const BoxDecoration(
                       color: Colors.black54,
                         borderRadius: BorderRadius.all(Radius.circular(120))
                     ),
                     child: ClipRRect(
                       borderRadius: const BorderRadius.all(Radius.circular(120)),
                       child: CachedNetworkImage(
                         imageUrl: widget.pic,
                         imageBuilder: (context, imageProvider) => Container(
                           height:50,
                           width: 50,
                           decoration: BoxDecoration(
                             borderRadius: const BorderRadius.all(Radius.circular(120)),
                             image: DecorationImage(
                               image: imageProvider,
                               fit: BoxFit.cover,
                             ),
                           ),
                         ),
                         placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
                         errorWidget: (context, url, error) => ClipRRect(
                             borderRadius: const BorderRadius.all(Radius.circular(50)),
                             child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,)
                         ),
                       ),
                     ),
                   ),
                ),
              ),
              const SizedBox(width: 10,),
              Text(widget.name,style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),),
            ],
          ),
          backgroundColor: ascent,
        ),
        body: Container(
            decoration: BoxDecoration(
              image:backgrounds[ind] == " " ? null : DecorationImage(
                image: AssetImage(
                  backgrounds[ind]
                ),
                fit: BoxFit.cover,
              ),
            ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:80.0),
                child: chatMessages(),
              ),
              WidgetAnimator(
                widget.isBlocked == true ? Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("This chat is blocked.")
                    ],
                  ),),
                ) : Container(
                  alignment: Alignment.bottomCenter,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 1),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(40)),
                        gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[primary, primary]),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16,),
                          Expanded(
                              child: AutoSizeTextField(
                                textCapitalization: TextCapitalization.sentences,
                                inputFormatters: <TextInputFormatter>[
                                  UpperCaseTextFormatter()
                                ],
                                maxLines: null,
                                onTap: (){
                                  //_controller.jumpTo(_controller.position.maxScrollExtent);
                                },
                                style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),
                                cursorColor: ascent,
                                controller: messageEditingController,
                                //style: simpleTextStyle(),
                                decoration: const InputDecoration(
                                    fillColor: ascent,
                                    hintText: "Message ...",
                                    hintStyle: TextStyle(
                                      color: ascent,
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none
                                ),
                              )),
                          const SizedBox(width: 16,),
                          GestureDetector(
                            onTap: () {
                              addMessage();
                            },
                            child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [
                                          ascent,
                                          ascent
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight
                                    ),
                                    borderRadius: BorderRadius.circular(40)
                                ),
                                padding: const EdgeInsets.only(left:4),
                                child: Center(child: Icon(Icons.send,color: primary,))
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String url;
  final String chatRoomId;
  final String docId;
  final int time;

  MessageTile({required this.message, required this.sendByMe,required this.url, required this.chatRoomId, required this.docId,required this.time});



  @override
  Widget build(BuildContext context) {
    DateTime msgTime=DateTime.fromMillisecondsSinceEpoch(time);
    String minutes='';
    int hours=msgTime.hour;
    if(msgTime.minute<=9){
       minutes="0${msgTime.minute}";
    }
    else{
       minutes=msgTime.minute.toString();
    }

    debugPrint("minutes is $minutes");
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: (){
          print("delete");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: GestureDetector(
                  onTap: (){
                    DatabaseMethods().deleteMessage(chatRoomId, docId);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 10,),
                      const Text("Delete chat",style: TextStyle(fontFamily: 'Montserrat'),),
                    ],
                  )),
            ),
          );
        },
        child: Container(
          margin: sendByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: const EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: sendByMe ? const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
              ) :
              const BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)),
              gradient: LinearGradient(
                colors: sendByMe ? [
                  Colors.grey, Colors.grey
                ]
                    : [
                  dark1,
                  dark1,
                ],
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message == ""
                  ? Image.network(url, height: 100, width: 100,)
                  : Text(message,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  color: ascent,
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 5), // Adjust the spacing between text and time
              Text(
                "${hours}:${minutes}",
                style: TextStyle(
                  color: primary, // You can customize the color
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
  void _showPopupMenu(context) async {
    // await showMenu(
    //   context: context,
    //   items: [
    //     PopupMenuItem(
    //         child: const Text('Delete'), value: 1),
    //   ],
    //   elevation: 8.0,
    // );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}
String capitalize(String value) {
  if(value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}