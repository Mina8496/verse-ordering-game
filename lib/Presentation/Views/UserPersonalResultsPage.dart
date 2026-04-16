import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:intl/intl.dart';

class UserPersonalResultsPage extends StatefulWidget {
  final String userId;

  const UserPersonalResultsPage({super.key, required this.userId});

  @override
  State<UserPersonalResultsPage> createState() =>
      _UserPersonalResultsPageState();
}

class _UserPersonalResultsPageState extends State<UserPersonalResultsPage> {
  String selectedFilter = 'الكل';
  final List<String> filters = ['الكل', 'اليوم', 'الأسبوع', 'الشهر', 'السنة'];

  bool _filterDate(DateTime date) {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'اليوم':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'الأسبوع':
        return date.isAfter(now.subtract(const Duration(days: 7)));
      case 'الشهر':
        return date.isAfter(DateTime(now.year, now.month - 1, now.day));
      case 'السنة':
        return date.isAfter(DateTime(now.year - 1, now.month, now.day));
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائجى'),
        // backgroundColor: Colors.indigo,
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          _buildFilterRow(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Exames')
                  .doc(widget.userId)
                  .collection('Results')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد نتائج بعد',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final results = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ts = data['date'] as Timestamp?;
                  if (ts == null) return false;
                  final date = ts.toDate();
                  return _filterDate(date);
                }).toList();

                if (results.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد نتائج في هذا النطاق الزمني',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final data = results[index].data() as Map<String, dynamic>;
                    final date = (data['date'] as Timestamp).toDate();
                    final formattedDate = DateFormat(
                      'yyyy/MM/dd – HH:mm',
                    ).format(date);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['bookTitle'] ?? 'بدون اسم السفر',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'الإصحاح: ${data['chapterTitle'] ?? '-'}',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'النتيجة: ${data['score'] ?? 0}%',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'عدد النجوم: ${data['stars'] ?? 0}',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'التاريخ: $formattedDate',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final f = filters[index];
          final selected = f == selectedFilter;
          return GestureDetector(
            onTap: () {
              setState(() => selectedFilter = f);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: selected ? Colors.indigo : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
