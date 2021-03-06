import 'dart:async';
import 'dart:collection';
import 'dart:convert';
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
import 'package:foodreadybusiness/utils/dialog.dart';

class OrderView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OrderViewState();
  }
}

class OrderViewState extends State<OrderView> {
  //variables
  final database = FirebaseDatabase(
          databaseURL:
              "https://canteen-management-systems-19bce.asia-southeast1.firebasedatabase.app/")
      .ref();
  bool refresh = false;
  // final database = FirebaseDatabase.instanceFor(databaseURL: "").ref();
  FirebaseAuth _auth = FirebaseAuth.instance;
  late Future _currentOrders, _previousOrders;
  var selected;
  bool _isCurrent = true;
  String CurrentTransactId = "";
  List<int> _state = [];
  //variables end
  @override
  void initState() {
    // TODO: implement initState
    _currentOrders = getCurrentOrders();
    _previousOrders = getPreviousOrders();
  }

  Future getCurrentOrders() async {
    final getActiveOrders = database.child('Status');
    final Orders = database.child('OrderedItems');
    List list = [];
    await getActiveOrders.get().then((document) {
      Map data = (document.value as Map);
      data.forEach((key, value) {
        list.add(key);
      });
    });
    List finaleList = [];
    print(list);
    if (list.isEmpty) {
      print("list is null");
      return Null;
    } else {
      for (var transaction_id in list) {
        final currentOrders = Orders.orderByKey().equalTo(transaction_id);
        Map tempo = {};
        var temp = await currentOrders.get().then((value) {
          if (value.value != null) {
            // Map temp = (value.value as Map);
            tempo["value"] = (value.value);
          }
        });
        final currentBill =
            database.child("Bill").orderByKey().equalTo(transaction_id);
        temp = await currentBill.get().then((value) {
          if (value.value != null) {
            Map temp = (value.value as Map);
            // temp.forEach((key, value) {
            //   print(key);
            //   print(value);
            // });
            tempo["token"] = (temp[transaction_id]["token"]);
          }
        });
        finaleList.add([transaction_id, tempo]);
        _state.add(0);
      }
    }
    print(finaleList);
    return finaleList;
  }

  Future getPreviousOrders() async {
    final Orders = database.child('Bill');

    List finaleList = [];
    var _ = await Orders.get().then((value) {
      if (value.value != null) {
        Map temp = (value.value as Map);
        temp.forEach((key, value) {
          finaleList.add({"key": key, "value": value});
        });
      }
    });
    if (finaleList == null) return null;
    print("previous");
    print(finaleList.length);
    print(finaleList);
    return finaleList;
  }

  _getExpandData(String transactionID) async {
    print("is called on " + transactionID);
    if (transactionID.length == 0) return null;
    List list = [];
    final Orders =
        database.child('OrderedItems').orderByKey().equalTo(transactionID);
    var jk = await Orders.get().then((value) {
      if (value.value == null) return null;
      Map temp = (value.value as Map);

      temp.forEach((key, value) {
        Map temptemp = value as Map;
        temptemp.forEach((key, value) {
          list.add(value);
        });
      });
    });
    if (list.isEmpty) return null;
    print("list is");
    print(list);
    return list;
  }

