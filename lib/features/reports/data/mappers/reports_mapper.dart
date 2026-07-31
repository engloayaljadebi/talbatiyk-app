class ReportsMapper {


 static ReportsEntity toEntity(
 ReportsModel model
 ){

   return ReportsEntity(
     id:model.id,
   );

 }


}

