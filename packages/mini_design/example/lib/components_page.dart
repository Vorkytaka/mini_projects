import 'package:flutter/material.dart';
import 'package:mini_design/mini_design.dart';

class ComponentsPage extends StatelessWidget {
  static const path = '/components';

  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const divider = SizedBox(height: 24);

    return RevertBackgroundTheme(
      child: Scaffold(
        appBar: AppBar(title: const Text('Components')),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            const MiniGroupHeader(header: Text('SEARCH BAR')),
            const MiniSearchBar(
              hint: 'Поиск',
            ),
            divider,
            MiniGroup(
              header: const Text('MINI LIST TILE'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MiniListTile(
                    title: const Text('Title'),
                    onTap: () {},
                  ),
                  MiniListTile(
                    title: const Text('Title'),
                    subtitle: const Text('Subtitle'),
                    onTap: () {},
                  ),
                  MiniListTile(
                    title: const Text('Title'),
                    leading: const MiniSettingIcon(
                      color: Colors.red,
                      icon: Icon(Icons.folder),
                    ),
                    onTap: () {},
                  ),
                  MiniListTile(
                    title: const Text('Title'),
                    subtitle: const Text('Subtitle'),
                    leading: const MiniSettingIcon(
                      color: Colors.blue,
                      icon: Icon(Icons.folder),
                    ),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('33'),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                  MiniListTile(
                    leading: const MiniSettingIcon(
                      color: Colors.green,
                      icon: Icon(Icons.folder),
                    ),
                    title: const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et'),
                    onTap: () {},
                  ),
                ].interpose(const MiniGroupDivider()),
              ),
            ),
            divider,
            MiniGroup(
              header: const Text('MINI TEXT FIELD'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniTextField(
                    hint: 'Hint',
                  ),
                  MiniTextFormField(
                    hint: 'Form field hint',
                    validator: (str) =>
                        str != null && str.isNotEmpty ? 'Error' : null,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const MiniTextField(
                    hint: 'Multiline hint',
                    minLines: 5,
                    maxLines: 5,
                  ),
                ].interpose(const MiniGroupDivider(indent: 0)),
              ),
            ),
            divider,
            const MiniGroup(
              header: Text('MINI CHECKBOX'),
              child: _CheckboxExample(),
            ),
            divider,
            const MiniGroup(
              header: Text('MINI COLOR PICKER'),
              child: _ColorPickerExample(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxExample extends StatefulWidget {
  const _CheckboxExample();

  @override
  State<_CheckboxExample> createState() => _CheckboxExampleState();
}

class _CheckboxExampleState extends State<_CheckboxExample> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MiniCheckbox(
          value: _isChecked,
          onChanged: _onTap,
        ),
        MiniCheckbox(
          value: _isChecked,
          onChanged: _onTap,
          size: 40,
          side: const BorderSide(width: 3),
          bubbleCount: 10,
        ),
        MiniCheckbox(
          value: _isChecked,
          onChanged: _onTap,
          checkColor: Colors.orange,
          fillColor: Colors.blue,
        ),
        MiniCheckbox(
          value: _isChecked,
          onChanged: _onTap,
          bubbleCount: 0,
        ),
        MiniCheckbox(
          value: _isChecked,
          onChanged: _onTap,
          bubbleColors: const [Colors.red],
          fillColor: Colors.red,
        ),
      ],
    );
  }

  void _onTap(bool isChecked) => setState(() {
        _isChecked = isChecked;
      });
}

class _ColorPickerExample extends StatefulWidget {
  const _ColorPickerExample();

  @override
  State<_ColorPickerExample> createState() => _ColorPickerExampleState();
}

class _ColorPickerExampleState extends State<_ColorPickerExample> {
  Color? _selectedColor;

  @override
  Widget build(BuildContext context) {
    return MiniColorPicker(
      selectedColor: _selectedColor,
      onChanged: (color) => setState(() {
        _selectedColor = color;
      }),
    );
  }
}
