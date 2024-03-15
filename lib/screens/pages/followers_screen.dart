import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../animations/bottom_animation.dart';
import '../../models/chats_model.dart';
import '../../utils/constants.dart';
import 'friend_profile.dart';

class FollowerScreen extends StatefulWidget {
  const FollowerScreen({Key? key}) : super(key: key);

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  String id = "";
  String token = "";
  bool loading = false;
  List<ChatModel> friends = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(token);
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
          Uri.parse("${serverUrl}/follow_get_friends/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token}"
          }
      ).then((value){
        setState(() {
          loading = false;
        });
        print(jsonDecode(value.body).toString());
        jsonDecode(value.body).forEach((data){
          setState(() {
            friends.add(ChatModel(
                data["id"].toString(),
                data["name"],
                data["pic"] == null?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":data["pic"],
                data["email"],
                data["username"],
                data["fcmToken"]
            ));
          });
        });
      });
    }catch(e){
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
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
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        backgroundColor: primary,
        title: Text("Friends",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body:loading == true ? SpinKitCircle(size: 50,color: primary,) : (friends.length<=0 ? Center(child: Text("No Friends")) :ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context,index) => WidgetAnimator(
            GestureDetector(
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
                    SizedBox(width: 20,),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(120))
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(120)),
                        child: CachedNetworkImage(
                          imageUrl: friends[index].pic,
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
                    SizedBox(width: 20,),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(friends[index].name == null ?"":friends[index].name,style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("@"+friends[index].username,style: TextStyle(fontFamily: 'Montserrat'),),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          )
      )),
    );
  }
}
