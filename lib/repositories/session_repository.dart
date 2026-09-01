import 'package:gym_tracker_app/models/workout_session_status.dart';
import 'package:gym_tracker_app/models/workout_set.dart';
import '../models/workout_session.dart';

class SessionRepository {
  final List<WorkoutSession> _sessions = [];

  List<WorkoutSession> findAll() => List.unmodifiable(_sessions);

  WorkoutSession? findById(String id) {
    for (final session in _sessions) {
      if (session.id == id) {
        return session;
      }
    }

    return null;
  }

  WorkoutSession? findActiveSession(){
    for (var session in _sessions) {
      if (session.status == WorkoutSessionStatus.active) {
        return session;
      }
      
    }
    return null;
  }

  bool addSession(WorkoutSession session){
    WorkoutSession? _session = findById(session.id);
    if(_session != null || findActiveSession() != null) return false;
    _sessions.add(session);
    return true;
  }

  bool completeSession(String idSession){
    WorkoutSession? session = findById(idSession);
    if(session == null || !session.isActive) return false;
    session.completedAt = DateTime.now();
    session.status  = WorkoutSessionStatus.completed;
    return true;
  }

  bool cancelSession(String idSession){
    WorkoutSession? session = findById(idSession);
    if(session == null || !session.isActive) return false;
    session.status = WorkoutSessionStatus.cancelled;
    return true;
    
  }

  bool removeSession(String idSession){
  WorkoutSession? session = findById(idSession);
  if(session == null) return false;
    _sessions.removeWhere((session) => session.id == idSession);
    return true;
  }

  bool addSetToSession(String sessionId, WorkoutSet set){
    final session = findById(sessionId);
    if(session == null || !session.isActive) return false;

    final getAlreadyExist = session.sets.any((s) => s.id == set.id);
    if(getAlreadyExist) return false;

    session.sets.add(set);
    return true;
  }

  List<WorkoutSet> getSetsFromSession(String sessionId){
    WorkoutSession? session = findById(sessionId);
    if(session == null) return [];
    return List.unmodifiable(session.sets);
  }

  bool removeSetFromSession(String sessionId, WorkoutSet set) {
    final session = findById(sessionId);
    if (session == null || !session.isActive) {
      return false;
    }

    final setExists = session.sets.any((item) => item.id == set.id);
    if (!setExists) {
      return false;
    }

    session.sets.removeWhere((s) => s.id == set.id);
    return true;
  }

  List<WorkoutSession> findSessionsByWorkoutId(String workoutId) {
    final sessions = _sessions
        .where((session) => session.workoutId == workoutId)
        .toList();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }


}
