import 'package:flutter/material.dart';
import 'test2.dart';
void main() async{
  //设置状态栏为透明
  //强制竖屏
  runApp(MyApp());


}
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emoji Store',
      theme: ThemeData(
          primaryColor:Color(0xFFf7f7f7),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('demo'),
      ),
      body:Center(
        child:Column(
          children: <Widget>[
             new MaterialButton(
                child: new Text("cute"),
                onPressed: (){
                  Navigator.push( context,
                      MaterialPageRoute(builder: (context) {
                        return readPackWidget(packid:'30');
                      }));
                }
            ),
            new MaterialButton(
                child: new Text("love"),
                onPressed: (){
                  Navigator.push( context,
                      MaterialPageRoute(builder: (context) {
                        return readPackWidget(packid:'36');
                      }));
                }
            ),
            new MaterialButton(
                child: new Text("baby"),
                onPressed: (){
                  Navigator.push( context,
                      MaterialPageRoute(builder: (context) {
                        return readPackWidget(packid:'32');
                      }));
                }
            ),

          ],
        )
      )
    );
  }
}