import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:share_extend/share_extend.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter_whatsapp_stickers/flutter_whatsapp_stickers.dart';
import 'premium.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


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
  Future setDir () async{
    _appDocsDir =await getApplicationDocumentsDirectory();
  }




  List iconList=[];
  String name = "";
  String whatsapp;
  String pro;
  bool isOver = false;
  void initState(){
    setDir();
    setPurchse();
    print("initState");
    getPack();

  }

  void didChangeDependencies() async {
    super.didChangeDependencies();
    print("didChangeDependencies");


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

    // TODO: implement build
    return new Scaffold(
        appBar: AppBar(
          title: Text(name),
        ),
        body:Center(
          child:Container(
            color: Color(0xFFf7f7f7),
            child:
                isOver?(whatsapp == "0" ? PackWidget(iconList:iconList,packid:widget.packid,pro:pro) : StickerWidget(iconList: iconList,packid:widget.packid,pro:pro,name:name)):CircularProgressIndicator()
//              iconList.length>0?PackWidget(iconList:iconList):CircularProgressIndicator()
          )

        )
    );
    throw UnimplementedError();
  }
}


class PackWidget extends StatefulWidget{
  PackWidget({
    Key key,
    this.iconList,
    this.pro,
    this.packid
  }):super(key:key);
  List iconList;
  String pro;
  String packid;

  @override
  PackState createState() => PackState();
}

Future want(packid) async{
  HttpClient httpClient = new HttpClient();
  //打开Http连接
  HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.us/emoji/want.php?packid="+packid));
  HttpClientResponse response = await request.close();
//     Map data = jsonDecode(await response.transform(utf8.decoder).join());
  httpClient.close();
}

class PackState extends State<PackWidget>{
   String dir;
   void initState() {
       getPath();
       for(var i=0;i<widget.iconList.length;i++){
         widget.iconList[i]["checked"] = false;
       }
   }

   Future getPath() async{
     dir=(await getApplicationDocumentsDirectory()).path;
   }

   void didChangeDependencies() async {
     super.didChangeDependencies();
     print("didChangeDependencies2");
//     await setPurchse();

   }




