import 'dart:convert';

import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/models/notification_model.dart';
import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/post_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String id = "";
  String token = "";
  String userName = '';
  bool loading = false;
  List<Map<String, dynamic>> notifications = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    userName = preferences.getString('username')!;
    print(token);
    debugPrint("the user name of user is ============>$userName");
    getNotifications();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getNotifications() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("${serverUrl}/notificationsApi/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      }).then((value) {
        print("Notification --> " + jsonDecode(value.body).toString());
        jsonDecode(value.body).forEach((data) {
          setState(() {
            notifications.add({
              "title": data["title"].toString(),
              "body": data["body"].toString(),
              "action": data["action"].toString(),
              "time": data["updated"].toString(),
              "type": data["action"].toString(),
              "sender": data["sender"]
            });
          });
        });
        readNotification();
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> ${e}");
    }
  }

  readNotification() {
    https.post(
        Uri.parse("${serverUrl}/notificationsmark-all-notifications-as-read/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token}"
        }).then((value) {
      print(value.body.toString());
      setState(() {
        loading = false;
      });
    }).catchError(() {
      print("Error");
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                  ])),
        ),
        backgroundColor: primary,
        title: const Text(
          "Notifications",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: loading == true
          ? SpinKitCircle(
              color: primary,
              size: 50,
            )
          : (notifications.length <= 0
              ? const Center(
                  child: Text("No Notifications"),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return notifications[index]['title'] ==
                                "Dislike on fashion" ||
                            (notifications[index]['action'] ==
                                    "comment_fashion" &&
                                notifications[index]['user']?['username'] ==
                                    userName)
                        ? null
                        : WidgetAnimator(
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 8, bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  if (notifications[index]["type"] ==
                                      "send_follow_request") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfileScreen(
                                                  id: notifications[index]
                                                          ["sender"]["id"]
                                                      .toString(),
                                                  username: notifications[index]
                                                      ["sender"]["username"],
                                                )));
                                  } else if (notifications[index]["type"] ==
                                      "fashion_created") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostDetail(
                                                  postId: notifications[index]
                                                          ["body"]
                                                      .toString()
                                                      .split("(Post ID: ")[1],
                                                )));
                                  } else if (notifications[index]["type"] ==
                                      "like_fashion") {
                                    // Navigator.push(context,MaterialPageRoute(builder: (context) => PostDetail(
                                    //   postId: notifications[index]["body"].toString().split("(Post ID: ")[1],
                                    // )));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfileScreen(
                                                  id: notifications[index]
                                                          ["sender"]["id"]
                                                      .toString(),
                                                  username: notifications[index]
                                                      ["sender"]["username"],
                                                )));
                                  } else if (notifications[index]["type"] ==
                                      "dislike_fashion") {
                                    // Navigator.push(context,MaterialPageRoute(builder: (context) => PostDetail(
                                    //   postId: notifications[index]["body"].toString().split("(Post ID: ")[1],
                                    // )));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfileScreen(
                                                  id: notifications[index]
                                                          ["sender"]["id"]
                                                      .toString(),
                                                  username: notifications[index]
                                                      ["sender"]["username"],
                                                )));
                                  } else if (notifications[index]["type"] ==
                                      "comment_fashion") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostDetail(
                                                  postId: notifications[index]
                                                          ["body"]
                                                      .toString()
                                                      .split("(Post ID: ")[1],
                                                )));
                                  } else if (notifications[index]["type"] ==
                                      "accept_follow_request") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FriendProfileScreen(
                                                  id: notifications[index]
                                                          ["sender"]["id"]
                                                      .toString(),
                                                  username: notifications[index]
                                                      ["sender"]["username"],
                                                )));
                                  }
                                  //readNotification(notifications[index]["id"]);
                                },
                                child: Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: primary,
                                        child: notifications[index]['title'] ==
                                                    "New like on fashion" ||
                                                notifications[index]['title'] ==
                                                    "Dislike on fashion"
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0.6),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                120))),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(120)),
                                                  child: CachedNetworkImage(
                                                    imageUrl: notifications[
                                                                        index]
                                                                    ["sender"]
                                                                ["pic"] ==
                                                            null
                                                        ? "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*rglk9r*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzMuNjAuMC4w"
                                                        : notifications[index]
                                                            ["sender"]["pic"],
                                                    imageBuilder: (context,
                                                            imageProvider) =>
                                                        Container(
                                                      // height:MediaQuery.of(context).size.height * 0.7,
                                                      // width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        image: DecorationImage(
                                                          image: imageProvider,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    placeholder:
                                                        (context, url) =>
                                                            SpinKitCircle(
                                                      color: primary,
                                                      size: 60,
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
                                                            child:
                                                                Image.network(
                                                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.9,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.9,
                                                            )),
                                                  ),
                                                ),
                                              )
                                            : const Icon(
                                                Icons.notifications_active,
                                                color: ascent,
                                              ),
                                      ),
                                      title: notifications[index]
                                                      ['title'] ==
                                                  "New like on fashion" ||
                                              notifications[index]['title'] ==
                                                  "Dislike on fashion" ||
                                              notifications[index]['title'] ==
                                                  "New like on reel" ||
                                              notifications[index]['title'] ==
                                                  'New Fashion Created' ||
                                              notifications[index]['title'] ==
                                                  'Follow Request Accepted'
                                          ? const SizedBox()
                                          : notifications[index]['title'] ==
                                                  'New Follow Request'
                                              ? Text(
                                                  notifications[index]["title"],style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontFamily: 'Montserrat'))
                                              : Text(
                                                  notifications[index]["title"],
                                                  style: TextStyle(
                                                      color: primary,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily: 'Montserrat'),
                                                ),
                                      subtitle: Text(
                                        (notifications[index]["type"] ==
                                                        "fashion_created" ||
                                                    notifications[index]
                                                            ["type"] ==
                                                        "like_fashion" ||
                                                    notifications[index]
                                                            ["type"] ==
                                                        "comment_fashion") ||
                                                notifications[index]['type'] ==
                                                    "like_fashion_reel"
                                            ? notifications[index]["body"]
                                                .toString()
                                                .split("(")[0]
                                            : notifications[index]['title'] ==
                                                    "Dislike on fashion"
                                                ? null
                                                : notifications[index]["body"],
                                        style: TextStyle(
                                            color: primary,
                                            fontSize: 13,
                                            fontFamily: 'Montserrat'),
                                      ),
                                      trailing:
                                          //Text(DateFormat('hh:mm a').format(DateTime.parse(notifications[index]["time"]).toLocal()),style: TextStyle(fontFamily: 'Montserrat'),),
                                          notifications[index]['title'] ==
                                                  "Dislike on fashion"
                                              ? null


                                              : Text(
                                                  formatNotificationTime(
                                                      notifications[index]
                                                          ["time"]),
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          'Montserrat'))),
                                ),
                              ),
                            ),
                          );
                  })),
    );
  }

  String formatNotificationTime(String rawTime) {
    DateTime notificationTime = DateTime.parse(rawTime).toLocal();
    DateTime now = DateTime.now();

    // Calculate the difference in days
    int differenceInDays = now.difference(notificationTime).inDays;

    // Format the time using RelativeDateFormat if it's less than a week
    if (differenceInDays == 0) {
      return DateFormat('MM/dd/yyyy ').format(notificationTime);
    } else if (differenceInDays == 1) {
      return 'Yesterday.';
    }
    // else if (differenceInDays>0&&differenceInDays<7 ) {
    //   return "This week.";
    // } else if(differenceInDays>7&&differenceInDays<14 ){
    //   // Format the time using your desired format for older dates
    //   return "A week ago.";
    // }
    // else if(differenceInDays>14&&differenceInDays<21){
    //   return '2 weeks ago';
    // }
    else {
      return DateFormat('MM/dd/yyyy ').format(notificationTime);
    }
  }
}
