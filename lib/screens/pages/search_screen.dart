import 'dart:convert';

import 'package:FashionTime/models/story_model.dart';
import 'package:FashionTime/models/userHistory.dart';
import 'package:FashionTime/models/user_model.dart';
import 'package:FashionTime/screens/pages/all_history_pages/userSearchHistory.dart';
import 'package:FashionTime/screens/pages/story/stories.dart';
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
  int pagination=1;
  String lastSearchQuery = "";
  List<UserHistory> userHistory = [];

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

  getMyFriends(int pagination, {String searchQuery = ''}) {
    if (searchQuery != lastSearchQuery) {
      friends.clear();
      lastSearchQuery = searchQuery;
    }
    setState(() {
      loading = true;
    });

    try {
      https.get(
        Uri.parse("$serverUrl/user/api/allUsers/?page=$pagination&search=$searchQuery"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      ).then((value) {
        friends.clear();
        setState(() {
          loading = false;
        });

        var responseData = jsonDecode(value.body);
        var results = responseData['results'];

        results.forEach((data) {
          if (data["id"].toString() != id.toString() && data["isBlocked"] == false) {
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
                data["most_recent_story"] == null ? {"story":false} : data["most_recent_story"],
              ));
            });
          }
        });
      });
      getUserHistory();
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }

  void searchUser(String query) {
    setState(() {
      // Reset pagination to 1 if the query has changed
      if (query != lastSearchQuery) {
        pagination = 1;
        lastSearchQuery = query;
      }
    });

    // Perform search only if the query is not empty
    if (query.isNotEmpty) {
      getMyFriends(pagination, searchQuery: query);
    } else {
      // Clear the friends list only if the query is empty and it's different from the previous query
      if (lastSearchQuery.isNotEmpty) {
        setState(() {
          friends.clear();
        });
      }
      if(lastSearchQuery.isEmpty){
        setState(() {
          friends.clear();
          getMyFriends(pagination);
        });
      }
    }
  }

  addUserHistory(String id,String name, String username, String image){
    print(id);
    https.post(
      Uri.parse("$serverUrl/apiSearchedHistory/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "userId": id.toString(),
        "name": name,
        "username": username,
        "image": image
      })
    ).then((value){
      //print("History added");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FriendProfileScreen(
            id: id,
            username: username,
          ),
        ),
      ).then((value){
        getUserHistory();
      });
    });
  }

  getUserHistory(){
    userHistory.clear();
    https.get(
      Uri.parse("$serverUrl/apiSearchedHistory/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    ).then((value){
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

  String formatTimeDifference(String dateString) {
    DateTime createdAt = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    Duration difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      if (difference.inDays == 1) {
        return '1 day ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      int months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      int years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  viewStory(SearchModel story1){
    List<Story> storyList =[];
    if(story1.most_recent_story["is_close_friend"] == false){
      if (story1.most_recent_story.containsKey('upload')) {
        if (story1.most_recent_story['upload'] != null && story1.most_recent_story['upload'].containsKey('media')) {
          final media = story1.most_recent_story['upload']['media'];
          if (media is List && media.isNotEmpty) {
            final String url = media[0]['image'] ?? media[0]['video'];
            final String mediaTypeString = media[0]['type'];
            if (mediaTypeString != null) {
              final MediaType mediaType = mediaTypeString == 'image' ? MediaType.image : MediaType.video;
              String time = story1.most_recent_story['created'];
              final duration=formatTimeDifference(story1.most_recent_story['created']);
              final User user = User(
                  name: story1.most_recent_story['user']['name'],
                  profileImageUrl: story1.most_recent_story['user']['pic'] ?? '',
                  id: story1.most_recent_story['user']['id'].toString()
              );

              final Story story = Story(
                  url: url,
                  media: mediaType,
                  user: user,
                  viewedBy: story1.most_recent_story['viewed_by'],
                  storyId: story1.most_recent_story['id'],
                  duration: duration,
                  uploadObject: story1.most_recent_story['upload'],
                  closeFriend: story1.most_recent_story['is_close_friend'],
                  viewed_users: []
              );
              storyList.add(story);
            } else {
              debugPrint("Error: 'type' property missing in media object");
            }
          } else {
            // Handle case where 'media' is not a list or is empty
            debugPrint("Error: 'media' property is not a non-empty list");
          }
        } else {
          // Handle case where media content is absent and text is present
          final duration=formatTimeDifference(story1.most_recent_story['created']);
          final User user = User(
              name: story1.most_recent_story['user']['name'],
              profileImageUrl: story1.most_recent_story['user']['pic'] ?? '',
              id: story1.most_recent_story['user']['id'].toString()
          );
          print("HERE IS ID====> ${story1.most_recent_story['user']['id'].toString()}");
          print("HERE IS ID====> ${story1.most_recent_story['user']['name'].toString()}");
          final Story story = Story(
              url: story1.most_recent_story['text'], // No media URL
              media: MediaType.text, // Text content
              user: user,
              viewedBy: story1.most_recent_story['viewed_by'],
              storyId: story1.most_recent_story['id'],
              duration: duration,
              uploadObject: story1.most_recent_story['upload'],
              closeFriend: story1.most_recent_story['is_close_friend'],
              viewed_users: []
          );
          storyList.add(story);
        }
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StoryScreen(stories: storyList),
          ));
    }
    print("Story List "+storyList.toString());
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
                        stops: const [0.0, 0.99],
                        tileMode: TileMode.clamp,
                        colors:  <Color>[secondary, primary] ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16,),
                      Expanded(
                          child: TextField(
                            onChanged: (value){
                              searchUser(value);
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
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left:30.0, right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recent Searches"),
                GestureDetector(
                    onTap: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context) => UserSearchHistory())).then((value){
                        getUserHistory();
                      });
                    },
                    child: Text("View All",style: TextStyle(color: Colors.blue),))
              ],
            ),
          ),
          Container(
            height: userHistory.length <= 0 ? 50 : 150,
          child:userHistory.length <= 0 ? Center(child: Text("No Searches")) : ListView.builder(
            itemCount: userHistory.length <= 2 ? userHistory.length : 2,
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
                              // friends[index].badge["id"] == 0
                              //     ? const SizedBox()
                              //     : Expanded(
                              //   child: ClipRRect(
                              //     borderRadius: const BorderRadius.all(Radius.circular(120)),
                              //     child: CachedNetworkImage(
                              //       imageUrl: friends[index].badge['document'],
                              //       imageBuilder: (context, imageProvider) => Container(
                              //         height: 45,
                              //         width: 45,
                              //         decoration: BoxDecoration(
                              //           borderRadius: const BorderRadius.all(Radius.circular(120)),
                              //           image: DecorationImage(
                              //             image: imageProvider,
                              //             fit: BoxFit.contain,
                              //           ),
                              //         ),
                              //       ),
                              //       placeholder: (context, url) => SpinKitCircle(color: primary, size: 20,),
                              //       errorWidget: (context, url, error) => ClipRRect(
                              //         borderRadius: const BorderRadius.all(Radius.circular(50)),
                              //         child: Image.network(
                              //           friends[index].badge['document'],
                              //           width: 45,
                              //           height: 45,
                              //           fit: BoxFit.contain,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
        ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left:30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("All users"),
              ],
            ),
          ),
          loading == true ? SpinKitCircle(color: primary,size: 50,) :(friends.isEmpty ? const SizedBox() :
              Expanded(
                child: ListView.builder(
                    itemCount: friends.length + 1,
                    itemBuilder: (context, index) {
                      if (index == friends.length) {
                        return IconButton(
                          onPressed: () {
                            // Refresh logic here
                            pagination++;
                            setState(() {
                              getMyFriends(pagination);
                            });

                          },
                          icon:   const Icon(Icons.refresh),color: primary,
                        );
                      }

                      return InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => FriendProfileScreen(
                          //       id: friends[index].id,
                          //       username: friends[index].username,
                          //     ),
                          //   ),
                          // );
                          addUserHistory(friends[index].id,friends[index].name,friends[index].username,friends[index].pic);
                        },
                        child: WidgetAnimator(
                          GestureDetector(
                            onTap: () {
                              addUserHistory(friends[index].id,friends[index].name,friends[index].username,friends[index].pic);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 20,),
                                      GestureDetector(
                                        onTap:(friends[index].most_recent_story["story"] == false || friends[index].most_recent_story["is_close_friend"] == true) ? (){}: (){
                                          print("Story opened");
                                          viewStory(friends[index]);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(120)),
                                              border: Border.all(
                                                width: 3,
                                                color: (friends[index].most_recent_story["story"] == false || friends[index].most_recent_story["is_close_friend"] == true) ? Colors.transparent : primary,
                                              )
                                          ),
                                          child: Container(
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
              ])
          );

  }
}
