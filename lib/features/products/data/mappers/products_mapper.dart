class ProductsMapper {


 static ProductsEntity toEntity(
 ProductsModel model
 ){

   return ProductsEntity(
     id:model.id,
   );

 }


}