  _orginExpanded() {
    Widget fj = FutureBuilder(
      future: _getExpandData(CurrentTransactId),
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
            {
              print(entryData.data);
              if (entryData.hasData) {
                List list = entryData.data as List;
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Text("foodName"),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.1,
                              child: Text("qty"),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text("price"),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text("result"),
                            )
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Row(children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Text(list[index]["foodName"]),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: Text(list[index]["qty"].toString()),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Text(list[index]["price"].toString()),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Text(list[index]["result"].toString()),
                                )
                              ]),
                            );
                          }),
                    ],
                  ),
                );
              } else {
                return Container(
                  child: Text("Empty"),
                );
              }
            }
        }
      },
    );
    return fj;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder(
          future: _isCurrent ? _currentOrders : _previousOrders,
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
                List list = entryData.data as List;

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
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                width: 200,
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isCurrent = true;
                                        });
                                        print("Current");
                                      },
                                      child: Text('Current'),
                                      style: TextButton.styleFrom(
                                          backgroundColor: _isCurrent
                                              ? Colors.white
                                              : Colors.grey[700],
                                          primary: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25))),
                                    )),
                                    Expanded(
                                        child: TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isCurrent = false;
                                        });
                                        print("Previous");
                                      },
                                      child: Text('Previous'),
                                      style: TextButton.styleFrom(
                                          backgroundColor: _isCurrent
                                              ? Colors.grey[700]
                                              : Colors.white,
                                          primary: Colors.black,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25))),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _isCurrent
                              ? Expanded(
                                  child: !refresh
                                      ? GridView.builder(
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
                                          itemCount: list.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 550,
                                                        maxHeight: 220),
                                                padding: EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 8, 0, 0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.grey),
                                                child: InkWell(
                                                  onLongPress: () {},
                                                  child: Card(
                                                    elevation: 0,
                                                    color: Colors.grey,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            Flexible(
                                                                child: Text(list[
                                                                            index][1]
                                                                        [
                                                                        "token"]
                                                                    .toString()))
                                                          ],
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            children: [
                                                              Flexible(
                                                                child: Text(
                                                                    list[index]
                                                                        [0]),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    print(list[index]
                                                                            [1][
                                                                        "value"]);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .remove_red_eye_sharp)),
                                                              Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: Colors
                                                                          .green),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(0),
                                                                  child: () {
                                                                    switch (_state[
                                                                        index]) {
                                                                      case 0:
                                                                        return TextButton(
                                                                          child:
                                                                              const Text(
                                                                            "No Action",
                                                                            textScaleFactor:
                                                                                1,
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              _state[index] = 1;
                                                                            });
                                                                          },
                                                                        );

                                                                      case 1:
                                                                        return TextButton(
                                                                            child:
                                                                                const Text(
                                                                              "Preparing",
                                                                              textScaleFactor: 1,
                                                                              style: TextStyle(color: Colors.white),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                _state[index] = 2;
                                                                              });
                                                                            });

                                                                      case 2:
                                                                        return TextButton(
                                                                          child:
                                                                              const Text(
                                                                            "Done",
                                                                            textScaleFactor:
                                                                                1,
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            final status =
                                                                                database.child('Status');
                                                                            status.child(list[index][0]).set("1");

                                                                            refresh =
                                                                                true;
                                                                            setState(() {});
                                                                            list.removeAt(index);
                                                                            _state.removeAt(index);
                                                                            Timer(const Duration(milliseconds: 50),
                                                                                () {
                                                                              refresh = false;
                                                                              setState(() {});
                                                                            });
                                                                            print(list.length);
                                                                          },
                                                                        );

                                                                      default:
                                                                        return Text(
                                                                            "Error");
                                                                    }
                                                                  }())
                                                            ])
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                          })
                                      : const Text(""))
                              : Expanded(
                                  child: !refresh
                                      ? Container(
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Container(
                                                  child: Row(children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                      child: Text(
                                                        "Token",
                                                        textScaleFactor: 1.6,
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                      child: const Text(
                                                        "Phone  Number",
                                                        textScaleFactor: 1.6,
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: const Text(
                                                        "Time",
                                                        textScaleFactor: 1.6,
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.1,
                                                      child: const Text(
                                                        "Amount",
                                                        textScaleFactor: 1.6,
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                              ),
                                              Expanded(
                                                child: ListView.builder(
                                                    key: Key(
                                                        'builder ${selected.toString()}'),
                                                    itemCount: list.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return ExpansionTile(
                                                        key: Key(
                                                            index.toString()),
                                                        initiallyExpanded:
                                                            index == selected,
                                                        title: Container(
                                                          child: Row(children: [
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.25,
                                                              child: Text(
                                                                list[index]["value"]![
                                                                        "token"]
                                                                    .toString(),
                                                                textScaleFactor:
                                                                    1.5,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.25,
                                                              child: Text(
                                                                list[index]["value"]
                                                                        [
                                                                        "phone"]
                                                                    .toString(),
                                                                textScaleFactor:
                                                                    1.5,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.3,
                                                              child: Text(
                                                                list[index]["value"]
                                                                        ["time"]
                                                                    .toString(),
                                                                textScaleFactor:
                                                                    1.5,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.1,
                                                              child: Text(
                                                                "???" +
                                                                    list[index]["value"]
                                                                            [
                                                                            "totalPrice"]
                                                                        .toString(),
                                                                textScaleFactor:
                                                                    1.5,
                                                              ),
                                                            ),
                                                          ]),
                                                        ),
                                                        children: [
                                                          Center(
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.75,
                                                              child:
                                                                  _orginExpanded(),
                                                            ),
                                                          )
                                                        ],
                                                        onExpansionChanged:
                                                            ((newState) {
                                                          if (newState) {
                                                            setState(() {
                                                              CurrentTransactId =
                                                                  list[index]
                                                                      ["key"];
                                                              selected = index;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              selected = -1;
                                                            });
                                                          }
                                                        }),
                                                      );
                                                    }),
                                              )
                                            ],
                                          ),
                                        )
                                      : const Text(""))
                        ],
                      );
            }
          },
        ),
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
                "Okay",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      }));
}
