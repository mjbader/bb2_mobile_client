// Integers types returned from server
class CompetitionStatus {
  static const int waiting = 0;
  static const int running = 1;
  static const int completed = 2;
  static const int paused = 3;
}

class CompetitionType {
  static const int placeholder0 = 0;
  static const int roundRobin = 1;
  static const int knockout = 2;
  static const int ladder = 3;
  static const int swiss = 4;
}

class MatchStatus {
  static const int unplayed = 0;
  static const int unvalidated = 1;
  static const int validated = 2;
}