import 'package:flutter/material.dart';
import 'package:foodreadybusiness/models/menu.dart';

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
  addandEditMenuState(this.edit, this.curModel);
  TextEditingController foodname = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController description = TextEditingController();
  bool isAvailable = true;
  @override
  void initState() {
    // TODO: implement initState
    if (edit == true) {
      foodname.text = curModel.name;
      price.text = curModel.price.toString();
      description.text = curModel.description.toString();
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
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(32),
          child: Column(children: [
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
              onPressed: () {},
            ),
          ]),
        ),
      ),
    );
  }
}

Widget imageProfile(String url) {
  return Stack(
    children: [
      CircleAvatar(
        backgroundImage: const AssetImage('images/spinning-loading.gif'),
        radius: 90,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 90,
          backgroundImage: NetworkImage(url),
        ),
      ),
      InkWell(
        onTap: () {},
        child: Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.camera_alt, color: Colors.teal, size: 30)),
      )
    ],
  );
}
