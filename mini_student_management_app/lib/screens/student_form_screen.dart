import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/student.dart';
import '../providers/student_provider.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? existingStudent;

  const StudentFormScreen({super.key, this.existingStudent});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _gradeOptions = [
    '9th Grade',
    '10th Grade',
    '11th Grade',
    '12th Grade',
  ];

  int? _age;
  String? _grade;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingStudent;
    if (existing != null) {
      _nameController.text = existing.name;
      _emailController.text = existing.email;
      _phoneController.text = existing.phone;
      _notesController.text = existing.notes;
      _age = existing.age;
      _grade = existing.grade;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingStudent != null;
    final title = isEditing ? 'Edit student' : 'Add student';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _age?.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an age';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 5 || parsed > 120) {
                    return 'Enter a valid age';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.tryParse(value!.trim());
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _grade,
                decoration: const InputDecoration(labelText: 'Grade level'),
                items:
                    _gradeOptions
                        .map(
                          (grade) => DropdownMenuItem(
                            value: grade,
                            child: Text(grade),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _grade = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Select a grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an email address';
                  }
                  if (!RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+',
                  ).hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text(isEditing ? 'Save changes' : 'Save student'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    final provider = Provider.of<StudentProvider>(context, listen: false);
    final student = Student(
      id: widget.existingStudent?.id,
      uid: widget.existingStudent?.uid ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      age: _age ?? 0,
      grade: _grade ?? _gradeOptions.first,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
      registeredAt: widget.existingStudent?.registeredAt,
    );

    if (widget.existingStudent == null) {
      provider.addStudent(student);
    } else {
      provider.updateStudent(student);
    }

    Navigator.of(context).pop();
  }
}
