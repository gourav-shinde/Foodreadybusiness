import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodreadybusiness/main.dart';
import 'package:foodreadybusiness/models/menu.dart';
import 'package:foodreadybusiness/utils/color.dart';

class NotificationView extends StatefulWidget {
  Map<MenuModel, int> pass = {};
  NotificationView(this.pass);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NotificationViewState();
  }
}

class NotificationViewState extends State<NotificationView> {
  late FirebaseMessaging messaging;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    messaging = FirebaseMessaging.instance;
    messaging.getAPNSToken().then((value) => print(value));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
