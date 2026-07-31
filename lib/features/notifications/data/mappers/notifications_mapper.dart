class NotificationsMapper {


 static NotificationsEntity toEntity(
 NotificationsModel model
 ){

   return NotificationsEntity(
     id:model.id,
   );

 }


}

