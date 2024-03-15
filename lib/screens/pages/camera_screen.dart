import 'dart:convert';
import 'dart:io';
import 'package:FashionTime/screens/pages/videos/video_file.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
// import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../helpers/multipart_request.dart';
import '../../utils/constants.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File _image = File("");
  File _cameraImage = File("");
  File _video = File("");
  File _cameraVideo = File("");
  bool value = false;
  bool isCommentEnable=true;
  String dropdownvalue = 'Fashion Style 1';
  double progress = 0;
  String result = "";
  bool loading = false;
  bool loading1 = false;
  bool loading2 = false;
  bool uploadedSuccess=false;
  bool capitalizeNext=false;
  List<Map<String, String>> media = [];
  List<Map<String, String>> media1 = [];
  TextEditingController description = TextEditingController();
  String id = "";
  String token = "";
  bool _submitted = true;
  bool _description=true;
  // bool _submittedStyle=false;
  String eventId = "";
    String gender='';
  int genderIndex=-1;
  String eventIdTemp='';
  String participants='';


  var items = [
    'Fashion Style 1',
    'Fashion Style 2',
    'Fashion Style 3',
    'Fashion Style 4',
    'Fashion Style 5',
  ];

  ImagePicker picker = ImagePicker();

  // VideoPlayerController _videoPlayerController = VideoPlayerController.network("");
  // VideoPlayerController _cameraVideoPlayerController = VideoPlayerController.network("");

  // This funcion will helps you to pick and Image from Gallery
  _pickImageFromGallery() async {
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery,);

    File image = File(pickedFile!.path);

    setState(() {
      _image = image;
    });
    uploadMedia(File(pickedFile!.path).path);
  }

  // This funcion will helps you to pick and Image from Camera
  _pickImageFromCamera() async {
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);

    File image = File(pickedFile!.path);
    uploadMedia(File(pickedFile!.path).path);
  }

  // This funcion will helps you to pick a Video File
  _pickVideo() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.gallery);

    _video = File(pickedFile!.path);
    // setState(() {
    //   media.add({
    //     "image": uint8list!
    //   });
    // });
    uploadVideoMedia(pickedFile!.path);
  }

  // This funcion will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    PickedFile? pickedFile = await picker.getVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile!.path);
    uploadVideoMedia(pickedFile!.path);
  }

  // void uploadFileToServer(imagePath) async {
  //   var request = new https.MultipartRequest(
  //       "POST", Uri.parse("${serverUrl}/fileUploader/"));
  //   request.files.add(await https.MultipartFile.fromPath('document', imagePath));
  //   request.send().then((response) {
  //     https.Response.fromStream(response).then((onValue) {
  //       try {
  //         print(onValue.body.toString());
  //         // get your response here...
  //       } catch (e) {
  //         print(e.toString());
  //         // handle exeption
  //       }
  //     });
  //   });
  // }

  uploadMedia(imagePath) async {
    Navigator.pop(context);
    var decoded;
    final request = MultipartRequest(
      'POST',
      Uri.parse("${serverUrl}/fileUploader/"),
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
        setState(() {
          media
              .add({"image": jsonDecode(decoded)["document"], "type": "image"});
          media1.add({"image": imagePath, "type": "image"});
        });
      });
    });
  }

  uploadVideoMedia(imagePath) async {
    Navigator.pop(context);
    var decoded;
    final request = MultipartRequest(
      'POST',
      Uri.parse("${serverUrl}/fileUploader/"),
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
      //contentType: MediaType('mp4','avi'),
    ));

    request.send().then((value) {
      setState(() {
        result = "";
      });
      print(value.stream.toString());
      value.stream.forEach((element) {
        decoded = utf8.decode(element);
        print(jsonDecode(decoded)["document"]);
        VideoThumbnail.thumbnailFile(
          video: imagePath,
          imageFormat: ImageFormat.JPEG,
          maxWidth:
              128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,

        ).then((value) {
          setState(() {
            media.add(
                {"video": jsonDecode(decoded)["document"], "type": "video"});
            media1.add({"image": value.toString(), "type": "video"});
          });
        });
      });
    });
  }

  // createPost() async {
  //   setState(() {
  //     loading1 = true;
  //   });
  //   try {
  //     if ( media.length == 0) {
  //       print("not create");
  //       setState(() {
  //         loading1 = false;
  //        // _submitted = true;
  //       });
  //       // showDialog(
  //       //   context: context,
  //       //   builder: (context) => AlertDialog(
  //       //     backgroundColor: primary,
  //       //     title: Text("Fashion Time",style: TextStyle(color: ascent,fontFamily: 'Montserrat',fontWeight: FontWeight.bold),),
  //       //     content: Text("Please complete all the fields.",style: TextStyle(color: ascent,fontFamily: 'Montserrat'),),
  //       //     actions: [
  //       //       TextButton(
  //       //         child: Text("Okay",style: TextStyle(color: ascent,fontFamily: 'Montserrat')),
  //       //         onPressed:  () {
  //       //           setState(() {
  //       //             Navigator.pop(context);
  //       //           });
  //       //         },
  //       //       ),
  //       //     ],
  //       //   ),
  //       // );
  //     } else {
  //       setState(() {
  //         loading1 = true;
  //        // _submitted = false;
  //         _description=true;
  //       });
  //       Map<String, dynamic> body = {
  //         "upload": {"media": media},
  //         "description": description.text,
  //         "addMeInWeekFashion": value,
  //         "user": id,
  //         "event": eventId,
  //         "gender": gender
  //       };
  //
  //
  //       https.post(Uri.parse("${serverUrl}/fashionUpload/"),
  //           body: json.encode(body),
  //           headers: {
  //             "Content-Type": "application/json",
  //             "Authorization": "Bearer ${token}"
  //           }).then((value) {
  //         print("Response ==> ${value.body}");
  //         setState(() {
  //           loading1 = false;
  //           print("value of loading 1 is $loading1");
  //           description.clear();
  //           //media.clear();
  //          // media1.clear();
  //         });
  //       }).catchError((error) {
  //         print("${error}can not post");
  //         setState(() {
  //           loading1 = false;
  //         });
  //         showDialog(
  //           context: context,
  //           builder: (context) => AlertDialog(
  //             backgroundColor: primary,
  //             title: Text(
  //               "FashionTime",
  //               style: TextStyle(
  //                   color: ascent,
  //                   fontFamily: 'Montserrat',
  //                   fontWeight: FontWeight.bold),
  //             ),
  //             content: Text(
  //               error.toString(),
  //               style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
  //             ),
  //             actions: [
  //               TextButton(
  //                 child: Text("Okay",
  //                     style:
  //                         TextStyle(color: ascent, fontFamily: 'Montserrat')),
  //                 onPressed: () {
  //                   setState(() {
  //                     Navigator.pop(context);
  //                   });
  //                 },
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       loading1 = false;
  //     });
  //     print("error creating post ${e.toString()}");
  //   }
  // }
  showToast(Color bg, String toastMsg) {
    Fluttertoast.showToast(
      msg: toastMsg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: bg,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
  createPost() async {
    setState(() {
      loading1 = true;
    });

    try {
      if (media.isEmpty) {
        // Handle the case where media is empty
        setState(() {
          loading1 = false;
          // Handle the error or show a dialog if needed
        });
      } else if(isCommentEnable==true) {
        Map<String, dynamic> body = {
          "upload": {"media": media},
          "description": description.text,
          "addMeInWeekFashion": true,
          "user": id,
          "event": eventId,
          "gender": gender
        };

        final response = await https.post(
          Uri.parse("$serverUrl/fashionUpload/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        );

        if (response.statusCode == 201) {
          // Successful post
          debugPrint("post created successfully");
          showToast(Colors.green, "Style created successfully.");
          setState(() {
            loading1 = false;
            description.clear();
            media.clear();
            media1.clear();
            // Clear other necessary fields
          });
        } else if (response.statusCode >= 400) {
          // Handle the case where the request is bad (status code 400)
          debugPrint("response=========>${response.body}");
          showToast(Colors.red, "Please provide all the fields.");
          setState(() {
            loading1 = false;
          });

        }
      }
      else{
        Map<String, dynamic> body = {
          "upload": {"media": media},
          "description": description.text,
          "addMeInWeekFashion": value,
          "user": id,
          "event": eventId,
          "gender": gender,
          "isCommentOff": isCommentEnable
        };

        final response = await https.post(
          Uri.parse("$serverUrl/fashionUpload/"),
          body: json.encode(body),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token"
          },
        );

        if (response.statusCode == 201) {
          // Successful post
          debugPrint("post created successfully");
          showToast(Colors.green, "Style created successfully.");
          setState(() {
            loading1 = false;
            description.clear();
            media.clear();
            media1.clear();
            // Clear other necessary fields
          });
        } else if (response.statusCode >= 400) {
          // Handle the case where the request is bad (status code 400)
          debugPrint("response=========>$response");
          showToast(Colors.red, "Please provide all the fields.");
          setState(() {
            loading1 = false;
          });
        }
      }
    } catch (e) {
      // Handle any other errors
      setState(() {
        loading1 = false;
      });
      debugPrint("error in create post api ${e.toString()}");
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_descriptionFocusNode = FocusNode();
    //_pickVideoFromCamera();
    getCashedData();
    //_descriptionFocusNode.addListener(_onDescriptionFocusChange);
  }
  @override
  void dispose() {
   // _descriptionFocusNode.removeListener(_onDescriptionFocusChange);
    //_descriptionFocusNode.dispose();
    description.dispose();
    super.dispose();
  }
  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    print(id);
    getEvents();
    //getParticipants();
  }

  getEvents() {
    setState(() {
      loading2 = false;//this was true before
    });
    try {
      https.get(Uri.parse("${serverUrl}/fashionEvent-week/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${token}"
      }).then((value) {

        print("all events of fashion"+jsonDecode(value.body).toString());

        setState(() {
          // eventId =
          //     jsonDecode(value.body)["current_week_events"][0]["id"].toString();
           eventIdTemp=jsonDecode(value.body)['last_week_events'][0]['id'].toString();
          debugPrint("the id is ===========>$eventIdTemp");
          getParticipants(eventIdTemp);
          loading2 = false;
        });
        print("value of loading2 of after getting all events");
      });
    } catch (e) {
      setState(() {
        loading2 = false;
      });
      print("Error --> $e");
    }
  }
  getParticipants(String eventId){
    String url="$serverUrl/fashionUpload/$eventId/participants/";
    https.get(Uri.parse(url),headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    }).then((value) {
      if(value.statusCode==200){
        debugPrint("response of participants========> ${value.body}");
        setState(() {
          participants=jsonDecode(value.body)["participants_count"].toString();
        });
      }
      else{
        debugPrint("error received");
      }

  });
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[secondary, primary],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
        //  FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: WidgetAnimator(
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0, right: 18.0, top: 25, bottom: 18),
                    child: Column(
                      children: [
                        Text(
                          "Total Participants:$participants/100",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Montserrat',
                              foreground: Paint()..shader = linearGradient),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Description of the style",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Montserrat',
                              foreground: Paint()..shader = linearGradient),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              WidgetAnimator(
                Padding(
                  padding: const EdgeInsets.only(
                      left: 30.0, right: 30.0, top: 0.0, bottom: 8.0),
                  child: Container(
                    child: TextField(
                        controller: description,
                        maxLines: 5,
                        maxLength: 2500,
                        // focusNode: _descriptionFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        style:
                            TextStyle(color: primary, fontFamily: 'Montserrat'),
                        decoration: InputDecoration(
                            // errorText: _submitted == true ? "Description not filled." : null,
                            hintStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat'),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1, color: primary),
                            ),
                            focusColor: primary,
                            alignLabelWithHint: true,
                            hintText: "Enter Description"),
                        cursorColor: primary,
                        onChanged: (text) {
                          if (text.isNotEmpty && text.endsWith(".")) {
                            capitalizeNext = true;
                          } else if (capitalizeNext && text.isNotEmpty) {
                            // Capitalize the next non-space character
                            description.value = description.value.copyWith(
                              text: text.replaceFirstMapped(
                                RegExp(r'\S'),
                                    (match) => match.group(0)!.toUpperCase(),
                              ),
                              selection: TextSelection.collapsed(offset: text.length),
                            );
                            capitalizeNext = false;
                          }
                        }
                        )
                    ,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              WidgetAnimator(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ToggleSwitch(
                      fontSize: 14,
                      centerText: true,
                      multiLineText: true,
                      dividerMargin: 0,
                      activeBgColor: [primary, secondary],
                      activeFgColor: ascent,
                      minWidth: 100,
                      minHeight: 60,
                      initialLabelIndex: genderIndex,
                      totalSwitches: 4,
                      labels: const ['Male', 'Female','Unisex', 'Other'],
                      onToggle: (index) {
                       // FocusScope.of(context).unfocus();
                        print('switched to: $index');
                        if (index == 0) {
                          gender = "Male";
                          genderIndex=index!;
                        } else if (index == 1) {
                          gender = "Female";
                          genderIndex=index!;
                        } else if (index == 2) {
                          gender = "Unisex";
                          genderIndex=index!;
                        }
                        else if(index==3){
                          gender="Other";
                          genderIndex=index!;
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              WidgetAnimator(Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Checkbox(
                      activeColor: primary,
                      checkColor: ascent,
                      value: value,
                      onChanged: (bool? val) {
                        setState(() {
                          debugPrint("fashion week bool=========>${val}");
                          value = val!;
                        });
                      },
                    ),
                    GestureDetector(
                        onTap: () {
                        //  FocusScope.of(context).unfocus();
                          setState(() {
                            value = !value;
                          });
                        },
                        child: const Text(
                          "Include my style for next week's event",
                          style: TextStyle(fontFamily: 'Montserrat'),
                        )),
                    GestureDetector(
                      onTap: () {
                       // FocusScope.of(context).unfocus();
                        Fluttertoast.showToast(
                            msg:
                                "When the checkbox is off, you will not be visible to others for likes.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            fontSize: 12.0);
                      },
                      child: const Icon(
                        Icons.question_mark,
                        size: 18,
                      ),
                    )
                  ],
                ),
              )),
              WidgetAnimator(
                 Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 19),
                      child: Checkbox(
                        activeColor: primary,
                        checkColor: ascent,
                        value: isCommentEnable,
                        onChanged: (bool? val) {
                          setState(() {
                            isCommentEnable = val!;
                            debugPrint('value of bool is ======>$isCommentEnable');
                          });
                        },
                      ),
                    ),
                    const Text("Enable comments on style?",style: TextStyle(fontFamily: 'Montserrat'))
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              if (_image.path == "" ||
                  _cameraImage.path == "" ||
                  _video.path == "" ||
                  _cameraVideo.path == "")
                WidgetAnimator(GestureDetector(
                  onTap: () {
                  //  FocusScope.of(context).unfocus();
                    setState(() {
                      loading = true;
                    });
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext bc) {
                          return Container(
                            child: new Wrap(
                              children: <Widget>[
                                new ListTile(
                                    leading: new Icon(Icons.image),
                                    title: new Text(
                                      'Image from Gallery',
                                      style:
                                          const TextStyle(fontFamily: 'Montserrat'),
                                    ),
                                    onTap: () {
                                      _pickImageFromGallery();
                                    }),
                                // new ListTile(
                                //   leading: new Icon(Icons.videocam),
                                //   title: new Text(
                                //     'Video from Gallery',
                                //     style: TextStyle(fontFamily: 'Montserrat'),
                                //   ),
                                //   onTap: () {
                                //     _pickVideo();
                                //   },
                                // ),
                                new ListTile(
                                  leading: new Icon(Icons.camera_alt),
                                  title: new Text(
                                    'Capture image',
                                    style: const TextStyle(fontFamily: 'Montserrat'),
                                  ),
                                  onTap: () {
                                    _pickImageFromCamera();
                                  },
                                ),
                                // new ListTile(
                                //   leading: new Icon(Icons.fiber_smart_record),
                                //   title: new Text(
                                //     'Record video',
                                //     style: TextStyle(fontFamily: 'Montserrat'),
                                //   ),
                                //   onTap: () {
                                //     _pickVideoFromCamera();
                                //   },
                                // ),
                              ],
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25),
                    child: Row(
                      children: [
                        Expanded(
                            child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: result != ""
                                ? Center(
                                    child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      LinearProgressIndicator(
                                        backgroundColor: Colors.grey,
                                        valueColor:
                                            new AlwaysStoppedAnimation<Color>(
                                                Colors.pink),
                                        value: progress,
                                      ),
                                      Text('${(progress * 100).round()}%'),
                                    ],
                                  ))
                                : ShaderMask(
                                    blendMode: BlendMode.srcIn,
                                    shaderCallback: (Rect bounds) =>
                                        LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.topRight,
                                            stops: [0.4, 0.6],
                                            tileMode: TileMode.clamp,
                                            colors: <Color>[
                                              secondary,
                                              primary,
                                            ]).createShader(bounds),
                                    child: Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 100,
                                      color: primary,
                                    )),
                          ),
                        ))
                      ],
                    ),
                  ),
                )),
              media.length>0?
              Column(
                children: [
                  const SizedBox(height: 4,),
                  Padding(
                    padding:  EdgeInsets.only(right: Platform.isIOS? 300.0:270),
                    child: Container(
                      child: InkWell(
                        child: const Icon(Icons.close,color: Colors.red,),
                        onTap: () {
                          media.clear();
                          media1.clear();
                          setState(() {

                          });
                        },
                      ),
                    ),
                  ),
                ],
              ):const SizedBox(),
              media.length <= 0
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30.0, top: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: media1.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            childAspectRatio: 11 / 8),
                        itemBuilder: (BuildContext context, int index) {
                          return WidgetAnimator(
                            GestureDetector(
                              onTap: () {
                                if (media1[index]["type"]! == "video") {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: primary,
                                      title: const Text(
                                        "Video",
                                        style: TextStyle(color: ascent),
                                      ),
                                      content: Container(
                                        height: 200,
                                        child: UsingVideoControllerExample(
                                          path: media[index]["video"]!,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Okay",
                                              style: TextStyle(
                                                  color: ascent,
                                                  fontFamily: 'Montserrat')),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: primary,
                                      title: const Text(
                                        "Image",
                                        style: TextStyle(color: ascent),
                                      ),
                                      content: Container(
                                        height: 200,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: FileImage(File(
                                                  media1[index]["image"]!))),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Okay",
                                              style: TextStyle(
                                                  color: ascent,
                                                  fontFamily: 'Montserrat')),
                                          onPressed: () {
                                            setState(() {
                                              media.clear();
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Card(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(
                                            File(media1[index]["image"]!))),
                                    borderRadius:
                                        const BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              Container(
                height: 70,
                child: Column(
                  children: [
                    // _description==false&& media.length<=0?const Text("Style could not be uploaded.",style: TextStyle(
                    //     fontSize: 14,
                    //     color: Colors.red,
                    //     fontFamily: 'Montserrat'),):const SizedBox(),
                    WidgetAnimator(Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // loading1 == true
                        //     ? SpinKitCircle(
                        //         color: primary,
                        //         size: 70,
                        //       )
                        //     :_descriptionFocusNode.hasFocus?SizedBox():
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 37,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.topRight,
                                    stops: [0.0, 0.99],
                                    tileMode: TileMode.clamp,
                                    colors: loading2 == true
                                        ? [Colors.grey, Colors.grey]
                                        : <Color>[
                                      secondary,
                                      primary,
                                    ])),
                            child: ElevatedButton(

                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12.0),
                                        )),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    padding: MaterialStateProperty.all(EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                        left: MediaQuery.of(context).size.width *
                                            0.26,
                                        right:
                                        MediaQuery.of(context).size.width *
                                            0.26)),
                                    textStyle: MaterialStateProperty.all(
                                        const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontFamily: 'Montserrat'))),
                                onPressed: loading2 == true
                                    ? null
                                    : () {
                                  if(media.length>0||media1.isNotEmpty){
                                    // _submittedStyle=true;
                                    setState(() {

                                    });
                                    // print(media.toString());
                                    // if(media.length<=0&&description.text.isEmpty){
                                    //   _submitted=true;
                                    //   _submittedStyle=true;
                                    //   setState(() {
                                    //
                                    //   });
                                    // }
                                    //  if(media.length<=0){
                                    //   _submittedStyle=true;
                                    //   setState(() {
                                    //
                                    //   });
                                    // }
                                    // else if(description.text.isEmpty){
                                    //   _submitted=true;
                                    //   setState(() {
                                    //
                                    //   });
                                    // }
                                    // if(_submittedStyle==true){
                                    //   createPost();
                                    // }
                                    debugPrint("value of add me in fashion week is ====>$value");
                                    createPost();

                                  }

                                  else if(_description==false&& media.isEmpty&& gender==""){
                                    showToast(Colors.red, "Style could not be uploaded!");
                                  }
                                  else{
                                    _description=false;
                                    setState(() {

                                    });
                                  }


                                  //Navigator.pop(context);
                                  //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Register()));
                                },
                                child: const Text(
                                  'Create Style',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Montserrat'),
                                )),
                          ),
                        ),
                      ],
                    )),

                  ],
                ),
              ),
            ],
          ),
          // bottomNavigationBar: Container(
          //   height: 70,
          //   child: Column(
          //     children: [
          //       // _description==false&& media.length<=0?const Text("Style could not be uploaded.",style: TextStyle(
          //       //     fontSize: 14,
          //       //     color: Colors.red,
          //       //     fontFamily: 'Montserrat'),):const SizedBox(),
          //       WidgetAnimator(Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           // loading1 == true
          //           //     ? SpinKitCircle(
          //           //         color: primary,
          //           //         size: 70,
          //           //       )
          //           //     :_descriptionFocusNode.hasFocus?SizedBox():
          //           Visibility(
          //             visible: _descriptionFocusNode.hasFocus?false:true,
          //             child: Padding(
          //                     padding: const EdgeInsets.all(8.0),
          //                     child: Container(
          //                       height: 37,
          //                       decoration: BoxDecoration(
          //                           borderRadius: BorderRadius.circular(15.0),
          //                           gradient: LinearGradient(
          //                               begin: Alignment.topLeft,
          //                               end: Alignment.topRight,
          //                               stops: [0.0, 0.99],
          //                               tileMode: TileMode.clamp,
          //                               colors: loading2 == true
          //                                   ? [Colors.grey, Colors.grey]
          //                                   : <Color>[
          //                                       secondary,
          //                                       primary,
          //                                     ])),
          //                       child: ElevatedButton(
          //
          //                           style: ButtonStyle(
          //                               shape: MaterialStateProperty.all<
          //                                       RoundedRectangleBorder>(
          //                                   RoundedRectangleBorder(
          //                                 borderRadius:
          //                                     BorderRadius.circular(12.0),
          //                               )),
          //                               backgroundColor: MaterialStateProperty.all(
          //                                   Colors.transparent),
          //                               shadowColor: MaterialStateProperty.all(
          //                                   Colors.transparent),
          //                               padding: MaterialStateProperty.all(EdgeInsets.only(
          //                                   top: 8,
          //                                   bottom: 8,
          //                                   left: MediaQuery.of(context).size.width *
          //                                       0.26,
          //                                   right:
          //                                       MediaQuery.of(context).size.width *
          //                                           0.26)),
          //                               textStyle: MaterialStateProperty.all(
          //                                   const TextStyle(
          //                                       fontSize: 14,
          //                                       color: Colors.white,
          //                                       fontFamily: 'Montserrat'))),
          //                           onPressed: loading2 == true
          //                               ? null
          //                               : () {
          //                             if(media.length>0||media1.isNotEmpty){
          //                               // _submittedStyle=true;
          //                             setState(() {
          //
          //                             });
          //                             // print(media.toString());
          //                             // if(media.length<=0&&description.text.isEmpty){
          //                             //   _submitted=true;
          //                             //   _submittedStyle=true;
          //                             //   setState(() {
          //                             //
          //                             //   });
          //                             // }
          //                             //  if(media.length<=0){
          //                             //   _submittedStyle=true;
          //                             //   setState(() {
          //                             //
          //                             //   });
          //                             // }
          //                             // else if(description.text.isEmpty){
          //                             //   _submitted=true;
          //                             //   setState(() {
          //                             //
          //                             //   });
          //                             // }
          //                             // if(_submittedStyle==true){
          //                             //   createPost();
          //                             // }
          //                               createPost();
          //
          //                             }
          //
          //                             else if(_description==false&& media.isEmpty){
          //                               showToast(Colors.red, "Style could not be uploaded!");
          //                             }
          //                             else{
          //                               _description=false;
          //                               setState(() {
          //
          //                               });
          //                             }
          //
          //
          //                                   //Navigator.pop(context);
          //                                   //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Register()));
          //                                 },
          //                           child: const Text(
          //                             'Create Style',
          //                             style: TextStyle(
          //                                 fontSize: 17,
          //                                 fontWeight: FontWeight.w700,
          //                                 fontFamily: 'Montserrat'),
          //                           )),
          //                     ),
          //                   ),
          //           ),
          //         ],
          //       )),
          //
          //     ],
          //   ),
          // ),
        ));
  }

}

// class PlayVideoFromNetwork extends StatefulWidget {
//   final String path;
//   const PlayVideoFromNetwork({Key? key, required this.path}) : super(key: key);
//
//   @override
//   State<PlayVideoFromNetwork> createState() => _PlayVideoFromNetworkState();
// }
//
// class _PlayVideoFromNetworkState extends State<PlayVideoFromNetwork> {
//   late final PodPlayerController controller;
//
//   @override
//   void initState() {
//     controller = PodPlayerController(
//       playVideoFrom: PlayVideoFrom.network(
//         widget.path,
//       ),
//     )..initialise().then((value){
//       setState(() {
//         controller.pause();
//         controller.mute();
//       });
//     });
//     super.initState();
//   }
//
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PodVideoPlayer(
//         controller: controller);
//   }
// }
