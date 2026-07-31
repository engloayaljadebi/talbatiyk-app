import 'dart:io';


class FileGenerator {


static void createFile(
String path,
String content
){

final file = File(path);


if(!file.existsSync()){

file.createSync(recursive:true);

}


file.writeAsStringSync(content);


print("📄 Created: $path");


}


}