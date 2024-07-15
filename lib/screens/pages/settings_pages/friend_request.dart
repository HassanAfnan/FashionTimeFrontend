import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as https;
import '../../../utils/constants.dart';
class FriendRequest extends StatefulWidget {
  const FriendRequest({super.key});

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}
String token='';
String id='';
String userName='';
String requestId='';
bool isGetRequest=false;
List<Map<String, dynamic>> friendRequests = [];
bool loading =false;
bool isRejected=false;
bool requestLoader = false;
class _FriendRequestState extends State<FriendRequest> {
  deleteNotification(id){
    String url="$serverUrl/notificationsApi/$id/";
    https.delete(Uri.parse(url),headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      debugPrint("deleted notification======>${value.statusCode}");
      setState(() {
        getFriendRequest();
      });
    }).onError((error, stackTrace) {
      debugPrint("error received while removing this notifications");
    });
  }
  matchFriendRequest(id1,notificationId){
    debugPrint("Match Friend id");
    try{
      https.get(
          Uri.parse("$serverUrl/followRequests/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          }
      ).then((value){
        debugPrint("id is =======>$id");
        jsonDecode(value.body).forEach((request){
          if(request["from_user"].toString() == id1.toString() && request["to_user"].toString() == id.toString()){
            setState(() {
              loading = false;
              isGetRequest = true;
              requestId = request["id"].toString();
              isRejected?rejectRequest(requestId):acceptRequest(requestId);
              deleteNotification(notificationId);
            });
            debugPrint(isGetRequest.toString());
            debugPrint(requestId.toString());
          }
          else if(request["from_user"].toString() == id.toString() && request["to_user"].toString() == id1.toString()){
            setState(() {
              loading = false;
            });
            requestId = request["id"].toString();
            isRejected?rejectRequest(requestId):acceptRequest(requestId);
            deleteNotification(notificationId);
          }
          else{
            setState(() {
              loading = false;
              deleteNotification(notificationId);
            });
            debugPrint(isGetRequest.toString());
          }
        });
        setState(() {
          loading = false;
        });
        debugPrint(jsonDecode(value.body).toString());

      });
    }catch(e){
      setState(() {
        loading = false;
      });
      debugPrint("Error --> $e");
    }
  }
  acceptRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_accept_request/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      debugPrint("request status======>${value.body}");
      // getMyFriends(widget.id);
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      debugPrint(value);
    });
  }
  rejectRequest(userid){
    setState(() {
      requestLoader = true;
    });
    https.post(
        Uri.parse("$serverUrl/follow_reject_request/$userid/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        }
    ).then((value){
      setState(() {
        requestLoader = false;
      });
      debugPrint(value.body.toString());
    }).catchError((value){
      setState(() {
        requestLoader = false;
      });
      debugPrint(value.toString());
    });
  }
  getFriendRequest() {
    friendRequests.clear();
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/notificationsApi/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {

        jsonDecode(value.body).forEach((data) {
          if (
              data['title'] == 'New Follow Request') {
            setState(() {
              loading=false;
              friendRequests.add({
                "title": data["title"].toString(),
                "body": data["body"].toString(),
                "action": data["action"].toString() ,
                "updated": data["updated"].toString(),
                'sender':data['sender']['id'].toString(),
                "id":data['id'].toString()
              });
            });
          }
        });
        setState(() {
          loading=false;
        });
        debugPrint("total request=====>${friendRequests.length}");
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("Error received========>${e.toString()}");
    }
  }
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    userName = preferences.getString('username')!;
    debugPrint(token);
    debugPrint("the user name of user is ============>$userName");
    getFriendRequest();
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
  @override
  void initState() {
    // TODO: implement initState
    getCashedData();
    super.initState();
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
                  stops: const [0.0, 0.99],
                  tileMode: TileMode.clamp,
                  colors: <Color>[
                    secondary,
                    primary,
                  ])),
        ),
        backgroundColor: primary,
        title: const Text(
          "Friend Requests",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: loading?SpinKitCircle(color: primary,):
          friendRequests.isEmpty?const Center(child: Text("No requests",style: TextStyle(fontFamily: 'Montserrat',fontSize: 20),)):
      ListView.builder(
        itemCount: friendRequests.length,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ListTile(
              title: Text(
                friendRequests[index]['body'],
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      matchFriendRequest(friendRequests[index]['sender'],friendRequests[index]['id']);
                    },
                    child: const Text(
                      "Accept",
                      style: TextStyle(
                        color: Colors.green,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      isRejected=true;
                      matchFriendRequest(friendRequests[index]['sender'],friendRequests[index]['id']);
                    },
                    child: const Text(
                      "Reject",
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
              trailing: Text(
                formatTimeDifference(friendRequests[index]['updated'].toString()),
                style: const TextStyle(fontFamily: 'Montserrat'),
              ),
            ),
          );
        },
      )

      ,
    );
  }
}
