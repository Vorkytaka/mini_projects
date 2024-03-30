import 'package:flutter/foundation.dart';

enum AppStyle {
  tracking,
  quitting,
}

enum BiologicalSex {
  male,
  female,
  notDefine,
}

@immutable
class UserData {
  final AppStyle appStyle;

  const UserData({
    required this.appStyle,
  });
}
