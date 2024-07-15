import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';

class PostLikeUserScreen extends StatefulWidget {
  var fashionId;
  PostLikeUserScreen({super.key, this.fashionId});

  @override
  State<PostLikeUserScreen> createState() => _PostLikeUserScreenState();
}

String id = '';
String token = '';
bool loading = true;
bool fanLoader=false;


class _PostLikeUserScreenState extends State<PostLikeUserScreen> {
  List<Map<String, dynamic>> users = [];
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    debugPrint(id);
    getUsers();
  }

  getUsers() {
    String url = "$serverUrl/fashionLikes/${widget.fashionId}/";
    try {
      https.get(Uri.parse(url), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        if (value.statusCode == 200) {
          final dynamic responseData = jsonDecode(value.body);
          if (responseData != null && responseData is Map<String, dynamic>) {
            final List<dynamic> results = responseData['results'] ?? [];

            setState(() {
              loading = false;
              users = List<Map<String, dynamic>>.from(results);
              debugPrint("all post data ${users.toString()}");
              debugPrint("post data length ${users.length}");
            });
          }
        } else {
          debugPrint("error received=======>");
        }
      });
    } catch (e) {
      debugPrint("error received=======>${e.toString()}");
    }
  }
  addFan(from,to){
    setState(() {
      fanLoader = true;
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
        fanLoader = false;
      });
      print(value.body.toString());
    }).catchError((value){
      setState(() {
        fanLoader = false;
      });
      print(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  ])),
        ),
        title: const Text(
          "Users who liked your post",
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
      ),
      body: loading
          ? SpinKitCircle(
              color: primary,
            )
          : loading == false && users.isEmpty
              ? const Center(
                  child: Text(
                  "No likes",
                  style: TextStyle(fontFamily: 'Montserrat'),
                ))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () {},
                        child: Container(
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(120)),
                                color: Colors.black),
                            child: const CircleAvatar()
                            // ClipRRect(
                            //   borderRadius: const BorderRadius.all(Radius.circular(120)),
                            //   child: CachedNetworkImage(
                            //     imageUrl: "",
                            //     imageBuilder: (context, imageProvider) => Container(
                            //       height: 50,
                            //       width: 50,
                            //       decoration: BoxDecoration(
                            //         borderRadius:
                            //         const BorderRadius.all(Radius.circular(120)),
                            //         image: DecorationImage(
                            //           image: imageProvider,
                            //           fit: BoxFit.cover,
                            //         ),
                            //       ),
                            //     ),
                            //     placeholder: (context, url) => SpinKitCircle(
                            //       color: primary,
                            //       size: 20,
                            //     ),
                            //     errorWidget: (context, url, error) => ClipRRect(
                            //         borderRadius:
                            //         const BorderRadius.all(Radius.circular(50)),
                            //         child: Image.network(
                            //           "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                            //           width: 50,
                            //           height: 50,
                            //         )),
                            //   ),
                            // ),
                            ),
                      ),
                      title: Text(users[index]['user']['username'].toString(),
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Montserrat')),
                      subtitle: Text(users[index]['user']['email'].toString(),
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Montserrat')),
                      trailing:
                      fanLoader?CircularProgressIndicator(color: primary,):
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primary),
                          onPressed: () {
                            addFan(id,users[index]['user']['id']);
                          },
                          child:

                          const Text("Fan",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat'))),
                    );
                  },
                ),
    );
  }
}
