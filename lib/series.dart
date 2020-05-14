import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'emoji.dart';
//import 'sticker.dart';
//背景颜色e5到f2

const iconUrl = "http://necta.us/emoji/icons/";
class readSeriesWidget extends StatefulWidget{
  readSeriesWidget({
    Key key,
    this.seriesid,
  }):super(key:key);
  String seriesid;

  @override
  readSeriesState createState() => readSeriesState();
}

class readSeriesState extends State<readSeriesWidget>{
  bool isOver = false;
  String name = "";
  List packList;
  void initState(){
    getSeries();
  }

  Future getSeries() async{
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.us/emoji/readseries.php?seriesid="+widget.seriesid));
    HttpClientResponse response = await request.close();
    Map data = jsonDecode(await response.transform(utf8.decoder).join());
    httpClient.close();
    if(data['result'] == "OK"){
      print(data);
      packList = data['packlist'];
      name = data['name'];
      setState(() {
        isOver = true;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(name,
        style: TextStyle(
          fontWeight: FontWeight.w600
        ),),
      ),
      body:isOver?
        Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:[Color(0xFFe5e5e5), Color(0xFFf2f2f2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          ),
//          color: Color(0xFFf5f5f5),
          child:
            Padding(
            padding: EdgeInsets.all(10),
                child: ListWidget(packlist:packList),
             )
        )
          :
          Center(
            child: CircularProgressIndicator(),
          )

    );
    throw UnimplementedError();
  }
}


class ListWidget extends StatefulWidget{
  ListWidget({
    Key key,
    @required this.packlist,
  }):super(key:key);
  List packlist;

  @override
  ListState createState() => ListState();
}

class ListState extends State<ListWidget>{
  Widget buildList(){
    List<Widget> list = [];
    for(var i=0;i<widget.packlist.length;i++){
      list.add(
          Container(
            height:120,
//              color:Color(0xFFf7f7f7),
            color: Colors.white,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              child: Column(
                children: <Widget>[
                  Container(
                    margin:EdgeInsets.only(top:10,bottom:15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:<Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              margin:EdgeInsets.only(right:15,left:5,),
                              child: Text(widget.packlist[i]["name"],style:TextStyle(

                                  fontWeight: FontWeight.w600
                              )),
                            ),

                            Text(widget.packlist[i]["author"],style:TextStyle(

                                color:Color(0xff646464),
                                fontSize: 12
                            )),
                          ],

                        ),
                        widget.packlist[i]["pro"]=="1"?Row(
                          children: <Widget>[
                            Container(
                              width:20,
                              margin: EdgeInsets.only(right:2),
                              child: ImageIcon(
                                  AssetImage("icons/crown.png"),
                                  color:Color(0xffE91E63)
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right:10),
                              child: Text("Premium",
                                  textAlign: TextAlign.left,style:TextStyle(
                                    color: Color(0xffE91E63),
                                    fontSize: 13,

                                  )),
                            )


                          ],
                        ):Text("")
                      ]

                    ),
                  ),

                  buildOne(widget.packlist[i]["iconlist"])
                ],
              ),
              onTap: (){
                Navigator.push( context,
                    MaterialPageRoute(builder: (context) {
                      return readPackWidget(packid:widget.packlist[i]["packid"]);
                    }));

              },
            )

          )
      );
    }
    return Column(
      children: list,
    );
  }

  Widget buildOne(iconlist){
    List<Widget> list = [];
    int limit;
    if(iconlist.length>=4){
      limit = 4;
    }else{
      limit = iconlist.length;
    }
    for(var i=0;i<limit;i++){
         list.add(
           Container(
             margin:EdgeInsets.only(right:12),
             child: Image.network(iconUrl+iconlist[i]["img"],width:50),
           ),
         );

    }
    if(iconlist.length>4){
      list.add(
        Text("+"+(iconlist.length-4).toString(),
            style:TextStyle(
              fontSize: 24,
              color: Color(0xffcbcbcb),
            )),
      );
    }
    return
      Row(
          children: list,
        );

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: buildList()
    );
    throw UnimplementedError();
  }
}