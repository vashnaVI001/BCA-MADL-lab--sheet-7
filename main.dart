import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/student.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudentApp());
}

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Records',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const StudentHomePage(),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _courseController = TextEditingController();
  final _searchController = TextEditingController();

  List<Student> _students = [];
  String _selectedCourse = 'All';
  bool _ascending = true;
  int _totalCount = 0;
  int? _editingId;
  String _status = 'Database is ready';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rollController.dispose();
    _courseController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final rows = await DatabaseHelper.instance.getAllStudents();
    final count = await DatabaseHelper.instance.getStudentCount();
    if (!mounted) return;
    setState(() {
      _students = rows;
      _totalCount = count;
    });
  }

  Future<void> _showMessage(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    final student = Student(
      id: _editingId,
      name: _nameController.text.trim(),
      rollNumber: _rollController.text.trim(),
      course: _courseController.text.trim(),
    );

    if (_editingId == null) {
      await DatabaseHelper.instance.insertStudent(student);
      await _showMessage('Student added successfully');
    } else {
      await DatabaseHelper.instance.updateStudent(student);
      await _showMessage('Student updated successfully');
    }

    _clearForm();
    await _loadStudents();
  }

  void _editStudent(Student student) {
    setState(() {
      _editingId = student.id;
      _nameController.text = student.name;
      _rollController.text = student.rollNumber;
      _courseController.text = student.course;
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _rollController.clear();
    _courseController.clear();
    setState(() => _editingId = null);
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    await _loadStudents();
    await _showMessage('Student deleted');
  }

  Future<void> _clearAll() async {
    if (_students.isEmpty) {
      await _showMessage('There are no records to clear');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all records?'),
        content: const Text('This will delete every student record.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteAllStudents();
      await _loadStudents();
      await _showMessage('All records deleted');
    }
  }

  Future<void> _searchByRoll() async {
    final roll = _searchController.text.trim();
    if (roll.isEmpty) {
      await _loadStudents();
      return;
    }
    final result = await DatabaseHelper.instance.searchByRollNumber(roll);
    if (!mounted) return;
    setState(() => _students = result);
  }

  Future<void> _filterByCourse(String? course) async {
    setState(() => _selectedCourse = course ?? 'All');
    final result = _selectedCourse == 'All'
        ? await DatabaseHelper.instance.getAllStudents()
        : await DatabaseHelper.instance.getStudentsByCourse(_selectedCourse);
    if (!mounted) return;
    setState(() => _students = result);
  }

  Future<void> _sortByName() async {
    setState(() => _ascending = !_ascending);
    final result = await DatabaseHelper.instance.getStudentsOrderedByName(
      ascending: _ascending,
    );
    if (!mounted) return;
    setState(() => _students = result);
  }

  Future<void> _demoRawInsert() async {
    final student = Student(
      name: 'Demo Student',
      rollNumber: 'RAW-${DateTime.now().millisecondsSinceEpoch % 100000}',
      course: 'BCA',
    );
    await DatabaseHelper.instance.rawInsertStudent(student);
    await _loadStudents();
    await _showMessage('Sample record inserted using rawInsert()');
  }

  Future<void> _demoRawQuery() async {
    final result = await DatabaseHelper.instance.rawQueryStudents();
    if (!mounted) return;
    setState(() {
      _students = result;
      _status = 'Records loaded using rawQuery()';
    });
    await _showMessage('Records loaded using rawQuery()');
  }

  @override
  Widget build(BuildContext context) {
    final courses = <String>{
      'All',
      ..._students.map((student) => student.course),
    }.toList()
      ..sort();
    if (!courses.contains('All')) courses.insert(0, 'All');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Record Management'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.storage, size: 30),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_status)),
                    Chip(label: Text('Total: $_totalCount')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _editingId == null ? 'Add Student' : 'Update Student',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Student name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter student name'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _rollController,
                    decoration: const InputDecoration(
                      labelText: 'Roll number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter roll number'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _courseController,
                    decoration: const InputDecoration(
                      labelText: 'Course (e.g. BCA)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter course'
                            : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _saveStudent,
                          icon: Icon(_editingId == null ? Icons.add : Icons.save),
                          label: Text(_editingId == null ? 'Add' : 'Update'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _clearForm,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Text('Search and Filter',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by roll number',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchByRoll(),
                  ),
                ),
                IconButton(
                  tooltip: 'Search',
                  onPressed: _searchByRoll,
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  tooltip: 'Show all',
                  onPressed: () {
                    _searchController.clear();
                    _filterByCourse('All');
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: courses.contains(_selectedCourse) ? _selectedCourse : 'All',
              decoration: const InputDecoration(
                labelText: 'Filter by course',
                border: OutlineInputBorder(),
              ),
              items: courses
                  .map((course) => DropdownMenuItem(
                        value: course,
                        child: Text(course),
                      ))
                  .toList(),
              onChanged: _filterByCourse,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _sortByName,
                  icon: const Icon(Icons.sort_by_alpha),
                  label: Text(_ascending ? 'Sort Z-A' : 'Sort A-Z'),
                ),
                OutlinedButton.icon(
                  onPressed: _demoRawInsert,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Raw Insert Demo'),
                ),
                OutlinedButton.icon(
                  onPressed: _demoRawQuery,
                  icon: const Icon(Icons.table_view),
                  label: const Text('Raw Query Demo'),
                ),
                OutlinedButton.icon(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear All'),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Student Records',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_students.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No student records found')),
              )
            else
              ..._students.map(
                (student) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student.name[0].toUpperCase())),
                    title: Text(student.name),
                    subtitle: Text(
                      'Roll: ${student.rollNumber}\nCourse: ${student.course}',
                    ),
                    isThreeLine: true,
                    trailing: Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _editStudent(student),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _deleteStudent(student.id!),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
