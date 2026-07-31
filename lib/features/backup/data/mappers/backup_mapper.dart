class BackupMapper {


 static BackupEntity toEntity(
 BackupModel model
 ){

   return BackupEntity(
     id:model.id,
   );

 }


}

