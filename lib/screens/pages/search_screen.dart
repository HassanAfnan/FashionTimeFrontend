import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../animations/bottom_animation.dart';
import '../../models/chats_model.dart';
import '../../models/search_model.dart';
import '../../utils/constants.dart';
import 'friend_profile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String search = "";
  String id = "";
  String token = "";
  bool loading = false;
  List<SearchModel> friends = [];
  List<SearchModel> filteredItems = [];
  int pagingation=1;

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(token);
    getMyFriends(1);
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  // getMyFriends(){
  //   setState(() {
  //     loading = true;
  //   });
  //   try{
  //     https.get(
  //         Uri.parse("${serverUrl}/user/api/allUsers/"),
  //         headers: {
  //           "Content-Type": "application/json",
  //           "Authorization": "Bearer ${token}"
  //         }
  //     ).then((value){
  //       setState(() {
  //         loading = false;
  //       });
  //       print(jsonDecode(value.body).toString());
  //       jsonDecode(value.body).forEach((data){
  //         if(data["id"].toString() != id.toString()){
  //           if(data["isBlocked"] == false) {
  //             setState(() {
  //               friends.add(SearchModel(
  //                   data["id"].toString(),
  //                   data["name"] == null ? "No Name" :  data["name"],
  //                   data["pic"] == null
  //                       ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
  //                       : data["pic"],
  //                   data["email"],
  //                   data["username"],
  //                   data["fcmToken"] == null ? "" : data["fcmToken"],
  //                   data["badge"] == null ?{"id":0}: data["badge"]
  //               ));
  //             });
  //           }
  //         }
  //       });
  //     });
  //   }catch(e){
  //     setState(() {
  //       loading = false;
  //     });
  //     print("Error --> ${e}");
  //   }
  // }
  getMyFriends(int pagination) {
    setState(() {
      loading = true;
    });

    try {
      https.get(
        Uri.parse("$serverUrl/user/api/allUsers/?page=$pagingation"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).then((value) {
        setState(() {
          loading = false;
        });

        var responseData = jsonDecode(value.body);
        var results = responseData['results'];

        results.forEach((data) {
          if (data["id"] != id) {
            if (data["isBlocked"] == false) {
              setState(() {
                friends.add(SearchModel(
                  data["id"].toString(),
                  data["name"] == null ? "No Name" : data["name"],
                  data["pic"] == null
                      ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w"
                      : data["pic"],
                  data["email"],
                  data["username"],
                  data["fcmToken"] == null ? "" : data["fcmToken"],
                  data["badge"] == null ? {"id": 0} : data["badge"],
                ));
              });
            }
          }
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }
  SearchUser(String query) {
    setState(
          () {
        search = query;
        filteredItems = friends
            .where(
              (item) => item.name.toLowerCase().contains(
            query.toLowerCase(),
          ),
        ).toList();
      },
    );
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
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        title: const Text("Search for users",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          WidgetAnimator(
            Container(
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
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                        stops: [0.0, 0.99],
                        tileMode: TileMode.clamp,
                        colors:  <Color>[secondary, primary] ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16,),
                      Expanded(
                          child: TextField(
                            onChanged: (value){
                              SearchUser(value);
                            },
                            style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),
                            cursorColor: ascent,
                            //style: simpleTextStyle(),
                            decoration: const InputDecoration(
                                fillColor: ascent,
                                hintText: "Search for users ...",
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
                          FocusScope.of(context).unfocus();
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
                            padding: const EdgeInsets.all(10),
                            child: Icon(Icons.person_search,color: primary,)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          loading == true ? SpinKitCircle(color: primary,size: 50,) :(friends.length <= 0 ? const Text("No People") : Expanded(
            child: filteredItems.isNotEmpty || search.isNotEmpty ? (filteredItems.isEmpty
                ? const Center(
              child: Text(
                'No Results Found',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context,index) => InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                      id: friends[index].id,
                      username: friends[index].username,
                    )));
                  },
                  child: WidgetAnimator(
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                            id: filteredItems[index].id,
                            username: filteredItems[index].username,
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
                                    imageUrl: filteredItems[index].pic,
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
                                    placeholder: (context, url) => SpinKitCircle(color: primary,size: 60,),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                                        child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 50,height: 50,)
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(child: Text(filteredItems[index].name,style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),textAlign: TextAlign.start,)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Flexible(child:Text(filteredItems[index].username,style: const TextStyle(fontFamily: 'Montserrat'),)),

                                      ],
                                    )
                                  ],
                                ),

                              ),
                              filteredItems[index].badge["id"] == 0 ? const SizedBox() : Expanded(child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(120)),
                                child: CachedNetworkImage(
                                  imageUrl: filteredItems[index].badge['document'],
                                  imageBuilder: (context, imageProvider) => Container(
                                    height:45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(Radius.circular(120)),
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
                                  errorWidget: (context, url, error) => ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                                      child: Image.network(filteredItems[index].badge['document'],width: 45,height: 45,fit: BoxFit.contain,)
                                  ),
                                ),
                              ),
                              )
                            ],
                          ),
                        ),
                      )
                  ),
                )
            )):
            ListView.builder(
              itemCount: friends.length + 1,
              itemBuilder: (context, index) {
                if (index == friends.length) {
                  return IconButton(
                    onPressed: () {
                      // Refresh logic here
                      pagingation++;
                      setState(() {
                        getMyFriends(pagingation);
                      });

                    },
                    icon:   const Icon(Icons.refresh),color: primary,
                  );
                }

                return InkWell(
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
                  child: WidgetAnimator(
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 20,),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: (friends[index].badge["id"] == 1 ||
                                          friends[index].badge["id"] == 2 ||
                                          friends[index].badge["id"] == 3 ||
                                          friends[index].badge["id"] == 4 ||
                                          friends[index].badge["id"] == 5 ||
                                          friends[index].badge["id"] == 6 ||
                                          friends[index].badge["id"] == 7 ||
                                          friends[index].badge["id"] == 8 ||
                                          friends[index].badge["id"] == 9
                                      ) ? Colors.orange : Colors.transparent,
                                    ),
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: const BorderRadius.all(Radius.circular(120)),
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
                                              friends[index].name == null ? "" : friends[index].name,
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
                                              friends[index].username,
                                              style: const TextStyle(fontFamily: 'Montserrat'),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                friends[index].badge["id"] == 0
                                    ? const SizedBox()
                                    : Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(120)),
                                    child: CachedNetworkImage(
                                      imageUrl: friends[index].badge['document'],
                                      imageBuilder: (context, imageProvider) => Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(120)),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => SpinKitCircle(color: primary, size: 20,),
                                      errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(50)),
                                        child: Image.network(
                                          friends[index].badge['document'],
                                          width: 45,
                                          height: 45,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          )),
        ],
      ),
    );
  }
}
