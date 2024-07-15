import 'dart:async';
import 'dart:convert';

import 'package:FashionTime/screens/pages/report_coment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/groups/add_group.dart';
import 'package:FashionTime/screens/pages/groups/all_groups.dart';
import 'package:FashionTime/screens/pages/search_screen.dart';
import 'package:FashionTime/screens/pages/settings_pages/add_chat_screen.dart';
import 'package:FashionTime/screens/pages/start_call.dart';
import 'package:FashionTime/screens/pages/users_screen.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'groups/group_message_screen.dart';
import 'message_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  bool chats = true;
  bool calls = false;
  String id = "";
  String token = "";
  String ownerEmail='';
  bool loading = false;
  bool loadingCalls = false;
  List<ChatModel> friends = [];
  String name = "";
  String pic = "";
  bool _isDelayFinished=false;
  List<Map<String,dynamic>> members = [];
  Stream? chatRooms;
  List<CallModel> callList = [];
  List<CallModel> outgoingCallList = [];
  bool showAdditionalIcons = false;
  late TabController tabController;
  String email = "";
  final _key = GlobalKey<ExpandableFabState>();
  Color _getTabIconColor(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.white : primary;
  }
  getCachedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
    email = preferences.getString("email")!;
    pic = preferences.getString("pic")!;
    ownerEmail = preferences.getString("email")!;
    print("token ==> " + ownerEmail.toString());
    print(name);
    print(pic);
    getUserInfogetChats();
    getGroups();
  }



  getUserInfogetChats() async {
    DatabaseMethods().getUserChats(name!).then((snapshots) {
      setState(() {
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${name!}");
      });
    });

    getCalls();
    // get Calls
  }

  getCalls() async {
    setState(() {
      loadingCalls = true;
      callList.clear();
      print("call lists$callList");
    });
    https.get(
      Uri.parse("$serverUrl/video-callMissedCall/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    ).then((value) {
      print('miss call getting is working');
      setState(() {
        loadingCalls = false;
      });
      jsonDecode(value.body).forEach((data) {
        print("miss call data is ${value.body.toString()}");
        setState(() {
          callList.add(CallModel(
              data["from_user"]["name"],
              data["from_user"]["pic"] ?? "",
              data["from_user"]["email"],
              "Missed",
              data["created"],
              data["from_user"]));

          print("call lsit data ${callList.toString()}");
        });
      });
      //print("${jsonDecode(value.body.toString())}my missed call");
    }).onError((error, stackTrace) {
      print("error with getting missed call is ${error.toString()}");
    });
  }
  getGroups(){
    members.clear();
    setState(() {
      loading = true;
    });
    FirebaseFirestore.instance.collection("groupChat").where('users', arrayContains: ownerEmail).get().then((value){
      value.docs.forEach((element) {
        setState(() {
          members.add(element.data());
        });
        print("Members ==> "+members.length.toString());
      });
    }).then((value1){
      FirebaseFirestore.instance.collection("groupChat").get().then((value2){
        value2.docs.forEach((element1) {
          if(element1.data()["owner"]["ownerEmail"] == ownerEmail){
            setState(() {
              members.add(element1.data());
            });
          }
        });
        // Print the length of members after all data retrieval is complete
        print("the length of group member is =======>${members.length}");
      }).catchError((e){
        setState(() {
          loading = false;
        });
        print(e.toString());
      });
      setState(() {
        loading = false;
      });
    }).catchError((e){
      setState(() {
        loading = false;
      });
      print(e.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initstate====>");
    setState(() {
      _isDelayFinished=false;
    });
    tabController = TabController(length: 2, vsync: this);
    getCachedData();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _isDelayFinished = true;
      });
    });

    // getCalls();
  }


  Widget chatRoomsList() {
    bool _isLoading = true;

    return StreamBuilder(
      stream: chatRooms,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Data is loading, display progress indicator
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // Error occurred while fetching data
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else if (snapshot.data == null) {
          // No data available
          return const Center(
            child: Text("No data available"),
          );
        } else {
          // Data has been loaded, display the list
          final chatData = snapshot.data.docs;
          // setState(() {
          //   _isLoading = false;
          // });
          // Update isLoading flag
          return ListView.builder(
            itemCount: (members.length + chatData.length).toInt(),
            itemBuilder: (context, index) {
              if (index < members.length) {
                // Render group chat tile
                return GroupChatTile(
                  groupData: members[index],
                  getCashedData: getCachedData,
                  onPressed: () {
                    // Handle group chat tile tap
                    // Navigate to group chat screen
                  },
                );
              } else {
                // Render individual chat tile
                final individualChatIndex = index - members.length;
                final chat = chatData[individualChatIndex].data();
                return ChatRoomsTile(
                  name: name,
                  chatRoomId: chat["chatRoomId"],
                  userData: chat["userData"],
                  friendData: chat["friendData"],
                  isBlocked: chat["isBlock"],
                );
              }
            },
          );
        }
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
                  tabs: const [
                    Tab(icon: Icon(Icons.message)),
                    Tab(icon: Icon(Icons.call)),
                  ],
                  indicatorColor: primary,
                  labelColor: primary,
                  unselectedLabelColor: ascent),
            ),
            Expanded(
                child: GridTab(
                  tabController: tabController,
                  chatRoomsList: chatRoomsList,
                  loadingCalls: loadingCalls,
                  callList: callList,
                  email: email,
                )),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
            child: const Icon(Icons.add),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.shade700),
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
                  MaterialPageRoute(builder: (context) => const AllGroups()));
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddChatScreen()));
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCallScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class GridTab extends StatelessWidget {
  const GridTab(
      {super.key,
        required this.tabController,
        required this.chatRoomsList,
        required this.loadingCalls,
        required this.callList,
        required this.email});

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
        chatRoomsList.isBlank == true
            ? const Center(child: Text("No chats"))
            : chatRoomsList(),
        callList.isEmpty
            ? const Center(child: Text("No missed calls"))
            : loadingCalls == true
            ? SpinKitCircle(
          color: primary,
        )
            : ListView.builder(
            itemCount: callList.length,
            itemBuilder: (context, index) => WidgetAnimator(
              Padding(
                padding:
                const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(15))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  // Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(
                                  //   id: posts[index].userid,
                                  //   username: friendData["username"],
                                  // )));
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const AddCallScreen(),
                                      ));
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(120)),
                                      color: Colors.black),
                                  child: ClipRRect(
                                    borderRadius:
                                    const BorderRadius.all(
                                        Radius.circular(120)),
                                    child: CachedNetworkImage(
                                      imageUrl: callList[index].pic,
                                      imageBuilder: (context,
                                          imageProvider) =>
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              const BorderRadius
                                                  .all(
                                                  Radius.circular(
                                                      120)),
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                      placeholder: (context, url) =>
                                          SpinKitCircle(
                                            color: primary,
                                            size: 20,
                                          ),
                                      errorWidget: (context, url,
                                          error) =>
                                          ClipRRect(
                                              borderRadius:
                                              const BorderRadius
                                                  .all(
                                                  Radius
                                                      .circular(
                                                      50)),
                                              child: Image.network(
                                                "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                width: 50,
                                                height: 50,
                                              )),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                          const AddCallScreen(),
                                        ));
                                  },
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          callList[index].name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        // callList[index].fromUser["email"] == email?
                                        callList[index].fromUser[
                                        "email"] ==
                                            email
                                            ? Row(
                                          children: [
                                            Text(
                                              "You called at ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(callList[index].date).toLocal())}",
                                              style: const TextStyle(
                                                  color: Colors
                                                      .green,
                                                  fontSize:
                                                  13,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500),
                                            ),
                                            //Icon(Icons.call_missed_outgoing,color: Colors.green,)
                                          ],
                                        )
                                            : Row(
                                          children: [
                                            Text(
                                              "You ${callList[index].type} a call at ${DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.parse(callList[index].date).toLocal())}",
                                              style: const TextStyle(
                                                  color: Colors
                                                      .red,
                                                  fontSize:
                                                  13,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500),
                                            ),
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
            )),
      ],
    );
  }
}
class GroupChatTile extends StatelessWidget {
  final Map<String, dynamic> groupData;
  final VoidCallback onPressed;
  final VoidCallback getCashedData;

