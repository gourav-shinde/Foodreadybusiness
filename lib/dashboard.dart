import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodreadybusiness/cart.dart';
import 'package:foodreadybusiness/editAndAddMenu.dart';
import 'package:foodreadybusiness/main.dart';
import 'package:foodreadybusiness/models/menu.dart';
import 'package:foodreadybusiness/orders.dart';
import 'package:foodreadybusiness/utils/color.dart';

class DashBoardView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DashBoardState();
  }
}

class DashBoardState extends State<DashBoardView> {
  final TextEditingController searchController = TextEditingController();
  final database = FirebaseDatabase(
          databaseURL:
              "https://canteen-management-systems-19bce.asia-southeast1.firebasedatabase.app/")
      .ref();

  // final database = FirebaseDatabase.instanceFor(databaseURL: "").ref();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late Future _menu;
  String searchString = "";
  Map<MenuModel, int> cartvalue2 = {};
  late FirebaseMessaging messaging;
  String messageId = "";
  int _index = 1;
  void onTapFunc(int index) {
    setState(() {
      _index = index;
    });
    if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OrderView()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(_auth.currentUser);
    messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) {
      messageId = value.toString();
    });
    _menu = getMenu();
  }

  Future getMenu() async {
    final Menu = database.child('Menu');
    final users = database.child('Users2');
    // DataSnapshot snapshot = await Menu.get();
    var list = [];
    // var temp = await users.child("8668585647").set({
    //   'firstName': "Gaurav",
    //   'isTeacher': false,
    //   'lastName': "shinde2",
    //   'password': "12345678",
    //   'phone': "8668585647"
    // }).then((temp) => print("hmmmm"));

    await Menu.get().then((document) {
      Map data = (document.value as Map);
      data.forEach((key, value) {
        // print(value["name"]);
        // print(value["uid"]);
        // print(value["imgUri"]);
        // print(value["price"]);
        // print(value["description"]);

        MenuModel temp = MenuModel(value["uid"], value["imgUri"],
            int.parse(value["price"]), value["name"], value["description"]);
        // list.add({
        //   "uid": value["uid"],
        //   "imgUri": value["imgUri"],
        //   "price": value["price"],
        //   "name": value["name"],
        //   "description": value["description"]
        // });
        list.add(temp);
      });
    });
    if (list != null) {
      return list;
    }
    return null;
  }

  void deleteMessageId() {
    final messageSnap = database
        .child('MessageIds/' + _auth.currentUser!.phoneNumber.toString());
    bool found = false;
    messageSnap.get().then((document) {
      Map data = (document.value as Map);
      for (MapEntry x in data.entries) {
        if (x.value["messageId"] == messageId) {
          messageSnap.child(x.key).remove();
          break;
        }
      }
      if (!found) {
        print("Not found");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Catalog",
          style: TextStyle(
              color: Colors.white, fontFamily: 'RobotoMono', fontSize: 20),
        ),
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                deleteMessageId();
                await _auth.signOut();
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyApp(false)));
              },
              icon: const Icon(Icons.logout_outlined))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _menu,
          builder: (context, entryData) {
            switch (entryData.connectionState) {
              case ConnectionState.none:
                return Container();

              case ConnectionState.waiting:
                return const Center(
                  child: CupertinoActivityIndicator(),
                );

              case ConnectionState.active:
                return Container();

              case ConnectionState.done:
                print(entryData.data);
                var list = entryData.data! as List;
                List searchList = [];
                for (var x in list) {
                  if (x.name
                      .toString()
                      .toLowerCase()
                      .contains(searchString.toLowerCase())) {
                    searchList.add(x);
                  }
                }
                return entryData.hasData == false
                    ? const Center(
                        child: Icon(
                          Icons.folder_open_outlined,
                          size: 60,
                        ),
                      )
                    : Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        searchString = value;
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        searchController.clear();
                                        searchString = "";
                                      });
                                    },
                                    icon: const Icon(Icons.cancel_outlined))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              (MediaQuery.of(context)
                                                          .size
                                                          .width ~/
                                                      300)
                                                  .toInt(),
                                          crossAxisSpacing: 5.0,
                                          mainAxisSpacing: 5.0,
                                          childAspectRatio: 3 / 2),
                                  itemCount: searchList.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                        constraints: const BoxConstraints(
                                            maxWidth: 550, maxHeight: 220),
                                        padding: EdgeInsets.all(10),
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 8, 0, 0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey),
                                        child: InkWell(
                                          onLongPress: () {
                                            dialogOption(
                                                context, searchList[index]);
                                          },
                                          child: Card(
                                            elevation: 0,
                                            color: Colors.grey,
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage:
                                                          const AssetImage(
                                                              'images/spinning-loading.gif'),
                                                      radius: 40,
                                                      child: CircleAvatar(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        radius: 40,
                                                        backgroundImage:
                                                            NetworkImage(
                                                                searchList[
                                                                        index]
                                                                    .url),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Flexible(
                                                        child: Text(
                                                            searchList[index]
                                                                .name))
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                            searchList[index]
                                                                .description),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0),
                                                      child: Text(
                                                        "₹" +
                                                            searchList[index]
                                                                .price
                                                                .toString(),
                                                        style: const TextStyle(
                                                            fontSize: 25),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          (cartvalue2[searchList[
                                                                      index]] !=
                                                                  null)
                                                              ? IconButton(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          0),
                                                                  onPressed:
                                                                      () {
                                                                    print(
                                                                        "subtracted");

                                                                    cartvalue2.update(
                                                                        searchList[
                                                                            index],
                                                                        (value) =>
                                                                            --value,
                                                                        ifAbsent:
                                                                            () =>
                                                                                0);
                                                                    if (cartvalue2[
                                                                            searchList[index]] ==
                                                                        0) {
                                                                      cartvalue2
                                                                          .remove(
                                                                              searchList[index]);
                                                                    }
                                                                    print(
                                                                        cartvalue2);
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  icon:
                                                                      const Icon(
                                                                    Icons
                                                                        .remove,
                                                                    size: 20,
                                                                  ))
                                                              : Container(),
                                                          (cartvalue2[searchList[
                                                                      index]] !=
                                                                  null)
                                                              ? Text(
                                                                  cartvalue2[searchList[
                                                                          index]]
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                )
                                                              : Container(),
                                                          IconButton(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              onPressed: () {
                                                                print("added");

                                                                cartvalue2.update(
                                                                    searchList[
                                                                        index],
                                                                    (value) =>
                                                                        ++value,
                                                                    ifAbsent:
                                                                        () =>
                                                                            1);
                                                                print(
                                                                    cartvalue2);
                                                                setState(() {});
                                                              },
                                                              icon: const Icon(
                                                                Icons.add,
                                                                size: 20,
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ));
                                  }))
                        ],
                      );
            }
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.shopping_cart,
            color: Colors.black,
            size: 35,
          ),
          onPressed: () async {
            print("pressed");
            final result = await Navigator.push(context,
                MaterialPageRoute(builder: (context) => CartView(cartvalue2)));
            if (result == 200) {
              cartvalue2 = {};
              setState(() {});
            }
            //go to cart view
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTapFunc,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Orders")
        ],
      ),
    );
  }
}

