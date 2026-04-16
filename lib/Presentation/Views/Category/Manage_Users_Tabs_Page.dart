import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersPage extends StatefulWidget {
  final String churchId;
  final String chapterId;

  const ManageUsersPage({
    Key? key,
    required this.churchId,
    required this.chapterId,
  }) : super(key: key);

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {

  late String currentChurch;
  late String currentClass;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    // ✅ القيم جاية من الصفحة السابقة
    currentChurch = widget.churchId.trim();
    currentClass  = widget.chapterId.trim();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Stream<QuerySnapshot> usersStream(String status) {
  Query query = FirebaseFirestore.instance
      .collection('users')
      .where('ChurchID', isEqualTo: currentChurch)
      .where('ChapterID', isEqualTo: currentClass)
      .where('role', isEqualTo: 'User');

  if (status == "all") {
    query = query.where('status', isEqualTo: 'pending');
  } else {
    query = query.where('status', isEqualTo: status);
  }

  return query.orderBy('full_name').snapshots();
}


  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildUsersList(Stream<QuerySnapshot> stream, String tab) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!.docs;
        if (users.isEmpty) {
          return const Center(child: Text("لا يوجد مستخدمين"));
        }
       
        print("My Church: $currentChurch");
        print("My Chapter: $currentClass");

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final fullName = user['full_name'] ?? '';
            final phoneNumber = user['Phone_Namber'] ?? '';

            return Card(
              child: ListTile(
                title: Text(fullName),
                subtitle: Text(phoneNumber),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab == "all") ...[
                      // ✅ موافق
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .update({'status': 'correct'})
                              .then((_) {
                                showSnackBar("✅ تم نقل $fullName إلى موافق");
                              });
                        },
                      ),
                      // ❌ غير موافق
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .update({'status': 'wrong'})
                              .then((_) {
                                showSnackBar(
                                  "❌ تم نقل $fullName إلى غير موافق",
                                );
                              });
                        },
                      ),
                    ] else ...[
                      // ↩️ رجوع إلى pending
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.blue),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .update({'status': 'pending'})
                              .then((_) {
                                showSnackBar(
                                  "↩️ تم إرجاع $fullName إلى كل المستخدمين",
                                );
                              });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (currentChurch == null || currentClass == null) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة المخدومين"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "قيد المراجعة"),
            Tab(text: "موافق"),
            Tab(text: "غير موافق"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildUsersList(usersStream("all"), "all"),
          buildUsersList(usersStream("correct"), "correct"),
          buildUsersList(usersStream("wrong"), "wrong"),
        ],
      ),
    );
  }
}
