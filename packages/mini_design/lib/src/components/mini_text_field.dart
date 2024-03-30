import 'package:flutter/material.dart';

import '../../mini_design.dart';

class MiniTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;

  const MiniTextField({
    super.key,
    this.controller,
    this.hint,
    this.maxLines = 1,
    this.autofocus = false,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      decoration: InputDecoration(
        border: InputBorder.none,
        isDense: true,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      textAlign: TextAlign.start,
      expands: false,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      onChanged: onChanged,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kTileMinHeight),
      child: Center(
        child: textField,
      ),
    );
  }
}

class MiniTextFormField extends FormField<String> {
  final TextEditingController? controller;

  MiniTextFormField({
    this.controller,
    String? hint,
    int? maxLines = 1,
    int? minLines,
    bool autofocus = false,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
    String? initialValue,
    FormFieldValidator<String?>? validator,
    AutovalidateMode? autovalidateMode,
    super.key,
  }) : super(
          initialValue:
              controller != null ? controller.text : (initialValue ?? ''),
          validator: validator,
          autovalidateMode: autovalidateMode,
          builder: (field) {
            final _MiniTextFormFieldState state =
                field as _MiniTextFormFieldState;

            void onChangedHandler(String value) {
              field.didChange(value);
              if (onChanged != null) {
                onChanged(value);
              }
            }

            // TODO(Vorkytaka): Move error to the text field?
            Widget? errorWidget;
            if (field.errorText != null) {
              final theme = Theme.of(field.context);
              final errorStyle = theme.textTheme.label?.copyWith(
                color: theme.colorScheme.error,
              );

              errorWidget = Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 8),
                child: DefaultTextStyle.merge(
                  style: errorStyle,
                  child: Text(
                    field.errorText!,
                  ),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MiniTextField(
                  controller: state._effectiveController,
                  hint: hint,
                  textCapitalization: textCapitalization,
                  textInputAction: textInputAction,
                  keyboardType: keyboardType,
                  minLines: minLines,
                  autofocus: autofocus,
                  maxLines: maxLines,
                  onChanged: onChangedHandler,
                ),
                if (errorWidget != null) errorWidget,
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _MiniTextFormFieldState();
}

/// Copy-paste from [TextFormField]
class _MiniTextFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController =>
      _textFormField.controller ?? _controller!.value;

  MiniTextFormField get _textFormField => super.widget as MiniTextFormField;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_textFormField.controller == null) {
      _createLocalController(widget.initialValue != null
          ? TextEditingValue(text: widget.initialValue!)
          : null);
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(MiniTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _textFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _textFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_textFormField.controller != null) {
        setValue(_textFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    // setState will be called in the superclass, so even though state is being
    // manipulated, no setState call is needed here.
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _handleControllerChanged() {
    // Suppress changes that originated from within this class.
    //
    // In the case where a controller has been passed in to this widget, we
    // register this change listener. In these cases, we'll also receive change
    // notifications for changes originating from within this class -- for
    // example, the reset() method. In such cases, the FormField value will
    // already have been set.
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
