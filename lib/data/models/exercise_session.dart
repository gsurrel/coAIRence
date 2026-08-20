class ExerciseSession {
  ExerciseSession({
    required this.patternName,
    required this.timestamp,
    required this.durationSeconds,
    required this.cyclesCompleted,
    this.id,
  });

  factory ExerciseSession.fromMap(Map<String, dynamic> map) => ExerciseSession(
    id: map['id'] as int?,
    patternName: map['patternName'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
    durationSeconds: map['durationSeconds'] as int,
    cyclesCompleted: map['cyclesCompleted'] as int,
  );

  final int? id;
  final String patternName;
  final DateTime timestamp;
  final int durationSeconds;
  final int cyclesCompleted;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'patternName': patternName,
    'timestamp': timestamp.toIso8601String(),
    'durationSeconds': durationSeconds,
    'cyclesCompleted': cyclesCompleted,
  };
}
