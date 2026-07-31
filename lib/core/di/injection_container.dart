import 'package:get_it/get_it.dart';


import 'register_core.dart';
import 'register_services.dart';
import 'register_repositories.dart';



final sl = GetIt.instance;



Future<void> configureDependencies() async {


  await registerCore(sl);


  await registerServices(sl);


  await registerRepositories(sl);



}