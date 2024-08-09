import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_eleven/managers/stadium_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';

// Events
abstract class StadiumEvent extends Equatable {
  const StadiumEvent();

  @override
  List<Object> get props => [];
}

class LoadStadiumDataEvent extends StadiumEvent {}

class UpgradeStadiumEvent extends StadiumEvent {}

// States
abstract class StadiumState extends Equatable {
  const StadiumState();

  @override
  List<Object> get props => [];
}

class StadiumInitial extends StadiumState {}

class StadiumLoaded extends StadiumState {
  final int level;
  final int upgradeCost;
  final bool canUpgrade;

  const StadiumLoaded({
    required this.level,
    required this.upgradeCost,
    required this.canUpgrade,
  });

  @override
  List<Object> get props => [level, upgradeCost, canUpgrade];
}

// Bloc
class StadiumBloc extends Bloc<StadiumEvent, StadiumState> {
  StadiumBloc() : super(StadiumInitial()) {
    on<LoadStadiumDataEvent>(_onLoadStadiumData);
    on<UpgradeStadiumEvent>(_onUpgradeStadium);
  }

  void _onLoadStadiumData(
    LoadStadiumDataEvent event,
    Emitter<StadiumState> emit,
  ) {
    final int level = StadiumManager.stadiumLevel;
    final int upgradeCost = StadiumManager.stadiumUpgradeCost;
    final bool canUpgrade = UserManager.money >= upgradeCost;

    emit(StadiumLoaded(
      level: level,
      upgradeCost: upgradeCost,
      canUpgrade: canUpgrade,
    ));
  }

  void _onUpgradeStadium(
    UpgradeStadiumEvent event,
    Emitter<StadiumState> emit,
  ) {
    if (UserManager.money >= StadiumManager.stadiumUpgradeCost) {
      StadiumManager.stadiumLevel++;
      UserManager.money -= StadiumManager.stadiumUpgradeCost;
      StadiumManager.stadiumUpgradeCost =
          ((StadiumManager.stadiumUpgradeCost * 1.8) / 10000).round() * 10000;

      StadiumManager().saveStadiumLevel();
      StadiumManager().saveStadiumUpgradeCost();

      add(LoadStadiumDataEvent()); // Reload the data
    }
  }
}
