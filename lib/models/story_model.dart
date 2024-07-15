import 'package:FashionTime/models/user_model.dart';

enum MediaType {
  image,
  video,
  text
}
class Story {
  var url;
  final MediaType media;
  final User user;
  var viewedBy;
  var uploadObject;
  var closeFriend;
  final int storyId;
  final String duration;
  final List<dynamic> viewed_users;

   Story( {
     required this.duration,
    required this.url,
    required this.media,
    required this.user,
    this.viewedBy,
     this.uploadObject,
     this.closeFriend,
     required this.storyId,
     required this.viewed_users
  });
}