import 'dart:convert';
import 'dart:io';
import 'package:FashionTime/authentication/login_screen.dart';
import 'package:FashionTime/screens/pages/New_calender_screen.dart';
import 'package:FashionTime/screens/pages/camera_screen.dart';
import 'package:FashionTime/screens/pages/chat_screen.dart';
import 'package:FashionTime/screens/pages/feed_screen.dart';
import 'package:FashionTime/screens/pages/groups/all_groups.dart';
import 'package:FashionTime/screens/pages/home_feed.dart';
import 'package:FashionTime/screens/pages/hundred_posts.dart';
import 'package:FashionTime/screens/pages/profile_screen.dart';
import 'package:FashionTime/screens/pages/reelsInterface.dart';
import 'package:FashionTime/screens/pages/search_screen.dart';
import 'package:FashionTime/screens/pages/settings_pages/calander_screen.dart';
import 'package:FashionTime/screens/pages/settings_pages/contact_screen.dart';
import 'package:FashionTime/screens/pages/settings_pages/friend_request.dart';
import 'package:FashionTime/screens/pages/settings_pages/notification.dart';
import 'package:FashionTime/screens/pages/settings_pages/personal_setting.dart';
import 'package:FashionTime/screens/pages/settings_pages/privacy_screen.dart';
import 'package:FashionTime/screens/pages/test_swapper.dart';
import 'package:FashionTime/screens/pages/search_by_hashtag.dart';
import 'package:FashionTime/screens/pages/warning_page/warning_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as https;
 import 'package:showcaseview/showcaseview.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  Color _getTabIconColor(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return isDarkMode ? Colors.white : primary;
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _widgetOptions = <Widget>[
    // SwappingScreen(),
    const HomeFeedScreen(),

    ShowCaseWidget(
      builder: Builder(
        builder: (context) => Example(),
      ),
    ),
    //Example(),
    const ChatScreen(),
    const CameraScreen(),
    const FeedScreen(),
    const ProfileScreen(
      type: false,
    ),
    const ReelsInterfaceScreen()
  ];

  String id = "";
  String token = "";
  String name = "";
  String username = "";
  bool loading = false;
  String appbarText = "";
  String nextWeekText = "";
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> friendRequests = [];

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    name = preferences.getString('name')!;
    username = preferences.getString('username')!;
    print("FCM Token " + preferences.getString("fcm_token")!);
    print("username of user is $username");
    getNotifications();
    getFriendRequest();
    getAppBarText();
    getNextEvent();
  }

  getAppBarText() async {
    try {
      final response =
          await https.get(Uri.parse("$serverUrl/fashionEvent-week/"));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey("current_week_events") &&
            responseData["current_week_events"].isNotEmpty) {
          print("app bar api data ${responseData.toString()}");
          final event = responseData["current_week_events"][0];
          setState(() {
            appbarText = event['title'];
          });
        }
      } else {
        print("Error in app bar api:${response.statusCode}");
      }
    } catch (e) {
      print("api didn't hit $e");
    }
  }

  Future<void> getNextEvent() async {
    try {
      final response = await https.get(Uri.parse(
          "$serverUrl/fashionEvents/")); // Replace with your actual API endpoint
      if (response.statusCode == 200) {
        final List<Map<String, dynamic>> events =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // Get the events for the next week
        DateTime nextWeek = DateTime.now().add(const Duration(days: 7));
        List<Map<String, dynamic>> nextWeekEvents = events
            .where((event) =>
                DateTime.parse(event['eventStartDate'])
                    .isAfter(DateTime.now()) &&
                DateTime.parse(event['eventStartDate']).isBefore(nextWeek))
            .toList();

        if (nextWeekEvents.isNotEmpty) {
          final event = nextWeekEvents[0];
          print("Next Event api data ${event.toString()}");
          setState(() {
            nextWeekText = event['title'];
          });
        } else {
          print("No events for the next week");
        }
      } else {
        print("Error in event  api: ${response.statusCode}");
      }
    } catch (e) {
      print("Event API didn't hit $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  getNotifications() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/notificationsApi/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        print(jsonDecode(value.body).toString());
        jsonDecode(value.body).forEach((data) {
          if (data["is_read"] == false) {
            setState(() {
              notifications.add({
                "title": data["title"].toString(),
                "body": data["body"].toString(),
                "action": data["action"].toString() == null
                    ? ""
                    : data["action"].toString(),
                "time": data["updated"].toString(),
              });
            });
          }
        });
        setState(() {
          loading = false;
        });
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      print("Error --> $e");
    }
  }

  getFriendRequest() {
    setState(() {
      loading = true;
    });
    try {
      https.get(Uri.parse("$serverUrl/notificationsApi/"), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }).then((value) {
        jsonDecode(value.body).forEach((data) {
          if (data["is_read"] == false &&
              data['title'] == 'New Follow Request') {
            setState(() {
              friendRequests.add({
                "title": data["title"].toString(),
                "body": data["body"].toString(),
                "action": data["action"].toString() == null
                    ? ""
                    : data["action"].toString(),
                "time": data["updated"].toString(),
              });
            });
          }
        });
        debugPrint("total request=====>${friendRequests.length}");
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("Error received========>${e.toString()}");
    }
  }

  initBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: "ca-app-pub-5248449076034001/6687962197",
        listener: BannerAdListener(onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        }, onAdFailedToLoad: (ad, error) {
          //print("${ad.adUnitId} Error ==> ${error.message}");
        }),
        request: const AdRequest());
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('The user tries to pop()');
        if (_selectedIndex == 0) {
          await showDialog(
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
                "Do you want to close this application?",
                style: TextStyle(color: ascent, fontFamily: 'Montserrat'),
              ),
              actions: [
                TextButton(
                  child: const Text("Yes",
                      style: TextStyle(
                          color: ascent, fontFamily: 'Montserrat')),
                  onPressed: () {
                    SystemNavigator.pop();
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
          return Future.value(false);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
          return Future.value(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const SizedBox(),
          centerTitle: true,
          // backgroundColor: primary,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    stops: [0.0, 0.7],
                    tileMode: TileMode.clamp,
                    colors: <Color>[
                      secondary,
                      primary,
                    ])),
          ),
          actions: [
            if (_selectedIndex == 0)
              friendRequests.isEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const FriendRequest()));
                      },
                      icon: const Icon(Icons.face_retouching_natural))
                  : CustomBadge(
                      label: friendRequests.length.toString(),
                      isVisible: true,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const FriendRequest()))
                              .then((value) => setState(() {
                                    friendRequests.clear();
                                  }));
                        },
                        icon: const Icon(Icons.face_retouching_natural),
                      ),
                    ),
            if (_selectedIndex == 0)
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SearchScreen()));
                },
                icon: const Icon(Icons.person_search),
              ),
            if(_selectedIndex==0)
            IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SearchByHashtagScreen()));
              },
              icon: const Icon(FontAwesomeIcons.hashtag),
            ),

            if(_selectedIndex == 0) IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WarningPage()));
              },
              icon: Icon(Icons.warning),
            ),

            if (_selectedIndex == 0)
              notifications.isEmpty
                  ? IconButton(
                      onPressed: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationScreen()))
                            .then((value) => setState(() {
                                  notifications.clear();
                                }));
                      },
                      icon: const Icon(Icons.notifications),
                    )
                  : CustomBadge(
                      label: notifications.length.toString(),
                      isVisible: true,
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationScreen()))
                              .then((value) => setState(() {
                                    notifications.clear();
                                  }));
                        },
                        icon: const Icon(Icons.notifications),
                      ),
                    ),
            if (_selectedIndex == 1)
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AllFashionWeeks()));
                },
                icon: const Icon(Icons.calendar_month_rounded),
              ),
            if (_selectedIndex == 4)
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              //  CalenderScreen()));
                              const AllFashionWeeks()));
                },
                icon: const Icon(Icons.calendar_month_rounded),
              ),
            // if (_selectedIndex == 5)
            //   IconButton(onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) =>
            //             const MyHundredLikedPost()));
            //   }, icon: const Icon(Icons.history,color: ascent,)),
            if (_selectedIndex == 5)
              PopupMenuButton(
                  icon: const Icon(Icons.settings),
                  onSelected: (value) {
                    // if (value == 0) {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => CalenderScreen()));
                    // }
                    // if (value == 1) {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
                    // }
                    if (value == 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyScreen()));
                    }
                    if (value == 3) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ContactScreen()));
                    }
                    if (value == 4) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PersonalSettingScreen()));
                    }
                    if (value == 5) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyHundredLikedPost()));
                    }
                    if (value == 6) {
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
                            "Do you want to logout?",
                            style: TextStyle(
                                color: ascent, fontFamily: 'Montserrat'),
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                "Yes",
                                style: TextStyle(
                                    color: ascent, fontFamily: 'Montserrat'),
                              ),
                              onPressed: () async {
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                preferences.clear().then((value) {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login()));
                                });
                              },
                            ),
                            TextButton(
                              child: const Text("No",
                                  style: TextStyle(
                                      color: ascent, fontFamily: 'Montserrat')),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()));
                    }
                    setState(() {});
                    print(value);
                    //Navigator.pushNamed(context, value.toString());
                  },
                  itemBuilder: (BuildContext bc) {
                    return [
                      // PopupMenuItem(
                      //   value: 0,
                      //   child: Text("Calander",style: TextStyle(fontFamily: 'Montserrat'),),
                      // ),
                      // PopupMenuItem(
                      //   value: 1,
                      //   child: Text("Notifications",style: TextStyle(fontFamily: 'Montserrat'),),
                      // ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(
                              Icons.privacy_tip,
                              color: primary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Privacy",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 3,
                        child: Row(
                          children: [
                            Icon(Icons.info, color: primary),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Contact",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 4,
                        child: Row(
                          children: [
                            Icon(Icons.person, color: primary),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Personal info.",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 5,
                        child: Row(
                          children: [
                            Icon(Icons.history, color: primary),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "100 Liked posts.",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 6,
                        child: Row(
                          children: [
                            Icon(
                              Icons.exit_to_app,
                              color: primary,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Logout",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 7,
                        child: Consumer<ThemeNotifier>(
                          builder: (context, notifier, child) => SwitchListTile(
                            dense: true,
                            activeColor:
                                notifier.darkTheme ? primary : Colors.white,
                            title: const Text(
                              "Dark Mode",
                              style: TextStyle(fontFamily: 'Montserrat'),
                            ),
                            onChanged: (val) {
                              notifier.toggleTheme();
                              print(notifier.darkTheme);
                            },
                            value: notifier.darkTheme,
                          ),
                        ),
                      )
                    ];
                  })
          ],
          title: _selectedIndex == 3
              ? Text(
                  "Next Event: $nextWeekText",
                  style:
                      const TextStyle(fontFamily: 'Montserrat', fontSize: 15),
                )
              : _selectedIndex == 1
                  ? Text(
                      "Current Event: $appbarText",
                      style: const TextStyle(
                          fontFamily: 'Montserrat', fontSize: 15),
                    )
                  : _selectedIndex == 5
                      ? Text(username,
                          style: const TextStyle(fontFamily: 'Montserrat'))
                      : _selectedIndex == 6
                          ? const Text("Flicks",
                              style: TextStyle(
                                  fontFamily: 'Montserrat', fontSize: 20))
                          : null,
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: SizedBox(
          child: Container(
            height: Platform.isIOS ? 90 : 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [secondary, primary],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                stops: [0.0, 0.99],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Column(
              children: [
                BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.yellow.shade600,
                  unselectedItemColor: Colors.white,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/4-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame4.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/5-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame5.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Home",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/6-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame6.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Chat",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/3-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame3.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Upload",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/1-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame1.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Feed",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/2-white.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/Frame2.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Profile",
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        "assets/FlickIcon.png",
                        height: 30,
                        width: 30,
                      ),
                      activeIcon: Image.asset(
                        "assets/FlickIcon.png",
                        height: 30,
                        width: 30,
                      ),
                      label: "Flicks",
                    ),
                  ],
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  selectedFontSize: 10,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                ),
                // _isAdLoaded == true ?
                //      Container(
                //        height: _bannerAd.size.height.toDouble(),
                //        width: _bannerAd.size.width.toDouble(),
                //        child: AdWidget(ad: _bannerAd,),
                //      )
                //     :SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBadge extends StatefulWidget {
  final String? label;
  final Widget child;
  final bool isVisible;

  CustomBadge({this.label, required this.child, required this.isVisible});

  @override
  State<CustomBadge> createState() => _CustomBadgeState();
}

class _CustomBadgeState extends State<CustomBadge> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        widget.child,
        Visibility(
          visible: widget.isVisible,
          child: Positioned(
            right: 10,
            top: 5,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              padding: const EdgeInsets.all(2),
              child: Padding(
                padding: const EdgeInsets.all(1.5),
                child: Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
