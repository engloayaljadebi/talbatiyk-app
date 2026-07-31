class VoiceUseCase {


 final VoiceRepository repository;


 VoiceUseCase(
 this.repository
 );


 Future<List<VoiceEntity>> call(){


 return repository.getVoices();


 }


}

