import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodreadybusiness/models/menu.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

class addandEditMenuView extends StatefulWidget {
  bool edit = false;
  MenuModel curModel;
  addandEditMenuView(this.edit, this.curModel);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return addandEditMenuState(edit, curModel);
  }
}

class addandEditMenuState extends State<addandEditMenuView> {
  bool edit = false;
  MenuModel curModel;
  final ImagePicker _picker = ImagePicker();
  addandEditMenuState(this.edit, this.curModel);
  TextEditingController foodname = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController description = TextEditingController();
  AssetImage logoimage = const AssetImage("images/Arsenel_logo.png");
  bool isAvailable = true;

  final database = FirebaseDatabase(
          databaseURL:
              "https://canteen-management-systems-19bce.asia-southeast1.firebasedatabase.app/")
      .ref();
  var imageFile;
  var imagePicker;
  @override
  void initState() {
    // TODO: implement initState
    if (edit == true) {
      foodname.text = curModel.name;
      price.text = curModel.price.toString();
      description.text = curModel.description.toString();
    }

    imagePicker = new ImagePicker();
  }

  Widget pickimg() {
    return Container(
        child: imageFile == null
            ? Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                        color: Colors.greenAccent,
                        onPressed: () {
                          _getFromGallery();
                          setState(() {});
                        },
                        icon: Icon(Icons.browse_gallery_outlined)),
                    IconButton(
                      color: Colors.lightGreenAccent,
                      onPressed: () {
                        _getFromCamera();
                        setState(() {});
                      },
                      icon: Icon(Icons.camera_alt_outlined),
                    )
                  ],
                ),
              )
            : Container());
  }

  Widget imageProfile(String url) {
    return Column(
      children: [
        CircleAvatar(
            backgroundImage: const AssetImage('images/spinning-loading.gif'),
            radius: 90,
            child: imageFile == null
                ? ((url != "")
                    ? CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 90,
                        backgroundImage: NetworkImage(url),
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 90,
                        backgroundImage: AssetImage('images/noImage.jpg'),
                      ))
                : CircleAvatar(
                    backgroundImage: FileImage(imageFile),
                    radius: 90,
                  )),
        pickimg()
      ],
    );
  }

  _getFromGallery() async {
    var pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  /// Get from Camera
  _getFromCamera() async {
    var pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: edit ? Text("Edit " + curModel.name) : const Text("Add item")),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            imageProfile(curModel.url),
            const SizedBox(
              height: 25,
            ),
            TextField(
              controller: foodname,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_box),
                  labelText: "Food item",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: price,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.money),
                  labelText: "Cost",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: description,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.account_box),
                  labelText: "Description",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              child: const Text("Confirm"),
              onPressed: () async {
                try {
                  final storageRef = FirebaseStorage.instance.ref();
                  if (edit) {
                    var time = DateTime.now().millisecondsSinceEpoch.toString();
                    final curMenu =
                        database.child('Menu/' + curModel.uid.toString());

                    if (imageFile != null) {
                      FirebaseStorage.instance
                          .refFromURL(curModel.url)
                          .delete();
                      var snapshot =
                          await storageRef.child(time).putFile(imageFile);
                    }
                    // var downloadUrl = await snapshot.ref.getDownloadURL();
                    // await curMenu.child("imgUrl").set(downloadUrl);
                    try {
                      var dumbo = await curMenu.set({
                        "description": description.text,
                        "imgUri": curModel.url,
                        "name": foodname.text,
                        "price": price.text,
                        "uid": curModel.uid
                      });
                    } catch (e) {
                      print("nothing");
                    }
                    // await curMenu.child("price").set(price.text);
                    // await curMenu.child("description").set(description.text);

                  } else {
                    print("unexpected error");
                    final menu = database.child('Menu');
                    await menu.push().set({
                      "description": description.text,
                      "imgUri": "http://surl.li/cbgvt",
                      "name": foodname.text,
                      "price": price.text,
                      "uid": curModel.uid
                    });
                  }
                  Navigator.pop(context);
                } catch (e) {
                  print(e);
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
