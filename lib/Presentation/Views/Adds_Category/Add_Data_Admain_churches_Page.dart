import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDataAdmainChurchesPage extends StatefulWidget {
  @override
  _AddDataAdmainChurchesPageState createState() =>
      _AddDataAdmainChurchesPageState();
}

class _AddDataAdmainChurchesPageState extends State<AddDataAdmainChurchesPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _churchController = TextEditingController();
  final TextEditingController _seasonController = TextEditingController();

  String _selectedRole = 'User';

  bool _isLoading = false;

  void _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. إنشاء المستخدم في Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. تخزين بيانات المستخدم في Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'Phone_Number': _phoneController.text.trim(),
        'Church': _churchController.text.trim(),
        'Season': _seasonController.text.trim(),
        'role': _selectedRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم إنشاء خادم الفصل بنجاح')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.message}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة امين فصل جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                validator: (value) =>
                    value!.isEmpty ? 'أدخل الاسم الكامل' : null,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
                validator: (value) =>
                    value!.isEmpty ? 'أدخل البريد الإلكتروني' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                validator: (value) => value!.length < 6
                    ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (value) => value!.isEmpty ? 'أدخل رقم الهاتف' : null,
              ),
              TextFormField(
                controller: _churchController,
                decoration: const InputDecoration(labelText: 'الكنيسة'),
                validator: (value) => value!.isEmpty ? 'أدخل الكنيسة' : null,
              ),
              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(labelText: 'السنة الدراسية'),
                validator: (value) =>
                    value!.isEmpty ? 'أدخل السنة الدراسية' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'الدور'),
                initialValue: _selectedRole,
                items: ['User', 'Admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveUser,
                      child: const Text('إضافة'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
