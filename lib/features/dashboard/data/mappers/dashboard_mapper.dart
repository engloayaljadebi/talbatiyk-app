class DashboardMapper {


 static DashboardEntity toEntity(
 DashboardModel model
 ){

   return DashboardEntity(
     id:model.id,
   );

 }


}

