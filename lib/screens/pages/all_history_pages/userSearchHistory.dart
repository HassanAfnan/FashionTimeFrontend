import 'dart:convert';

import 'package:FashionTime/models/userHistory.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;

import '../../../animations/bottom_animation.dart';

class UserSearchHistory extends StatefulWidget {
  const UserSearchHistory({super.key});

  @override
  State<UserSearchHistory> createState() => _UserSearchHistoryState();
}

class _UserSearchHistoryState extends State<UserSearchHistory> {
  String id = "";
  String token = "";
  bool loading = false;
  List<UserHistory> userHistory = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(token);
    getUserHistory();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getUserHistory(){
    userHistory.clear();
    setState(() {
      loading = true;
    });
    https.get(
      Uri.parse("$serverUrl/apiSearchedHistory/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).then((value){
      setState(() {
        loading = false;
      });
      print(value.body.toString());
      var responseData = jsonDecode(value.body);
      responseData.forEach((e){
        setState(() {
          userHistory.add(UserHistory(
              e["id"].toString(),
              e["userId"],
              e["name"],
              e["username"],
              e["image"]
          ));
        });
      });
    }).onError((error, stackTrace){
      setState(() {
        loading = false;
      });
    });
  }

  removeUserHistory(String id,index){
    print(id);
    https.delete(
        Uri.parse("$serverUrl/apiSearchedHistory/${id}/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      //print("History added");
      setState(() {
        userHistory.removeAt(index);
      });
      getUserHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        backgroundColor: primary,
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
        title: const Text("All Searches",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: loading == true ? SpinKitCircle(color: primary, size: 20,) :Column(
        children: [
          userHistory.length <= 0 ? Center(child: Text("No Searches")) : Expanded(
            child: ListView.builder(
            itemCount: userHistory.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendProfileScreen(
                        id: userHistory[index].id,
                        username: userHistory[index].username,
                      ),
                    ),
                  );
                  //addUserHistory(friends[index].id,friends[index].name,friends[index].username,friends[index].pic);
                },
                child: WidgetAnimator(
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FriendProfileScreen(
                            id: userHistory[index].id,
                            username: userHistory[index].username,
                          ),
                        ),
                      );
                      //addUserHistory(friends[index].id,friends[index].name,friends[index].username,friends[index].pic);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 20,),
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.all(Radius.circular(120)),
                                  child: CachedNetworkImage(
                                    imageUrl: userHistory[index].image,
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
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            userHistory[index].name == null ? "" : userHistory[index].name,
                                            style: TextStyle(
                                              color: primary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            userHistory[index].username,
                                            style: const TextStyle(fontFamily: 'Montserrat'),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: (){
                                  removeUserHistory(userHistory[index].historyID,index);
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),)
        ],
      ),
    );
  }
}



