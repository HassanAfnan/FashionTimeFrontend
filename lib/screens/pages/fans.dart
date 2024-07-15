import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../animations/bottom_animation.dart';
import '../../models/chats_model.dart';
import '../../utils/constants.dart';

class FanScreen extends StatefulWidget {
  const FanScreen({Key? key}) : super(key: key);

  @override
  State<FanScreen> createState() => _FanScreenState();
}

class _FanScreenState extends State<FanScreen> {
  String id = "";
  String token = "";
  bool loading = false;
  List<ChatModel> friends = [];
  List<ChatModel> filteredFriends = [];
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    debugPrint(token);
    getMyFriends();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getMyFriends(){
    friends.clear();
    setState(() {
      loading = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/fansfans/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        setState(() {
          loading = false;
        });
        debugPrint("fansfans response==========>${jsonDecode(value.body)}");
        jsonDecode(value.body).forEach((data){
          setState(() {
            friends.add(ChatModel(
                data["fans"]["id"].toString(),
                data["fans"]["name"],
                data["fans"]["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                data["fans"]["email"],
                data["fans"]["username"],
                data["fans"]["fcmToken"],
                isfan: data["fans"]["isFan"]

            ));
          });
        });
      });
    }catch(e){
      setState(() {
        loading = false;
      });
      debugPrint("Error --> $e");
    }
  }
  void filterFriends(String query) {

    filteredFriends.clear();
    if (query.isEmpty) {
      setState(() {
        filteredFriends.addAll(friends);
      });
    } else {

      friends.forEach((friend) {
        if (friend.name.toLowerCase().contains(query.toLowerCase())) {
          setState(() {
            filteredFriends.add(friend);
          });
        }
      });
    }
  }
  removeFan(fanId){
    setState(() {
      loading = true;
    });
    https.delete(
      Uri.parse("$serverUrl/fansfansRequests/$fanId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).then((value){
      setState(() {
        loading = false;
      });
      print(value.body.toString());
      getMyFriends();
    }).catchError((value){
      setState(() {
        loading = false;
      });
      print(value);
    });
  }
  addFan(from,to){
    setState(() {
      loading = true;
    });
    https.post(
      Uri.parse("$serverUrl/fansRequests/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "from_user": from,
        "to_user": to
      }),
    ).then((value){
      setState(() {
        loading= false;
        friends.clear();
        getMyFriends();
      });
      print(value.body.toString());

    }).catchError((value){
      setState(() {
        loading = false;
      });
      print(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: const [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        backgroundColor: primary,
        title: const Text("Fans",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body:loading == true ? SpinKitCircle(size: 50,color: primary,) : (friends.isEmpty ? const Center(child: Text("No Fans")) :

      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height*0.02,),
          SizedBox(
            height: 40,
            child: Padding(
              padding: const EdgeInsets.only(left: 16,right: 16),
              child: TextField(
                onChanged: (value) {
                  filterFriends(value);
                  // if (posts.isNotEmpty) {
                  //   SearchUser(value);
                  //   searchViaDescription(value);
                  // } else {
                  //   SearchFilteredUser(value);
                  //   searchViaDescriptionForFiltered(value);
                  // }
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  // hintTextDirection: TextDirection.ltr,
                  contentPadding:
                  const EdgeInsets.only(top: 10),
                  hintText: 'Search for users.',
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Montserrat',
                  ),
                  border: const OutlineInputBorder(),
                  focusColor: primary,
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(width: 1, color: primary),
                  ),
                ),
                cursorColor: primary,
                style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
          filteredFriends.isEmpty?
          Expanded(
            child: ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) => WidgetAnimator(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendProfileScreen(
                          id: friends[index].id,
                          username: friends[index].username,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(120)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: friends[index].pic,
                              imageBuilder: (context, imageProvider) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => SpinKitCircle(color: primary, size: 20,),
                              errorWidget: (context, url, error) => ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(50)),
                                child: Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friends[index].name ?? "",
                              style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                            ),
                            Text(
                              friends[index].username,
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Align the button to the right
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              friends[index].isfan!
                                  ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                onPressed: () {
                                  removeFan(friends[index].id);
                                },
                                child: const Text(
                                  "Unfan",
                                  style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                ),
                              )
                                  : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                ),
                                onPressed: () {
                                  addFan(id, friends[index].id);
                                },
                                child: const Text(
                                  "Fan",
                                  style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
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
            ),
          )

        // Expanded(
          //   child:
          //   ListView.builder(
          //     itemCount: friends.length,
          //     itemBuilder: (context, index) {
          //       return ListTile(
          //         leading: GestureDetector(
          //           onTap: () {},
          //           child: Container(
          //             decoration: const BoxDecoration(
          //                 borderRadius:
          //                 BorderRadius.all(Radius.circular(120)),
          //                 color: Colors.black),
          //             child: Container(
          //                 decoration: const BoxDecoration(
          //                     borderRadius:
          //                     BorderRadius.all(Radius.circular(120)),
          //                     color: Colors.black),
          //                 child: const CircleAvatar()),
          //
          //           ),
          //         ),
          //         title: Text(friends[index].name ?? "",
          //             style: const TextStyle(
          //                 color: Colors.white, fontFamily: 'Montserrat')),
          //         subtitle: Text(friends[index].username ?? "",
          //             style: const TextStyle(
          //                 color: Colors.white, fontFamily: 'Montserrat')),
          //         trailing: friends[index].email != friends
          //             ?
          //             friends[index].isfan!?
          //         ElevatedButton(
          //             style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.grey),
          //             onPressed: () {},
          //             child: const Text("Fan",
          //                 style: TextStyle(
          //                     color: Colors.white,
          //                     fontFamily: 'Montserrat'))):
          //             ElevatedButton(
          //                 style: ElevatedButton.styleFrom(
          //                     backgroundColor: primary),
          //                 onPressed: () {
          //
          //                 },
          //                 child: const Text("Fan",
          //                     style: TextStyle(
          //                         color: Colors.white,
          //                         fontFamily: 'Montserrat')))
          //             : const SizedBox(),
          //       );
          //     },
          //   ),
          //   // ListView.builder(
          //   //     itemCount: friends.length,
          //   //     itemBuilder: (context,index) => WidgetAnimator(
          //   //         GestureDetector(
          //   //           onTap: (){
          //   //             Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
          //   //               id: friends[index].id,
          //   //               username: friends[index].username,
          //   //             )));
          //   //           },
          //   //           child: Padding(
          //   //             padding: const EdgeInsets.all(10.0),
          //   //             child: Row(
          //   //               mainAxisAlignment: MainAxisAlignment.start,
          //   //               children: [
          //   //                 const SizedBox(width: 20,),
          //   //                 Container(
          //   //                   decoration: const BoxDecoration(
          //   //                       borderRadius: BorderRadius.all(Radius.circular(120))
          //   //                   ),
          //   //                   child: ClipRRect(
          //   //                     borderRadius: const BorderRadius.all(Radius.circular(120)),
          //   //                     child: CachedNetworkImage(
          //   //                       imageUrl: friends[index].pic,
          //   //                       imageBuilder: (context, imageProvider) => Container(
          //   //                         height:50,
          //   //                         width: 50,
          //   //                         decoration: BoxDecoration(
          //   //                           borderRadius: const BorderRadius.all(Radius.circular(120)),
          //   //                           image: DecorationImage(
          //   //                             image: imageProvider,
          //   //                             fit: BoxFit.cover,
          //   //                           ),
          //   //                         ),
          //   //                       ),
          //   //                       placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
          //   //                       errorWidget: (context, url, error) => ClipRRect(
          //   //                           borderRadius: const BorderRadius.all(Radius.circular(50)),
          //   //                           child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,)
          //   //                       ),
          //   //                     ),
          //   //                   ),
          //   //                 ),
          //   //                 const SizedBox(width: 20,),
          //   //                 Column(
          //   //                   mainAxisAlignment: MainAxisAlignment.start,
          //   //                   children: [
          //   //                     Row(
          //   //                       mainAxisAlignment: MainAxisAlignment.start,
          //   //                       children: [
          //   //                         Text(friends[index].name ?? "",style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
          //   //                       ],
          //   //                     ),
          //   //                     Row(
          //   //                       mainAxisAlignment: MainAxisAlignment.start,
          //   //                       children: [
          //   //                         Text("@${friends[index].username}",style: const TextStyle(fontFamily: 'Montserrat'),),
          //   //                       ],
          //   //                     )
          //   //                   ],
          //   //                 )
          //   //               ],
          //   //             ),
          //   //           ),
          //   //         )
          //   //     )
          //   // ),
          // )
              :
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) => WidgetAnimator(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendProfileScreen(
                          id: filteredFriends[index].id,
                          username: filteredFriends[index].username,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(120)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: filteredFriends[index].pic,
                              imageBuilder: (context, imageProvider) => Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => SpinKitCircle(color: primary, size: 20,),
                              errorWidget: (context, url, error) => ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(50)),
                                child: Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filteredFriends[index].name ?? "",
                              style: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
                            ),
                            Text(
                              filteredFriends[index].username,
                              style: const TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Align the button to the right
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              friends[index].isfan!
                                  ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                ),
                                onPressed: () {
                                  removeFan(filteredFriends[index].id);
                                },
                                child: const Text(
                                  "Unfan",
                                  style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
                                ),
                              )
                                  : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                ),
                                onPressed: () {
                                  addFan(id, filteredFriends[index].id);
                                },
                                child: const Text(
                                  "Fan",
                                  style: TextStyle(color: Colors.white, fontFamily: 'Montserrat'),
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
            ),
          )
        ],
      )),
    );
  }
}
