class SearchMapper {


 static SearchEntity toEntity(
 SearchModel model
 ){

   return SearchEntity(
     id:model.id,
   );

 }


}

