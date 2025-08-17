import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shifaa/core/services/notification_service.dart'; 

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial()) {
    _subscribeToUserNotifications();
  }

  void _subscribeToUserNotifications() {
    print('HomeCubit created, attempting to subscribe to user notifications...');
   
   
  }
}
