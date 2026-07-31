part of 'home_bottom_navigation.dart_bloc.dart';

abstract class HomeBottomNavigation.dartEvent extends BaseEvent<HomeBottomNavigation.dartBloc, HomeBottomNavigation.dartState> {}

class HomeBottomNavigation.dartInitEvent extends HomeBottomNavigation.dartEvent {
  @override
  Future<HomeBottomNavigation.dartState> on(HomeBottomNavigation.dartBloc bloc, HomeBottomNavigation.dartState currentState) async {
    return HomeBottomNavigation.dartInitState();
  }
}