class FavoritesMapper {


 static FavoritesEntity toEntity(
 FavoritesModel model
 ){

   return FavoritesEntity(
     id:model.id,
   );

 }


}

