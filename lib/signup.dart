import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodreadybusiness/dashboard.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUpView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignUpState();
  }
}

TextEditingController Otp = TextEditingController();
String verificationID = "";

class SignUpState extends State<SignUpView> {
  final database = FirebaseDatabase(
          databaseURL:
              "https://canteen-management-systems-19bce.asia-southeast1.firebasedatabase.app/")
      .ref();
  // final database = FirebaseDatabase.instance.ref();
  late FirebaseMessaging messaging;
  String messageId = "";
  bool _loading = false;
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController password2 = TextEditingController();
  AssetImage logoimage = const AssetImage("images/Arsenel_logo.png");
  String countryCode = "+91";
  bool _isTeacher = false;
  bool _showPassword = false;
  bool _showPassword2 = false;
  bool _passMisMatch = false;
  bool _fnameEmpty = false;
  bool _lnameEmpty = false;
  bool _passEmpty = false;
  bool _mobileNo = false;

  void goToDashBoard(PhoneAuthCredential phoneAuthCredential) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final users = database.child('Users2');
    final messageSnap = database.child('MessageIds/+91' + mobile.text);
    setState(() {
      _loading = true;
    });
    try {
      final AuthCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (AuthCredential.user != null) {
        await users.child(countryCode + mobile.text).set({
          'firstName': fname.text,
          'isTeacher': false,
          'lastName': lname.text,
          'password': password.text,
          'phone': countryCode + mobile.text
        }).then((value) => print("Entry saved"));
        messageSnap.push().set({'messageId': messageId});
        Navigator.pop(context);
        Navigator.pop(context);
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

  void _bottomSheetModel(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                    color: Colors.black54,
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: const BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            children: [
                              const Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Enter OTP",
                                  textScaleFactor: 1.5,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: Otp,
                                        keyboardType: TextInputType.phone,
                                        decoration: InputDecoration(
                                            prefixIcon: const Icon(
                                                Icons.confirmation_number),
                                            labelText: "Enter OTP",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white),
                                        child: TextButton(
                                          child: const Text(
                                            "Verify",
                                            style:
                                                TextStyle(color: Colors.black),
                                            textScaleFactor: 1.2,
                                          ),
                                          onPressed: () async {
                                            PhoneAuthCredential
                                                phoneAuthCredential =
                                                PhoneAuthProvider.credential(
                                                    verificationId:
                                                        verificationID,
                                                    smsCode: Otp.text);
                                            goToDashBoard(phoneAuthCredential);
                                            print('done');
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      messageId = value.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final users = database.child('Users2');
    // TODO: implement build
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: Stack(
              children: [
                _loading
                    ? Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: const CupertinoActivityIndicator(
                          animating: true,
                          radius: 20,
                        ),
                      )
                    : Container(
                        alignment: Alignment.topCenter,
                        constraints: const BoxConstraints(maxWidth: 550),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 150,
                              child: Image(image: logoimage),
                            ),
                            const SizedBox(
                              child: Text(
                                "Business",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 30),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              controller: fname,
                              decoration: InputDecoration(
                                  errorText:
                                      _fnameEmpty ? 'Enter First Name' : null,
                                  prefixIcon: const Icon(Icons.account_box),
                                  labelText: "First Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextField(
                              controller: lname,
                              decoration: InputDecoration(
                                  errorText:
                                      _lnameEmpty ? 'Enter Last name' : null,
                                  prefixIcon: const Icon(Icons.face_outlined),
                                  labelText: "Last Name",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  )),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            IntlPhoneField(
                              controller: mobile,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  counterText: "",
                                  errorText:
                                      _mobileNo ? 'Enter Valid Number' : null,
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
                              controller: password,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                  errorText:
                                      _passEmpty ? 'Enter Password' : null,
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
                            TextField(
                              controller: password2,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                  errorText: _passMisMatch
                                      ? 'Password Mismatch or Enter valid Password'
                                      : null,
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: "Re-Enter Password",
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _showPassword2 = !_showPassword2;
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
                              obscureText: !_showPassword2,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue),
                              child: TextButton(
                                child: const Text(
                                  "Sign Up",
                                  textScaleFactor: 1.5,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  _loading = true;
                                  setState(() {});
                                  print(_loading);
                                  _fnameEmpty = false;
                                  _lnameEmpty = false;
                                  _mobileNo = false;
                                  _passEmpty = false;
                                  _passMisMatch = false;
                                  String pass1 = password.text;
                                  String pass2 = password2.text;
                                  String fName = fname.text;
                                  String lName = lname.text;
                                  String mobileNo = mobile.text;
                                  print(mobileNo);
                                  String credential;
                                  if (fName.isEmpty) {
                                    _fnameEmpty = true;
                                  }
                                  if (lName.isEmpty) {
                                    _lnameEmpty = true;
                                  }
                                  // if (mobileNo.isEmpty || mobileNo.length != 10) {
                                  //   _mobileNo = true;
                                  // }
                                  if (pass1.isEmpty) {
                                    _passEmpty = true;
                                  }

                                  if (pass1 != pass2) {
                                    //password error
                                    password2.clear();
                                    _passMisMatch = true;
                                  }
                                  if (!(_fnameEmpty ||
                                      _lnameEmpty ||
                                      _passEmpty ||
                                      _passMisMatch ||
                                      _mobileNo)) {
                                    print("correct inputs");
                                    try {
                                      await FirebaseAuth.instance
                                          .verifyPhoneNumber(
                                        phoneNumber: countryCode + mobileNo,
                                        verificationCompleted:
                                            (phoneAuthCredential) async {
                                          credential = phoneAuthCredential
                                              .verificationId
                                              .toString();
                                          //save in get preferences
                                          print("is successful");

                                          // setState(() {
                                          //   _loading = false;
                                          // });
                                        },
                                        codeAutoRetrievalTimeout:
                                            (verificationId) {},
                                        codeSent: (verificationId,
                                            forceResendingToken) async {
                                          setState(() {
                                            _loading = false;
                                            _bottomSheetModel(context);
                                            verificationID = verificationId;
                                          });
                                        },
                                        verificationFailed: (error) async {
                                          print("verification failed $error");
                                          setState(() {
                                            _loading = false;
                                          });
                                        },
                                      );
                                      print("okay");
                                    } catch (e) {
                                      print(e);
                                    }
                                  }
                                  setState(() {
                                    _loading = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
