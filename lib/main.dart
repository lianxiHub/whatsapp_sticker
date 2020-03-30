import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'emoji.dart';
import 'sticker.dart';
import 'series.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:network_to_file_image/network_to_file_image.dart';



void main() async{
//  debugPaintSizeEnabled = true;
//  debugPaintPointersEnabled = true;
//  debugPaintLayerBordersEnabled = true;
//  debugRepaintRainbowEnabled = true;

  WidgetsFlutterBinding.ensureInitialized();
  _appDocsDir = await getApplicationDocumentsDirectory();
  runApp(MyApp());
}

const iconUrl = "http://necta.online/emoji/icons/";
Directory _appDocsDir;


File fileFromDocsDir(String filename) {
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Store',
      theme: ThemeData(
          primaryColor:Colors.white,
        fontFamily: 'our'
      ),
      home: MyHomePage(title: 'Emoji Store'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List list;
  List banner;
  Map feature;
  List seriesList = [];


  Future getHttp() async{
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.online/emoji/exploreV1.php?country=CN"));
    HttpClientResponse response = await request.close();
    Map data = jsonDecode(await response.transform(utf8.decoder).join());
    httpClient.close();
    if(data['result'] == "OK"){
      return data['series'];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:
      Center(
        child: FutureBuilder(
          future:getHttp(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // 请求已结束
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
//                // 请求失败，显示错误
                return Text("Error: ${snapshot.error}");
              } else {
                seriesList = [];
                for(var i=0;i<snapshot.data.length;i++){

                  if(snapshot.data[i]["type"] == "banner"){
                    banner = snapshot.data[i]["list"];
                  }else if(snapshot.data[i]["type"] == 'feature'){
                    feature = snapshot.data[i];
                  }else if(snapshot.data[i]["type"] =="series"){
                     seriesList.add(snapshot.data[i]);
                  }
                }


//                // 请求成功，显示数据

                return Container(
                    decoration: BoxDecoration(color: Colors.black12),
                    child: SingleChildScrollView(
                      child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: new Column(
                          children: [
                            SwiperWidget(banner:banner),
                            FeatureWidget(feature:feature),
                            SeriesWidget(seriesList: seriesList,)
                          ],
                        ),
                      )
//
                    ],
                  ),

                    ),

                );

              }
            } else {
              // 请求未结束，显示loading
              return CircularProgressIndicator();
            }
          },
        )
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class SwiperWidget extends StatefulWidget{
  SwiperWidget({
    Key key,
    @required this.banner,
  }):super(key:key);
   List banner;
  @override
  SwiperState createState() => SwiperState();
}

class SwiperState extends State<SwiperWidget>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: MediaQuery.of(context).size.width,
      height:150,
      child: new Swiper(
        itemBuilder: (BuildContext context,int index){
         // return new Image.network(iconUrl+widget.banner[index]['img'],fit: BoxFit.fill,);
          return Image(image:
          NetworkToFileImage(
              url: iconUrl+widget.banner[index]['img'],
              file: fileFromDocsDir(widget.banner[index]['img']),
              debug: false));
        },
        itemCount: widget.banner.length,
        pagination: new SwiperPagination(),
        control: new SwiperControl(),
        autoplay: true,
      ),
    );
    throw UnimplementedError();
  }
}


class FeatureWidget extends StatefulWidget{
  FeatureWidget({
    Key key,
    this.feature,
  }):super(key:key);

  Map feature;
  @override
  FeatureState createState() => FeatureState();
}

class FeatureState extends State<FeatureWidget>{
  Widget buildList(){
    List<Widget> tiles=[];
    List list = widget.feature['list'];
    int limit;
    if(list.length>=4){
       limit = 4;
    }else{
       limit = list.length;
    }
    for(var i=0;i<limit;i++){
       tiles.add(
         Container(
           padding: EdgeInsets.only(left:5,right:5),
           child:
               SizedBox(
                 width:50,
                 child:Image(image:
                 NetworkToFileImage(
                     url: iconUrl+list[i]["img"],
                     file: fileFromDocsDir(list[i]["img"]),
                     debug: false)) ,
               )

//           Image(
//               image: NetworkImage(
//                   iconUrl+list[i]["img"]),
//               width:50
//
//           ),
         ),
       );
    }

    if(list.length>4){
      int num = list.length-4;
      tiles.add(
        Container(
          margin:EdgeInsets.only(left: 20.0),
          child:Text("+" + num.toString(),
              style:TextStyle(
                  fontSize: 24,
                  color: Colors.black12,

              )),
        )


      );
    }
    return new Row(
      children: tiles,
    );
  }
//  Widget ExampleWidget = buildList();

