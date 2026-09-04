import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class EditUserPage extends StatefulWidget {
  final String? userID;
  const EditUserPage({super.key, this.userID});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  String name = "";
  String churchController = "";
  String SeasonController = "";
  TextEditingController BirthdayController = TextEditingController();
  String GenderController = "";
  TextEditingController Phone_NamberController = TextEditingController();
  // TextEditingController SeasonController = TextEditingController();
  String email = "";
  TextEditingController full_nameController = TextEditingController();
  String roleController = "User";

  String currentUserRole =
      ""; // هنا نخزن صلاحية المستخدم الحالي (اللي فاتح التطبيق)
  final userController = Get.find<UserController>();

  Future<void> fetchCurrentUser() async {
    // نجيب بيانات المستخدم اللي بيفتح الصفحة
    final currentUserProfile = await userController.fetchCurrentUserProfile();
    currentUserRole = currentUserProfile?.role ?? 'User';

    // نجيب بيانات المستخدم المراد تعديله
    if (widget.userID == null) return;
    final userData = await userController.fetchUserById(widget.userID!);

    if (userData == null || !mounted) return;

    setState(() {
      name = userData['name'] ?? "";
      churchController = userData['Church'] ?? "";

      final birthdayData = userData['Birthday'];
      if (birthdayData is Timestamp) {
        BirthdayController.text = birthdayData
            .toDate()
            .toString()
            .split(" ")
            .first;
      } else {
        BirthdayController.text = birthdayData?.toString() ?? "";
      }

      GenderController = userData["Gender"] ?? "";
      Phone_NamberController.text = userData['Phone_Namber'] ?? "";
      SeasonController =
          userData['Season'] ??
          ""; // SeasonController.text = userDoc['Season'] ?? "";
      email = userData['email'] ?? "";
      full_nameController.text = userData['full_name'] ?? "";
      roleController = userData['role'] ?? "User";
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
  }

  Future<void> saveUser() async {
    if (widget.userID == null) return;
    await userController.updateUser(widget.userID!, {
      "full_name": full_nameController.text,
      "Gender": GenderController,
      "Phone_Namber": Phone_NamberController.text,
      // "Season": SeasonController.text,
      // لو المستخدم الحالي SuperAdmin نسمح له يعدل الصلاحية
      if (currentUserRole == "SuperAdmin") "role": roleController,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("✅ تم تعديل بيانات المستخدم")));

    Navigator.pop(context);
  }

  @override
  void dispose() {
    BirthdayController.dispose();
    Phone_NamberController.dispose();
    full_nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (full_nameController.text.isEmpty && name.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("✏️ تعديل المستخدم")),
      body: Padding(
        padding: EdgeInsets.all(16.dg),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(name),
              TextField(
                controller: full_nameController,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "الاسم",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                churchController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
              SizedBox(height: 12.h),
              Text(
                SeasonController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
              // TextField(
              //   controller: SeasonController,
              //   style: TextStyle(fontSize: 15.sp, color: Colors.black),
              //   decoration: const InputDecoration(
              //     labelText: "الخدمة",
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              SizedBox(height: 12.h),
              Text(
                email,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: Phone_NamberController,
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "رقم الهاتف",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),

              // Dropdown الخاص بالنوع
              DropdownButtonFormField<String>(
                initialValue: (["ذكر", "انثى"].contains(GenderController))
                    ? GenderController
                    : null,
                decoration: const InputDecoration(
                  labelText: "النوع",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "ذكر", child: Text("ذكر")),
                  DropdownMenuItem(value: "انثى", child: Text("انثى")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => GenderController = val);
                },
              ),
              SizedBox(height: 12.h),

              // الصلاحية تظهر فقط إذا المستخدم الحالي SuperAdmin
              if (currentUserRole == "SuperAdmin") ...[
                DropdownButtonFormField<String>(
                  initialValue:
                      (["User", "Admin", "SuperAdmin"].contains(roleController))
                      ? roleController
                      : null,
                  decoration: const InputDecoration(
                    labelText: "الصلاحية",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: "User", child: Text("User")),
                    DropdownMenuItem(value: "Admin", child: Text("Admin")),
                    DropdownMenuItem(
                      value: "SuperAdmin",
                      child: Text("SuperAdmin"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => roleController = val);
                  },
                ),
                SizedBox(height: 20.h),
              ],

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("حفظ"),
                  onPressed: saveUser,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
