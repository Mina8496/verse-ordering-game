import 'package:aner_astaner/Presentation/Views/Bible_Books/Bible_Books_Page.dart';
import 'package:flutter/material.dart';

class BibleReadButton extends StatefulWidget {
  const BibleReadButton({super.key});

  @override
  State<BibleReadButton> createState() => _BibleReadButtonState();
}

class _BibleReadButtonState extends State<BibleReadButton>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        // نفذ الإجراء هنا
        Navigator.push(context, MaterialPageRoute(builder: (context) => BiblePage() ),);
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 90, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFF1CB29B),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'قراءة الكتاب المقدس',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
