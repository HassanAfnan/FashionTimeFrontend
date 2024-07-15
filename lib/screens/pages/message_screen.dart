import 'dart:convert';
import 'package:FashionTime/screens/pages/reactions/reactions.dart';
import 'package:FashionTime/screens/pages/shared_post.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../animations/bottom_animation.dart';
import '../../helpers/multipart_request.dart';
import '../../utils/constants.dart';
import 'package:http/http.dart' as https;
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'friend_profile.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:giphy_picker/giphy_picker.dart';

class MessageScreen extends StatefulWidget {
  final String friendId;
  final String chatRoomId;
  final String name;
  final String pic;
  final String email;
  final String fcm;
  final bool isBlocked;
  final String? share;
  final String? postId;
  const MessageScreen(
      {Key? key,
      required this.name,
      required this.pic,
      required this.email,
      required this.chatRoomId,
      required this.fcm,
      required this.isBlocked,
      required this.friendId,
      this.share,
      this.postId})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

String? repliedMessage;

class _MessageScreenState extends State<MessageScreen> {
  final _controller = ScrollController();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
  bool showEmojiKeyboard = false;
  final TextEditingController controller = TextEditingController();
  List<String> backgrounds = [
    ' ',
    'assets/bg1.jpg',
    'assets/bg2.jpg',
    'assets/bg3.jpg',
    'assets/bg4.jpg',
    'assets/bg5.jpg',
    'assets/bg6.jpg',
    'assets/bg7.jpg',
    'assets/bg8.jpg',
    'assets/bg9.jpg',
    'assets/bg10.jpg',
    'assets/bg11.jpg',
    'assets/bg12.jpg'
  ];

  int ind = 0;

  String name = "";
  String pic = "";
  File _video = File("");
  File _cameraVideo = File("");
  File _image = File("");
  File _cameraImage = File("");
  ImagePicker picker = ImagePicker();
  double progress = 0;
  String result = "";
  String id = "";
  String token = "";
  String videoLink = "";
  String imageLink = '';
  String fileLink = '';
  bool isReelUploaded = false;
  bool isLoading = false;
  File? fileVideo;
  bool value = true;
  Uint8List? thumbnailBytes;
  int? videoSize;
  var decoded;
  GiphyGif? _gif;
  final FocusNode messageFocusNode = FocusNode();

