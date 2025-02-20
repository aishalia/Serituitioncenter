import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserInformationForm extends StatefulWidget {
  final String? userId;

  const UserInformationForm({super.key, this.userId});

  @override
  UserInformationFormState createState() => UserInformationFormState();
}

class UserInformationFormState extends State<UserInformationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String _selectedRole = 'Student'; // Default role
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _classController =
      TextEditingController(); // Added class field
  final TextEditingController _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _selectedRole = userData['role'] ?? 'Student';
        _schoolController.text = userData['school'] ?? '';
        _classController.text = userData['class'] ?? ''; // Load class data
        _departmentController.text = userData['department'] ?? '';
      });
    }
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> userData = {
        'name': _nameController.text,
        'role': _selectedRole,
        'school': _selectedRole == "Student" ? _schoolController.text : null,
        'class':
            _selectedRole == "Student"
                ? _classController.text
                : null, // Save class
        'department':
            _selectedRole == "Teacher" ? _departmentController.text : null,
        'isDeleted': false,
      };

      if (widget.userId == null) {
        await FirebaseFirestore.instance.collection('users').add(userData);
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update(userData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User saved successfully!")));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userId == null ? "Add User" : "Edit User"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) => value!.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 10),

              // Role dropdown (Student or Teacher)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: "Role"),
                items:
                    ['Student', 'Teacher']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 10),

              // School (Only for Students)
              if (_selectedRole == "Student")
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(labelText: "School"),
                  validator:
                      (value) =>
                          _selectedRole == "Student" && value!.isEmpty
                              ? "Enter school name"
                              : null,
                ),

              // Class (Only for Students)
              if (_selectedRole == "Student")
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(labelText: "Class"),
                  validator:
                      (value) =>
                          _selectedRole == "Student" && value!.isEmpty
                              ? "Enter class name"
                              : null,
                ),

              // Department (Only for Teachers)
              if (_selectedRole == "Teacher")
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(labelText: "Department"),
                  validator:
                      (value) =>
                          _selectedRole == "Teacher" && value!.isEmpty
                              ? "Enter department"
                              : null,
                ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveUser, child: const Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
