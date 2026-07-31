class ProfileMapper {


 static ProfileEntity toEntity(
 ProfileModel model
 ){

   return ProfileEntity(
     id:model.id,
   );

 }


}

