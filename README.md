# Flutter SQLite Student Record Management

This project is prepared from **Lab Sheet – 7: Flutter SQLite Database Basics (CRUD Operations)**.

It combines the 17 lab-sheet tasks into one runnable Student Record Management application.

## Features covered

1. Create an SQLite database with `sqflite`.
2. Create the `students` table (`id`, `name`, `roll_number`, `course`).
3. Insert a student using `insert()`.
4. Enter student details through Flutter text fields.
5. Insert a student using `rawInsert()`.
6. Display records using `query()` and a Flutter list.
7. Display records using `rawQuery()`.
8. Update a student using `update()`.
9. Delete one student using `delete()`.
10. Delete all students using the **Clear All** button.
11. Search by roll number using a `WHERE` condition.
12. Filter students by course using a dropdown.
13. Sort student names using `orderBy`.
14. Display the total number of records.
15. Use a `Student` model with `toMap()` and `fromMap()`.
16. Use a `DatabaseHelper` for database operations.
17. Complete Student Record Management application.

## Project structure

```text
flutter_sqlite_student_management/
├── lib/
│   ├── main.dart
│   ├── database/
│   │   └── database_helper.dart
│   └── models/
│       └── student.dart
├── pubspec.yaml
└── README.md
```

## Requirements

- Flutter SDK installed
- Android Studio or VS Code
- Android emulator or Android phone

## Run the project

1. Extract the ZIP file.
2. Open the extracted folder in VS Code or Android Studio.
3. Open a terminal in the project folder.
4. Run:

```bash
flutter create .
flutter pub get
flutter run
```

If `flutter create .` asks to overwrite files, keep the existing `lib` folder and `pubspec.yaml`. The command creates the platform folders such as `android/`.

## How to use

- Enter name, roll number and course, then tap **Add**.
- Tap the edit icon on a record to load it into the form, then tap **Update**.
- Tap the delete icon to delete one record.
- Search with a roll number.
- Use the course dropdown to filter records.
- Use the sort button to switch between A–Z and Z–A.
- Use **Raw Insert Demo** and **Raw Query Demo** to demonstrate those SQLite methods.
- Use **Clear All** to remove all records.

## Important notes

- The database file is created automatically on the device the first time the app runs.
- Roll numbers are unique in this sample project.
- This is a local SQLite learning project; it does not include online login, cloud sync or a remote server.
- Test the app on Android. The `sqflite` package has platform-specific setup requirements for other platforms.
