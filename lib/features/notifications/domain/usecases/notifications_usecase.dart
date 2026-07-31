class NotificationsUseCase {


 final NotificationsRepository repository;


 NotificationsUseCase(
 this.repository
 );


 Future<List<NotificationsEntity>> call(){


 return repository.getNotificationss();


 }


}

