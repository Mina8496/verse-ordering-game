import 'package:aner_astaner/Presentation/Views/Login/Edit_User_Page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class DisabledUsersPage extends StatefulWidget {
  const DisabledUsersPage({super.key});

  @override
  State<DisabledUsersPage> createState() => _DisabledUsersPageState();
}

class _DisabledUsersPageState extends State<DisabledUsersPage> {
  String? currentUserChurchID;
  String? currentUserRole;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserData();
  }

  Future<void> fetchCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    if (!userDoc.exists) return;

    setState(() {
      currentUserChurchID = userDoc['ChurchID'];
      currentUserRole = userDoc['role'];
    });
  }

  Stream<List<Map<String, dynamic>>> getDisabledUsers() {
    if (currentUserChurchID == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection("users")
        .where("ChurchID", isEqualTo: currentUserChurchID)
        .where("disabled", isEqualTo: true) // ✅ المستخدمين المحظورين فقط
        .snapshots()
        .map((snap) {
          return snap.docs.map((d) {
            final data = d.data();
            return {
              "id": d.id,
              "full_name": data['full_name'] ?? "مستخدم",
              "email": data['email'] ?? "",
              "role": data['role'] ?? "User",
              "profileImageUrl": data['profileImageUrl'],
              "Season": data['Season'],
            };
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserChurchID == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("🚫 المستخدمين المحظورين"),

        centerTitle: true,
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getDisabledUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text("لا يوجد مستخدمين محظورين ✅"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              final photoUrl = u['profileImageUrl'];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 26.r,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : const AssetImage("assets/images/def_prof.gif")
                                as ImageProvider,
                    ),
                    title: Text(
                      u['full_name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "البريد: ${u['email']} \nالفصل: ${u['Season']}",
                    ),
                    trailing:
                        (currentUserRole == "Admin" ||
                            currentUserRole == "SuperAdmin")
                        ? PopupMenuButton<String>(
                            onSelected: (val) async {
                              if (val == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditUserPage(userID: u['id']),
                                  ),
                                );
                              } else if (val == "enable") {
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(u['id'])
                                    .update({"disabled": false});
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: "edit",
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text("تعديل"),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: "enable",
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text("إعادة التفعيل"),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
