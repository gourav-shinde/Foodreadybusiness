import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:foodreadybusiness/signup.dart';
import 'package:foodreadybusiness/dashboard.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
    // FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance;
  }
  if (FirebaseAuth.instance.currentUser != null) {
    runApp(const MyApp(true));
  } else {
    runApp(const MyApp(false));
  }
}

class MyApp extends StatelessWidget {
  final bool auth;
  // ignore: use_key_in_widget_constructors
  const MyApp(this.auth);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ready Business',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      // home: DashBoardView(),
      home: (auth == true)
          ? DashBoardView()
          : const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = FirebaseDatabase(
          databaseURL:
              "https://canteen-management-systems-19bce.asia-southeast1.firebasedatabase.app/")
      .ref();
  // final database = FirebaseDatabase.instance.ref();
  FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController OtpController = TextEditingController();
  AssetImage logoimage = const AssetImage("images/Arsenel_logo.png");
  bool _showPassword = false;
  bool _loading = false;
  bool _otp = false;
  late FirebaseMessaging messaging;
  String messageId = "";
  String countryCode = "+91";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      messageId = value.toString();
    });
  }

  void login(String mobileNo, String password) async {}

  void _alertBox(BuildContext context, String msg) {
    showDialog(
        context: context,
        useSafeArea: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("$msg"),
          );
        });
  }

  void goToDashBoard(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      _loading = true;
    });

    try {
      final AuthCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (AuthCredential.user != null) {
        final messageSnap = database
            .child('MessageIds/' + AuthCredential.user!.phoneNumber.toString());
        bool found = false;
        messageSnap.get().then((document) {
          Map data = (document.value as Map);
          for (MapEntry x in data.values) {
            if (x.value == messageId) {
              found = true;
              break;
            }
          }
          if (!found) {
            messageSnap.push().set({'messageId': messageId});
          }
        });

        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => DashBoardView()));
      }
    } on FirebaseAuthException catch (e) {
      print('e');
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = database.child('Users2');
    return Scaffold(
        body: Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 550),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  SizedBox(
                    height: 250,
                    child: Image(image: logoimage),
                  ),
                  const SizedBox(
                    child: Text(
                      "Business",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _otp
                      ? Column(
                          children: [
                            TextField(
                              keyboardType: TextInputType.phone,
                              controller: OtpController,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      const Icon(Icons.phone_android_outlined),
                                  labelText: "OTP",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white),
                              child: TextButton(
                                child: const Text(
                                  "Verify",
                                  style: TextStyle(color: Colors.black),
                                  textScaleFactor: 1.2,
                                ),
                                onPressed: () async {
                                  PhoneAuthCredential phoneAuthCredential =
                                      PhoneAuthProvider.credential(
                                          verificationId: verificationID,
                                          smsCode: OtpController.text);

                                  goToDashBoard(phoneAuthCredential);
                                  print('done');
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            IntlPhoneField(
                              controller: usernameController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  counterText: "",
                                  prefixIcon: const Icon(Icons.phone_android),
                                  labelText: "Mobile Number",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              initialCountryCode: 'IN',
                              onChanged: (value) {
                                print(value.countryCode);
                                countryCode = value.countryCode;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: passwordController,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: "Password",
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    child: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                              obscureText: !_showPassword,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue),
                              child: _loading
                                  ? const CupertinoActivityIndicator(
                                      animating: true,
                                      radius: 20,
                                    )
                                  : TextButton(
                                      child: const Text(
                                        "Login",
                                        textScaleFactor: 1.5,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          _loading = true;
                                        });
                                        print("object");
                                        if (usernameController.text != null) {
                                          DatabaseReference currentUser =
                                              users.child(countryCode +
                                                  usernameController.text);

                                          final snapshot =
                                              await currentUser.get();
                                          if (snapshot.value != null) {
                                            print(snapshot.value);
                                            print(snapshot
                                                .child('password')
                                                .value);
                                            var pass = snapshot
                                                .child('password')
                                                .value
                                                .toString();
                                            if (pass ==
                                                passwordController.text) {
                                              //go for otp
                                              await FirebaseAuth.instance
                                                  .verifyPhoneNumber(
                                                phoneNumber: countryCode +
                                                    usernameController.text,
                                                verificationCompleted:
                                                    (phoneAuthCredential) async {
                                                  print("logged in");
                                                },
                                                codeAutoRetrievalTimeout:
                                                    (verificationId) {},
                                                codeSent: (verificationId,
                                                    forceResendingToken) async {
                                                  setState(() {
                                                    //change to otp state

                                                    _otp = true;
                                                    _loading = false;

                                                    verificationID =
                                                        verificationId;
                                                  });
                                                },
                                                verificationFailed:
                                                    (error) async {
                                                  print(
                                                      "verification failed $error");
                                                  setState(() {
                                                    _loading = false;
                                                  });
                                                },
                                              );
                                            } else {
                                              setState(() {
                                                _loading = false;
                                              });
                                              print("wrong password");
                                              _alertBox(context,
                                                  "Incorrect Password");
                                            }
                                          } else {
                                            _alertBox(context, "Invalid User");
                                            setState(() {
                                              _loading = false;
                                            });
                                          }
                                        }
                                      },
                                    ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return SignUpView();
                                }));
                              },
                              child: const Text("Create An Account? Sign Up"),
                            ),
                          ],
                        )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
