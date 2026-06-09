
class Student {
  final int? id;
  final String uid;
  final String name;
  final int age;
  final String grade;
  final String email;
  final String phone;
  final String notes;
  final DateTime registeredAt;

  Student({
    this.id,
    required this.uid,
    required this.name,
    required this.age,
    required this.grade,
    required this.email,
    required this.phone,
    this.notes = '',
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  Student copyWith({
    int? id,
    String? uid,
    String? name,
    int? age,
    String? grade,
    String? email,
    String? phone,
    String? notes,
    DateTime? registeredAt,
  }) {
    return Student(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      age: age ?? this.age,
      grade: grade ?? this.grade,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      registeredAt: registeredAt ?? this.registeredAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'age': age,
      'grade': grade,
      'email': email,
      'phone': phone,
      'notes': notes,
      'registeredAt': registeredAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, Object?> map) {
    return Student(
      id: map['id'] as int?,
      uid: map['uid'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      grade: map['grade'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      notes: map['notes'] as String? ?? '',
      registeredAt: DateTime.parse(map['registeredAt'] as String),
    );
  }
}
