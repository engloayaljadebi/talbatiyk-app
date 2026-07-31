class WalletMapper {


 static WalletEntity toEntity(
 WalletModel model
 ){

   return WalletEntity(
     id:model.id,
   );

 }


}

