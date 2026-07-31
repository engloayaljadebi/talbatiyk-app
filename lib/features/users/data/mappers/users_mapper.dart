class UsersMapper {


 static UsersEntity toEntity(
 UsersModel model
 ){

   return UsersEntity(
     id:model.id,
   );

 }


}

