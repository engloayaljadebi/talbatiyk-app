class HomeMapper {


 static HomeEntity toEntity(
 HomeModel model
 ){

   return HomeEntity(
     id:model.id,
   );

 }


}

