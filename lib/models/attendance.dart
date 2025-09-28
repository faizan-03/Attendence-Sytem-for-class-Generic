import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 2)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  int courseId;

  @HiveField(1)
  String date; // yyyy-MM-dd format

  @HiveField(2)
  Map<int, bool> studentStatus; // studentId → present/absent

  @HiveField(3)
  String? classType; // Regular Class, Makeup, Lab - nullable for backward compatibility

  AttendanceRecord({
    required this.courseId,
    required this.date,
    required this.studentStatus,
    this.classType,
  });

  // Getter to provide default value
  String get effectiveClassType => classType ?? 'Regular Class';
}
