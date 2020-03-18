import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_share_file/flutter_share_file.dart';
import 'package:path_provider/path_provider.dart';


const iconUrl = "http://necta.online/emoji/icons/";
class readPackWidget extends StatefulWidget{
  readPackWidget({
    Key key,
    this.packid,
    @required this.name,
  }):super(key:key);
  String packid;
  String name;

  @override
  readPackState createState() => readPackState();
}

class readPackState extends State<readPackWidget>{
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
                    return PackWidget(iconList:snapshot.data);

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

   void initState(){
       for(var i=0;i<widget.iconList.length;i++){
         widget.iconList[i]["checked"] = false;
       }
   }
   Future<Directory> _appDocumentsDirectory;
   void _requestAppDocumentsDirectory() {
     print("aaa");
     print(getApplicationDocumentsDirectory());
     setState(() {
       _appDocumentsDirectory = getApplicationDocumentsDirectory();
     });
     print( _appDocumentsDirectory);
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
                childAspectRatio: 0.8//宽高比为1时，子widget
            ),
            children:widget.iconList.map((f){
                return Column(
                    children: <Widget>[
                      Image.network(iconUrl+f['img'],width:60),
                      SizedBox(
                        height:30,
                        child: Checkbox(
                          value: f['checked'],
                          activeColor: Colors.red, //选中时的颜色
                          onChanged:(value){
                            setState(() {
                              f["checked"] = !f["checked"];
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
            Directory dir = await getApplicationDocumentsDirectory();
            File testFile = new File("${dir.path}/c470a9265df4a03bd9713c897539c974.png");
            print("share");
            print(dir);
            FlutterShareFile.shareImage(dir.path, "c470a9265df4a03bd9713c897539c974.png");
          },

          ),
        ),

      ],
    );
    throw UnimplementedError();
  }
}

class UserInfo{
  String Name;
  int Id;
  bool isSelected;
  UserInfo({this.Name,this.Id,this.isSelected=false});
}

class DemoPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => DemoPageState();
}

class DemoPageState extends State<DemoPage> {
  List<UserInfo> userMapList=new List();

  List<String> selName=new List();
  List<String> selIds=new List();

  @override
  void initState() {
    // TODO: implement initState
    addUser();
  }

  addUser(){

    for(int i=0;i<=8;i++){
      UserInfo  u =new UserInfo();

      u.Name="A$i";
      u.Id=i;


      userMapList.add(u);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Column(

      children: <Widget>[
        Column(
            children: userMapList.map((f){
              return Column(
                children: <Widget>[


                  Container(
                    child: CheckboxListTile(
                      value: f.isSelected,
                      onChanged: (bool){
                        setState(() {
                          f.isSelected=!f.isSelected;
                          //保存已选中的
//                          if(f.isSelected){
//                            if(!selName.contains(f.Name))
//                              selName.add(f.Name);
//                            if(!selIds.contains(f.Id.toString()))
//                              selIds.add(f.Id.toString());
//
//                          }//删除
//                          else{
//                            if(selName!=null && selName.contains(f.Name))
//                              selName.remove(f.Name);
//                            if(selIds!=null && selIds.contains(f.Id.toString()))
//                              selIds.remove(f.Id.toString());
//                          }
                        });

                      },
                      title: Text(f.Name),
                      controlAffinity: ListTileControlAffinity.platform,
                      activeColor: Colors.green,
                    ),
                  ),


                ],
              );

            }).toList()// <Widget>[

          //],
        ),


        Container(
          color: Colors.grey[100],
          height: 20,
        ),

        Column(

          children: <Widget>[

            Container(height: 30,

              child: Text("选中Name："+selName.join(","),style: TextStyle(color:Colors.red),),
            ),

            Container(
              height: 30,
              child: Text("选中Id："+selIds.join(","),style: TextStyle(color:Colors.green)),
            )
          ],




        ),
      ],

    );
  }
}
