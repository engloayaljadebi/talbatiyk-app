class TemplateGenerator {
  static String model(String name) {
    return '''
class ${name}Model {

  final String id;

  ${name}Model({
    required this.id,
  });


  factory ${name}Model.fromJson(
      Map<String,dynamic> json
  ){

    return ${name}Model(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}

''';
  }

  static String dto(String name) {
    return '''
class ${name}Dto {

  final String id;


  ${name}Dto({
    required this.id,
  });


}

''';
  }

  static String entity(String name) {
    return '''
class ${name}Entity {


  final String id;


  ${name}Entity({
    required this.id,
  });


}

''';
  }

  static String datasource(String name, String type) {
    return '''
abstract class $name${type}Datasource {


  Future<List<dynamic>> get${name}s();


}


class $name${type}DatasourceImpl
implements $name${type}Datasource {


  @override
  Future<List<dynamic>> get${name}s() async {

    return [];

  }


}

''';
  }

  static String mapper(String name) {
    return '''
class ${name}Mapper {


 static ${name}Entity toEntity(
 ${name}Model model
 ){

   return ${name}Entity(
     id:model.id,
   );

 }


}

''';
  }

  static String repositoryImpl(String name) {
    return '''
class ${name}RepositoryImpl
implements ${name}Repository {


}


''';
  }

  static String repository(String name) {
    return '''
abstract class ${name}Repository {


 Future<List<${name}Entity>> get${name}s();


}

''';
  }

  static String usecase(String name) {
    return '''
class ${name}UseCase {


 final ${name}Repository repository;


 ${name}UseCase(
 this.repository
 );


 Future<List<${name}Entity>> call(){


 return repository.get${name}s();


 }


}

''';
  }

  static String service(String name) {
    return '''
class ${name}Service {


 Future<void> initialize(){

   return Future.value();

 }


}

''';
  }

  static String page(String name) {
    return '''
import 'package:flutter/material.dart';


class ${name}Page extends StatelessWidget {


 const ${name}Page({super.key});


 @override
 Widget build(BuildContext context){


 return Scaffold(

 body:Center(

 child:Text(
 "$name Page"
 ),

 ),

 );


 }


}

''';
  }

  static String widget(String name) {
    return '''
import 'package:flutter/material.dart';


class ${name}Widget extends StatelessWidget {


 const ${name}Widget({super.key});


 @override
 Widget build(BuildContext context){

 return Container();

 }


}

''';
  }

  static String controller(String name) {
    return '''
class ${name}Controller {


 void load(){


 }


}

''';
  }

  static String state(String name) {
    return '''
class ${name}State {


 final bool loading;


 const ${name}State({

 this.loading=false,

 });


}

''';
  }

  static String viewmodel(String name) {
    return '''
class ${name}ViewModel {


}

''';
  }

  static String binding(String name) {
    return '''
class ${name}Binding {


 void dependencies(){


 }


}

''';
  }

  static String provider(String name) {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';


final ${name}Provider =
Provider<${name}Controller>((ref){

 return ${name}Controller();

});


''';
  }

  static String bloc(String name) {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';


class ${name}Bloc
extends Bloc<${name}Event,${name}State>{


 ${name}Bloc()
 :
 super(${name}State());


}


class ${name}Event{}



''';
  }
}
