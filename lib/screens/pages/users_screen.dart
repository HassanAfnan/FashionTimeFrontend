import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:flutter/material.dart';
import '../../animations/bottom_animation.dart';
import '../../models/chats_model.dart';
import '../../utils/constants.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
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
        title: Text("Friends",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: ListView.builder(
          itemCount: chatsList.length,
          itemBuilder: (context,index) => WidgetAnimator(
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListTile(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(
                    id: "12",
                    username: "username",
                  )));
                },
                leading: CircleAvatar(
                  radius: 30,
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      child: Image.network(chatsList[index].pic)),
                ),
                title: Text(chatsList[index].name,style: TextStyle(color: primary,fontSize: 20,fontWeight: FontWeight.bold,fontFamily: 'Montserrat'),),
                subtitle: Text(chatsList[index].email,style: TextStyle(fontFamily: 'Montserrat'),),
                trailing: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(icon: Icon(Icons.chat,color: Colors.green,),onPressed: (){},),
                      IconButton(icon: Icon(Icons.call,color: Colors.green,),onPressed: (){},),
                    ],
                  ),
                ),
              ),
            ),
          )
      ),
    );
  }
}
