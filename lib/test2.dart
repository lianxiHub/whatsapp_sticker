import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp_stickers/whatsapp_stickers.dart';
import 'package:whatsapp_stickers/exceptions.dart';




Directory _appDocsDir;
File fileFromDocsDir(String filename)  {
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}
const iconUrl = "http://necta.us/emoji/icons/";
bool purchase = false;

class readPackWidget extends StatefulWidget{
  readPackWidget({
    Key key,
    @required this.packid,
  }):super(key:key);
  String packid;

  @override
  readPackState createState() => readPackState();
}

Future setPurchse() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print("prefs>>>>$prefs");

  if(prefs.getBool("purchse") != null){
    purchase = prefs.getBool("purchse");
  }
  print("purchse>>>$purchase");
//  return true;

}

class readPackState extends State<readPackWidget>{
  Future<String> setDir () async{
    _appDocsDir =await getApplicationDocumentsDirectory();
    return "a";
  }




  List iconList=[];
  String name = "";
  String whatsapp;
  String pro;
  bool isOver = false;
  void initState(){
    setPurchse();
    //print("initState");
    getPack();

  }
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    print("didChangeDependencies");


  }
  @override
  void deactivate(){
    print("deactivate");
  }


  Future getPack() async{
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.us/emoji/readpack.php?packid="+widget.packid));
    HttpClientResponse response = await request.close();
    Map data = jsonDecode(await response.transform(utf8.decoder).join());
    httpClient.close();
    if(data['result'] == "OK"){
      print(data);
      name = data['name'];
      whatsapp = data["whatsapp"];
      iconList = data['iconlist'];
      pro = data['pro'];
      setState(() {
        isOver = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("root build");
    return FutureBuilder(
      future:setDir(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot){
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // 请求失败，显示错误
            return Text("Error: ${snapshot.error}");
          } else {
            // 请求成功，显示数据
            return new Scaffold(
                appBar: AppBar(
                  title: Text(name),
                ),
                body:Center(
                    child:Container(
                        color: Color(0xFFf7f7f7),
                        child:
                        isOver?( StickerWidget(iconList: iconList,packid:widget.packid,pro:pro,name:name))
                            :CircularProgressIndicator()

                    )

                )
            );
          }
        } else {
          return new Scaffold(
              appBar: AppBar(
                title: Text(name),
              ),
              body:Center(
                  child:Container(
                    child: CircularProgressIndicator(),
                  )

              )
          );
          // 请求未结束，显示loading

        }
      },
    );
    // TODO: implement build

    throw UnimplementedError();
  }
}







class StickerWidget extends StatefulWidget{
  StickerWidget({
    Key key,
    this.iconList,
    this.packid,
    this.pro,
    this.name
  }):super(key:key);
  List iconList;
  String packid;
  String pro;
  String name;

  @override
  StickerState createState() => StickerState();
}

class StickerState extends State<StickerWidget>{
  String dir;
  Future getPath() async{
    dir=(await getApplicationDocumentsDirectory()).path;
  }
  void initState(){
    getPath();
    for(var i=0;i<widget.iconList.length;i++){
      widget.iconList[i]["checked"] = false;
    }
    if(Platform.isIOS){
      isDownOver(widget.iconList);
//       hasDone = true;
    }else if(Platform.isAndroid){

    }

    //initPlatformState();
  }

  void didChangeDependencies(){
    print("didChangeDependencies3");
//    setPurchse();

  }

  bool _stickerPackInstalled = false;
  String platformVersion;
  Directory deleteDir;

  WhatsAppStickers _waStickers;
  bool hasDone = false;
  void dispose() async{
    super.dispose();
    //将增加的存放图片的文件夹删除
    if(deleteDir !=null){
      if (deleteDir.existsSync()) {
        List<FileSystemEntity> files = deleteDir.listSync();
        if (files.length > 0) {
          files.forEach((file) {
            file.deleteSync();
          });
        }
        deleteDir.deleteSync();
      }
    }
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
          "publisher": "Emoji Store",
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

  Map getJSONFileforIOS(){
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
          "publisher": "Emoji Store",
          "tray_image_file":widget.iconList[0]["img"],
          "publisher_website" : "",
          "privacy_policy_website" : "",
          "license_agreement_website" : "",
          "stickers":stickers,

        }
      ]
    };
    return jsonfile;
  }

  void addToWhatsappforIOS() async{
    print("installFromRemote");
    var applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
    var stickersDirectory = Directory('${applicationDocumentsDirectory.path}/stickers');
    await stickersDirectory.create(recursive: true);
    Map stickers = {};

    for(int i=1;i<widget.iconList.length;i++){
      stickers["${widget.iconList[i]["img"]}"] = ['😄', '😀'];
    }
    // print("$stickers");
    var stickerPack = WhatsappStickers(
      identifier: widget.packid,
      name: widget.name,
      publisher: 'Emoji Store',
      trayImageFileName: WhatsappStickerImage.fromFile('${applicationDocumentsDirectory.path}/${widget.iconList[0]["img"]}'),
      publisherWebsite: '',
      privacyPolicyWebsite: '',
      licenseAgreementWebsite: '',
    );

    stickers.forEach((sticker, emojis) async {
      stickerPack.addSticker(WhatsappStickerImage.fromFile('${applicationDocumentsDirectory.path}/$sticker'), emojis);
    });


    try {
      await stickerPack.sendToWhatsApp();

    } on WhatsappStickersException catch (e) {
      print(e.cause);
    }

  }


  Widget getBtnWidget(){
    print("getBtnWidget");
    if(hasDone == true){
          return
            Positioned(
              bottom:50,
              left:(MediaQuery.of(context).size.width-220)/2,
              right:(MediaQuery.of(context).size.width-220)/2,
              child: new Container(
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
                      //            color: Colors.white,
                      color:Color(0xFFc3185e) ,
                      child: Text("ADD TO WHATSAPP",
                          style:TextStyle(
                              color: Colors.white
                          )),
                      onPressed: () async{
                          addToWhatsappforIOS();
                          //installFromRemote();


                      },

                    )


                ),
              ),
            );



    }else{
      return Text("");
    }


  }

  @override
  Widget build(BuildContext context) {

    return
      Container(
          constraints: BoxConstraints(
//          minWidth: 180,
            minHeight: MediaQuery.of(context).size.height,
          ),

          child: Stack(
            children: <Widget>[
              Container(
                height:MediaQuery.of(context).size.height-200,
//                margin: EdgeInsets.only(top:20),
                child: GridView(
                    padding: EdgeInsets.only(top:20),
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
                              //debug: true,
                                url: iconUrl+f['img'],
                                file: fileFromDocsDir(f["img"]))),
                          )


                        ],
                      );
                    }).toList()
                ),
              ),
              FutureBuilder(
                future: setPurchse(),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  return getBtnWidget();
                },
              ),
              hasDone?
              Text("")
                  :
              Center(
                  child: CircularProgressIndicator()
              )



            ],
          )
      );
  }
  void isDownOver(list) async {
    print("isDownOver");
    for(int i=0;i<list.length;i++){
      File img = File('$dir/${list[i]["img"]}');
//      print(dir);
      bool isExists = await img.exists();
      if(!isExists){
        var timeout = const Duration(milliseconds: 500);
        Timer(timeout,(){
          print('currentTime='+DateTime.now().toString());
          isDownOver(list);

        }

        );
        return;
      }
    }
    print("jieshule");
    setState(() {
      hasDone = true;
    });


  }


}







