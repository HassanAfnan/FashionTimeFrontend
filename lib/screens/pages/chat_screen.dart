import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/groups/add_group.dart';
import 'package:FashionTime/screens/pages/groups/all_groups.dart';
import 'package:FashionTime/screens/pages/search_screen.dart';
import 'package:FashionTime/screens/pages/settings_pages/add_chat_screen.dart';
import 'package:FashionTime/screens/pages/start_call.dart';
import 'package:FashionTime/screens/pages/users_screen.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as https;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../animations/bottom_animation.dart';
import '../../helpers/database_methods.dart';
import '../../models/call_model.dart';
import '../../models/chats_model.dart';
import 'message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  bool chats = true;
  bool calls = false;
  String id = "";
  String token = "";
  bool loading = false;
  bool loadingCalls = false;
  List<ChatModel> friends = [];
  String name = "";
  String pic = "";
  Stream? chatRooms;
  List<CallModel> callList = [];
  List<CallModel> outgoingCallList=[];
  bool showAdditionalIcons=false;
  late TabController tabController;
  String email = "";
  final _key = GlobalKey<ExpandableFabState>();
  Color _getTabIconColor(BuildContext context) {

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;


    return isDarkMode ? Colors.white : primary;
  }

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    email = preferences.getString("email")!;
    pic = preferences.getString("pic")!;
    print("token ==> "+token.toString());
    print(name);
    print(pic);
    getUserInfogetChats();


  }

  getUserInfogetChats() async {
    DatabaseMethods().getUserChats(name!).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print("we got the data + ${chatRooms.toString()} this is name  ${name!}");
      });
    });
    getCalls();
    // get Calls

  }
  getCalls()async{
    setState(() {
      loadingCalls = true;
      callList.clear();
      print("call lists$callList");
    });
    https.get(Uri.parse("$serverUrl/video-callMissedCall/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },).then((value){
        print('miss call getting is working');
        setState(() {
          loadingCalls = false;
        });
      jsonDecode(value.body).forEach((data){
        print("miss call data is ${value.body.toString()}");
        setState(() {
          callList.add(CallModel(
              data["from_user"]["name"],
              data["from_user"]["pic"]??"",
              data["from_user"]["email"],
              "Missed",
              data["created"],
             data["from_user"]
          ));

          print("call lsit data ${callList.toString()}");
        });
      });
      //print("${jsonDecode(value.body.toString())}my missed call");
    }).onError((error, stackTrace) {
      print("error with getting missed call is ${error.toString()}");
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getCashedData();

   // getCalls();
  }

  Widget chatRoomsList() {
    return chatRooms == null  ? Center(child: Text("No Chats"))  : StreamBuilder(
      stream: chatRooms,
      builder: (context,AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Padding(
          padding: const EdgeInsets.only(top:50.0),
          child: SpinKitCircle(color: primary,),
        ));
        else if (snapshot.connectionState == ConnectionState.done) return Center(child: Text("No Chats"));
        // else if (snapshot.connectionState == ConnectionState.active) return Center(child: Text("No Chats"));
        // else if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Text("No Chats"));
        return snapshot.data.docs.length <= 0
            ? Center(child: Text("No Chats")) : ListView.builder(
          //controller: _controller,
            itemCount: snapshot.data.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              print((snapshot.data.docs[index]['chatRoomId'].toString().split("_")[0] == name! ?snapshot.data.docs[index]['chatRoomId'].toString().split("_")[1] :(snapshot.data.docs[index]['chatRoomId'].toString().split("_")[1] == name! ? snapshot.data.docs[index]['chatRoomId'].toString().split("_")[0] :"")),);
              return ChatRoomsTile(
                  name: name,
                  chatRoomId: snapshot.data.docs[index]["chatRoomId"],
                  userData: snapshot.data.docs[index]["userData"],
                  friendData: snapshot.data.docs[index]["friendData"],
                  isBlocked: snapshot.data.docs[index]["isBlock"],
              );
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Column(
          children: [
            Container(
              height: 50,
              child: TabBar(
                controller: tabController,
                tabs: [
                  Tab(icon: Icon(Icons.message)),
                  Tab(icon: Icon(Icons.call)),
                ],
                indicatorColor: primary,
                labelColor: primary,
                  unselectedLabelColor: ascent
              ),
            ),
            Expanded(child: GridTab(tabController: tabController,chatRoomsList:chatRoomsList,loadingCalls: loadingCalls,callList:callList,email: email,)),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child:Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey.shade700
        ),
        children: [
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.groups),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                debugPrint('isOpen:${state.isOpen}');
                state.toggle();
              }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AllGroups()));

            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.message_outlined),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                debugPrint('isOpen:${state.isOpen}');
                state.toggle();
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddChatScreen()));
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            child: const Icon(Icons.add_call),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                debugPrint('isOpen:${state.isOpen}');
                state.toggle();
              }
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddCallScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class GridTab extends StatelessWidget {
  const GridTab({
    super.key,
    required this.tabController,
    required this.chatRoomsList,
    required this.loadingCalls,
    required this.callList,
    required this.email
  });

  final TabController tabController;
  final Function chatRoomsList;
  final bool loadingCalls;
  final List<CallModel> callList;
  final String email;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        chatRoomsList.isBlank == true ? Center(child:
        Text("No chats")
        ) : chatRoomsList(),
        callList.isEmpty?
        Center(child:
        Text("No missed calls")
        ):
        loadingCalls == true ? SpinKitCircle(color: primary,) : ListView.builder(
            itemCount: callList.length,
            itemBuilder: (context,index) => WidgetAnimator(
              Padding(
                padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: (){
                                  // Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(
                                  //   id: posts[index].userid,
                                  //   username: friendData["username"],
                                  // )));
                                  Navigator.push(context,MaterialPageRoute(builder: (context) => AddCallScreen(),));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(120)),
                                    color: Colors.black
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(120)),
                                    child: CachedNetworkImage(
                                      imageUrl: callList[index].pic,
                                      imageBuilder: (context, imageProvider) => Container(
                                        height:50,
                                        width: 50,
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
                                          child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 50,height: 50,)
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16,),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (context) => AddCallScreen(),));
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        Text(callList[index].name, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                        SizedBox(height: 6,),
                                        // callList[index].fromUser["email"] == email?
                                        callList[index].fromUser["email"] == email?
                                        Row(
                                          children: [
                                            Text("You called at ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(callList[index].date).toLocal())}",style: TextStyle(color:Colors.green,fontSize: 13,fontWeight: FontWeight.w500),),
                                            //Icon(Icons.call_missed_outgoing,color: Colors.green,)
                                          ],
                                        ):
                                        Row(
                                          children: [
                                            Text("You ${callList[index].type} a call at ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(callList[index].date).toLocal())}",style: TextStyle(color:Colors.red,fontSize: 13,fontWeight: FontWeight.w500),),
                                               //Icon(Icons.call_missed,color: Colors.red,size: 8.0,),

                                          ],
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
        ),
      ],
    );
  }
}

