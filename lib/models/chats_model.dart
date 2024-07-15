class ChatModel {
  late String id;
  late String name;
  late String pic;
  late String email;
  late String username;
  late String fcmToken;
  bool? isfan;
  bool? isCloseFriend;

  ChatModel(
      this.id,
      this.name,
      this.pic,
      this.email,
      this.username,
      this.fcmToken,
      {
        this.isfan,
        this.isCloseFriend
      }
      );
}

List<ChatModel> chatsList = [
];