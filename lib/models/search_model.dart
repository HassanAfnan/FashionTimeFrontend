class SearchModel {
  late String id;
  late String name;
  late String pic;
  late String email;
  late String username;
  late String fcmToken;
  late Map<String,dynamic> badge;
  late Map<String,dynamic> most_recent_story;

  SearchModel(
      this.id,
      this.name,
      this.pic,
      this.email,
      this.username,
      this.fcmToken,
      this.badge,
      this.most_recent_story
      );
}

