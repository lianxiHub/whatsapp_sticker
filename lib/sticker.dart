import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
//import 'main.dart';



const iconUrl = "http://necta.online/emoji/icons/";

Directory _appDocsDir;
class readStickerWidget extends StatefulWidget{
  readStickerWidget({
    Key key,
    this.packid,
    @required this.name,
  }):super(key:key);
  String packid;
  String name;

  @override
  readStickerState createState() => readStickerState();
}



File fileFromDocsDir(String filename)  {
//  print(_appDocsDir);

//  print(_appDocsDir);
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}

class readStickerState extends State<readStickerWidget>{
  Future setDir () async{
    _appDocsDir =await getApplicationDocumentsDirectory();
  }

  void initState(){
    setDir();
    print("initState");
  }

  void didChangeDependencies(){
     print("didChangeDependencies");
  }

  void deactivate(){
     print("deactivate");
  }

  void dispose(){
    super.dispose();
      print("dispose");
  }

//  void didUpdateWidget(){
//    print("didUpdateWidget");
//  }


  Future getPack() async{
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.online/emoji/readpack.php?packid="+widget.packid));
    HttpClientResponse response = await request.close();
    Map data = jsonDecode(await response.transform(utf8.decoder).join());
    httpClient.close();
//    print(data);
    if(data['result'] == "OK"){
      return data['iconlist'];
    }

  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return new Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body:Center(
            child:Container(
              color: Color(0xFFf5f5f5),
              child: FutureBuilder(
                future: getPack(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
//                // 请求失败，显示错误
                      return Text("Error: ${snapshot.error}");
                    } else {
//                 print((snapshot.data));
                      return StickerWidget(iconList:snapshot.data,
                      packid:widget.packid,
                      name:widget.name);

                    }
                  } else {
                    // 请求未结束，显示loading
                    return CircularProgressIndicator();
                  }
                },
              ),
            )

        )
    );
    throw UnimplementedError();
  }
}
class StickerWidget extends StatefulWidget{
  StickerWidget({
    Key key,
    this.iconList,
    this.packid,
    this.name,
  }):super(key:key);
  List iconList;
  String packid;
  String name;

  @override
  StickerState createState() => StickerState();
}

class StickerState extends State<StickerWidget>{

  void initState(){
    for(var i=0;i<widget.iconList.length;i++){
      widget.iconList[i]["checked"] = false;
    }

  }


  String _platformVersion = 'Unknown';

  bool _whatsAppInstalled = false;
  bool _whatsAppConsumerAppInstalled = false;
  bool _whatsAppSmbAppInstalled = false;
  bool _stickerPackInstalled = false;
  String platformVersion;


  WhatsAppStickers _waStickers;

  Future<void> initPlatformState() async {
    _waStickers= WhatsAppStickers();
    try {
      platformVersion = await WhatsAppStickers.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
//     _waStickers


    // Platform messages may fail, so we use a try/catch PlatformException.


    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    bool whatsAppInstalled = await WhatsAppStickers.isWhatsAppInstalled;
    bool whatsAppConsumerAppInstalled =
    await WhatsAppStickers.isWhatsAppConsumerAppInstalled;
    bool whatsAppSmbAppInstalled =
    await WhatsAppStickers.isWhatsAppSmbAppInstalled;

    _stickerPackInstalled =
    await _waStickers.isStickerPackInstalled(widget.packid);

    setState(() {
      _platformVersion = platformVersion;
      _whatsAppInstalled = whatsAppInstalled;
      _whatsAppConsumerAppInstalled = whatsAppConsumerAppInstalled;
      _whatsAppSmbAppInstalled = whatsAppSmbAppInstalled;
    });
  }
  void dispose(){
    super.dispose();
  }
  Map getJSONFile(){
    List stickers = [];
    for(var i=1;i<widget.iconList.length;i++){
       stickers.add({
         "image_file": widget.iconList[i]["img"],
       });
    }
    Map jsonfile = {
      "android_play_store_link": "",
      "ios_app_store_link": "",
      "sticker_packs":[
        {
          "identifier":widget.packid,
          "name":widget.name,
          "publisher": "Example Sticker Pack",
          "tray_image_file":widget.iconList[0]["img"],
          "publisher_email":"",
          "publisher_website": "",
          "privacy_policy_website": "",
          "license_agreement_website": "",
          "image_data_version":"1",
          "avoid_cache": false,
          "stickers":stickers

        }
      ]
    };
    return jsonfile;
  }

   void  addToWhatsapp () async {
     initPlatformState();
     String dir = (await getApplicationDocumentsDirectory()).path;
     Directory stickersDirectory = Directory("$dir/sticker_packs");
     if (!await stickersDirectory.exists()) {
        await stickersDirectory.create();
     }

     File jsonFile = File('$dir/sticker_packs/sticker_packs.json');
     String content = jsonEncode(getJSONFile());
     jsonFile.writeAsStringSync(content);

     var content2 = await jsonFile.readAsStringSync();
//     print("content>>$content2");
     String url = stickersDirectory.path;
     String packid = widget.packid;
     Directory num = Directory("$url/$packid");
     if(!await num.exists()){
       await num.create();
//       print("ID目录不存在,正在建立");
     }
     String url2 = num.path;
     for(var i=0;i<widget.iconList.length;i++){
       String img = widget.iconList[i]["img"];
       File info =  new File("$dir/$img");
       info.copySync('$url2/$img');
     }

       Directory dire2 = Directory("$url");
      dire2.listSync().forEach((file) {
//        print("pack文件夹里有");
//        print(file.path);
      });
     Directory dire3 = Directory("$url2");
     dire3.listSync().forEach((file) {
//       print("编号文件夹里有");
//       print(file.path);
     });
     print(WhatsAppPackage.Consumer);
     print(widget.packid);
     print(widget.name);

     _waStickers.addStickerPack(
       packageName: WhatsAppPackage.Consumer,
       stickerPackIdentifier: widget.packid,
       stickerPackName: widget.name,
       listener: _listener,
     );

   }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: <Widget>[
          Container(
            height:500,
            margin: EdgeInsets.only(top:20),
            child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, //横轴三个子widget
                    childAspectRatio: 1//宽高比为1时，子widget
                ),
                children:widget.iconList.map((f){
                  return Column(
                    children: <Widget>[
//                      Image.network(iconUrl+f['img'],width:60),
                    SizedBox(
                      width:60,
                      child: Image(image:
                      NetworkToFileImage(
//                        debug: true,
                          url: iconUrl+f['img'],
                          file: fileFromDocsDir(f["img"]))),
                    )


                    ],
                  );
                }).toList()
            ),
          ),
          Container(
            width:200,
            height:50,
            decoration: BoxDecoration(
                color: Color(0xFFc3185e),
                borderRadius: BorderRadius.all(Radius.circular(25))
            ),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)
              ),
//            color: Colors.white,
              color:Color(0xFFc3185e) ,
              child: Text("ADD TO WHATSAPP",
                  style:TextStyle(
                      color: Colors.white
                  )),
              onPressed: () async{
                addToWhatsapp();
              },

            ),
          ),

        ],
      );
    throw UnimplementedError();
  }

  Future<void> _listener(StickerPackResult action, bool result,
      {String error}) async {
    print("_listener");
    print(action);
    print(result);
    print(error);
  }
}