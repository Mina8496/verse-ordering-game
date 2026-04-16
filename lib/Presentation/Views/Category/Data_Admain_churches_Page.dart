import 'package:aner_astaner/Presentation/Views/Login/Edit_User_Page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataAdmainChurchesPage extends StatefulWidget {
  final String? church;
  final String? chapter;

  const DataAdmainChurchesPage({
    Key? key,
    required this.church,
    required this.chapter,
  }) : super(key: key);

  @override
  _DataAdmainChurchesPageState createState() => _DataAdmainChurchesPageState();
}

class _DataAdmainChurchesPageState extends State<DataAdmainChurchesPage> {
  String? selectedRole;
  String? selectedChurch;
  String searchQuery = '';
  List<String> churchesList = [];

  @override
  void initState() {
    super.initState();
    fetchChurches();
  }

  void fetchChurches() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Churches')
        .get();
    setState(() {
      churchesList = snapshot.docs
          .map((doc) => doc['title'] as String)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Query usersQuery = FirebaseFirestore.instance
        .collection('users')
        .where('role', isNotEqualTo: 'SuperAdmin')
        .where('ChurchID', isEqualTo: widget.church)
        .where('ChapterID', isEqualTo: widget.chapter)
        .orderBy('role');

    if (selectedRole != null) {
      usersQuery = usersQuery.where('role', isEqualTo: selectedRole);
    }
    // if (selectedChurch != null) {
    //   usersQuery = usersQuery.where('Church', isEqualTo: selectedChurch);
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المستخدمين'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: '...ابحث باسم المستخدم',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.dg),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toLowerCase();
                });
              },
            ),
            SizedBox(height: 12.h),
            // Row(
            //   children: [
            //     Expanded(
            //       child: DropdownButtonFormField<String>(
            //         initialValue: selectedChurch,
            //         decoration: InputDecoration(
            //           labelText: 'الكنيسة',
            //           border: OutlineInputBorder(),
            //           isDense: true,
            //         ),
            //         items: [
            //           const DropdownMenuItem(value: null, child: Text('الكل')),
            //           ...churchesList.map(
            //             (church) => DropdownMenuItem(
            //               value: church,
            //               child: Text(
            //                 church,
            //                 style: TextStyle(fontSize: 10.sp),
            //               ),
            //             ),
            //           ),
            //         ],
            //         onChanged: (value) {
            //           setState(() {
            //             selectedChurch = value;
            //           });
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 12.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: usersQuery.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final fullName = doc.data().toString().contains('full_name')
                        ? (doc['full_name'] ?? '').toString().toLowerCase()
                        : '';
                    return fullName.contains(searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('لا يوجد نتائج تطابق البحث'),
                    );
                  }

                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (context, _) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final fullName =
                          user.data().toString().contains('full_name')
                          ? (user['full_name'] ?? '')
                          : '';
                      final email = user.data().toString().contains('email')
                          ? (user['email'] ?? '')
                          : '';
                      final church = user.data().toString().contains('Church')
                          ? (user['Church'] ?? '')
                          : '';
                      final role = user.data().toString().contains('role')
                          ? (user['role'] ?? '')
                          : '';

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.dg),
                        ),
                        child: ListTile(
                          title: Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(email, overflow: TextOverflow.ellipsis),
                              Text(
                                'الكنيسة: $church',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shield,
                                size: 20,
                                color: Colors.grey,
                              ),
                              Text(role, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditUserPage(userID: user.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (ctx) => AddDataAdmainChurchesPage(),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
