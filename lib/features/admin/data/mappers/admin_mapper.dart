class AdminMapper {


 static AdminEntity toEntity(
 AdminModel model
 ){

   return AdminEntity(
     id:model.id,
   );

 }


}

