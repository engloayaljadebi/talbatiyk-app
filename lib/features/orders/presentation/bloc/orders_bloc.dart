
import 'package:flutter_bloc/flutter_bloc.dart';



class OrdersBloc extends Bloc<OrdersEvent, OrdersState>{


  OrdersBloc()
      :
      super(OrdersInitial());



}



abstract class OrdersEvent {}



class OrdersState {}



class OrdersInitial extends OrdersState {}

