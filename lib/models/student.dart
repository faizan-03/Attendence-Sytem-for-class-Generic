import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 1)
class Student extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String rollNumber; // Changed from 'roll' to 'rollNumber' for consistency

  @HiveField(2)
  String? email;

  @HiveField(3)
  String? phone;

  Student({
    required this.name,
    required this.rollNumber,
    this.email,
    this.phone,
  });

  // Getter for backward compatibility
  String get roll => rollNumber;
}
