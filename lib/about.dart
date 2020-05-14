import 'package:flutter/material.dart';

class AboutWidget extends StatefulWidget{
//  AboutWidget({
//    Key key,
//}):super(key:key);
  @override
  AboutState createState() => AboutState();
}


class AboutState extends State<AboutWidget>{
  @override
  Widget build(BuildContext context){
     return new Scaffold(
       body:Stack(
         children: <Widget>[
           new Column(
             children: <Widget>[
               Image(
                 image: AssetImage("bg/about.png")
               ),
               new Padding(
                 padding: const EdgeInsets.only(left:30,right:30,top:30),
                 child: Column(
                   children: <Widget>[
                     Text(
                       "Emoji Store provides thousands of funny and cute emoji and stickers.",
                       style: TextStyle(
                         color:Color(0xff8b8b8b),
                         height: 1.5,
                       ),
                     ),
                     Text(
                       "Our team is committed to making more fun emoji.",
                       style: TextStyle(
                           color:Color(0xff8b8b8b),
                         height: 1.5,
                       ),
                     ),
                     Text.rich(
                       TextSpan(
                         children: [
                           TextSpan(
                             text:"If you have the emoji or stickers you want,you can send us an email: ",
                             style: TextStyle(
                                 color:Color(0xff8b8b8b),
                               height: 1.5,
                             ),
                           ),
                           TextSpan(
                             text:"wangshimeng@gmail.com.",
                             style: TextStyle(
                               color: Color(0xffd2005b),
                               height: 1.5,
                             )
                           )
                         ]
                       )

                     ),
                     Text.rich(TextSpan(
                       children:[
                         TextSpan(
                             style: TextStyle(
                                 color:Color(0xff8b8b8b),
                               height: 1.5,
                             ),
                           text:"If you are an art designer and you want to cooperate with us,please also contact us: "
                         ),
                         TextSpan(
                           text:"wangshimeng@gmail.com.",
                             style: TextStyle(
                                 color: Color(0xffd2005b),
                               height: 1.5,
                             )
                         )
                       ]
                     )),

                   ],
                 ),
               ),

             ],

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
             bottom: 30,
             child: Container(
//               color:Colors.green,
                 width:MediaQuery.of(context).size.width,
                 child: Text(
                     "Copyright 2020 by Kada CO.LTD",
                   textAlign: TextAlign.center,
                   style:TextStyle(
                     color:Color(0xff8e8e8e),
                     fontSize: 12
                   )
                 ),
                )
           )


         ],
       )
     );
  }
}

