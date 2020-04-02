import 'package:flutter/material.dart';

class PremiumWidget extends StatefulWidget{
  PremiumWidget({
    Key key,
  }):super(key:key);


  @override
  PremiumState createState() => PremiumState();
}

class PremiumState extends State<PremiumWidget>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body:Padding(
        padding: EdgeInsets.only(left:45,right:45,top:45),
        child:
        new Stack(

          children: <Widget>[
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin:EdgeInsets.only(bottom:10),
                  child: Text("Remove all ads.",
                    style: TextStyle(
                        color:Color(0xff5b5b5b) ,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),),
                ),
                Container(
                  child: Text("Get all emojis and stickers for free.",
                    style: TextStyle(
                        color:Color(0xff5b5b5b) ,
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),),
                ),
              ],
            ),
            Positioned(
              bottom:80,
              left:(MediaQuery.of(context).size.width-220-90)/2,
              right:(MediaQuery.of(context).size.width-220-90)/2,
              child: new Container(
//                decoration: BoxDecoration(
//                  color: Colors.green
//                ),
//                alignment: Alignment.center,
                child: Container(
                  width:220,
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
                        Text("Premium",
                            style:TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600
                            )),
                      ],
                    ),

                    onPressed: () async{

//                      addToWhatsapp();
                    },

                  ),
                ),
              ),
            )


          ],
        ),
      ),


    );
  }
}

