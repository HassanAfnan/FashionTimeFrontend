import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;
import '../../../animations/bottom_animation.dart';
import '../../../models/chats_model.dart';
import '../../../utils/constants.dart';
import '../friend_profile.dart';
class CloseFriends extends StatefulWidget {
  const CloseFriends({super.key});

  @override
  State<CloseFriends> createState() => _CloseFriendsState();
}

class _CloseFriendsState extends State<CloseFriends> {
  String id = "";
  String token = "";
  bool loading = false;
  List<ChatModel> friends = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    debugPrint(token.toString());
    getMyFriends();
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }
  getMyFriends(){
    setState(() {
      loading = true;
    });
    try{
      https.get(
          Uri.parse("$serverUrl/follow_get_friends/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        setState(() {
          loading = false;
        });
        debugPrint(jsonDecode(value.body).toString());
        jsonDecode(value.body).forEach((data){
          setState(() {
            friends.add(ChatModel(
                data["id"].toString(),
                data["name"],
                data["pic"] ?? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                data["email"],
                data["username"],
                data["fcmToken"],
              isCloseFriend: data['is_close_friend']
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
  updateFriendStatus(bool status,String id){
    String url="$serverUrl/follow_update_close_friend_status/$id/";
    try{
      https.post(
        Uri.parse(url),
          headers: {
          "Content-Type": "application/json",
        "Authorization": "Bearer $token",

      },body:
          jsonEncode({
            "is_close_friend": status
          })

      ).then((value) {
        if(value.statusCode==200&&status==true){
          Fluttertoast.showToast(msg: "Added to close friends!",backgroundColor: primary);
          debugPrint("status updated");
        } if(value.statusCode==200&&status==false){
          Fluttertoast.showToast(msg: "Removed from close friends!",backgroundColor: primary);
          debugPrint("status updated");
        }

      });
    }
    catch(e){
      debugPrint("error received=====>${e.toString()}");
      Fluttertoast.showToast(msg: "Something went wrong!",backgroundColor: Colors.red);
    }

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
        title: const Text("Close Friends",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body:loading == true ? SpinKitCircle(size: 50,color: primary,) : (friends.isEmpty ? const Center(child: Text("No Friends")) :ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context,index) => GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                id: friends[index].id,
                username: friends[index].username,
              )));
            },
            child: WidgetAnimator(
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                      id: friends[index].id,
                      username: friends[index].username,
                    )));
                  },
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                        id: friends[index].id,
                        username: friends[index].username,
                      )));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20,),
                          Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(120))
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                              child: CachedNetworkImage(
                                imageUrl: friends[index].pic,
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
                                    child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 50,height: 50,)
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20,),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(friends[index].name ?? "",style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(friends[index].username,style: const TextStyle(fontFamily: 'Montserrat'),),
                                ],
                              )
                            ],
                          ),
                          const Spacer(),
                          Checkbox(
                              activeColor: primary,
                              checkColor: ascent,
                              value: friends[index].isCloseFriend, onChanged: (bool? value){
                            setState(() {
                              friends[index].isCloseFriend=value!;
                              updateFriendStatus(value, friends[index].id);
                            });
                          })
                        ],
                      ),
                    ),
                  ),
                )
            ),
          )
      )),
    );
  }
}
