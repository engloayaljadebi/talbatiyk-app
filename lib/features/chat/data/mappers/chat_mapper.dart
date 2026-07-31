class ChatMapper {


 static ChatEntity toEntity(
 ChatModel model
 ){

   return ChatEntity(
     id:model.id,
   );

 }


}

