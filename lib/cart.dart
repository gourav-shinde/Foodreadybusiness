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

class CartView extends StatefulWidget {
  Map<MenuModel, int> pass = {};
  CartView(this.pass);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CartViewState(pass);
  }
}

class CartViewState extends State<CartView> {
  int checkout_amount = 0;
  Map<MenuModel, int> currentCart = {};
  String msg = "";
  CartViewState(this.currentCart);
  final _razorpay = Razorpay();
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds go to menu
    print("success");
    setState(() {
      msg = "Success";
    });
    Navigator.pop(context, 200);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("error");
    setState(() {
      alertBox(context, "Unexpected Error occured!");
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
    print("external access");
    setState(() {
      alertBox(context, "External Portal");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth _auth = FirebaseAuth.instance;
    print(_auth.currentUser);

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // _razorpay.open(options);
    currentCart.forEach((key, value) {
      checkout_amount = checkout_amount + (key.price * value);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: const Text(
          "Cart",
          style: TextStyle(
              color: Colors.black, fontFamily: 'RobotoMono', fontSize: 20),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.79,
            child: Container(
              child: currentCart.isEmpty
                  ? const Center(
                      child: Text("Empty Cart"),
                    )
                  : ListView.builder(
                      itemCount: currentCart.length,
                      itemBuilder: (BuildContext context, int index) {
                        MenuModel key = currentCart.keys.elementAt(index);
                        int value = currentCart.values.elementAt(index);

                        return ListTile(
                          leading: SizedBox(
                              child: CircleAvatar(
                            backgroundImage:
                                const AssetImage('images/spinning-loading.gif'),
                            radius: 35,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 35,
                              backgroundImage: NetworkImage(key.url),
                            ),
                          )),
                          title: Text(key.name),
                          subtitle: Text("Quantity: " + value.toString()),
                          trailing: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Text("₹" + (key.price * value).toString()),
                          ),
                        );
                      }),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey)),
                onPressed: () {
                  if (checkout_amount != 0) {
                    var options = {
                      'key': 'rzp_test_WmO6Cw1u0gMuY3',
                      'amount': checkout_amount * 100,
                      'name': 'Acme Corp.',
                      'description': 'Fine T-Shirt',
                      'prefill': {
                        'contact': '8888888888',
                        'email': 'test@razorpay.com'
                      }
                    };
                    _razorpay.open(options);
                  }
                },
                child: Text(
                  "Pay ₹ " + checkout_amount.toString(),
                  style: TextStyle(color: Colors.black),
                )),
          )
        ],
      ),
    );
  }
}
