import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';

// Events
abstract class TrainingEvent extends Equatable {
  const TrainingEvent();

  @override
  List<Object> get props => [];
}

class LoadTrainingDataEvent extends TrainingEvent {}

class UpgradeTrainingEvent extends TrainingEvent {}

// States
abstract class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object> get props => [];
}

class TrainingInitial extends TrainingState {}

class TrainingLoaded extends TrainingState {
  final int level;
  final int upgradeCost;
  final bool canUpgrade;

  const TrainingLoaded({
    required this.level,
    required this.upgradeCost,
    required this.canUpgrade,
  });

  @override
  List<Object> get props => [level, upgradeCost, canUpgrade];
}

// Bloc
class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  TrainingBloc() : super(TrainingInitial()) {
    on<LoadTrainingDataEvent>(_onLoadTrainingData);
    on<UpgradeTrainingEvent>(_onUpgradeTraining);
  }

  void _onLoadTrainingData(
    LoadTrainingDataEvent event,
    Emitter<TrainingState> emit,
  ) {
    final int level = TrainingManager.trainingLevel;
    final int upgradeCost = TrainingManager.trainingUpgradeCost;
    final bool canUpgrade = UserManager.money >= upgradeCost;

    emit(TrainingLoaded(
      level: level,
      upgradeCost: upgradeCost,
      canUpgrade: canUpgrade,
    ));
  }

  void _onUpgradeTraining(
    UpgradeTrainingEvent event,
    Emitter<TrainingState> emit,
  ) {
    if (UserManager.money >= TrainingManager.trainingUpgradeCost) {
      TrainingManager.trainingLevel++;
      UserManager.money -= TrainingManager.trainingUpgradeCost;
      TrainingManager.trainingUpgradeCost =
          ((TrainingManager.trainingUpgradeCost * 1.8) / 10000).round() * 10000;

      TrainingManager().saveTrainingLevel();
      TrainingManager().saveTrainingUpgradeCost();

      add(LoadTrainingDataEvent()); // Reload the data
    }
  }
}