   List<String> checkedList = [];
   Widget getBtnWidget(){
     print("getBtnWidget");
     if(widget.pro == '1' && !purchase){
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
                     await want(widget.packid);
                     Navigator.push( context,
                         MaterialPageRoute(builder: (context) {
                           return PremiumWidget();
                         }));
//                      addToWhatsapp();
                   },

                 )


             ),
           ),
         );

     }else{
       return
         Positioned(
           bottom:50,
           left:(MediaQuery.of(context).size.width-220)/2,
           right:(MediaQuery.of(context).size.width-220)/2,
           child: Container(
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
               child: Text("SHARE",
                   style:TextStyle(
                       color: Colors.white
                   )),
//            onPressed: _requestAppDocumentsDirectory
               onPressed: () async{
                 String dir=(await getApplicationDocumentsDirectory()).path;
                 for(var i=0;i<checkedList.length;i++){
                   File f=new File(checkedList[i]);
                   var dir_bool=await f.exists();
                   if(dir_bool){
                     print("exist");
                   }else{
                     print("not exist");
                   }
                 }
//            if (f != null) {
//              ShareExtend.share(f.path, "image",
//                  sharePanelTitle: "share image title",
//                  subject: "share image subject");
//            }
                 ShareExtend.shareMultiple(checkedList, "image");


               },

             ),
           ),

         );
     }



   }
  @override
  Widget build(BuildContext context) {
    return
    Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
      child: Stack(
        children: <Widget>[
          Container(
//            color: Colors.green,
            height:480,
//            padding: EdgeInsets.only(top:20),
            child: GridView(
              padding: EdgeInsets.only(top:20),

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, //横轴三个子widget
                    childAspectRatio: 1,//宽高比为1时，子widget
                ),
                children:widget.iconList.map((f){
                  return Column(
                    children: <Widget>[
                      SizedBox(
                        width:60,
                        child:Image(image:
                        NetworkToFileImage(
                            url: iconUrl+f['img'],
                            file: fileFromDocsDir(f['img']),
                            )),
                      ),

//                     Image.network(iconUrl+f['img'],width:60),
                      SizedBox(
                        height:30,
                        child: Checkbox(
                          value: f['checked'],
                          activeColor: Colors.red, //选中时的颜色
                          onChanged:(value){
                            setState(() {
                              f["checked"] = !f["checked"];
                              if(f["checked"]){
                                if(!checkedList.contains(dir+"/"+f['img'])){
                                  checkedList.add(dir+"/"+f['img']);
                                }

                              }else{
                                if(checkedList.contains(dir+"/"+f['img'])){
                                  checkedList.remove(dir+"/"+f['img']);
                                }
                              }
                            });
                          } ,
                        ),
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
          )

        ],
      )
    );

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

  void initState(){
    for(var i=0;i<widget.iconList.length;i++){
      widget.iconList[i]["checked"] = false;
    }
    initPlatformState();
  }

  void didChangeDependencies(){
    print("didChangeDependencies3");
//    setPurchse();

  }

  String _platformVersion = 'Unknown';
  bool _whatsAppInstalled = false;
  bool _whatsAppConsumerAppInstalled = false;
  bool _whatsAppSmbAppInstalled = false;
  bool _stickerPackInstalled = false;
  String platformVersion;
  Directory deleteDir;

  WhatsAppStickers _waStickers;
  bool hasDone = false;
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
      hasDone = true;
      _platformVersion = platformVersion;
      _whatsAppInstalled = whatsAppInstalled;
      _whatsAppConsumerAppInstalled = whatsAppConsumerAppInstalled;
      _whatsAppSmbAppInstalled = whatsAppSmbAppInstalled;
    });
  }
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
  void addToWhatsapp () async {
//     initPlatformState();
    String dir = (await getApplicationDocumentsDirectory()).path;
    Directory stickersDirectory = Directory("$dir/sticker_packs");
    if (!await stickersDirectory.exists()) {
      await stickersDirectory.create();
    }

    File jsonFile = File('$dir/sticker_packs/sticker_packs.json');
    String content = jsonEncode(getJSONFile());
    jsonFile.writeAsStringSync(content);

    var content2 = await jsonFile.readAsStringSync();
    String url = stickersDirectory.path;
    String packid = widget.packid;
    Directory num = Directory("$url/$packid");
    if(!await num.exists()){
      await num.create();
//       print("ID目录不存在,正在建立");
    }
    deleteDir = num;
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

    _waStickers.addStickerPack(
      packageName: WhatsAppPackage.Consumer,
      stickerPackIdentifier: widget.packid,
      stickerPackName: widget.name,
      listener: _listener,
    );

  }
  Widget getBtnWidget(){
    print("getBtnWidget");
    if(hasDone == true){
      if(_stickerPackInstalled == false){

        if(widget.pro == '1' && !purchase){
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
                        await want(widget.packid);
                        Navigator.push( context,
                            MaterialPageRoute(builder: (context) {
                              return PremiumWidget();
                            }));
//                      addToWhatsapp();
                      },

                    )


                ),
              ),
            );

        }else{
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
                        addToWhatsapp();
                      },

                    )


                ),
              ),
            );

        }
      }else{
        return Positioned(
            bottom: 50,
            left:(MediaQuery.of(context).size.width-185)/2,
            right:(MediaQuery.of(context).size.width-185)/2,
            child:
            Container(
              width:185,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.done),
                  GestureDetector(
                    child: Text.rich(TextSpan(
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16
                        ),
                        children: [
                          TextSpan(
                            text:" Added to ",

                          ),
                          TextSpan(
                            text: "WhatsApp",
                            style: TextStyle(
                              color:Color(0xffE91E63),

                            ),

                          )
                        ]
                    )),
                    onTap: () async {


//                      try {
//                        await Linker.startActivity(new Intent.callApp( packageName:  "com.tencent.mm",className: "com.tencent.mm.ui.LauncherUI"));
//                      } on PlatformException catch (e) {
//                        print("Open failed $e");
//                      }
//                      print("tap");
                      const url = 'whatsapp://app ';
                      await launch(url);
                      if (await canLaunch(url)) {
                        print("andriod");
                        await launch(url);
                      } else {
                        //  Ios
                        print("IOS");
                        const url = 'whatsapp://';
                        if(await canLaunch(url)){
                          await launch(url);
                        }else{
                          throw 'Could not launch $url';
                        }
                      }
                    },
                  )



                ],
              ),
            )

        );

      }
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
                height:480,
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
              )


            ],
          )
      );
  }

  Future<void> _listener(StickerPackResult action, bool result,
      {String error}) async {
    print("_listener");
    print(action);
    print(result);
    if(action == StickerPackResult.ADD_SUCCESSFUL){
      setState(() {
        _stickerPackInstalled = true;
      });
    }
    print(error);
  }
}





