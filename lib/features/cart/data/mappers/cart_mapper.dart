class CartMapper {


 static CartEntity toEntity(
 CartModel model
 ){

   return CartEntity(
     id:model.id,
   );

 }


}

