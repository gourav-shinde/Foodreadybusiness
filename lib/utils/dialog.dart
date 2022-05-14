import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void alertBox(BuildContext context, String msg) {
  showDialog(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("$msg"),
        );
      });
}
