import 'package:flutter/material.dart';

class MiniSearchBar extends StatelessWidget {
  final Widget? leadingIcon;
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<String?>? onChanged;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? hint;

  const MiniSearchBar({
    Key? key,
    this.leadingIcon,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
    this.trailing,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(48),
          ),
          borderSide: BorderSide.none,
        ),
        hintText: hint,
        filled: true,
        prefixIcon: leadingIcon ?? const Icon(Icons.search),
        // constraints: BoxConstraints(minHeight: 48, maxHeight: 48),
        contentPadding: EdgeInsets.zero,
        suffixIcon: trailing,
      ),
      maxLines: 1,
      minLines: 1,
      style: Theme.of(context).textTheme.titleMedium,
      textAlignVertical: TextAlignVertical.center,
      onTap: onTap,
      readOnly: readOnly,
      autofocus: autofocus,
      enabled: true,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      onChanged: onChanged,
    );
  }
}
