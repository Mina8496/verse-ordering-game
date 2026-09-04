import 'package:aner_astaner/Presentation/Views/Category/Alshahat_Page.dart';
import 'package:aner_astaner/features/category/presentation/controllers/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  Future<void> _showDeleteDialog(
    BuildContext context,
    CategoryController controller,
    String categoryId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا العنصر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteCategory(categoryId);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسفار والإنجيل'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => ZoomDrawer.of(context)!.toggle(),
          icon: const Icon(Icons.menu),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  itemCount: controller.categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, i) {
                    final category = controller.categories[i];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                AlshahatPage(AlshahatID: category.id),
                          ),
                        );
                      },
                      onLongPress: () =>
                          _showDeleteDialog(context, controller, category.id),
                      child: Card(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              child: Image.asset(
                                "assets/images/Splash_View2.png",
                                height: 100,
                              ),
                            ),
                            Text(category.title),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.of(context).pushNamed("AddNewCatgory");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
