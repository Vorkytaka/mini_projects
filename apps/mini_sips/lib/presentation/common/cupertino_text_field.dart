import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoTextField extends StatefulWidget {
  final Widget title;
  final ValueChanged<String?> onChanged;

  const CupertinoTextField({
    required this.title,
    required this.onChanged,
    super.key,
  });

  @override
  State<CupertinoTextField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<CupertinoTextField> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      onTap: _focusNode.requestFocus,
      title: Row(
        children: [
          widget.title,
          Flexible(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
