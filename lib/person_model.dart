// lib/person_model.dart

class Person {
  final int? id;
  final String firstName;
  final String lastName;
  final String school;
  final String position;
  final String phoneNumber;

  Person({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.school,
    required this.position,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'school': school,
      'position': position,
      'phoneNumber': phoneNumber,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      school: map['school'] ?? '',
      position: map['position'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}
