class CheckoutMapper {


 static CheckoutEntity toEntity(
 CheckoutModel model
 ){

   return CheckoutEntity(
     id:model.id,
   );

 }


}

