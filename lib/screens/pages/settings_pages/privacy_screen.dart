import 'package:FashionTime/animations/bottom_animation.dart';
import 'package:FashionTime/screens/pages/settings_pages/block_list.dart';
import 'package:FashionTime/screens/pages/settings_pages/close_friends.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as https;
import '../../../authentication/login_screen.dart';
import '../../../utils/constants.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool loading1 = false;
  String id = "";
  String token = "";
  String index = "0";
  bool isSwitchedOn=true;
  TextEditingController password=TextEditingController();

  getCashedData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    id = preferences.getString("id")!;
    token = preferences.getString("token")!;
    setState(() {
      index = preferences.getString("toggle")!;
      isSwitchedOn=preferences.getBool("notify")!;
    });
    print(token);
  }

  deleteAccount() async {

    setState(() {

    });
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: AlertDialog(
            title: const Text("FashionTime",style: TextStyle(fontFamily: 'Montserrat')),
            backgroundColor: primary,
            content: const Text('Enter your password',style: TextStyle(fontFamily: 'Montserrat')),

            actions:  [ Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller:password ,
              ),
            ),
            TextButton(child: const Text("Ok",style: TextStyle(fontFamily: 'Montserrat')),onPressed: () {
            deleteAccountAfterVerification();
            },)],
            actionsPadding: const EdgeInsets.only(bottom: 40),


          ),
        );
      },

    );


  }
  deleteAccountAfterVerification()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    https.delete(
        Uri.parse("$serverUrl/api/delete-account/"),body: {
          'password':password.text.toString()
    },
        headers: {
          
          "Authorization": "Bearer $token"
        }
    ).then((value){
      print(value.body.toString());
      setState(() {
        loading1 = false;
      });
      preferences.clear().then((value){
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
      });
    // ignore: argument_type_not_assignable_to_error_handler
    }).catchError((error) {
      setState(() {
        loading1 = false;
      });
      Navigator.pop(context);
      // Handle the error or log it
      print("Error occurred during account deletion: $error");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCashedData();
  }

  saveNotification(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("toggle",index.toString());
  }
  saveNotif(bool notify)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("notify", notify);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primary,
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
        title: const Text("Privacy",style: TextStyle(fontFamily: 'Montserrat'),),
      ),
      body: ListView(
        children: [
          WidgetAnimator(
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  const BlockList()));
              },
              child: Padding(
                padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 8,bottom: 8),
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.block,color: Colors.red,),
                    title: Text("Blocked Accounts",style: TextStyle(
                        color: primary,
                        fontFamily: 'Montserrat'
                    ),),
                  ),
                ),
              ),
            ),
          ),
          WidgetAnimator(
            Padding(
              padding: const EdgeInsets.only(left:10.0,right: 10.0,top: 8,bottom: 8),
              child: Card(
                elevation: 5,
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.green),
                  title: Text(
                    "Notifications",
                    style: TextStyle(color: primary, fontFamily: 'Montserrat'),
                  ),
                  trailing: Switch(
                    value: isSwitchedOn,
                    activeColor: primary,// Assuming 0 means 'On' and 1 means 'Off'
                    onChanged: (value) {
                      setState(() {
                        isSwitchedOn = value;
                      });
                      saveNotif(value);
                      saveNotification(value ? '0' : '1');
                      print('switched to: ${value ? "On" : "Off"}');
                    },
                  ),
                ),
              )
            ),
          ),
          WidgetAnimator(
            loading1 == true ? SpinKitCircle(color: primary,size: 50,) : Padding(
              padding: const EdgeInsets.only(left:8.0,right: 8.0,top: 8,bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(10.0),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all(Colors.red),
                            padding: MaterialStateProperty.all(EdgeInsets.only(
                                top: 13,bottom: 13,
                                left:MediaQuery.of(context).size.width * 0.1,right: MediaQuery.of(context).size.width * 0.1)),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                        onPressed: () {
                          deleteAccount();
                          //Navigator.pop(context);
                          //Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Register()));
                        },
                        child: const Text('Delete Account',style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat'
                        ),)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(10.0),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )
                            ),
                            backgroundColor: MaterialStateProperty.all(Colors.lightGreenAccent),
                            padding: MaterialStateProperty.all(EdgeInsets.only(
                                top: 13,bottom: 13,
                                left:MediaQuery.of(context).size.width * 0.1,right: MediaQuery.of(context).size.width * 0.1)),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(fontSize: 14, color: Colors.white,fontFamily: 'Montserrat'))),
                        onPressed: () {
                          //Navigator.pop(context);
                          Navigator.push(context,MaterialPageRoute(builder: (context) => const CloseFriends()));

                        },
                        child: const Text('Close friends',style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat'
                        ),)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}