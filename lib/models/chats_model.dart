class ChatModel {
  late String id;
  late String name;
  late String pic;
  late String email;
  late String username;
  late String fcmToken;

  ChatModel(
      this.id,
      this.name,
      this.pic,
      this.email,
      this.username,
      this.fcmToken
      );
}

List<ChatModel> chatsList = [
];