import 'package:hive/hive.dart';

part 'course.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  String code;

  @HiveField(1)
  String name;

  @HiveField(2)
  String instructor;

  @HiveField(3)
  List<int> studentIds;

  @HiveField(4)
  String department;

  @HiveField(5)
  String semester;

  @HiveField(6)
  String section;

  Course({
    required this.code,
    required this.name,
    required this.instructor,
    required this.studentIds,
    this.department = 'General',
    this.semester = 'Current',
    this.section = 'A',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          name == other.name &&
          instructor == other.instructor &&
          department == other.department &&
          semester == other.semester &&
          section == other.section;

  @override
  int get hashCode =>
      code.hashCode ^
      name.hashCode ^
      instructor.hashCode ^
      department.hashCode ^
      semester.hashCode ^
      section.hashCode;

  @override
  String toString() => '$code - $name (Section $section)';

  // Helper method to get full course display name
  String get fullDisplayName => '$code - $name';
  String get sectionDisplayName => '$code - $name (Section $section)';
  String get detailedDisplayName =>
      '$department | $semester | $code - $name (Section $section)';
}
