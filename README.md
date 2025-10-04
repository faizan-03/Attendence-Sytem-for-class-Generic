# Attend Track - Professional Attendance Management System

A comprehensive Flutter-based attendance management application designed for educational institutions to efficiently track and manage student attendance across multiple courses.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)

## 📱 About the Project

Attend Track is a modern, intuitive attendance system that streamlines the process of managing courses, students, and attendance records. Built with Flutter and designed with educators in mind, it offers a seamless experience from course creation to detailed reporting.

### Key Features

#### 🎓 Course Management
- Create and manage multiple courses with unique codes
- Assign instructors and set course credits
- Track enrolled students per course
- View course statistics and attendance overview
- Edit or delete courses with data integrity checks

#### 👨‍🎓 Student Management
- Add students manually or import from CSV/Excel files
- Organize students by roll number and course enrollment
- Search and filter student records
- Edit student information
- Bulk student operations

#### ✅ Attendance Tracking
- Mark attendance for different class types (Regular, Lab, Makeup)
- Date and session-based attendance recording
- Quick attendance marking with intuitive checkboxes
- Edit historical attendance records
- View attendance statistics in real-time

#### 📊 Reports & Analytics
- Generate PDF attendance reports
- View attendance percentages and statistics
- Session-wise attendance breakdowns
- Export and share reports via email or messaging apps
- Professional report formatting with course and session details

#### 🎨 Modern UI/UX
- Clean, purple gradient theme (#6366F1, #8B5CF6)
- Responsive design with Material Design principles
- First-time user onboarding (6-screen tutorial)
- Intuitive navigation with tab-based interface
- Professional card-based layouts

## 🏗️ Project Architecture

### Technology Stack
- **Framework**: Flutter 3.7.2
- **Language**: Dart
- **Database**: Hive (Local NoSQL storage)
- **State Management**: Provider pattern
- **PDF Generation**: pdf & printing packages
- **File Handling**: file_picker, csv, excel packages

### Project Structure

```
lib/
├── main.dart                 # App entry point with onboarding logic
├── models/                   # Data models
│   ├── attendance.dart       # Attendance record model
│   ├── course.dart          # Course model
│   └── student.dart         # Student model
├── providers/               # State management
│   ├── attendance_provider.dart
│   ├── course_provider.dart
│   └── student_provider.dart
├── screens/                 # UI screens
│   ├── attendence/         # Attendance marking/editing screens
│   ├── courses/            # Course management screens
│   ├── reports/            # Report generation screens
│   └── students/           # Student management screens
├── services/               # Business logic
│   ├── db_service.dart    # Database initialization
│   ├── pdf_service.dart   # PDF generation
│   └── import_service.dart # CSV/Excel import
└── widgets/               # Reusable components
    ├── attendance_tab_content.dart
    ├── course_card.dart
    ├── student_tile.dart
    ├── onboarding_screen.dart
    └── about_tab_content.dart
```

### Data Models

**Course**: Stores course information with unique integer keys
- Properties: name, code, instructor, credits, studentIds
- Hive TypeAdapter for persistence

**Student**: Stores student information
- Properties: name, roll number, course associations
- Supports bulk import from CSV/Excel

**Attendance**: Records attendance sessions
- Properties: courseId, date, classType, studentStatus map
- Session-based tracking with timestamps

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. **Clone the repository**
```powershell
git clone https://github.com/faizan-03/Attendence-Sytem-for-class-Generic.git
cd attendence_system
```

2. **Install dependencies**
```powershell
flutter pub get
```

3. **Run the app**
```powershell
flutter run
```

### Building APKs

**Debug APK** (for testing):
```powershell
flutter build apk --debug
```
Output: `build\app\outputs\flutter-apk\Attend_Track_Debug.apk`

**Release APK** (optimized):
```powershell
flutter build apk --release
```
Output: `build\app\outputs\flutter-apk\Attend_Track_Release.apk`

## 📦 Dependencies

### Core Dependencies
```yaml
provider: ^6.1.2          # State management
hive: ^2.2.3             # Local database
hive_flutter: ^1.1.0     # Hive Flutter integration
```

### Feature Dependencies
```yaml
pdf: ^3.10.7             # PDF document generation
printing: ^5.12.0        # PDF printing/sharing
file_picker: ^8.1.2      # File selection
csv: ^6.0.0              # CSV parsing
excel: ^4.0.6            # Excel file handling
share_plus: ^7.2.2       # Share functionality
url_launcher: ^6.2.4     # External URL opening
shared_preferences: ^2.2.2 # Local preferences
intl: ^0.19.0            # Date formatting
```

### Dev Dependencies
```yaml
flutter_lints: ^5.0.0          # Code quality
hive_generator: ^2.0.1         # Code generation
build_runner: ^2.4.8           # Build automation
flutter_launcher_icons: ^0.13.1 # Icon generation
```

## 💾 Data Persistence

The app uses **Hive** for local data storage with three main boxes:
- `courses` - Stores all course records
- `students` - Stores all student records
- `attendance` - Stores all attendance sessions

Data persists across app restarts and is stored locally on the device.

## 📁 File Import Format

### CSV/Excel Student Import
Required columns:
- `Name` - Student's full name
- `Roll Number` - Unique identifier

Example CSV:
```csv
Name,Roll Number
John Doe,2021-CS-001
Jane Smith,2021-CS-002
```

## 🎨 Customization

### Theme Colors
Primary gradient: `#6366F1` → `#8B5CF6` (Purple)
- Modify in individual screen files
- Consistent across app for professional look

### App Icon
Located at: `lib/assets/LOGO.png`
- Configure in `pubspec.yaml` under `flutter_launcher_icons`
- Generate icons: `flutter pub run flutter_launcher_icons`

### Developer Info
Avatar image: `lib/assets/faizan.jpeg`
- Used in About tab
- Update in `lib/widgets/about_tab_content.dart`

## 🐛 Known Issues & Solutions

### Issue: Dropdown duplicate value errors
**Solution**: App uses unique integer keys instead of Course objects in dropdowns

### Issue: File format instructions UI overflow
**Solution**: Implemented scrollable dialogs with height constraints

### Issue: First-time users confused by interface
**Solution**: Added 6-screen onboarding flow with `shared_preferences` persistence

## 🔧 Development Notes

### Code Quality
Run linter to check for issues:
```powershell
flutter analyze
```

### Common Lint Fixes Applied
- ✅ Replaced `withOpacity()` with `withValues(alpha:)`
- ✅ Updated to super parameter syntax
- ✅ Replaced debug `print()` with `debugPrint()` in assertions
- ✅ Fixed async BuildContext usage with proper mounted checks

### Clean Build
If encountering build issues:
```powershell
flutter clean
flutter pub get
flutter run
```

## 👨‍💻 Developer

**Rana Faizan Ali**
- Software Developer || AI/ML Enthusiast
- GitHub: [@faizan-03](https://github.com/faizan-03)
- Email: ranafaizanali8@gmail.com

## 📄 License

This project is developed as a generic classroom attendance system. Feel free to use and modify for educational purposes.

## 🙏 Acknowledgments

- Flutter team for the excellent framework
- Material Design for UI/UX guidelines
- Community packages that made this project possible

---

**Version**: 1.0.0  
**Last Updated**: October 2025  
**Platform**: Android (iOS support can be added)

For issues or feature requests, please create an issue on the GitHub repository.
