import 'package:cached_network_image/cached_network_image.dart';
import 'package:FashionTime/screens/pages/groups/add_new_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../utils/constants.dart';

class GroupDetails extends StatefulWidget {
  final String chatRoomId;
  final String name;
  final String pic;
  final String memberCount;
  final List<dynamic> members;
  const GroupDetails({Key? key, required this.chatRoomId, required this.name, required this.pic, required this.memberCount, required this.members}) : super(key: key);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        title: Text("Group Info"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: "ABC",
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(120))
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(120)),
                    child: CachedNetworkImage(
                      imageUrl: widget.pic,
                      imageBuilder: (context, imageProvider) => Container(
                        height:150,
                        width: 150,
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
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.name,style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),)
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Group • ${widget.memberCount} participants")
            ],
          ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewMember(
                groupID: widget.chatRoomId,
                previousGroup: widget.members,
              )));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.add),
                Text(" Add New"),
                SizedBox(width: 30,)
              ],
            ),
          ),
          SizedBox(height: 10,),
          widget.members.length <= 0 ? Expanded(child: Center(child: Text("No Members"),)) : Expanded(
            child: ListView.builder(
                itemCount: widget.members.length,
                itemBuilder: (context,index){
                  return Padding(
                    padding: const EdgeInsets.only(left:20.0,right: 20.0,bottom: 15),
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.all(Radius.circular(120))
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(120)),
                            child: CachedNetworkImage(
                              imageUrl: widget.members[index]["pic"],
                              imageBuilder: (context, imageProvider) => Container(
                                height:40,
                                width: 40,
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
                             mainAxisAlignment:MainAxisAlignment.start,
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              Text(widget.members[index]["name"],style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18),),
                              SizedBox(height: 5,),
                              Text("@${widget.members[index]["username"]}",style: TextStyle(fontSize: 16),),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            showModalBottomSheet(
                                context: context,
                                builder: (builder){
                                  return new Container(
                                    height: 120.0,
                                    child: new Container(
                                        decoration: new BoxDecoration(
                                            borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(10.0),
                                                topRight: const Radius.circular(10.0))),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left:8.0),
                                              child: ListTile(
                                                leading: Icon(Icons.person_remove),
                                                title: Text("Remove"),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.pop(context);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(left:8.0),
                                                child: ListTile(
                                                  leading: Icon(Icons.close),
                                                  title: Text("Close"),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                    ),
                                  );
                                }
                            );
                          },
                          icon: Icon(Icons.arrow_forward_ios),
                        ),
                      ],
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}
