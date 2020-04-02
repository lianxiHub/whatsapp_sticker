import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:path_provider/path_provider.dart';



//Directory _appDocsDir;
//void main() async{
//  _appDocsDir = await getApplicationDocumentsDirectory();
//}


Directory _appDocsDir;
void getDir() async{
  _appDocsDir = await getApplicationDocumentsDirectory();

}

File fileFromDocsDir(String filename) {
  getDir();
  String pathName = p.join(_appDocsDir.path, filename);
  return File(pathName);
}

