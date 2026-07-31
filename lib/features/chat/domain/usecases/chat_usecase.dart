class ChatUseCase {


 final ChatRepository repository;


 ChatUseCase(
 this.repository
 );


 Future<List<ChatEntity>> call(){


 return repository.getChats();


 }


}

