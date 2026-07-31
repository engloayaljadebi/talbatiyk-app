class CategoriesMapper {


 static CategoriesEntity toEntity(
 CategoriesModel model
 ){

   return CategoriesEntity(
     id:model.id,
   );

 }


}

