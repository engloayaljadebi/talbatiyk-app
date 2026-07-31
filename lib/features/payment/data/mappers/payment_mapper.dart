class PaymentMapper {


 static PaymentEntity toEntity(
 PaymentModel model
 ){

   return PaymentEntity(
     id:model.id,
   );

 }


}

