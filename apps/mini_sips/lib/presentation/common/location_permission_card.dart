import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../dependencies.dart';
import 'cupertino_card.dart';

// TODO(Vorkytaka): Move it to the state manager
const String _shouldHideKey = 'hide_location_permission_card';

class LocationPermissionCard extends StatefulWidget {
  const LocationPermissionCard({super.key});

  @override
  State<LocationPermissionCard> createState() => _LocationPermissionCardState();
}

class _LocationPermissionCardState extends State<LocationPermissionCard> {
  bool _shouldHide = false;

  @override
  void initState() {
    super.initState();
    final sharedPreferences = context.read<Dependencies>().sharedPreferences;
    _shouldHide = sharedPreferences.getBool(_shouldHideKey) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldHide) {
      return const SizedBox();
    }

    return StreamBuilder<LocationPermission>(
      stream: context.read<Dependencies>().locationManager.permissionStream,
      builder: (context, snapshot) {
        final permission = snapshot.data;

        if (permission == null) {
          return const SizedBox();
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          return const SizedBox();
        }

        final cupertinoTheme = CupertinoTheme.of(context);

        final subtitleStyle = cupertinoTheme.textTheme.textStyle.merge(
          TextStyle(
            fontSize: 12,
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        );

        return CupertinoListSection.insetGrouped(
          backgroundColor: Colors.transparent,
          children: [
            CupertinoCard(
              title: const Text('Улучшить данные'),
              trailing: GestureDetector(
                onTap: () async {
                  final sharedPreferences =
                      context.read<Dependencies>().sharedPreferences;
                  await sharedPreferences.setBool(_shouldHideKey, true);
                  setState(() {
                    _shouldHide = true;
                  });
                },
                child: const SizedBox.square(
                  dimension: 44,
                  child: Icon(Icons.close),
                ),
              ),
              bottom: DefaultTextStyle(
                style: subtitleStyle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        'Позвольте нам сохранять места где вы пьёте. Можно отключить в настройках.',
                      ),
                    ),
                    CupertinoButton(
                      child: const Text('Разрешить'),
                      onPressed: () => context
                          .read<Dependencies>()
                          .locationManager
                          .requestPermission(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
