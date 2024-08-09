import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';

// Events
abstract class YouthEvent extends Equatable {
  const YouthEvent();

  @override
  List<Object> get props => [];
}

class LoadYouthDataEvent extends YouthEvent {}

class UpgradeYouthEvent extends YouthEvent {}

// States
abstract class YouthState extends Equatable {
  const YouthState();

  @override
  List<Object> get props => [];
}

class YouthInitial extends YouthState {}

class YouthLoaded extends YouthState {
  final int level;
  final int upgradeCost;
  final bool canUpgrade;

  const YouthLoaded({
    required this.level,
    required this.upgradeCost,
    required this.canUpgrade,
  });

  @override
  List<Object> get props => [level, upgradeCost, canUpgrade];
}

// Bloc
class YouthBloc extends Bloc<YouthEvent, YouthState> {
  YouthBloc() : super(YouthInitial()) {
    on<LoadYouthDataEvent>(_onLoadYouthData);
    on<UpgradeYouthEvent>(_onUpgradeYouth);
  }

  void _onLoadYouthData(
    LoadYouthDataEvent event,
    Emitter<YouthState> emit,
  ) {
    final int level = YouthManager.youthLevel;
    final int upgradeCost = YouthManager.youthUpgradeCost;
    final bool canUpgrade = UserManager.money >= upgradeCost;

    emit(YouthLoaded(
      level: level,
      upgradeCost: upgradeCost,
      canUpgrade: canUpgrade,
    ));
  }

  void _onUpgradeYouth(
    UpgradeYouthEvent event,
    Emitter<YouthState> emit,
  ) {
    if (UserManager.money >= YouthManager.youthUpgradeCost) {
      YouthManager.youthLevel++;
      UserManager.money -= YouthManager.youthUpgradeCost;
      YouthManager.youthUpgradeCost =
          ((YouthManager.youthUpgradeCost * 1.8) / 10000).round() * 10000;

      YouthManager().saveYouthLevel();
      YouthManager().saveYouthUpgradeCost();

      add(LoadYouthDataEvent()); // Reload the data after upgrading
    }
  }
}
