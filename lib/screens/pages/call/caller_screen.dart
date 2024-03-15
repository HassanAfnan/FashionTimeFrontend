import 'package:FashionTime/authentication/splash_screen.dart';
import 'package:flutter/material.dart';

import '../../../helpers/database_methods.dart';
import '../../../utils/constants.dart';

class CallerScreen extends StatefulWidget {
  final String callRoomId;
  final String name;
  final String pic;
  final String email;
  const CallerScreen({Key? key, required this.callRoomId, required this.name, required this.pic, required this.email}) : super(key: key);

  @override
  State<CallerScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<CallerScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  endCall(chatRoomId){
    DatabaseMethods().endCallRoom(chatRoomId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.pic),
          fit: BoxFit.fill,
        ),
      ),
      child: WillPopScope(
        onWillPop: () async {
          print('The user tries to pop()');
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: SizedBox(),
            centerTitle: true,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            title: Text("",style: TextStyle(fontFamily: 'Montserrat'),),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        widget.name,
                       style: TextStyle(
                         fontSize: 36,
                         fontWeight: FontWeight.bold,
                         color: Colors.white
                       ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom:MediaQuery.of(context).size.height * 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 5,),
                    GestureDetector(
                      onTap: (){
                        endCall(widget.callRoomId);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.red,
                        child: Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5,),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
