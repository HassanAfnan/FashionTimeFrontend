import 'dart:convert';
import 'dart:io';

import 'package:FashionTime/screens/pages/friend_profile.dart';
import 'package:FashionTime/screens/pages/reel_comment.dart';
import 'package:auto_size_text_field/auto_size_text_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/helpers/database_methods.dart';
import 'package:FashionTime/screens/pages/groups/group_details.dart';
import 'package:emoji_keyboard_flutter/emoji_keyboard_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../helpers/multipart_request.dart';
import '../../../utils/constants.dart';
import '../message_screen.dart';


class GroupMessageScreen extends StatefulWidget {
  final String chatRoomId;
  final String name;
  final String pic;
  final String memberCount;
  final List<dynamic> members;
  const GroupMessageScreen({Key? key, required this.name, required this.pic, required this.memberCount, required this.chatRoomId, required this.members}) : super(key: key);

  @override
  State<GroupMessageScreen> createState() => _GroupMessageScreenState();
}

class _GroupMessageScreenState extends State<GroupMessageScreen> {
  final _controller = ScrollController();
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
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
  GiphyGif? _gif;
  double progress = 0;
  String result = "";
  List<Map<String, String>> media = [];
  List<Map<String, String>> media1 = [];
  String fileLink='';
  var decoded;
  ImagePicker picker = ImagePicker();
  String videoLink = "";
  String imageLink='';
  File _video = File("");
  File _cameraVideo = File("");
  File _image = File("");
  File _cameraImage = File("");
  String id="";
  String username='';
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    name = preferences.getString("name")!;
    pic = preferences.getString("pic")!;
    id=preferences.getString("id")!;
    username=preferences.getString("username")!;
    print(name);
    print(pic);
    print("id of logged in user=====>$id");
    print("id of logged in user=====>$username");
    getIndex();
  }
  var image_indicator = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      ind = int.parse(prefs.getString("index") == null ?"0":prefs.getString("index").toString());
    });
    getUserInfogetChats();
  }


  addMessage() {
    if (messageEditingController.text.isNotEmpty&&_gif==null) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": messageEditingController.text,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic,
        "id":id,
        'username':username
      };

      DatabaseMethods().addGroupMessage(widget.chatRoomId!, chatMessageMap);
      //_controller.jumpTo(_controller.position.maxScrollExtent);
      // sendNotification(name!,messageEditingController.text,widget.fcm);
      setState(() {
        messageEditingController.text = "";
      });
      FocusScope.of(context).unfocus();
    }
    else if(messageEditingController.text.isEmpty&&_gif!=null){
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": _gif?.images.original?.url,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic
      };


      DatabaseMethods().addGroupMessage(widget.chatRoomId!, chatMessageMap);
      setState(() {
        messageEditingController.text = "";
        _gif=null;
      });
      FocusScope.of(context).unfocus();
    }
    else if(imageLink!=''){
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": imageLink,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic
      };
      DatabaseMethods().addGroupMessage(widget.chatRoomId!, chatMessageMap);
      setState(() {
        messageEditingController.text = "";
        imageLink="";
      });
      FocusScope.of(context).unfocus();
    }
    else if(videoLink!=''){
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": videoLink,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic
      };
      DatabaseMethods().addGroupMessage(widget.chatRoomId!, chatMessageMap);
      setState(() {
        messageEditingController.text = "";
        videoLink="";
      });
      FocusScope.of(context).unfocus();
    }
    else if(fileLink!=''){
      Map<String, dynamic> chatMessageMap = {
        "sendBy": name!,
        "message": fileLink,
        'time': DateTime
            .now()
            .millisecondsSinceEpoch,
        'image':pic
      };
      DatabaseMethods().addGroupMessage(widget.chatRoomId!, chatMessageMap);
      setState(() {
        messageEditingController.text = "";
        fileLink="";
      });
      FocusScope.of(context).unfocus();
    }
  }

  sendNotification(String name,String message,String token) async {
    print("Entered");
    print("1- "+name);
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

    https.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAAIgQSOH0:APA91bGZExBIg_hZuaqTYeCMB2ulE_iiRXY8kTYH6MqEpimm6WIshqH6GAhoor1MGnGl2dDbvJqWNRzEGBm_17Kd6-vS-BHZD31HZu_EFCKs5cOQh8EJzpKP2ayJicozOU4csM528EBy',
      },
      body: body,
    ).then((value1){
      print(value1.body.toString());
    });
  }

  getUserInfogetChats(){
    DatabaseMethods().getGroupChats(widget.chatRoomId!).then((val) {
      setState(() {
        chats = val;
      });
    });
  }
  uploadFile(filePath)async{
    setState(() {
      image_indicator = true; // Show loader when file upload starts
      progress = 0; // Initialize progress
    });
    final request = MultipartRequest(
      'POST',
      Uri.parse("$serverUrl/fileUploader/"),
      onProgress: (int bytes, int total) {
        setState(() {
          progress = bytes / total;
          result = 'progress: $progress ($bytes/$total)';
        });
        if (progress == 1) {
          image_indicator = false; // Hide loader when upload is complete
        }
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
        print("file link============>"+jsonDecode(decoded)["document"]);
        fileLink=jsonDecode(decoded)["document"];
        setState(() {
          media
              .add({"image": jsonDecode(decoded)["document"], "type": "file"});
          media1.add({"image": filePath, "type": "file"});
          Fluttertoast.showToast(msg: "Done! Proceed to continue",backgroundColor: primary);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: primary,
                title: const Text('File Selected'),
                content:Text("${jsonDecode(decoded)["document"]}"),
                actions: <Widget>[
                  IconButton(icon: const Icon(Icons.send), onPressed: () { addMessage();
                  Navigator.of(context).pop();},),
                ],
              );
            },
          );
        });
      });
    });
  }
  Future<void> _pickVideo() async {
    setState(() {
      loading = true; // Set loading flag to true
    });

    try {
      PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
          pickedFile.path,
          quality: VideoQuality.Res640x480Quality, // Adjust quality as needed
          deleteOrigin: false, // Set to true if you want to delete the original video
          includeAudio: true, // Set to false to exclude audio
        );

        if (compressedVideoInfo != null && compressedVideoInfo.path != null) {
          _video = File(compressedVideoInfo.path!);
          uploadVideoMedia(compressedVideoInfo.path!);
        } else {
          debugPrint("bad compressing");
        }
      } else {
        // Handle case where user cancels video selection
        debugPrint("No video selected");
      }
    } catch (error) {
      debugPrint(
          "error compressing and uploading video received this error ${error.toString()}");
    } finally {
      setState(() {
        loading = false; // Set loading flag to false after process completes
      });
    }
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc','docx','txt','pptx'],
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
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery,);

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
        imageLink=jsonDecode(decoded)["document"];
        setState(() {
          media
              .add({"image": jsonDecode(decoded)["document"], "type": "image"});
          media1.add({"image": imagePath, "type": "image"});
          Fluttertoast.showToast(msg: "Done! Proceed to continue",backgroundColor: primary);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: primary,
                title: const Text('Image Selected'),
                content:Image(image: NetworkImage("${jsonDecode(decoded)["document"]}"),),
                actions: <Widget>[
                  IconButton(icon: const Icon(Icons.send), onPressed: () { addMessage();
                  Navigator.of(context).pop();},),
                ],
              );
            },
          );
        });
      });
    });
  }
  uploadVideoMedia(imagePath) async {
    // Navigator.pop(context);

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
            Fluttertoast.showToast(msg: "Done! Proceed to continue",backgroundColor: primary,);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: primary,
                  title: const Text('Video Selected'),
                  content:Image(image: NetworkImage("${value.toString()}"),),
                  actions: <Widget>[
                    IconButton(icon: const Icon(Icons.send), onPressed: () { addMessage();
                    Navigator.of(context).pop();},),
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


  Widget chatMessages(){
    return StreamBuilder(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // Use CircularProgressIndicator while loading
          );
        }

        if (!snapshot.hasData || (snapshot.data!).docs.isEmpty) {
          return const Center(
            child: Text('No messages yet'), // Display message when no data is available
          );
        }

        return ListView.builder(
          controller: _controller,
          itemCount: (snapshot.data!).docs.length,
          itemBuilder: (context, index) {
            return MessageTile(
              message: (snapshot.data!).docs[index]["message"],
              sendByMe: name! == (snapshot.data!).docs[index]["sendBy"],
              url: (snapshot.data!).docs[index]["image"],
              time: (snapshot.data!).docs[index]["time"],
              name: (snapshot.data!).docs[index]["sendBy"],
              //id: int.parse((snapshot.data!).docs[index]["id"].toString()),
              //username: (snapshot.data!).docs[index]["username"],
            );
          },
        );
      },
    );

  }

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
                    stops: const [0.0, 0.99],
                    tileMode: TileMode.clamp,
                    colors: <Color>[
                      secondary,
                      primary,
                    ])
            ),),
          actions: [
            IconButton(onPressed:(){
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                    builder: (context,setState) {
                      return AlertDialog(
                        title: const Text('Select Background'),
                        content: SizedBox(
                            height: 300,
                            width: 450,
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: backgrounds.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 10
                              ),
                              itemBuilder: (BuildContext context, int index){
                                return backgrounds[index] == " " ? WidgetAnimator(
                                  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString("index",index.toString());
                                      setState(() {
                                        ind = index;
                                      });
                                    },
                                    child: Card(
                                      elevation: 5,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            color: Colors.white
                                        ),
                                        child: Center(child: ind == index ? Icon(Icons.check,color: primary,size: 40,) : const Text("")),
                                      ),
                                    ),
                                  ),
                                ) : WidgetAnimator(
                                  GestureDetector(
                                    onTap: () async {
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      prefs.setString("index",index.toString());
                                      setState(() {
                                        ind = index;
                                      });
                                    },
                                    child: Card(
                                      elevation: 5,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: AssetImage(
                                                  backgrounds[index]
                                              )
                                          ),
                                        ),
                                        child: Center(child: ind == index ? const Icon(Icons.check,color: ascent,size: 40,) : Container(
                                          color: Colors.transparent,
                                        )),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true)
                                  .pop();
                              Navigator.pop(context);// dismisses only the dialog and returns nothing
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    }
                ),
              );
            }, icon: const Icon(Icons.imagesearch_roller_sharp))
          ],
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetails(
                    name: widget.name,
                    pic: widget.pic,
                    memberCount: widget.memberCount,
                    chatRoomId: widget.chatRoomId,
                    members: widget.members,
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Hero(
                  tag: "ABC",
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(120)),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(120)),
                      child: CachedNetworkImage(
                        imageUrl: widget.pic,
                        imageBuilder: (context, imageProvider) => Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(120)),
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
                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                          child: Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: ascent,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ascent,
        ),
        body: Container(
          decoration: BoxDecoration(
            image:backgrounds[ind] == " " ? null : DecorationImage(
              image: AssetImage(
                  backgrounds[ind]
              ),
              fit: BoxFit.cover,
            ),
          ),
          child:
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom:80.0),
                child: chatMessages(),
              ),
              Row(
                children: [
                  WidgetAnimator(
                    Container(
                      alignment: Alignment.bottomCenter,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(20)),
                            gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[primary, primary]),
                          ),
                          child: Row(
                            children: [
                              // const SizedBox(width: 16,),
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 2),
                                child: IconButton(
                                  icon: const Icon(Icons.emoji_emotions,
                                      size: 24),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Column(
                                          children: [
                                            AutoSizeTextField(
                                              textCapitalization: TextCapitalization.sentences,
                                              inputFormatters: <TextInputFormatter>[
                                                UpperCaseTextFormatter(),
                                              ],
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
                              Expanded(
                                  child: AutoSizeTextField(
                                    textCapitalization:
                                    TextCapitalization.sentences,
                                    inputFormatters: <TextInputFormatter>[
                                      UpperCaseTextFormatter()
                                    ],
                                    maxLines: null,
                                    onTap: () {
                                      //_controller.jumpTo(_controller.position.maxScrollExtent);
                                    },
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
                              // const SizedBox(width: 16,),

                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 2),
                                child: IconButton(
                                  icon: const Icon(Icons.gif, size: 26),
                                  onPressed: () async {
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
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 2),
                                child: IconButton(
                                  icon: const Icon(
                                      FontAwesomeIcons.noteSticky,
                                      size: 20),
                                  onPressed: () async {
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
                                ),
                              ),
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 2),
                                child: IconButton(
                                  icon: const Icon(Icons.attach_file,
                                      size: 24),
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      // loading = true;
                                    });
                                    showModalBottomSheet(
                                        context: context,
                                        builder: (BuildContext bc) {
                                          return Wrap(
                                            children: <Widget>[
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.file_present),
                                                title: const Text(
                                                  'File upload',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Montserrat'),
                                                ),
                                                onTap: () {
                                                  pickFile();
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.videocam),
                                                title: const Text(
                                                  'Video from gallery',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Montserrat'),
                                                ),
                                                onTap: () {
                                                  _pickVideo();
                                                },
                                              ),
                                              ListTile(
                                                leading: const Icon(Icons
                                                    .fiber_smart_record),
                                                title: const Text(
                                                  'Record video',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Montserrat'),
                                                ),
                                                onTap: () {
                                                  _pickVideoFromCamera();
                                                },
                                              ),
                                              ListTile(
                                                  leading: const Icon(
                                                      Icons.image),
                                                  title: const Text(
                                                    'Image from Gallery',
                                                    style: TextStyle(
                                                        fontFamily:
                                                        'Montserrat'),
                                                  ),
                                                  onTap: () {
                                                    _pickImageFromGallery();
                                                  }),
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.camera_alt),
                                                title: const Text(
                                                  'Capture image',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Montserrat'),
                                                ),
                                                onTap: () {
                                                  _pickImageFromCamera();
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  addMessage();
                                },
                                child: Container(
                                    height: 34,
                                    width: 34,
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [ascent, ascent],
                                            begin: FractionalOffset
                                                .topLeft,
                                            end: FractionalOffset
                                                .bottomRight),
                                        borderRadius:
                                        BorderRadius.circular(40)),
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                    ),
                                    child: Center(
                                        child: Icon(
                                          Icons.send,
                                          color: primary,
                                        ))),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      addMessage();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height),

                    ),
                  ),
                ],
              )
            ],
          )
          // Stack(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.only(bottom:80.0),
          //       child: chatMessages(),
          //     ),
          //     WidgetAnimator(
          //       Container(
          //         alignment: Alignment.bottomCenter,
          //         width: MediaQuery
          //             .of(context)
          //             .size
          //             .width,
          //         child: Card(
          //           shape: const RoundedRectangleBorder(
          //             borderRadius: BorderRadius.all(Radius.circular(40)),
          //           ),
          //           child: Container(
          //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 1),
          //             decoration: BoxDecoration(
          //               borderRadius: const BorderRadius.all(Radius.circular(40)),
          //               gradient: LinearGradient(
          //                   begin: Alignment.bottomLeft,
          //                   end: Alignment.bottomRight,
          //                   colors: <Color>[primary, primary]),
          //             ),
          //             child: Row(
          //               children: [
          //                 const SizedBox(width: 16,),
          //                 Expanded(
          //                     child: AutoSizeTextField(
          //                       onTap: (){
          //                         //_controller.jumpTo(_controller.position.maxScrollExtent);
          //                       },
          //                       style: const TextStyle(color: ascent,fontFamily: 'Montserrat'),
          //                       cursorColor: ascent,
          //                       controller: messageEditingController,
          //                       //style: simpleTextStyle(),
          //                       decoration: const InputDecoration(
          //                           fillColor: ascent,
          //                           hintText: "Message ...",
          //                           hintStyle: TextStyle(
          //                             color: ascent,
          //                             fontFamily: 'Montserrat',
          //                             fontSize: 16,
          //                           ),
          //                           border: InputBorder.none
          //                       ),
          //                     )),
          //                 const SizedBox(width: 16,),
          //                 GestureDetector(
          //                   onTap: () {
          //                     addMessage();
          //                   },
          //                   child: Container(
          //                       height: 40,
          //                       width: 40,
          //                       decoration: BoxDecoration(
          //                           gradient: const LinearGradient(
          //                               colors: [
          //                                 ascent,
          //                                 ascent
          //                               ],
          //                               begin: FractionalOffset.topLeft,
          //                               end: FractionalOffset.bottomRight
          //                           ),
          //                           borderRadius: BorderRadius.circular(40)
          //                       ),
          //                       padding: const EdgeInsets.all(10),
          //                       child: Icon(Icons.send,color: primary,)
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     )
          //   ],
          // )
          ,
        ),
      ),
    );
  }
}
class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;
  final String url;
  int time;
  String name;


  MessageTile({required this.message, required this.sendByMe,required this.url,required this.time,required this.name});


  @override
  Widget build(BuildContext context) {
    DateTime msgTime = DateTime.fromMillisecondsSinceEpoch(time);
    int hours = msgTime.hour;
    int minutes = msgTime.minute;
    bool isGif=message.startsWith("https://media");
    bool isImageOr = message.endsWith('.jpg') ||
        message.endsWith('.jpeg') ||
        message.endsWith('.png');
    bool isVideo=message.endsWith('.mp4')||message.endsWith('.mov');
    bool isFile=message.endsWith('.pdf')||message.endsWith('.docx')||message.endsWith('.txt')||message.endsWith('.pptx');

    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () {
          print("delete");
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text("Delete chat",
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold)),
              ),
            ),
          );
        },
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(id: id.toString(), username: username),));
        },
        child: Container(
          margin: sendByMe
              ? const EdgeInsets.only(left: 30)
              : const EdgeInsets.only(right: 30),
          padding: const EdgeInsets.only(
              top: 17, bottom: 17, left: 20, right: 20),
          decoration: BoxDecoration(
            borderRadius: sendByMe
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
              colors: sendByMe
                  ? [primary, primary]
                  : [dark1, dark1],
            ),
          ),
          child: Column(

            children: [

              const SizedBox(height: 10),
              isGif?buildGifWidget(context):isImageOr?_buildMediaWidget(context):isVideo?_buildVideoPlayer(context):isFile?_buildFileWidget(context):
              Row(
                children: [
                  // Container(
                  //   height: 50,
                  //   width: 50,
                  //   decoration: BoxDecoration(
                  //     color: Colors.black.withOpacity(0.6),
                  //     borderRadius: const BorderRadius.all(Radius.circular(120)),
                  //   ),
                  //   child: ClipRRect(
                  //     borderRadius: const BorderRadius.all(Radius.circular(120)),
                  //     child: CachedNetworkImage(
                  //       imageUrl: url,
                  //       imageBuilder: (context, imageProvider) => Container(
                  //         height: 40,
                  //         width: 40,
                  //         decoration: BoxDecoration(
                  //           borderRadius: const BorderRadius.all(Radius.circular(120)),
                  //           image: DecorationImage(
                  //             image: imageProvider,
                  //             fit: BoxFit.cover,
                  //           ),
                  //         ),
                  //       ),
                  //       placeholder: (context, url) =>
                  //           SpinKitCircle(color: primary, size: 20),
                  //       errorWidget: (context, url, error) => ClipRRect(
                  //         borderRadius: const BorderRadius.all(Radius.circular(50)),
                  //         child: Image.network(
                  //           "https://firebasestorage.googleapis.com/v0/b/fashiontime-28e3a.appspot.com/o/WhatsApp_Image_2023-11-08_at_4.48.19_PM-removebg-preview.png?alt=media&token=215bdc12-d53a-4772-bca1-efbbdf6ee955&_gl=1*nea8nk*_ga*NDIyMTUzOTQ2LjE2OTkyODU3MDg.*_ga_CW55HF8NVT*MTY5OTQ0NDE2NS4zMy4xLjE2OTk0NDUxNzcuNTYuMC4w",
                  //           width: 40,
                  //           height: 40,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(id: , username: ),));
                    },
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          name,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            color: ascent,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width*0.02,),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: ascent,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "$hours:$minutes",
                      style: const TextStyle(
                        color: ascent,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _showPopupMenu(context) async {
    // await showMenu(
    //   context: context,
    //   items: [
    //     PopupMenuItem(
    //         child: const Text('Delete'), value: 1),
    //   ],
    //   elevation: 8.0,
    // );
  }
  Widget buildGifWidget(BuildContext context) {
    debugPrint("gif link after sending msg========>$message");
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(message),
        FutureBuilder(
          future: precacheImage(NetworkImage(message), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: secondary));
            } else {
              return const SizedBox.shrink(); // Empty container when image is loaded
            }
          },
        ),
      ],
    );
  }
  Widget _buildVideoPlayer(BuildContext context) {
    final VideoPlayerController controller = VideoPlayerController.network(message);
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
  Widget _buildFileWidget(BuildContext context){
    return GestureDetector(onTap: () {
      FileDownloader.downloadFile(
        url: message,
        name: message,
        onDownloadCompleted: (String path) {
          debugPrint('FILE DOWNLOADED TO PATH: $path');
          Fluttertoast.showToast(msg: "File downloaded at $path",backgroundColor: primary);
        },
        onDownloadError: (String error) {
          debugPrint('DOWNLOAD ERROR: $error');
          Fluttertoast.showToast(msg: "Error while downloading file",backgroundColor:Colors.red);
        },
      );

    },
        child: Text(message,style: TextStyle(color: secondary,decoration: TextDecoration.underline,fontFamily: 'Montserrat'),));
  }
  Widget _buildMediaWidget(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(message),
        FutureBuilder(
          future: precacheImage(NetworkImage(message), context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            } else {
              return const SizedBox.shrink(); // Empty container when image is loaded
            }
          },
        ),
      ],
    );
  }

}