  GroupChatTile({required this.groupData, required this.onPressed, required this.getCashedData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  GroupMessageScreen(members: groupData['members'],memberCount: groupData['members'].length.toString(),name: groupData["group_name"],chatRoomId: groupData['roomID'],pic: groupData['pic']==""?"https://cdn.raceroster.com/assets/images/team-placeholder.png":groupData['pic'], ),)).then((value){
          getCashedData();
        });
      },
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: ListTile(
          leading: CircleAvatar(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(120)),
                child: CachedNetworkImage(
                  imageUrl:groupData['pic']!=""?groupData['pic']:"https://cdn.raceroster.com/assets/images/team-placeholder.png",
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
              )
          ),
          title: Text(groupData["group_name"] ?? "Unnamed Group",style: const TextStyle(fontFamily: "Montserrat")),
          subtitle: Text("${groupData["members"].length} members",style: const TextStyle(fontFamily: "Montserrat")),
        ),
      ),
    );
  }
}
class ChatRoomsTile extends StatelessWidget {
  final String? name;
  final String? chatRoomId;
  final Map<String, dynamic> userData;
  final Map<String, dynamic> friendData;
  final bool isBlocked;

  ChatRoomsTile({
    this.name,
    this.chatRoomId,
    required this.userData,
    required this.friendData,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: GestureDetector(
              onTap: () {
                DatabaseMethods().deleteChats(chatRoomId!);
                Navigator.pop(context);
              },
              child: Column(
                children: [
                  Row(
                    children:  const [
                      Icon(Icons.delete),
                      SizedBox(width: 10),
                      Text("Delete all chats with:", style: TextStyle(fontFamily: 'Montserrat',fontSize: 16)),

                    ],

                  ),
                  Text(friendData["name"],style: const TextStyle(fontFamily: 'Montserrat',fontSize: 16))
                ],
              ),
            ),
          ),
        );
      },
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MessageScreen(
                    friendId: friendData["id"],
                    chatRoomId: chatRoomId!,
                    email: (chatRoomId!.split("_")[0] == name)
                        ? friendData["username"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["username"]
                        : ""),
                    name: (chatRoomId!.split("_")[0] == name)
                        ? friendData["name"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["name"]
                        : ""),
                    pic: (chatRoomId!.split("_")[0] == name)
                        ? friendData["pic"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["pic"]
                        : ""),
                    fcm: (chatRoomId!.split("_")[0] == name)
                        ? friendData["token"]
                        : (chatRoomId!.split("_")[1] == name
                        ? userData["token"]
                        : ""),
                    isBlocked: isBlocked)));
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // Navigator.push(context,MaterialPageRoute(builder: (context) => FriendProfileScreen(
                          //   id: posts[index].userid,
                          //   username: friendData["username"],
                          // )));
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius:
                              BorderRadius.all(Radius.circular(120))),
                          child: ClipRRect(
                            borderRadius:
                            const BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: (chatRoomId!.split("_")[0] == name)
                                  ? friendData["pic"]
                                  : (chatRoomId!.split("_")[1] == name
                                  ? userData["pic"]
                                  : ""),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(120)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              placeholder: (context, url) => SpinKitCircle(
                                color: primary,
                                size: 20,
                              ),
                              errorWidget: (context, url, error) => ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50)),
                                  child: Image.network(
                                    "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                    width: 50,
                                    height: 50,
                                  )),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              (chatRoomId!.split("_")[0] == name)
                                  ? friendData["name"]
                                  : (chatRoomId!.split("_")[1] == name
                                  ? userData["name"]
                                  : ""),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold,fontFamily: "Montserrat"),
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Text(
                              (chatRoomId!.split("_")[0] == name)
                                  ? friendData["username"]
                                  : (chatRoomId!.split("_")[1] == name
                                  ? userData["username"]
                                  : ""),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500,fontFamily: "Montserrat"),
                            ),
                          ],
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
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}