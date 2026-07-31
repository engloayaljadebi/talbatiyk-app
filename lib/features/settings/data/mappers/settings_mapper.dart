class SettingsMapper {


 static SettingsEntity toEntity(
 SettingsModel model
 ){

   return SettingsEntity(
     id:model.id,
   );

 }


}

