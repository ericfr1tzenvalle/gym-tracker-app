import 'package:gym_tracker_app/repositories/session_repository.dart';

import '../models/workout_session.dart';
import '../models/workout_set.dart';

class WorkoutSessionController {
  final SessionRepository _sessionRepository;

  WorkoutSessionController(this._sessionRepository);

  WorkoutSession startOrResumeSession(String workoutId) {
    return _sessionRepository.startOrResumeSession(workoutId);
  }

  bool completeSession(String sessionId) {
    return _sessionRepository.completeSession(sessionId);
  }

  bool cancelSession(String sessionId) {
    return _sessionRepository.cancelSession(sessionId);
  }

  WorkoutSet? addSetToSession({
    required String sessionId,
    required String exerciseId,
    required double weight,
    required int repetitions,
    int? rpe,
  }) {
    final invalidRpe = rpe != null && (rpe < 1 || rpe > 10);
    if (exerciseId.trim().isEmpty ||
        !weight.isFinite ||
        weight <= 0 ||
        repetitions <= 0 ||
        invalidRpe) {
      return null;
    }

    return _sessionRepository.addSetToSession(
      sessionId: sessionId,
      exerciseId: exerciseId,
      weight: weight,
      repetitions: repetitions,
      rpe: rpe,
    );
  }

  WorkoutSession? getSessionById(String sessionId) {
    return _sessionRepository.findById(sessionId);
  }

  WorkoutSession? getActiveSession() {
    return _sessionRepository.findActiveSession();
  }

  List<WorkoutSession> getAllSessions() {
    return _sessionRepository.findAll();
  }

  List<WorkoutSession> getSessionsByWorkoutId(String workoutId) {
    return _sessionRepository.findSessionsByWorkoutId(workoutId);
  }

  List<WorkoutSet> getSetsFromSession(String sessionId) {
    return _sessionRepository.getSetsFromSession(sessionId);
  }

  bool removeSetFromSession({
    required String sessionId,
    required String setId,
  }) {
    return _sessionRepository.removeSetFromSession(
      sessionId: sessionId,
      setId: setId,
    );
  }

  bool deleteSession(String sessionId) {
    return _sessionRepository.removeSession(sessionId);
  }
}