void dialogOption(context, MenuModel curModel) {
  Navigator.of(context).push(DialogRoute(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Select your Action for " + curModel.name),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Edit"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            addandEditMenuView(true, curModel))).then((value) {
                  Navigator.pop(context);
                });
              },
            )
          ],
        );
      }));
}

// Widget gridTile(List searchList,index) {
//   return Container(
//       margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10), color: Colors.grey),
//       child: InkWell(
//         onLongPress: (){dialogOption(
//                                                   context, searchList[index]);},
//         child: Card(
//           child: Column(
//             children: [
//               Row(children: [
//                 CircleAvatar(
//                   backgroundImage: const AssetImage(
//                       'images/spinning-loading.gif'),
//                   radius: 35,
//                   child: CircleAvatar(
//                     backgroundColor:
//                         Colors.transparent,
//                     radius: 35,
//                     backgroundImage: NetworkImage(
//                         searchList[index].url),
//                   ),
//                 ),
//                 Text(searchList[index].name)
//               ],),
//               Row(children: [Text(searchList[index].description)],),
//               Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(0),
//                                                   child: Text("₹" +
//                                                       searchList[index]
//                                                           .price
//                                                           .toString()),
//                                                 ),
//                                                 (cartvalue2[searchList[
//                                                             index]] !=
//                                                         null)
//                                                     ? IconButton(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(0),
//                                                         onPressed: () {
//                                                           print("subtracted");

//                                                           cartvalue2.update(
//                                                               searchList[index],
//                                                               (value) =>
//                                                                   --value,
//                                                               ifAbsent: () =>
//                                                                   0);
//                                                           if (cartvalue2[
//                                                                   searchList[
//                                                                       index]] ==
//                                                               0) {
//                                                             cartvalue2.remove(
//                                                                 searchList[
//                                                                     index]);
//                                                           }
//                                                           print(cartvalue2);
//                                                           setState(() {});
//                                                         },
//                                                         icon: const Icon(
//                                                           Icons.remove,
//                                                           size: 12,
//                                                         ))
//                                                     : Container(),
//                                                 (cartvalue2[searchList[
//                                                             index]] !=
//                                                         null)
//                                                     ? Text(cartvalue2[
//                                                             searchList[index]]
//                                                         .toString())
//                                                     : Container(),
//                                                 IconButton(
//                                                     padding:
//                                                         const EdgeInsets.all(0),
//                                                     onPressed: () {
//                                                       print("added");

//                                                       cartvalue2.update(
//                                                           searchList[index],
//                                                           (value) => ++value,
//                                                           ifAbsent: () => 1);
//                                                       print(cartvalue2);
//                                                       setState(() {});
//                                                     },
//                                                     icon: const Icon(
//                                                       Icons.add,
//                                                       size: 12,
//                                                     )),
//                                               ],
//                                             )
      
//             ],
//           ),
//         ),
//       ));
// }
