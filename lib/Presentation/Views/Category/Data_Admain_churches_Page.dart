import 'package:aner_astaner/Presentation/Views/Login/Edit_User_Page.dart';
import 'package:flutter/material.dart';
import 'package:aner_astaner/features/user/domain/entities/user_summary.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  String searchQuery = '';
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usersStream = userController.watchUsersByOrganization(
      churchId: widget.church!,
      chapterId: widget.chapter!,
      role: selectedRole,
    );
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
              child: StreamBuilder<List<UserSummary>>(
                stream: usersStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!
                      .where(
                        (user) => user.name.toLowerCase().contains(searchQuery),
                      )
                      .toList();

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
                      final fullName = user.name;
                      final email = user.email;
                      final church = widget.church ?? '';
                      final role = user.role;

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
