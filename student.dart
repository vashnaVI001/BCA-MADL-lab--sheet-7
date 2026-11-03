class Student {
  final int? id;
  final String name;
  final String rollNumber;
  final String course;

  const Student({
    this.id,
    required this.name,
    required this.rollNumber,
    required this.course,
  });

  // Convert a Student object into a Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'course': course,
    };
  }

  // Create a Student object from a SQLite Map.
  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'] as int?,
      name: map['name'] as String,
      rollNumber: map['roll_number'] as String,
      course: map['course'] as String,
    );
  }
}
