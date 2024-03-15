import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import '../../../animations/bottom_animation.dart';
import '../../../models/chats_model.dart';
import '../../../utils/constants.dart';
import '../friend_profile.dart';

class BlockList extends StatefulWidget {
  const BlockList({Key? key}) : super(key: key);

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  String id = "";
  String search = "";
  String token = "";
  bool loading = false;
  List<ChatModel> friends = [];
  bool loading1 = false;
  List<ChatModel> filteredItems = [];
  final FocusNode _searchFocusNode = FocusNode();
  String name = "";

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString("name")!;
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
          Uri.parse("${serverUrl}/user/api/BlockUser/block_list/"),
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
                data["blocked_user_info"]["id"].toString(),
                data["blocked_user_info"]["name"] == null ?"No name":data["blocked_user_info"]["name"],
                data["blocked_user_info"]["pic"] == null?"https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w":data["blocked_user_info"]["pic"],
                data["blocked_user_info"]["email"] == null?"":data["blocked_user_info"]["email"],
                data["blocked_user_info"]["username"],
                ""
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
  unBlockUser(user,user1,user2){
    setState(() {
      loading1 = true;
    });

    https.delete(
        Uri.parse("${serverUrl}/user/api/BlockUser/${user}/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token}"
        }
    ).then((value){
      print(value.body.toString());
      setState(() {
        loading1 = false;
      });
      DatabaseMethods().unBlockChat(user1, user2);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: primary,
          title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
          content: Text("User unblocked successfully.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
          actions: [
            TextButton(
              child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
              onPressed:  () {

                setState(() {
                  friends.clear();
                  filteredItems.clear();
                  Navigator.pop(context);
                  getMyFriends();
                 // Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      );
    }).catchError((){
      setState(() {
        loading1 = false;
      });
      Navigator.pop(context);
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
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])
          ),),
        backgroundColor: primary,
        title: Text("Blocked Accounts",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: loading == true ? SpinKitCircle(size: 50,color: primary,) : (friends.length<=0 ? Center(child: Text("No Blocked Users")) :

      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),

      WidgetAnimator(
      Container(
      alignment: Alignment.bottomCenter,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  stops: [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors:  <Color>[secondary, primary],),
            ),
            child: Row(
              children: [
                SizedBox(width: 16,),
                Expanded(
                    child: TextField(
                      onChanged: (value){
                        SearchUser(value);
                      },
                      style: TextStyle(color: ascent,fontFamily: 'Montserrat'),
                      cursorColor: ascent,
                      //style: simpleTextStyle(),
                      decoration: InputDecoration(
                          fillColor: ascent,
                          hintText: "Search for blocked users ...",
                          hintStyle: TextStyle(
                            color: ascent,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                          border: InputBorder.none
                      ),
                    )),
                SizedBox(width: 16,),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                ascent,
                                ascent
                              ],
                              begin: FractionalOffset.topLeft,
                              end: FractionalOffset.bottomRight
                          ),
                          borderRadius: BorderRadius.circular(40)
                      ),
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.search,color: primary,)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      )
          ,
          SizedBox(height: 20,),
          Expanded(
              child: filteredItems.isNotEmpty || search.isNotEmpty ? (filteredItems.isEmpty
                  ? const Center(
                child: Text(
                  'No Results Found',
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context,index) => WidgetAnimator(
                      GestureDetector(
                        // onTap: (){
                        //   Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                        //     id: filteredItems[index].id,
                        //     username: filteredItems[index].username,
                        //   )));
                        // },
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(width: 20,),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(120))
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(120)),
                                  child: CachedNetworkImage(
                                    imageUrl: filteredItems[index].pic,
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
                                    placeholder: (context, url) => SpinKitCircle(color: primary,size: 60,),
                                    errorWidget: (context, url, error) => ClipRRect(
                                        borderRadius: BorderRadius.all(Radius.circular(50)),
                                        child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 50,height: 50,)
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(

                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(filteredItems[index].name == null ?"":filteredItems[index].name,style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text("@"+filteredItems[index].username,style: TextStyle(fontFamily: 'Montserrat'),),
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(width: 44),
                              GestureDetector(
                                onTap: (){
                                  unBlockUser(friends[index].id,name,friends[index].name);

                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Text("Unblock",style: TextStyle(
                                    fontSize: 16,
                                      color: Colors.green
                                  ),),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                  )
              )):
              ListView.builder(
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
                                height:50,
                                width: 50,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
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
                                        child: Image.network("https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",width: 40,height: 40,)
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                ),
                              ),
                             // SizedBox(width: MediaQuery.of(context).size.width * 0.2,),
                              GestureDetector(
                                onTap: (){
                                  unBlockUser(friends[index].id,name,friends[index].name);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 25.0),
                                  child: Text("Unblock",style: TextStyle(
                                    fontSize: 16,
                                      color: Colors.green
                                  ),),
                                ),
                              )

                            ],
                          ),
                        ),
                      )
                  )
              ),

          ),
        ],
      )),
    );
  }
}
// ListView.builder(
//     itemCount: friends.length,
//     itemBuilder: (context,index) => WidgetAnimator(
//         GestureDetector(
//           onTap: (){
//             // Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
//             //   id: friends[index].id,
//             // )));
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Row(
//               children: [
//                 SizedBox(width: 20,),
//                 Container(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(120))
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.all(Radius.circular(120)),
//                     child: CachedNetworkImage(
//                       imageUrl: friends[index].pic,
//                       imageBuilder: (context, imageProvider) => Container(
//                         height:50,
//                         width: 50,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.all(Radius.circular(120)),
//                           image: DecorationImage(
//                             image: imageProvider,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       placeholder: (context, url) => SpinKitCircle(color: primary,size: 20,),
//                       errorWidget: (context, url, error) => Icon(Icons.error),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20,),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text(friends[index].name == null ?"":friends[index].name,style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Text("@"+friends[index].username,style: TextStyle(fontFamily: 'Montserrat'),),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: MediaQuery.of(context).size.width * 0.2,),
//                 GestureDetector(
//                   onTap: (){
//                     unBlockUser(friends[index].id);
//                   },
//                   child: Text("Unblock",style: TextStyle(
//                     color: Colors.green
//                   ),),
//                 ),
//                 SizedBox(width: 10,),
//               ],
//             ),
//           ),
//         )
//     )
// ),
