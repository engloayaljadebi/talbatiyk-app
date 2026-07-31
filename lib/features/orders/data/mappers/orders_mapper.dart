class OrdersMapper {


 static OrdersEntity toEntity(
 OrdersModel model
 ){

   return OrdersEntity(
     id:model.id,
   );

 }


}

