class AuthMapper {


 static AuthEntity toEntity(
 AuthModel model
 ){

   return AuthEntity(
     id:model.id,
   );

 }


}

