class SettingsUseCase {


 final SettingsRepository repository;


 SettingsUseCase(
 this.repository
 );


 Future<List<SettingsEntity>> call(){


 return repository.getSettingss();


 }


}

