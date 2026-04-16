import 'package:aner_astaner/Presentation/widgets/Custem_text.dart';
import 'package:aner_astaner/Presentation/widgets/NextButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'package:cupertino_date_textbox/cupertino_date_textbox.dart';

class CompleteInformationBody extends StatefulWidget {
  const CompleteInformationBody({super.key});

  @override
  State<CompleteInformationBody> createState() =>
      _CompleteInformationBodyState();
}

class _CompleteInformationBodyState extends State<CompleteInformationBody> {
  DateTime _selectedDateTime = DateTime.now();
  bool isLoading = false;

  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNamber = TextEditingController();
  TextEditingController cumbirthday = TextEditingController();
  TextEditingController church = TextEditingController();
  TextEditingController season = TextEditingController();
  String GenderController = "";

  // String _selectedGender = genderMap.keys.first;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  List<DropdownMenuItem<String>> dataChurches = [];
  Map<String, String> churchNameToId = {}; // name → ID
  Map<String, String> seasonNameToId = {}; // الموسم → ID

  List<DropdownMenuItem<String>> dataseason = [];

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    getChurchesList();
  }

  Future<void> getChurchesList() async {
    dataChurches.clear();
    churchNameToId.clear();

    final querySnapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .get();

    for (var doc in querySnapshot.docs) {
      final String churchName = doc['title'];
      final String churchId = doc.id;

      churchNameToId[churchName] = churchId;

      dataChurches.add(
        DropdownMenuItem<String>(
          value: churchName,
          child: Text(
            churchName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      );
    }

    setState(() {});
  }

  Future<void> getDataChurches() async {
    dataseason.clear();
    seasonNameToId.clear(); // ⬅️ مهم

    final selectedChurchId = churchNameToId[church.text];
    if (selectedChurchId == null) return;

    final chaptersCollection = FirebaseFirestore.instance
        .collection("Churches")
        .doc(selectedChurchId)
        .collection("Chapters");

    final querySnapshot = await chaptersCollection.get();

    for (var doc in querySnapshot.docs) {
      final dynamic seasonData = doc['season'];
      if (seasonData != null) {
        final seasonStr = seasonData.toString();
        if (!dataseason.any((item) => item.value == seasonStr)) {
          dataseason.add(
            DropdownMenuItem<String>(
              value: seasonStr,
              child: Text(
                seasonStr,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          );
          // نحفظ ID الفصل
          seasonNameToId[seasonStr] = doc.id;
        }
      }
    }

    setState(() {});
  }

  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> userData,
    required String selectedChurchId,
    required String selectedChapterId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final batch = firestore.batch();

      // المرجع الأول: users
      final userRef = firestore.collection("users").doc(uid);

      // المرجع الثاني: Approved
      final approvedRef = firestore
          .collection("Churches")
          .doc(selectedChurchId)
          .collection("Chapters")
          .doc(selectedChapterId)
          .collection("Approved")
          .doc(uid);

      // إضافة العمليتين للـ batch
      batch.set(userRef, userData);
      batch.set(approvedRef, userData);

      // تنفيذ العمليات كلها مره واحدة
      await batch.commit();
      print("✅ اهلا بك في التطبيق");
    } catch (e) {
      print("❌ Error while updating user: $e");
      rethrow;
    }
  }

  void onBirthdayChange(DateTime birthday) {
    setState(() {
      _selectedDateTime = birthday;
      cumbirthday.text = DateFormat.yMd().format(birthday);
    });
  }

  // static final Map<String, String> genderMap = {
  //   'male': 'Male',
  //   'female': 'Female',
  // };

  // void onGenderSelected(String genderKey) {
  //   setState(() {
  //     _selectedGender = genderKey;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final String formattedDate = DateFormat.yMd().format(_selectedDateTime);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromRGBO(117, 239, 255, 1).withOpacity(0.5),
              const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formstate,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 200.h,
                    child: Image.asset(
                      "assets/logo.png", // أو أي صورة مناسبة
                      fit: BoxFit.cover,
                    ),
                  ),

                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 230.dg),
                        child: Text(
                          "تسجيل",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 25.sp),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 210.dg),
                        child: CustomText(title: "برجاء ادخال البيانات"),
                      ),
                      CustomTextField(
                        validator: (val) => val == null || val.isEmpty
                            ? "لا يمكن أن يكون فارغًا"
                            : null,
                        controller: fullName,
                        obscureText: false,
                        inputType: TextInputType.name,
                        hintText: "* الاســـــم",
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 20.h),
                      IntlPhoneField(
                        controller: phoneNamber,
                        initialCountryCode: 'EG',
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: "* رقم الهاتف",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Dropdown الكنيسة
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.dg),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text(
                            "                                          حدد كنيستك",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value:
                              dataChurches.any(
                                (item) => item.value == church.text,
                              )
                              ? church.text
                              : null,
                          items: dataChurches,
                          onChanged: (value) async {
                            if (value != null && value != church.text) {
                              setState(() {
                                church.text = value;
                                season.text = '';
                                dataseason.clear();
                              });
                              await getDataChurches();
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Dropdown الموسم
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1.dg),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text(
                            "                                          حدد فصلك",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value:
                              dataseason.any(
                                (item) => item.value == season.text,
                              )
                              ? season.text
                              : null,
                          items: dataseason,
                          onChanged: (value) {
                            if (value != null && value != season.text) {
                              setState(() {
                                season.text = value;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      CustomText(
                        title: "* تاريخ الميلاد",
                        textAlign: TextAlign.right,
                      ),
                      CupertinoDateTextBox(
                        initialValue: DateTime.now(),
                        onDateChange: onBirthdayChange,
                        hintText: 'اختر تاريخ الميلاد',
                      ),
                      SizedBox(height: 20.h),
                      CustomText(title: "* النوع", textAlign: TextAlign.right),
                      SizedBox(height: 20.h),
                      DropdownButtonFormField<String>(
                        initialValue:
                            (["ذكر", "انثى"].contains(GenderController))
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
                          if (val != null)
                            setState(() => GenderController = val);
                        },
                      ),
                      // CupertinoRadioChoice(
                      //   choices: genderMap,
                      //   onChange: onGenderSelected,
                      //   initialKeyValue: _selectedGender,
                      // ),
                      SizedBox(height: 30.h),
                      Center(
                        child: NextButton(
                          iconData: Icons.arrow_back_ios,
                          nextQuestion: () async {
                            if (formstate.currentState!.validate()) {
                              if (fullName.text.isEmpty ||
                                  phoneNamber.text.isEmpty ||
                                  church.text.isEmpty ||
                                  season.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("برجاء إدخال البيانات كاملة"),
                                  ),
                                );
                              } else {
                                if (isLoading) return;
                                setState(() => isLoading = true);

                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) return; // احتياط لو مفيش يوزر

                                final selectedChurchId =
                                    churchNameToId[church.text]!;
                                final selectedChapterId =
                                    seasonNameToId[season.text]!;

                                final userData = {
                                  "uid": user.uid,
                                  "full_name": fullName.text,
                                  "Phone_Namber": phoneNamber.text,
                                  "Birthday": cumbirthday.text,
                                  "Church": church.text, // اسم الكنيسة
                                  "Season": season.text, // اسم الفصل
                                  "Gender": GenderController,
                                  "ChurchID":
                                      selectedChurchId, // 🟢 أضف ID الكنيسة
                                  "ChapterID":
                                      selectedChapterId, // 🟢 أضف ID الفصل
                                  "createdAt": FieldValue.serverTimestamp(),
                                  'email': user.email,
                                  'name': user.displayName,
                                  'role': 'User',
                                  'status': 'pending',
                                };

                                await updateUser(
                                  uid: user.uid,
                                  userData: userData,
                                  selectedChurchId: selectedChurchId,
                                  selectedChapterId: selectedChapterId,
                                );

                                setState(() => isLoading = false);

                                Fluttertoast.showToast(
                                  msg: "تم حفظ البيانات بنجاح",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0.sp,
                                );

                                Navigator.of(context).pushReplacementNamed("MasterHome");
                              }
                            }
                          },

                          text: "تسجيل الدخول",
                          width: 165.0.w,
                        ),
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
