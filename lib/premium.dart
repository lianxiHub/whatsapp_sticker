import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'consumable_store.dart';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';





class PremiumWidget extends StatefulWidget{
  PremiumWidget({
    Key key,
  }):super(key:key);


  @override
  PremiumState createState() => PremiumState();
}

const String _kConsumableId = 'consumable';
const bool kAutoConsume = true;
const List<String> _kProductIds = <String>[
  "allpacks"
];

class PremiumState extends State<PremiumWidget>{
  List<ProductDetails> _products = [];

  @override
  void initState(){
    Stream purchaseUpdated =
        InAppPurchaseConnection.instance.purchaseUpdatedStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _handlePurchaseUpdates(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    });
    super.initState();
    initStoreInfo();
  }
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _connection.isAvailable();
    if (!isAvailable) {
      setState(() {
        _products = [];
      });
      return;
    }

    ProductDetailsResponse productDetailResponse =
    await _connection.queryProductDetails(_kProductIds.toSet());

    if (productDetailResponse.error != null) {
      print("error");
      setState(() {
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _products = productDetailResponse.productDetails;
      });
      return;
    }

    final QueryPurchaseDetailsResponse purchaseResponse =
    await _connection.queryPastPurchases();
    if (purchaseResponse.error != null) {
      // handle query past purchase error..
    }
    print(purchaseResponse.pastPurchases);
    final List<PurchaseDetails> verifiedPurchases = [];
    for (PurchaseDetails purchase in purchaseResponse.pastPurchases) {
      if (await _verifyPurchase(purchase)) {
        verifiedPurchases.add(purchase);
      }
    }
    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _products = productDetailResponse.productDetails;
    });
  }


  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }


  StreamSubscription<List<PurchaseDetails>> _subscription;


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:Stack(
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
             alignment: Alignment(0,0),
             decoration: BoxDecoration(
               image:DecorationImage(
                 image:AssetImage(
                   'bg/premium_bg.png'
                 ),
                 alignment: Alignment.topCenter

               )
             ),
            child: Container(
              height:75,
//            color: Colors.green,
//              alignment: Alignment(0,0),
//                height:((MediaQuery.of(context).size.height-MediaQuery.of(context).size.width-140)),
              margin:EdgeInsets.only(top:MediaQuery.of(context).size.width+15,bottom: 130),
              child: new Column(
                 children: <Widget>[

                   Container(
                     margin:EdgeInsets.only(bottom:5),
                     width:280,
                     child: Row(
                       children: <Widget>[
                         Image(
                           image:AssetImage("icons/store.png"),
                           width:20,
                         ),
                         Text(
                           "  All emojis and stickers for free",
                           style: TextStyle(
                               fontWeight: FontWeight.w600,
                               color:Colors.black54
                           ),
                         )
                       ],
                     ),
                   ),
                   Container(
                     width:280,
                     margin:EdgeInsets.only(bottom:5),
                     child: Row(
                       children: <Widget>[
                         Image(
                           image:AssetImage("icons/store.png"),
                           width:20,
                         ),
                         Text(
                           "  New emojis and stickers every week",
                           style: TextStyle(
                               fontWeight: FontWeight.w600,
                               color:Colors.black54
                           ),
                         )
                       ],
                     ),
                   )
                   ,
                   Container(
                     width:280,
                     child: Row(
                       children: <Widget>[
                         Image(
                           image:AssetImage("icons/store.png"),
                           width:20,
                         ),
                         Text(
                           "  Remove all ads",
                           style: TextStyle(
                               fontWeight: FontWeight.w600,
                               color:Colors.black54
                           ),
                         )
                       ],
                     ),
                   )

                 ],
              )
            ),
          ),
          Positioned(
            child:GestureDetector(
              child:  new Icon(Icons.arrow_back,color:Colors.black,size:25),
              onTap:(){
                Navigator.pop(context);
              },
            ),


            top:40,
            left:16,
          ),
          Positioned(
            bottom:0,
            child: Column(
              children: <Widget>[
                Container(
//                  height:70,
//                  color:Colors.green,
                  decoration: BoxDecoration(
                    border: Border(top:BorderSide(color: Color(0xFFeeeeee),width:1)),
                  ),
                  padding:EdgeInsets.only(top:10),
                  child:Padding(
                      padding: EdgeInsets.only(left:40,right:40),
                      child:Container(

                        width:MediaQuery.of(context).size.width-80,
                        padding: EdgeInsets.only(left:5,right:5),
                        child: Text(
                            "Subscription only 0.99\$ per month, it will be automatically renewed and charged every month, also you can cancelit at anytime."
                            ,style:TextStyle(
                                fontSize: 12,color: Color(0xFF666666)
                            )
                        ),

                      )
                  ),
                ),

                Container(
                  margin:EdgeInsets.only(bottom:15,top:10),
                  child: Container(
                    width:MediaQuery.of(context).size.width-60,
                    height:50,
                    decoration: BoxDecoration(
                        color: Color(0xFFc3185e),
                        borderRadius: BorderRadius.all(Radius.circular(25))
                    ),
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                      ),
                      color:Color(0xFFc3185e) ,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width:50,
                            margin: EdgeInsets.only(),
                            child: ImageIcon(
                                AssetImage("icons/crown.png"),
                                color:Colors.white
                            ),
                          ),
                          Text("Subscribe",
                              style:TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600
                              )),
                        ],
                      ),

                      onPressed: () async{
//                      onPressed: () {
                        PurchaseParam purchaseParam = PurchaseParam(
                            productDetails: _products[0],
                            applicationUserName: null,
                            sandboxTesting: true);
                        if (_products[0].id == _kConsumableId) {
                          _connection.buyConsumable(
                              purchaseParam: purchaseParam,
                              autoConsume: kAutoConsume || Platform.isIOS);
                        } else {
                          _connection.buyNonConsumable(
                              purchaseParam: purchaseParam);
                        }
                      },

                    ),
                  ),
                ),




              ],
            ),
          )