class ChatRoomsTile extends StatelessWidget {
  final String? name;
  final String? chatRoomId;
  final Map<String,dynamic> userData;
  final Map<String,dynamic> friendData;
  final bool isBlocked;

  ChatRoomsTile({this.name, this.chatRoomId, required this.userData, required this.friendData, required this.isBlocked, });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessageScreen(
          friendId: friendData["id"],
          chatRoomId: chatRoomId!,
          email: (chatRoomId!.split("_")[0] == name)? friendData["username"] : (chatRoomId!.split("_")[1] == name ?userData["username"]:""),
          name: (chatRoomId!.split("_")[0] == name)? friendData["name"] : (chatRoomId!.split("_")[1] == name ?userData["name"]:""),
          pic: (chatRoomId!.split("_")[0] == name)? friendData["pic"] : (chatRoomId!.split("_")[1] == name ?userData["pic"]:""),
          fcm: (chatRoomId!.split("_")[0] == name)? friendData["token"] : (chatRoomId!.split("_")[1] == name ?userData["token"]:""),
            isBlocked:isBlocked
        )));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 8.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: (){
                          // Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(
                          //   id: posts[index].userid,
                          //   username: friendData["username"],
                          // )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(120))
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: (chatRoomId!.split("_")[0] == name)? friendData["pic"] : (chatRoomId!.split("_")[1] == name ?userData["pic"]:""),
                              imageBuilder: (context, imageProvider) => Container(
                                height:50,
                                width: 50,
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
                                  child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 50,height: 50,)
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16,),
                      Expanded(
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text((chatRoomId!.split("_")[0] == name)? friendData["name"] : (chatRoomId!.split("_")[1] == name ?userData["name"]:""), style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                              SizedBox(height: 6,),
                              Text((chatRoomId!.split("_")[0] == name)? friendData["username"] : (chatRoomId!.split("_")[1] == name ?userData["username"]:""),style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500),),
                            ],
                          ),
                        ),
                      ),
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
extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

