import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExamesEditQuestionsPage extends StatefulWidget {
  static const String kFixedExameID = "nFL11C4v8fPRqIgG0ZAe";
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;
  final String? AlshahatID;
  final String questionId;
  ExamesEditQuestionsPage({
    required this.questionId,
    required this.ChurchID,
    required this.ChapterID,
    required this.AlngelID,
    required this.AlshahatID,
  });

  @override
  _ExamesEditQuestionsPageState createState() =>
      _ExamesEditQuestionsPageState();
}

class _ExamesEditQuestionsPageState extends State<ExamesEditQuestionsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quizController = TextEditingController();
  List<TextEditingController> _optionControllers = [];
  int _correctOptionIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  void _loadQuestionData() async {
    DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection("Churches")
        .doc(widget.ChurchID)
        .collection("Chapters")
        .doc(widget.ChapterID)
        .collection("Exames")
        .doc(ExamesEditQuestionsPage.kFixedExameID)
        .collection("Alangel")
        .doc(widget.AlngelID)
        .collection("Alshahat")
        .doc(widget.AlshahatID)
        .collection("Qusstions")
        .doc(widget.questionId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      _quizController.text = data['Quiz'] ?? '';

      Map<String, dynamic> options = Map<String, dynamic>.from(data['options']);
      _optionControllers = [];
      _correctOptionIndex = 0;

      int index = 0;
      options.forEach((key, value) {
        _optionControllers.add(TextEditingController(text: key));
        if (value == true) {
          _correctOptionIndex = index;
        }
        index++;
      });
    }

    setState(() {
      _isLoading = false;
    });
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
        _optionControllers.removeAt(index);
      });
    }
  }

  void _updateQuestion() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> options = {};
      for (int i = 0; i < _optionControllers.length; i++) {
        options[_optionControllers[i].text.trim()] = (i == _correctOptionIndex);
      }

      await FirebaseFirestore.instance
          .collection("Churches")
          .doc(widget.ChurchID)
          .collection("Chapters")
          .doc(widget.ChapterID)
          .collection("Exames")
          .doc(ExamesEditQuestionsPage.kFixedExameID)
          .collection("Alangel")
          .doc(widget.AlngelID)
          .collection("Alshahat")
          .doc(widget.AlshahatID)
          .collection("Qusstions")
          .doc(widget.questionId) // ← مهم
          .update({
        'Quiz': _quizController.text.trim(),
        'options': options,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تعديل السؤال بنجاح')),
      );

      Navigator.pop(context); // العودة للخلف
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('تعديل سؤال')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('تعديل سؤال')),
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
                        decoration:
                            InputDecoration(labelText: 'الخيار ${index + 1}'),
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
                onPressed: _updateQuestion,
                child: Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
