import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FashionTime/screens/pages/groups/all_groups.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../animations/bottom_animation.dart';
import '../../../utils/constants.dart';

class AddGroup extends StatefulWidget {
  final List<Map<String,dynamic>> members;
  final List<String> users;
  AddGroup({Key? key, required this.members, required this.users}) : super(key: key);

  @override
  State<AddGroup> createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  bool progress1 = false;
  String ownerName = "";
  String ownerId = "";
  String ownerToken = "";
  String ownerEmail = "";
  String ownerPic = "";

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    ownerId = preferences.getString("id")!;
    ownerToken = preferences.getString("fcm_token")!;
    ownerName = preferences.getString("name")!;
    ownerEmail = preferences.getString("email")!;
    ownerPic = preferences.getString("pic")!;
    print(ownerToken);
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
        title: Text("Add Group",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: ListView(
        children: [
          SizedBox(height: 10,),
          WidgetAnimator(
            Padding(
              padding: const EdgeInsets.only(left:30.0,right: 30.0,top: 8.0,bottom: 8.0),
              child: Container(
                child: TextField(
                  controller: name,
                  style: TextStyle(
                      color: primary,
                      fontFamily: 'Montserrat'
                  ),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                        //color: Colors.black54,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat'
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: primary),
                      ),
                      focusColor: primary,
                      alignLabelWithHint: true,
                      hintText: "Enter group name"
                  ),
                  cursorColor: primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          WidgetAnimator(
            Padding(
              padding: const EdgeInsets.only(left:30.0,right: 30.0,top: 8.0,bottom: 8.0),
              child: Container(
                child: TextField(
                  controller: description,
                  maxLines: 5,
                  style: TextStyle(
                      color: primary,
                      fontFamily: 'Montserrat'
                  ),
                  decoration: InputDecoration(
                      hintStyle: TextStyle(
                        //color: Colors.black54,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat'
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: primary),
                      ),
                      focusColor: primary,
                      alignLabelWithHint: true,
                      hintText: "Enter group description"
                  ),
                  cursorColor: primary,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:Container(
        height: 75,
        child: Column(
          children: [
            WidgetAnimator(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    progress1 == true ? SpinKitCircle(color: primary,size: 50,) : Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  )
                              ),

                              backgroundColor: MaterialStateProperty.all(primary),
                              padding: MaterialStateProperty.all(EdgeInsets.only(
                                  top: 8,bottom: 8,
                                  left:MediaQuery.of(context).size.width * 0.26,right: MediaQuery.of(context).size.width * 0.26)),
                              textStyle: MaterialStateProperty.all(
                                  const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                          onPressed: () {
                            if(name.text.isNotEmpty){
                              String uuid = Uuid().v4();
                              print("uuid "+uuid.toString());
                              createGroup(
                                  {
                                    "roomID":uuid,
                                    "group_name": name.text,
                                    "description": description.text,
                                    "members": widget.members,
                                    "users": widget.users,
                                    "owner": {
                                      "ownerId": ownerId,
                                      "ownerToken": ownerToken,
                                      "ownerName": ownerName,
                                      "ownerEmail": ownerEmail,
                                      "ownerPic": ownerPic
                                    }
                                  },
                                  uuid
                              );
                            }
                            else{
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: primary,
                                  title: Text("FashionTime",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
                                  content: Text("Group name can not be empty",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
                                  actions: [
                                    TextButton(
                                      child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
                                      onPressed:  () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }

                          },
                          child: const Text('Create Group',style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat'
                          ),)),
                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
  createGroup(chatMessageData,docID){
    setState(() {
      progress1 = true;
    });
    FirebaseFirestore.instance.collection("groupChat")
        .doc(docID)
        .set(chatMessageData)
        .then((value){
          print("Created");
        setState(() {
          progress1 = false;
        });
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context,MaterialPageRoute(builder: (context) => AllGroups()));
    })
        .catchError((e){
      setState(() {
        progress1 = false;
      });
         print(e.toString());
    });
  }
}
