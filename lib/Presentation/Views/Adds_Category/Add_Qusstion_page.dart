import 'package:flutter/material.dart';
import 'package:aner_astaner/features/question/presentation/controllers/question_controller.dart';
import 'package:get/get.dart';

class addQusstionPage extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;
  final String? AlshahatID;

  const addQusstionPage({
    super.key,
    this.ChurchID,
    this.ChapterID,
    this.AlngelID,
    this.AlshahatID,
  });
  @override
  _addQusstionPageState createState() => _addQusstionPageState();
}

class _addQusstionPageState extends State<addQusstionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizController = TextEditingController();
  List<TextEditingController> _optionControllers = [];
  int _correctOptionIndex = 0;

  @override
  void initState() {
    super.initState();
    _addOption(); // نبدأ بخيار واحد على الأقل
    _addOption(); // خيار ثاني كبداية
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      setState(() {
        if (_correctOptionIndex == index) {
          _correctOptionIndex = 0;
        } else if (_correctOptionIndex > index) {
          _correctOptionIndex--;
        }
        _optionControllers.removeAt(index).dispose();
      });
    }
  }

  void _submitQuestion() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, bool> options = {};
      for (int i = 0; i < _optionControllers.length; i++) {
        options[_optionControllers[i].text.trim()] = (i == _correctOptionIndex);
      }

      await Get.find<QuestionController>().addQuestion(
        churchId: widget.ChurchID,
        chapterId: widget.ChapterID,
        categoryId: widget.AlngelID,
        sectionId: widget.AlshahatID,
        quiz: _quizController.text.trim(),
        options: options,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إضافة السؤال بنجاح')));

      _quizController.clear();
      for (final controller in _optionControllers) {
        controller.dispose();
      }
      setState(() {
        _optionControllers = [];
        _correctOptionIndex = 0;
        _addOption();
        _addOption();
      });
    }
  }

  @override
  void dispose() {
    _quizController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة سؤال')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _quizController,
                decoration: InputDecoration(labelText: 'نص السؤال'),
                validator: (value) => value!.isEmpty ? 'أدخل نص السؤال' : null,
              ),
              SizedBox(height: 16),
              Text('الخيارات:', style: TextStyle(fontWeight: FontWeight.bold)),
              ..._optionControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;

                return Row(
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          _correctOptionIndex = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'الخيار ${index + 1}',
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'أدخل الخيار' : null,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeOption(index),
                    ),
                  ],
                );
              }),
              SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addOption,
                icon: Icon(Icons.add),
                label: Text('إضافة خيار'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitQuestion,
                child: Text('حفظ السؤال'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