  bool checkedValue = true;
  List<Map<String, String>> media = [];
  List<Map<String, String>> media1 = [];
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name = preferences.getString("name")!;
    pic = preferences.getString("pic")!;
    print("your name is $name");
    print(pic);
    getIndex();
    messageEditingController.text =
        (widget.share == null ? "" : "${widget.share})${widget.postId}")!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      });
    });
  }

  getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ind = int.parse(prefs.getString("index") == null
          ? "0"
          : prefs.getString("index").toString());
    });
    getUserInfogetChats();
  }
  addMessage() async {
    if (messageEditingController.text.isNotEmpty && repliedMessage != null) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, messageEditingController.text, widget.fcm);

      setState(() {
        messageEditingController.text = "";
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    }
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": messageEditingController.text,
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, messageEditingController.text, widget.fcm);

      setState(() {
        messageEditingController.text = "";
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    } else if (imageLink != '') {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": imageLink,
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, "photo", widget.fcm);
      setState(() {
        messageEditingController.text = "";
        imageLink = '';
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    } else if (videoLink != '') {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": videoLink,
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, "video", widget.fcm);
      setState(() {
        messageEditingController.text = "";
        videoLink = '';
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    } else if (fileLink != '') {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": fileLink,
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, "Document", widget.fcm);
      setState(() {
        messageEditingController.text = "";
        fileLink = '';
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    } else if (_gif != null) {
      debugPrint("gif if block called");
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": _gif?.images.original?.url.toString(),
        'time': DateTime.now().millisecondsSinceEpoch,
        'image': pic,
        'reply': repliedMessage,
        "emoji":"none"
      };

      DatabaseMethods().addMessage(widget.chatRoomId!, chatMessageMap);
      _controller.jumpTo(_controller.position.maxScrollExtent);
      await DatabaseMethods().getIsMuteField(widget.chatRoomId!)
          ? null
          : sendNotification(name!, "Document", widget.fcm);
      setState(() {
        messageEditingController.text = "";
        _gif = null;
        repliedMessage = null;
      });
      FocusScope.of(context).unfocus();
    }
  }
  sendNotification(String name, String message, String token) async {
    print("Entered");
    print("1- $name");
    //print("2- "+widget.person_name!.toString());
    var body = jsonEncode(<String, dynamic>{
      "to": token,
      "notification": {
        "title": name,
        "body": message,
        "mutable_content": true,
        "sound": "Tri-tone"
      },
      "data": {
        "url": "https://www.w3schools.com/w3images/avatar2.png",
        "dl": "<deeplink action on tap of notification>"
      }
    });

    https
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAIgQSOH0:APA91bGZExBIg_hZuaqTYeCMB2ulE_iiRXY8kTYH6MqEpimm6WIshqH6GAhoor1MGnGl2dDbvJqWNRzEGBm_17Kd6-vS-BHZD31HZu_EFCKs5cOQh8EJzpKP2ayJicozOU4csM528EBy',
      },
      body: body,
    )
        .then((value1) {
      print(value1.body.toString());
    });
  }
  getUserInfogetChats() {
    DatabaseMethods().getChats(widget.chatRoomId!).then((val) {
      setState(() {
        chats = val;
      });
    });
  }
  uploadFile(filePath) async {
    var decoded;
    final request = MultipartRequest(
      'POST',
      Uri.parse("$serverUrl/fileUploader/"),
      onProgress: (int bytes, int total) {
        setState(() {
          progress = bytes / total;
          result = 'progress: $progress ($bytes/$total)';
        });
        print('progress: $progress ($bytes/$total)');
      },
    );

    request.files.add(await https.MultipartFile.fromPath(
      'document',
      filePath,
      contentType: MediaType('pdf', 'doc'),
    ));

    request.send().then((value) {
      setState(() {
        result = "";
      });
      print(value.stream.toString());
      value.stream.forEach((element) {
        decoded = utf8.decode(element);
        print("file link============>" + jsonDecode(decoded)["document"]);
        fileLink = jsonDecode(decoded)["document"];
        setState(() {
          media.add({"image": jsonDecode(decoded)["document"], "type": "file"});
          media1.add({"image": filePath, "type": "file"});
          Fluttertoast.showToast(
              msg: "Done! Proceed to continue", backgroundColor: primary);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: primary,
                title: const Text('File Selected'),
                content: Text("${jsonDecode(decoded)["document"]}"),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      addMessage();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        });
      });
    });
  }
  _pickVideo() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);

    try {
      MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
        pickedFile!.path,
        quality: VideoQuality.Res640x480Quality, // Adjust quality as needed
        deleteOrigin:
            false, // Set to true if you want to delete the original video
        includeAudio: true, // Set to false to exclude audio
      );

      if (compressedVideoInfo != null && compressedVideoInfo.path != null) {
        _video = File(compressedVideoInfo.path!);
        uploadVideoMedia(compressedVideoInfo.path!);
      } else {
        debugPrint("bad compressing");
      }
    } catch (error) {
      debugPrint(
          "error compressing and uploading video received this error ${error.toString()}");
    }
  }
  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'pptx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      uploadFile(file.path);
    } else {
      debugPrint("=======>error received while uploading file");
    }
  }
  _pickVideoFromCamera() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile!.path);
    uploadVideoMedia(pickedFile.path);
  }
  _pickImageFromGallery() async {
    PickedFile? pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );

    File image = File(pickedFile!.path);

    setState(() {
      _image = image;
    });
    uploadMedia(File(pickedFile!.path).path);
  }
  uploadMedia(imagePath) async {
    Navigator.pop(context);
    var decoded;
    final request = MultipartRequest(
      'POST',
      Uri.parse("$serverUrl/fileUploader/"),
      onProgress: (int bytes, int total) {
        setState(() {
          progress = bytes / total;
          result = 'progress: $progress ($bytes/$total)';
        });
        print('progress: $progress ($bytes/$total)');
      },
    );

    request.files.add(await https.MultipartFile.fromPath(
      'document',
      imagePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    request.send().then((value) {
      setState(() {
        result = "";
      });
      print(value.stream.toString());
      value.stream.forEach((element) {
        decoded = utf8.decode(element);
        print(jsonDecode(decoded)["document"]);
        imageLink = jsonDecode(decoded)["document"];
        setState(() {
          media
              .add({"image": jsonDecode(decoded)["document"], "type": "image"});
          media1.add({"image": imagePath, "type": "image"});
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: primary,
                title: const Text('Image Selected'),
                content: Image(
                  image: NetworkImage("${jsonDecode(decoded)["document"]}"),
                ),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      addMessage();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          Fluttertoast.showToast(
              msg: "Done! Proceed to continue", backgroundColor: primary);
        });
      });
    });
  }
  uploadVideoMedia(imagePath) async {

    final request = MultipartRequest(
      'POST',
      Uri.parse("$serverUrl/fileUploader/"),
      onProgress: (int bytes, int total) {
        setState(() {
          progress = bytes / total;
          result = 'progress: $progress ($bytes/$total)';
        });
        debugPrint('progress: $progress ($bytes/$total)');
      },
    );

    request.files.add(await https.MultipartFile.fromPath(
      'document',
      imagePath,
      //contentType: MediaType('mp4','avi'),
    ));

    request.send().then((value) {
      setState(() {
        result = "";
      });
      debugPrint(value.stream.toString());
      value.stream.forEach((element) {
        decoded = utf8.decode(element);
        debugPrint("video-link is${jsonDecode(decoded)["document"]}");
        videoLink = jsonDecode(decoded)['document'];
        VideoThumbnail.thumbnailFile(
          video: imagePath,
          imageFormat: ImageFormat.JPEG,
          maxWidth:
              128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        ).then((value) {
          setState(() {
            media.clear();
            media1.clear();
            media.add(
                {"video": jsonDecode(decoded)["document"], "type": "video"});
            media1.add({"image": value.toString(), "type": "video"});
            debugPrint("the length of media is ${media.length}");
            Fluttertoast.showToast(
              msg: "Done! Proceed to continue",
              backgroundColor: primary,
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: primary,
                  title: const Text('Video Selected'),
                  content: Image(
                    image: NetworkImage(value.toString()),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        addMessage();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          });
        });
      });
    });
  }
  _pickImageFromCamera() async {
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);

    File image = File(pickedFile!.path);
    uploadMedia(File(pickedFile!.path).path);
  }
  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                controller: _controller,
                itemCount: (snapshot.data! as QuerySnapshot).docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: (snapshot.data! as QuerySnapshot).docs[index]
                        ["message"],
                    sendByMe: name! ==
                        (snapshot.data! as QuerySnapshot).docs[index]["sendBy"],
                    url: (snapshot.data! as QuerySnapshot).docs[index]["image"],
                    chatRoomId: widget.chatRoomId!,
                    docId: (snapshot.data! as QuerySnapshot).docs[index].id,
                    time: (snapshot.data! as QuerySnapshot).docs[index]["time"],
                    onSwipeReply: (p0) {
                      setState(() {
                        messageFocusNode.requestFocus();
                        // Optionally, add a slight delay to ensure the focus is set before showing the keyboard
                        Future.delayed(const Duration(milliseconds: 100), () {
                          FocusScope.of(context).requestFocus(messageFocusNode);
                          // Print statement for debugging
                          print(
                              "Focus requested on the text field after swipe");
                        });
                      });
                    },
                    reply: (snapshot.data! as QuerySnapshot).docs[index]
                        ["reply"],
                    emoji:(snapshot.data! as QuerySnapshot).docs[index]
                    ["emoji"] ,
                  );
                })
            : Container();
      },
    );
  }

  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                    ])),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Select Background'),
                        content: SizedBox(
                            height: 300,
                            width: 450,
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: backgrounds.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, mainAxisSpacing: 10),
                              itemBuilder: (BuildContext context, int index) {
                                return backgrounds[index] == " "
                                    ? WidgetAnimator(
                                        GestureDetector(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString(
                                                "index", index.toString());
                                            setState(() {
                                              ind = index;
                                            });
                                          },
                                          child: Card(
                                            elevation: 5,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  color: Colors.white),
                                              child: Center(
                                                  child: ind == index
                                                      ? Icon(
                                                          Icons.check,
                                                          color: primary,
                                                          size: 40,
                                                        )
                                                      : const Text("")),
                                            ),
                                          ),
                                        ),
                                      )
                                    : WidgetAnimator(
                                        GestureDetector(
                                          onTap: () async {
                                            SharedPreferences prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                            prefs.setString(
                                                "index", index.toString());
                                            setState(() {
                                              ind = index;
                                            });
                                          },
                                          child: Card(
                                            elevation: 5,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: AssetImage(
                                                        backgrounds[index])),
                                              ),
                                              child: Center(
                                                  child: ind == index
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: ascent,
                                                          size: 40,
                                                        )
                                                      : Container(
                                                          color: Colors
                                                              .transparent,
                                                        )),
                                            ),
                                          ),
                                        ),
                                      );
                              },
                            )),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(
                                  context); // dismisses only the dialog and returns nothing
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    }),
                  );
                },
                icon: const Icon(Icons.imagesearch_roller_sharp))
          ],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: "ABC",
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FriendProfileScreen(
                                  username: widget.name,
                                  id: widget.friendId,
                                )));
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(120))),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(120)),
                      child: CachedNetworkImage(
                        imageUrl: widget.pic,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(120)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => SpinKitCircle(
                          color: primary,
                          size: 20,
                        ),
                        errorWidget: (context, url, error) => ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            child: Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                              width: 40,
                              height: 40,
                            )),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: primary,
                        title: const Text(
                          "FashionTime",
                          style: TextStyle(
                              color: ascent,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Do you want to mute the chats?",
                          style: TextStyle(
                              color: ascent, fontFamily: 'Montserrat'),
                        ),
                        actions: [
                          TextButton(
                            child: const Text("Yes",
                                style: TextStyle(
                                    color: ascent, fontFamily: 'Montserrat')),
                            onPressed: () {
                              DatabaseMethods()
                                  .toggleIsMuteField(widget.chatRoomId, true);
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text("No",
                                style: TextStyle(
                                    color: ascent, fontFamily: 'Montserrat')),
                            onPressed: () {
                              DatabaseMethods()
                                  .toggleIsMuteField(widget.chatRoomId, false);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    widget.name,
                    style: const TextStyle(
                        color: ascent, fontFamily: 'Montserrat'),
                  )),
            ],
          ),
          backgroundColor: ascent,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              repliedMessage = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              image: backgrounds[ind] == " "
                  ? null
                  : DecorationImage(
                      image: AssetImage(backgrounds[ind]),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: chatMessages(),
                ),
                WidgetAnimator(
                  widget.isBlocked == true
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Text("This chat is blocked.")],
                            ),
                          ),
                        )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.bottomCenter,
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                child: Container(
                                  // padding:
                                  //     const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.bottomRight,
                                        stops: [0.0, 0.7], // Define stops from 0 to 1
                                        colors: [primary, primary]),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [

                                      if(isRecording == false) Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(Icons.emoji_emotions,
                                              size: 24),
                                          onPressed: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Column(
                                                  children: [
                                                    AutoSizeTextField(
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      // inputFormatters: <
                                                      //     TextInputFormatter>[
                                                      //   UpperCaseTextFormatter(),
                                                      // ],
                                                      maxLines: null,
                                                      onTap: () {
                                                        //_controller.jumpTo(_controller.position.maxScrollExtent);
                                                      },
                                                      style: const TextStyle(
                                                          color: ascent,
                                                          fontFamily:
                                                              'Montserrat'),
                                                      cursorColor: ascent,
                                                      controller:
                                                          messageEditingController,
                                                      decoration:
                                                          InputDecoration(
                                                        fillColor: ascent,
                                                        hintText: "Message",
                                                        hintStyle:
                                                            const TextStyle(
                                                          color: ascent,
                                                          fontFamily:
                                                              'Montserrat',
                                                          fontSize: 16,
                                                        ),
                                                        border:
                                                            InputBorder.none,
                                                        suffixIcon: IconButton(
                                                          icon: const Icon(
                                                              Icons.send),
                                                          onPressed: () {
                                                            addMessage();
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    EmojiKeyboard(
                                                      emotionController:
                                                          messageEditingController,
                                                      emojiKeyboardHeight: 300,
                                                      darkMode: true,
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      if(isRecording == false) Expanded(
                                          child: AutoSizeTextField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        // inputFormatters: <TextInputFormatter>[
                                        //   UpperCaseTextFormatter()
                                        // ],
                                        maxLines: null,
                                        onTap: () {
                                          //_controller.jumpTo(_controller.position.maxScrollExtent);
                                        },
                                        focusNode: messageFocusNode,
                                        style: const TextStyle(
                                            color: ascent,
                                            fontFamily: 'Montserrat'),
                                        cursorColor: ascent,
                                        controller: messageEditingController,
                                        //style: simpleTextStyle(),
                                        decoration: const InputDecoration(
                                            fillColor: ascent,
                                            hintText: "Message ...",
                                            hintStyle: TextStyle(
                                              color: ascent,
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                            ),
                                            border: InputBorder.none),
                                      )),
                                      if(isRecording == false) GestureDetector(
                                        onTap: () {
                                          _pickImageFromCamera();
                                        },
                                        child: const Icon(
                                          Icons.camera_alt,color: ascent,),
                                      ),
                                      if(isRecording == false) const SizedBox(width: 2,),
                                      if(isRecording == false) Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2),
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            setState(() {
                                              // loading = true;
                                            });
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (BuildContext bc) {
                                                  return Wrap(
                                                    children: <Widget>[
                                                      SizedBox(height: 20,),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            GestureDetector(
                                                              onTap:(){
                                                                pickFile();
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.deepPurpleAccent,
                                                                radius:30,
                                                                child: const Icon(
                                                                    Icons.file_present,color: ascent,),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                _pickVideo();
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.pink,
                                                                radius:30,
                                                                child: const Icon(
                                                                    Icons.videocam,color: ascent,),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                _pickVideoFromCamera();
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.purpleAccent,
                                                                radius:30,
                                                                child: const Icon(Icons
                                                                    .fiber_smart_record,color: ascent,),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 20,),
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                               _pickImageFromGallery();
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.deepOrange,
                                                                radius:30,
                                                                child: const Icon(
                                                                    Icons.image,color: ascent,),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async{
                                                                final sticker =
                                                                await GiphyPicker.pickGif(
                                                                  context: context,
                                                                  apiKey: giphyKey,
                                                                  sticker: true,
                                                                  searchHintText:
                                                                  "Search for stickers",
                                                                );
                                                                if (sticker != null) {
                                                                  setState(() {
                                                                    _gif = sticker;
                                                                    debugPrint(
                                                                        "gif link==========>${_gif?.images.original?.url}");
                                                                  });
                                                                  // ignore: use_build_context_synchronously
                                                                  showDialog(
                                                                    context: context,
                                                                    builder:
                                                                        (BuildContext context) {
                                                                      return AlertDialog(
                                                                        backgroundColor: primary,
                                                                        title: const Text(
                                                                            'Sticker Selected'),
                                                                        content: _gif
                                                                            ?.images
                                                                            .original
                                                                            ?.url !=
                                                                            null
                                                                            ? Image(
                                                                            image: NetworkImage(
                                                                                _gif!
                                                                                    .images
                                                                                    .original!
                                                                                    .url!))
                                                                            : const Text(
                                                                            'No Sticker URL available'),
                                                                        actions: <Widget>[
                                                                          IconButton(
                                                                            icon: const Icon(
                                                                                Icons.send),
                                                                            onPressed: () {
                                                                              addMessage();
                                                                              Navigator.of(context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.green,
                                                                radius:30,
                                                                child: const Icon(
                                                                  Icons.image,color: ascent,),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () async{
                                                                final gif =
                                                                await GiphyPicker.pickGif(
                                                                    context: context,
                                                                    apiKey: giphyKey,
                                                                    sticker: false);
                                                                if (gif != null) {
                                                                  setState(() {
                                                                    _gif = gif;
                                                                    debugPrint(
                                                                        "gif link==========>${_gif?.images.original?.url}");
                                                                  });
                                                                  // ignore: use_build_context_synchronously
                                                                  showDialog(
                                                                    context: context,
                                                                    builder:
                                                                        (BuildContext context) {
                                                                      return AlertDialog(
                                                                        backgroundColor: primary,
                                                                        title: const Text(
                                                                            'GIF Selected'),
                                                                        content: _gif
                                                                            ?.images
                                                                            .original
                                                                            ?.url !=
                                                                            null
                                                                            ? Image(
                                                                            image: NetworkImage(
                                                                                _gif!
                                                                                    .images
                                                                                    .original!
                                                                                    .url!))
                                                                            : const Text(
                                                                            'No GIF URL available'),
                                                                        actions: <Widget>[
                                                                          IconButton(
                                                                            icon: const Icon(
                                                                                Icons.send),
                                                                            onPressed: () {
                                                                              addMessage();
                                                                              Navigator.of(context)
                                                                                  .pop();
                                                                            },
                                                                          ),
                                                                        ],
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.blue,
                                                                radius:30,
                                                                child: SizedBox(
                                                                    width: 24,
                                                                    height: 24,
                                                                  child: Image(image: AssetImage("assets/gif.png"),color: ascent,)),
                                                                ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 20,),
                                                      // ListTile(
                                                      //   leading: const Icon(
                                                      //       Icons.file_present),
                                                      //   title: const Text(
                                                      //     'File upload',
                                                      //     style: TextStyle(
                                                      //         fontFamily:
                                                      //         'Montserrat'),
                                                      //   ),
                                                      //   onTap: () {
                                                      //     pickFile();
                                                      //   },
                                                      // ),
                                                      // ListTile(
                                                      //   leading: const Icon(
                                                      //       Icons.videocam),
                                                      //   title: const Text(
                                                      //     'Video from gallery',
                                                      //     style: TextStyle(
                                                      //         fontFamily:
                                                      //         'Montserrat'),
                                                      //   ),
                                                      //   onTap: () {
                                                      //     _pickVideo();
                                                      //   },
                                                      // ),
                                                      // ListTile(
                                                      //   leading: const Icon(Icons
                                                      //       .fiber_smart_record),
                                                      //   title: const Text(
                                                      //     'Record video',
                                                      //     style: TextStyle(
                                                      //         fontFamily:
                                                      //         'Montserrat'),
                                                      //   ),
                                                      //   onTap: () {
                                                      //     _pickVideoFromCamera();
                                                      //   },
                                                      // ),
                                                      // ListTile(
                                                      //     leading: const Icon(
                                                      //         Icons.image),
                                                      //     title: const Text(
                                                      //       'Image from Gallery',
                                                      //       style: TextStyle(
                                                      //           fontFamily:
                                                      //           'Montserrat'),
                                                      //     ),
                                                      //     onTap: () {
                                                      //       _pickImageFromGallery();
                                                      //     }),
                                                      // ListTile(
                                                      //   leading: const Icon(
                                                      //       Icons.camera_alt),
                                                      //   title: const Text(
                                                      //     'Capture image',
                                                      //     style: TextStyle(
                                                      //         fontFamily:
                                                      //         'Montserrat'),
                                                      //   ),
                                                      //   onTap: () {
                                                      //     _pickImageFromCamera();
                                                      //   },
                                                      // ),
                                                    ],
                                                  );
                                                });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.zero,
                                            child: const Icon(Icons.attach_file,
                                                size: 24),

                                          ),
                                        ),
                                      ),
                                      if(isRecording == false) const SizedBox(width: 4,),
                                      if(isRecording == false) GestureDetector(
                                        onTap: () {
                                          addMessage();
                                        },
                                        child: Container(
                                            height: 45,
                                            width: 45,
                                            decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                    colors: [ascent, ascent],
                                                    begin: FractionalOffset
                                                        .topLeft,
                                                    end: FractionalOffset
                                                        .bottomRight),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            padding: const EdgeInsets.only(
                                              left: 4,
                                            ),
                                            child: Center(
                                                child: Icon(
                                              Icons.send,
                                              color: primary,
                                            ))),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 50,
                                          child: SocialMediaRecorder(
                                              fullRecordPackageHeight:45,
                                              initRecordPackageWidth:45,
                                              radius: BorderRadius.all(Radius.circular(200)),
                                              startRecording: () {
                                                print("start called");
                                                // setState(() {
                                                //   isRecording = true;
                                                // });
                                              },
                                              stopRecording: (_time) {
                                                print("stop called");
                                                // setState(() {
                                                //   isRecording = false;
                                                // });
                                              },
                                              sendRequestFunction: (soundFile, _time) {
                                                //  print("the current path is ${soundFile.path}");
                                              },
                                            encode: AudioEncoderType.AAC
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String message;
  final bool sendByMe;
  final String url;
  final String chatRoomId;
  final String docId;
  final int time;
  final Function(String) onSwipeReply;
  final String? reply;
  final String emoji;

  const MessageTile(
      {required this.message,
      required this.sendByMe,
      required this.url,
      required this.chatRoomId,
      required this.docId,
      required this.time,
      required this.onSwipeReply,
      this.reply,
      required this.emoji});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  double offsetX = 0.0;
   String replyingString='';
  @override
  Widget build(BuildContext context) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(widget.time);
    String minutes =
        msgTime.minute <= 9 ? "0${msgTime.minute}" : msgTime.minute.toString();
    int hours = msgTime.hour;
    String imageUrl = '';
    String postId = '';
    bool isImageOr = widget.message.endsWith('.jpg') ||
        widget.message.endsWith('.jpeg') ||
        widget.message.endsWith('.png');
    bool isGif = widget.message.startsWith('https://media');
    bool isVideo =
        widget.message.endsWith('.mp4') || widget.message.endsWith('.mov');
    bool isFile = widget.message.endsWith('.pdf') ||
        widget.message.endsWith('.docx') ||
        widget.message.endsWith('.txt') ||
        widget.message.endsWith('.pptx');

    if (widget.message.contains("http") && widget.message.contains(")")) {
      postId = widget.message.split(")")[1];
      imageUrl = widget.message.split(")")[0];
      print("post id is=====>${postId}");
    }

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          offsetX += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        if (offsetX > 100) {
          setState(() {
            replyingString = widget.message;
            repliedMessage=widget.message;// Set the replied message
          });
          widget.onSwipeReply(widget.message);
        }
        setState(() {
          offsetX = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(offsetX, 0, 0),
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: widget.sendByMe ? 0 : 24,
          right: widget.sendByMe ? 24 : 0,
        ),
        alignment:
            widget.sendByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: GestureDetector(
          onLongPress: () {
            print("delete");
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Container(
                  height: (widget.url != "" || widget.url != null) ? 60 :30,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          DatabaseMethods()
                              .deleteMessage(widget.chatRoomId, widget.docId);
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 10),
                            Text("Delete chat",
                                style: TextStyle(fontFamily: 'Montserrat')),
                          ],
                        ),
                      ),
                      if(widget.url != "" || widget.url != null) SizedBox(height: 10),
                      if(widget.url != "" || widget.url != null) GestureDetector(
                        onTap: () {
                          FileDownloader.downloadFile(
                            url: widget.url,
                            name: widget.docId,
                            onDownloadCompleted: (String path) {
                              debugPrint('IMAGE DOWNLOADED TO PATH: $path');
                              Fluttertoast.showToast(msg: "File downloaded at $path",backgroundColor: primary);
                            },
                            onDownloadError: (String error) {
                              debugPrint('DOWNLOAD ERROR: $error');
                              Fluttertoast.showToast(msg: "Error while downloading file",backgroundColor:Colors.red);
                            },
                          );
                          Navigator.pop(context);
                        },
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 10),
                            Text("Download",
                                style: TextStyle(fontFamily: 'Montserrat')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Container(
            margin: widget.sendByMe
                ? const EdgeInsets.only(left: 30)
                : const EdgeInsets.only(right: 30),
            padding:
                const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: widget.sendByMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomLeft: Radius.circular(23),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(23),
                      topRight: Radius.circular(23),
                      bottomRight: Radius.circular(23),
                    ),
              gradient: LinearGradient(
                colors: widget.sendByMe
                    ? [Colors.grey, Colors.grey]
                    : [dark1, dark1],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (replyingString !=
                    ""&&repliedMessage!=null) // Display replied message if available
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.transparent,
                    child: Text(
                      "Replying to : $replyingString",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: ascent),
                    ),
                  ),
                (isImageOr)
                    ? _buildMediaWidget(context)
                    : isVideo
                        ? _buildVideoPlayer(context)
                        : isFile
                            ? _buildFileWidget(context)
                            : isGif
                                ? buildGifWidget(context)
                                : imageUrl != "" && postId != ""
                                    ? _buildSharedImageWidget(context, imageUrl,
                                        postId) // Display as image or gif
                                    : widget.reply != null &&
                                            (widget.reply!.endsWith(".png") ||
                                                widget.reply!
                                                    .endsWith(".jpeg") ||
                                                widget.reply!
                                                    .endsWith(".jpg") ||
                                                widget.reply!.startsWith(
                                                        "https://media") ==
                                                    true)
                                        ? SizedBox(
                                            height: 50,
                                            width: 60,
                                            child: Image.network(widget.reply!))
                                        : widget.reply != null
                                            ? Text(
                                                "Replied to : ${widget.reply}",
                                                style: const TextStyle(
                                                  color: ascent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : const SizedBox(),

                widget.reply != null?  const Divider(color: ascent):const SizedBox(),
                isImageOr
                    ? const SizedBox()
                    : isVideo
                        ? const SizedBox()
                        : isFile
                            ? const SizedBox()
                            : isGif
                                ? const SizedBox()
                                : imageUrl != "" && postId != ""
                                    ? const SizedBox()
                                    : Text(
                                        widget.message,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: ascent,
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      "$hours:$minutes",
                      style: TextStyle(
                        color: primary,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                    ReactionButton(
                      initialReaction: widget.emoji=="like"?getFakeInitialReaction(1):widget.emoji=="love"?getFakeInitialReaction(2):widget.emoji=="laugh"?getFakeInitialReaction(3):null,
                      onReactionChanged: (reaction) {
                        print(reaction.name);
                        DatabaseMethods().updateEmojiForMessage(widget.chatRoomId, widget.docId, reaction.name.toString());
                      },),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaWidget(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: primary,
                  title: const Text(
                    "FashionTime",
                    style: TextStyle(
                        color: ascent,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Do you want to download this media?",
                    style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Yes",
                          style: TextStyle(
                              color: ascent, fontFamily: 'Montserrat')),
                      onPressed: () {
                        FileDownloader.downloadFile(
                          url: widget.message,
                          name: widget.message,
                          onDownloadCompleted: (String path) {
                            debugPrint('IMAGE DOWNLOADED TO PATH: $path');
                            Fluttertoast.showToast(
                                msg: "File downloaded at $path",
                                backgroundColor: primary);
                          },
                          onDownloadError: (String error) {
                            debugPrint('DOWNLOAD ERROR: $error');
                            Fluttertoast.showToast(
                                msg: "Error while downloading file",
                                backgroundColor: Colors.red);
                          },
                        );
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: const Text("No",
                          style: TextStyle(
                              color: ascent, fontFamily: 'Montserrat')),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
            child: Image.network(widget.message)),
        FutureBuilder(
          future: precacheImage(NetworkImage(widget.message), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            } else {
              return const SizedBox
                  .shrink(); // Empty container when image is loaded
            }
          },
        ),
      ],
    );
  }

  Widget _buildSharedImageWidget(BuildContext context, imageLink, postId) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SharePost(postId: postId),
                  ));
            },
            child: Image.network(imageLink)),
        FutureBuilder(
          future: precacheImage(NetworkImage(imageLink), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            } else {
              return const SizedBox
                  .shrink(); // Empty container when image is loaded
            }
          },
        ),
      ],
    );
  }

  Widget buildGifWidget(BuildContext context) {
    debugPrint("gif link after sending msg========>${widget.message}");

    return Container(
      color: Colors.transparent, // Makes the remaining space transparent
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(widget.message),
          FutureBuilder(
            future: precacheImage(NetworkImage(widget.message), context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: primary),
                );
              } else {
                return const SizedBox
                    .shrink(); // Empty container when the image is loaded
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileWidget(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FileDownloader.downloadFile(
            url: widget.message,
            name: widget.message,
            onDownloadCompleted: (String path) {
              debugPrint('FILE DOWNLOADED TO PATH: $path');
              Fluttertoast.showToast(
                  msg: "File downloaded at $path", backgroundColor: primary);
            },
            onDownloadError: (String error) {
              debugPrint('DOWNLOAD ERROR: $error');
              Fluttertoast.showToast(
                  msg: "Error while downloading file",
                  backgroundColor: Colors.red);
            },
          );
        },
        child: Text(widget.message,
            style: TextStyle(
                color: secondary,
                decoration: TextDecoration.underline,
                fontFamily: 'Montserrat')));
  }

  Widget _buildVideoPlayer(BuildContext context) {
    final VideoPlayerController controller =
        VideoPlayerController.network(widget.message);
    return FutureBuilder(
      future: controller.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              FloatingActionButton(
                onPressed: () {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                child: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ],
          );
        } else {
          return CircularProgressIndicator(color: primary);
        }
      },
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
Reaction? getFakeInitialReaction(int index) {
  if (index ==1) {
    return Reaction.like;
  } else if (index==2) {
    return Reaction.love;
  } else if (index==3) {
    return Reaction.laugh;
  }
  return null;
}

enum AudioEncoder {
  AAC,
  AAC_LD,
  AAC_HE,
  AMR_NB,
  AMR_WB,
  OPUS,
}
