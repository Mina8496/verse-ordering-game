import 'package:aner_astaner/Presentation/Views/MasterHome_Page.dart';
import 'package:aner_astaner/features/auth/data/services/auth_service.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final user = Get.find<AuthService>().currentUser!;
  final userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();

  String? name, church, gender;
  String? season;

  final nameController = TextEditingController();
  final churchController = TextEditingController();
  final seasonController = TextEditingController();
  final phoneController = TextEditingController();

  int? day, month, year;
  DateTime? lastUpdated;
  bool isSaving = false;
  bool canEdit = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final data = await userController.fetchCurrentUserData();
    print(data);

    if (data != null) {
      gender = data['Gender'];
      // ✅ تحويل الجنس إذا كان بالإنجليزي
      if (gender == "Male") gender = "ذكر";
      if (gender == "Female") gender = "أنثى";

      setState(() {
        name = data['full_name'];
        nameController.text = name ?? '';

        church = data['Church'];
        churchController.text = church ?? '';

        season = data['Season'];
        seasonController.text = season ?? '';

        phoneController.text = data['Phone_Namber'] ?? 'غير متوفر';

        // ✅ التعامل مع Birthday سواء String أو Timestamp
        final birthdayData = data['Birthday'];
        if (birthdayData is Timestamp) {
          final birthday = birthdayData.toDate();
          day = birthday.day;
          month = birthday.month;
          year = birthday.year;
        } else if (birthdayData is String) {
          try {
            final birthday = DateTime.tryParse(birthdayData);
            if (birthday != null) {
              day = birthday.day;
              month = birthday.month;
              year = birthday.year;
            }
          } catch (e) {
            debugPrint("⚠️ خطأ في تحويل تاريخ الميلاد: $e");
          }
        }

        canEdit = true; // ← تعديل متاح دائمًا
      });
    }
  }

  Future<void> saveChanges() async {
    if (!canEdit || !_formKey.currentState!.validate()) return;

    name = nameController.text;
    _formKey.currentState!.save();
    setState(() => isSaving = true);

    final newBirthday = DateTime(year!, month!, day!);

    await userController.updateCurrentUser({
      'full_name': name,
      'Church': church,
      'Season': season,
      'Gender': gender,
      'Phone_Namber': phoneController.text, // ✅ النص نفسه مش الكنترولر
      'Birthday': Timestamp.fromDate(
        newBirthday,
      ), // ✅ تخزين كـ Timestamp دايمًا
      'lastEditDate': FieldValue.serverTimestamp(),
    });

    setState(() => isSaving = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MasterHome()),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    churchController.dispose();
    seasonController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // title: const Text("🚫 المستخدمين المحظورين"),
        centerTitle: true,
        // leading:
        actions: [
          IconButton(
            onPressed: () => ZoomDrawer.of(context)!.toggle(),
            icon: const Icon(Icons.menu),
          ),
          Expanded(
            child: Text(
              "تعديل البيانات الشخصية",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: const AssetImage("assets/images/avatar_placeholder.jpg"),
        //     onError: (exception, stackTrace) {
        //       debugPrint("⚠️ الخلفية غير موجودة، تأكد من المسار");
        //     },
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: isSaving
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 60.w),
                child: Container(
                  padding: EdgeInsets.all(20.dg),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.dg),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10.r),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      CircleAvatar(
                        radius: 50.r,
                        // backgroundColor: Colors.amber,
                        child: CircleAvatar(
                          radius: 46.r,
                          backgroundImage: AssetImage(
                            "assets/images/avatar_placeholder.jpg",
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // if (!canEdit)
                      if (canEdit) buildForm(),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: canEdit ? saveChanges : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40.h,
                            vertical: 12.w,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.dg),
                          ),
                        ),
                        child: Text("حفظ", style: TextStyle(fontSize: 15.sp)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // الاسم - قابل للتعديل
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'الاسم',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.dg),
              ),
            ),
            onSaved: (val) => name = val,
            validator: (val) =>
                (val == null || val.isEmpty) ? 'هذا الحقل مطلوب' : null,
          ),
          SizedBox(height: 10.h),

          // الكنيسة - للعرض فقط
          TextFormField(
            controller: churchController,
            style: TextStyle(fontSize: 10.sp),
            enabled: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.w,
                horizontal: 12.h,
              ), // ← كده بيكبر الحقل

              labelText: 'الكنيسة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.dg),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // الفصول - للعرض فقط
          TextFormField(
            controller: seasonController,
            enabled: false,
            decoration: InputDecoration(
              labelText: 'الموسم',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.dg),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // رقم الهاتف - للعرض فقط
          TextFormField(
            controller: phoneController,
            // enabled: false,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.dg),
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // النوع
          DropdownButtonFormField<String>(
            initialValue: ["ذكر", "أنثى"].contains(gender) ? gender : null,
            decoration: const InputDecoration(
              labelText: "النوع",
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: "ذكر", child: Text("ذكر")),
              DropdownMenuItem(value: "أنثى", child: Text("أنثى")),
            ],
            onChanged: (val) => setState(() => gender = val),
          ),
          SizedBox(height: 20.h),

          // تاريخ الميلاد
          Row(
            children: [
              Expanded(
                child: buildDropdown(
                  "اليوم",
                  1,
                  31,
                  day,
                  (val) => setState(() => day = val),
                ),
              ),
              SizedBox(width: 8.h),
              Expanded(
                child: buildDropdown(
                  "الشهر",
                  1,
                  12,
                  month,
                  (val) => setState(() => month = val),
                ),
              ),
              SizedBox(width: 8.h),
              Expanded(
                child: buildDropdown(
                  "السنة",
                  1970,
                  DateTime.now().year,
                  year,
                  (val) => setState(() => year = val),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    String label,
    String? initialValue,
    Function(String?) onSaved,
  ) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg)),
      ),
      onSaved: onSaved,
      validator: (val) =>
          (val == null || val.isEmpty) ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget buildDropdown(
    String label,
    int start,
    int end,
    int? value,
    Function(int?) onChanged,
  ) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.dg)),
      ),
      items: List.generate(end - start + 1, (i) => i + start)
          .map((v) => DropdownMenuItem(value: v, child: Text(v.toString())))
          .toList(),
      onChanged: onChanged,
      validator: (val) => (val == null) ? 'هذا الحقل مطلوب' : null,
    );
  }
}
