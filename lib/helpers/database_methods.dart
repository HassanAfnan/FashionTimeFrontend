import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods {
  Future<void> addUserInfo(userData) async {
    FirebaseFirestore.instance.collection("users").add(userData).catchError((e) {
      //print(e.toString());
    });
  }

  getUserInfo(String email) async {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userEmail", isEqualTo: email)
        .get()
        .catchError((e) {
      //print(e.toString());
    });
  }

  searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection("users")
        .where('userName', isEqualTo: searchField)
        .get();
  }

  addChatRoom(chatRoom, chatRoomId) {
    FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      //print(e);
    });
  }

  addCallRoom(chatRoom, chatRoomId) {
    FirebaseFirestore.instance
        .collection("callRoom")
        .doc(chatRoomId)
        .set(chatRoom)
        .catchError((e) {
      //print(e);
    });
  }

  endCallRoom(chatRoomId) {
    FirebaseFirestore.instance
        .collection("callRoom")
        .doc(chatRoomId)
        .delete()
        .catchError((e) {
      //print(e);
    });
  }

  getChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }

  getGroupChats(String chatRoomId) async{
    return FirebaseFirestore.instance
        .collection("groupChat")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy('time')
        .snapshots();
  }


  addMessage(String chatRoomId, chatMessageData){
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData).catchError((e){
      //print(e.toString());
    });
  }

  blockChat(String user1,String user2){
    print("Entered");
    String id = "";
    FirebaseFirestore.instance.collection("chatRoom").where("users",arrayContains: user1).get().then((value){
      print(value.docs.length.toString());
      value.docs.forEach((element) {
        if(element.id.split("_")[0] == user2){
          print("In 0 ----> ${element.id}");
          id = element.id;
        }
        else if(element.id.split("_")[1] == user2){
          print("In 1 ----> ${element.id}");
          id = element.id;
        }
      });
    }).then((value2){
      FirebaseFirestore.instance.collection("chatRoom")
          .doc(id)
          .update({
        "isBlock": true
      }).then((value){
        print("Updated");
      })
          .catchError((e){
        print(e.toString());
      });
    }).catchError((e){
      print(e.toString());
    });
  }
  unBlockChat(String user1,String user2){
    print("Entered");
    String id = "";
    FirebaseFirestore.instance.collection("chatRoom").where("users",arrayContains: user1).get().then((value){
      print(value.docs.length.toString());
      value.docs.forEach((element) {
        if(element.id.split("_")[0] == user2){
          print("In 0 ----> ${element.id}");
          id = element.id;
        }
        else if(element.id.split("_")[1] == user2){
          print("In 1 ----> ${element.id}");
          id = element.id;
        }
      });
    }).then((value2){
      FirebaseFirestore.instance.collection("chatRoom")
          .doc(id)
          .update({
        "isBlock": false
      }).then((value){
        print("Updated");
      })
          .catchError((e){
        print(e.toString());
      });
    }).catchError((e){
      print(e.toString());
    });
  }


  deleteMessage(String chatRoomId, String docId){
    FirebaseFirestore.instance.collection("chatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(docId)
        .delete().catchError((e){
      //print(e.toString());
    });
  }

  addGroupMessage(String chatRoomId, chatMessageData){
    FirebaseFirestore.instance.collection("groupChat")
        .doc(chatRoomId)
        .collection("chats")
        .add(chatMessageData).catchError((e){
      //print(e.toString());
    });
  }

  Future<bool> addGroupMember(String chatRoomId,members,users){
    FirebaseFirestore.instance.collection("groupChat")
        .doc(chatRoomId)
        .update({
      "members": FieldValue.arrayUnion(members),
      "users": FieldValue.arrayUnion(users)
    })
        .catchError((e){
      print(e.toString());
    }).then((value){
      print("Updated");
    });
    return Future.value(false);
  }

  getUserChats(String itIsMyName) async {
    return await FirebaseFirestore.instance
        .collection("chatRoom")
        .where('users', arrayContains: itIsMyName)
        .snapshots();
  }

}