   @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          margin: EdgeInsets.only(top: 10.0),
          decoration: BoxDecoration(color: Colors.white),
          child:Column(
              children:[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10.0,bottom:10,right:20,),
                      decoration: BoxDecoration(color: Color(0xFFc4165b)),
                      child: new Padding(
                        padding: const EdgeInsets.all(10),
                        child: new Text("feature",
                            style:TextStyle(color:Colors.white)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right:10),
                      child: Text(
                          widget.feature['packname'],

                      ),
                    ),

                    Text(
                      widget.feature["author"],
                      style: TextStyle(

                          color:Colors.black26,
                          fontSize: 12
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0,right:10,bottom:10),
                  child:buildList()
                  ,
                )
              ]
          )
      ),
      onTap: (){
        if(widget.feature["whatsapp"] == "0"){
          Navigator.push( context,
              MaterialPageRoute(builder: (context) {
                return readPackWidget(packid:widget.feature["packid"],name:widget.feature["packname"],);
              }));
        }else{
          Navigator.push( context,
              MaterialPageRoute(builder: (context) {
                return readStickerWidget(packid:widget.feature["packid"],name:widget.feature["packname"],);
              }));
        }

      },
    );

    // TODO: implement build
    throw UnimplementedError();
  }
}

class SeriesWidget extends StatefulWidget{
  SeriesWidget({
    Key key,
    this.seriesList
  }):super(key:key);
  List seriesList;

  @override
  SeriesState createState() => SeriesState();
}

class SeriesState extends State<SeriesWidget>{
  Widget buildSeries(){
    List<Widget> item = [];
//    print(widget.seriesList);
     for(var i=0;i<(widget.seriesList).length;i++){
       item.add(
         Container(padding: EdgeInsets.only(top:15,left:15,right:10),
           margin:EdgeInsets.only(top:10),
           decoration: BoxDecoration(color: Colors.white),
           child: Column(
             children: <Widget>[
               Row(
                 mainAxisAlignment:MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                   Text(widget.seriesList[i]["seriesname"],),
                   GestureDetector(
                     child:Text("MORE",
                       style: TextStyle(
                           fontSize: 12,
                       ),) ,
                     onTap: (){
                       Navigator.push( context,
                           MaterialPageRoute(builder: (context) {
                             return readSeriesWidget(seriesid:widget.seriesList[i]["seriesid"],name:widget.seriesList[i]["seriesname"],);
                           }));
                     },

                   )

                 ],
               ),
               new Container(
                 margin:EdgeInsets.only(top:15),
                 height:150,
                 child: buildListView(widget.seriesList[i]["list"])

               ),


             ],
           ),
         ),
       );

     }
     return Column(
       children: item
     );
  }

  Widget buildListView(list){
//    print(list);
    List<Widget> itemj = [];
    int limit;
    if(list.length>6){
      limit = 6;
    }else{
      limit = list.length;
    }
    for(var j=0;j<limit;j++){
      double num;
      limit-1 == j ? num =0 : num = 15;
      itemj.add(
        Container(
          margin:EdgeInsets.only(right:num),
          child:Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width:100,
                    height:100,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Color(0xFFf6f6f6)),
                    child: buildGridView(list[j]["iconlist"])
                ),
                onTap: (){
                  if(list[j]["whatsapp"] == "0"){
                    Navigator.push( context,
                        MaterialPageRoute(builder: (context) {
                          return readPackWidget(packid:list[j]["packid"],name:list[j]["name"],);
                        }));
                  }else{
                    Navigator.push( context,
                        MaterialPageRoute(builder: (context) {
                          return readStickerWidget(packid:list[j]["packid"],name:list[j]["name"],);
                        }));
                  }
                }
              ),

              Container(
                margin: EdgeInsets.only(top:5),
                child: Text(list[j]["name"],textAlign: TextAlign.left,style:TextStyle(
                    color: Colors.black26,
                )),

              ),
              Container(
                margin: EdgeInsets.only(top:5),
                child: Text(list[j]["author"],
                    textAlign: TextAlign.left,style:TextStyle(
                      color: Colors.black26,

                    )),
              )
            ],
          ) ,
        )

      );
    }

     return ListView(
        scrollDirection:Axis.horizontal,
//        itemExtent:110,
        children: itemj,
     );

  }

  Widget buildGridView(iconList){
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

//            Image.network(
//                iconUrl+iconList[0]["img"],
//                width:40
//
//            ),
            SizedBox(
              width:40,
              child:Image(image:
              NetworkToFileImage(
                  url: iconUrl+iconList[0]["img"],
                  file: fileFromDocsDir(iconList[0]["img"]),
                  debug: false))
            ),
            SizedBox(
                width:40,
                child:Image(image:
                NetworkToFileImage(
                    url: iconUrl+iconList[1]["img"],
                    file: fileFromDocsDir(iconList[1]["img"]),
                    debug: false))
            ),
//            Image.network(
//                iconUrl+iconList[1]["img"],
//                width:40
//
//            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
                width:40,
                child:Image(image:
                NetworkToFileImage(
                    url: iconUrl+iconList[2]["img"],
                    file: fileFromDocsDir(iconList[2]["img"]),
                    debug: false))
            ),
            SizedBox(
                width:40,
                child:Image(image:
                NetworkToFileImage(
                    url: iconUrl+iconList[3]["img"],
                    file: fileFromDocsDir(iconList[3]["img"]),
                    debug: false))
            ),
//            Image.network(
//                iconUrl+iconList[2]["img"],
//                width:40
//
//            ),
//            Image.network(
//                iconUrl+iconList[3]["img"],
//                width:40
//
//            ),
          ],
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return buildSeries();
  }
}

