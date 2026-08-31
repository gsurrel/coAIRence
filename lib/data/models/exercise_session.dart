class ExerciseSession {
  const ExerciseSession({
    required this.patternName,
    required this.timestamp,
    required this.durationSeconds,
    required this.cyclesCompleted,
    required this.localHour,
  });

  factory ExerciseSession.fromMap(Map<String, dynamic> map) => ExerciseSession(
    patternName: map['patternName'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    durationSeconds: map['durationSeconds'] as int,
    cyclesCompleted: map['cyclesCompleted'] as int,
    localHour: map['localHour'] as int,
  );

  final String patternName;
  final DateTime timestamp;
  final int durationSeconds;
  final int cyclesCompleted;
  final int localHour;

  Map<String, dynamic> toMap() => {
    'patternName': patternName,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'durationSeconds': durationSeconds,
    'cyclesCompleted': cyclesCompleted,
    'localHour': localHour,
  };
}