//          Padding(
//            padding: EdgeInsets.only(left:45,right:45,top:45),
//            child:
//            new Stack(
//              children: <Widget>[
//                new Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Container(
//                      margin:EdgeInsets.only(bottom:10),
//                      child: Text("Remove all ads.",
//                        style: TextStyle(
//                            color:Color(0xff5b5b5b) ,
//                            fontSize: 20,
//                            fontWeight: FontWeight.w600
//                        ),),
//                    ),
//                    Container(
//                      child: Text("Get all emojis and stickers for free.",
//                        style: TextStyle(
//                            color:Color(0xff5b5b5b) ,
//                            fontSize: 20,
//                            fontWeight: FontWeight.w600
//                        ),),
//                    ),
//                  ],
//                ),
//                Positioned(
//                  bottom:80,
//                  left:(MediaQuery.of(context).size.width-220-90)/2,
//                  right:(MediaQuery.of(context).size.width-220-90)/2,
//                  child: new Container(
//                    child: Container(
//                      width:220,
//                      height:50,
//                      decoration: BoxDecoration(
//                          color: Color(0xFFc3185e),
//                          borderRadius: BorderRadius.all(Radius.circular(25))
//                      ),
//                      child: FlatButton(
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(25)
//                        ),
//                        color:Color(0xFFc3185e) ,
//                        child:Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Container(
//                              width:50,
//                              margin: EdgeInsets.only(),
//                              child: ImageIcon(
//                                  AssetImage("icons/crown.png"),
//                                  color:Colors.white
//                              ),
//                            ),
//                            Text("Premium",
//                                style:TextStyle(
//                                    fontSize: 16,
//                                    color: Colors.white,
//                                    fontWeight: FontWeight.w600
//                                )),
//                          ],
//                        ),
//
//                        onPressed: () async{
////                      onPressed: () {
//                          PurchaseParam purchaseParam = PurchaseParam(
//                              productDetails: _products[0],
//                              applicationUserName: null,
//                              sandboxTesting: true);
//                          if (_products[0].id == _kConsumableId) {
//                            _connection.buyConsumable(
//                                purchaseParam: purchaseParam,
//                                autoConsume: kAutoConsume || Platform.isIOS);
//                          } else {
//                            _connection.buyNonConsumable(
//                                purchaseParam: purchaseParam);
//                          }
//                        },
//
//                      ),
//                    ),
//                  ),
//                )
//
//
//              ],
//            ),
//          ),
        ],
      )



    );
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    print("purchaseUpdate");
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        print("purchaseDetails.status == PurchaseStatus.pending");
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          print("purchaseDetails.status == PurchaseStatus.error");
//          handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          print("purchaseDetails.status == PurchaseStatus.purchased");
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            print("valid");
            final prefs = await SharedPreferences.getInstance();
            prefs.setBool('purchse', true);
            Navigator.pop(context);

          } else {
            print("not valid");
//            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            await InAppPurchaseConnection.instance
                .consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchaseConnection.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }


  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }


}

