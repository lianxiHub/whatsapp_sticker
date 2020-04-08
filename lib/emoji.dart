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

Directory _appDocsDir;
File fileFromDocsDir(String filename)  {
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}
const iconUrl = "http://necta.online/emoji/icons/";
class readPackWidget extends StatefulWidget{
  readPackWidget({
    Key key,
    this.packid,
    @required this.name,
    this.pro
  }):super(key:key);
  String packid;
  String name;
  String pro;

  @override
  readPackState createState() => readPackState();
}

class readPackState extends State<readPackWidget>{
  Future setDir () async{
    _appDocsDir =await getApplicationDocumentsDirectory();
  }
  List iconList=[];
  void initState(){
    setDir();
    print("initState");
    getPack();
  }
  Future getPack() async{
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient.getUrl(Uri.parse("http://necta.online/emoji/readpack.php?packid="+widget.packid));
    HttpClientResponse response = await request.close();
    Map data = jsonDecode(await response.transform(utf8.decoder).join());
    httpClient.close();
    if(data['result'] == "OK"){
//      return data['iconlist'];
      iconList = data['iconlist'];
      setState(() {

      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return new Scaffold(
        appBar: AppBar(
          title: Text(widget.name,),
        ),
        body:Center(
          child:Container(
            color: Color(0xFFf5f5f5),
            child:
              iconList.length>0?PackWidget(iconList:iconList):CircularProgressIndicator()
          )

        )
    );
    throw UnimplementedError();
  }
}


class PackWidget extends StatefulWidget{
  PackWidget({
    Key key,
    this.iconList
  }):super(key:key);
  List iconList;

  @override
  PackState createState() => PackState();
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

  List<String> checkedList = [];
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
                childAspectRatio: 0.8//宽高比为1时，子widget
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
                            debug: true)),
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

      ],
    );
    throw UnimplementedError();
  }
}


