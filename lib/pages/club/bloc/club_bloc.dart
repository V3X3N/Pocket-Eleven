import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/managers/user_manager.dart';

abstract class ClubEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserDataEvent extends ClubEvent {}

abstract class ClubState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClubInitial extends ClubState {}

class ClubLoading extends ClubState {}

class ClubLoaded extends ClubState {
  final String clubName;

  ClubLoaded(this.clubName);

  @override
  List<Object?> get props => [clubName];
}

class ClubError extends ClubState {
  final String error;

  ClubError(this.error);

  @override
  List<Object?> get props => [error];
}

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  ClubBloc() : super(ClubInitial()) {
    on<LoadUserDataEvent>(_onLoadUserData);
  }

  Future<void> _onLoadUserData(
      LoadUserDataEvent event, Emitter<ClubState> emit) async {
    emit(ClubLoading());
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        final clubName = await FirebaseFunctions.getClubName(userId);
        await UserManager().loadAllUserData();
        emit(ClubLoaded(clubName));
      } else {
        emit(ClubError("User not logged in"));
      }
    } catch (error) {
      emit(ClubError('Error loading user data: $error'));
    }
  }
}
