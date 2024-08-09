import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';

// Events
abstract class MedicalEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMedicalDataEvent extends MedicalEvent {}

class UpgradeMedicalEvent extends MedicalEvent {}

// States
abstract class MedicalState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MedicalInitial extends MedicalState {}

class MedicalLoading extends MedicalState {}

class MedicalLoaded extends MedicalState {
  final int level;
  final int upgradeCost;
  final bool canUpgrade;

  MedicalLoaded({
    required this.level,
    required this.upgradeCost,
    required this.canUpgrade,
  });

  @override
  List<Object?> get props => [level, upgradeCost, canUpgrade];
}

class MedicalError extends MedicalState {
  final String error;

  MedicalError(this.error);

  @override
  List<Object?> get props => [error];
}

// BLoC
class MedicalBloc extends Bloc<MedicalEvent, MedicalState> {
  MedicalBloc() : super(MedicalInitial()) {
    on<LoadMedicalDataEvent>(_onLoadMedicalData);
    on<UpgradeMedicalEvent>(_onUpgradeMedical);
  }

  Future<void> _onLoadMedicalData(
      LoadMedicalDataEvent event, Emitter<MedicalState> emit) async {
    emit(MedicalLoading());
    try {
      final level = MedicalManager.medicalLevel;
      final upgradeCost = MedicalManager.medicalUpgradeCost;
      final canUpgrade = UserManager.money >= upgradeCost;

      emit(MedicalLoaded(
        level: level,
        upgradeCost: upgradeCost,
        canUpgrade: canUpgrade,
      ));
    } catch (error) {
      emit(MedicalError('Failed to load medical data'));
    }
  }

  Future<void> _onUpgradeMedical(
      UpgradeMedicalEvent event, Emitter<MedicalState> emit) async {
    final state = this.state;
    if (state is MedicalLoaded) {
      if (UserManager.money >= state.upgradeCost) {
        final newLevel = state.level + 1;
        final newUpgradeCost =
            ((state.upgradeCost * 1.8) / 10000).round() * 10000;

        UserManager.money -= state.upgradeCost;
        MedicalManager.medicalLevel = newLevel;
        MedicalManager.medicalUpgradeCost = newUpgradeCost;

        await MedicalManager().saveMedicalLevel();
        await MedicalManager().saveMedicalUpgradeCost();

        emit(MedicalLoaded(
          level: newLevel,
          upgradeCost: newUpgradeCost,
          canUpgrade: UserManager.money >= newUpgradeCost,
        ));
      }
    }
  }
}
