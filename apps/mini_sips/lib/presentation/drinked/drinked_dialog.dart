import 'package:flutter/cupertino.dart' hide CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/bloc_effect.dart';
import '../../dependencies.dart';
import '../../domain/alcohol.dart';
import '../common/cupertino_text_field.dart';
import '../platform/src/platform_bottom_sheet.dart';
import 'drinked_dialog_cubit.dart';

Future<void> showDrinkedDialog({
  required BuildContext context,
}) async =>
    showPlatformBottomSheet(
      context: context,
      expand: true,
      builder: (context) {
        return const DrinkedDialog();
      },
    );

class DrinkedDialog extends StatelessWidget {
  const DrinkedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DrinkedDialogCubit>(
      create: (context) {
        final dependencies = context.read<Dependencies>();
        return DrinkedDialogCubit(
          dataManager: dependencies.dataManager,
          locationManager: dependencies.locationManager,
        )..init();
      },
      lazy: false,
      child: BlocEffectListener<DrinkedDialogCubit, DrinkedDialogState,
          DrinkedDialogEffect>(
        onEffect: (context, effect) {
          switch (effect) {
            case DrinkedDialogEffect.success:
              Navigator.of(context).pop();
          }
        },
        child: const DrinkedDialogBody(),
      ),
    );
  }
}

class DrinkedDialogBody extends StatefulWidget {
  const DrinkedDialogBody({super.key});

  @override
  State<DrinkedDialogBody> createState() => _DrinkedDialogBodyState();
}

class _DrinkedDialogBodyState extends State<DrinkedDialogBody> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final padding = MediaQuery.paddingOf(context);

    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            const SliverPersistentHeader(
              delegate: CupertinoSliverAppBar(),
              pinned: true,
            ),
            SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                additionalDividerMargin: 0,
                backgroundColor: Colors.transparent,
                children: const [
                  SelectAlcoholField(),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: CupertinoListSection.insetGrouped(
                additionalDividerMargin: 0,
                backgroundColor: Colors.transparent,
                children: [
                  CupertinoListTile(
                    onTap: () => setState(() {
                      _showDetails = !_showDetails;
                    }),
                    title: const Text('Подробнее'),
                    subtitle: const Text('Опционально'),
                    trailing: AnimatedRotation(
                      turns: _showDetails ? 0.25 : 0,
                      duration: kThemeAnimationDuration,
                      curve: Curves.easeIn,
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: kThemeAnimationDuration,
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, anim) => SizeTransition(
                  sizeFactor: anim,
                  axis: Axis.vertical,
                  axisAlignment: -1,
                  child: child,
                ),
                child: _showDetails
                    ? CupertinoListSection.insetGrouped(
                        additionalDividerMargin: 0,
                        backgroundColor: Colors.transparent,
                        children: const [
                          VolumeField(),
                          AlcoholByVolumeField(),
                          PriceField(),
                          _TrackLocationField(),
                          NoteField(),
                        ],
                      )
                    : const SizedBox(),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  20,
                  20,
                  20,
                  10,
                ),
                child: AddButton(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: padding.bottom + viewInsets.bottom),
            ),
          ],
        ),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<DrinkedDialogCubit, DrinkedDialogState, bool>(
      selector: (state) => state.status == DrinkedDialogStatus.loading,
      builder: (context, isLoading) => CupertinoButton.filled(
        onPressed:
            isLoading ? null : () => context.read<DrinkedDialogCubit>().add(),
        child: const Text('Добавить'),
      ),
    );
  }
}

class SelectAlcoholField extends StatefulWidget {
  const SelectAlcoholField({super.key});

  @override
  State<SelectAlcoholField> createState() => _SelectAlcoholFieldState();
}

class _SelectAlcoholFieldState extends State<SelectAlcoholField> {
  final _controller = PageController(
    viewportFraction: 0.5,
    initialPage: alcohol.length * 10000,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTileWithBottom(
      title: const Text('Что пьём?'),
      bottom: SizedBox(
        height: 160,
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (i) {
            final selectedAlcohol = alcohol[i % alcohol.length];
            context.read<DrinkedDialogCubit>().setAlcohol(selectedAlcohol);
          },
          itemBuilder: (context, i) {
            final index = i % alcohol.length;
            final alco = alcohol[index];

            return GestureDetector(
              onTap: () {
                if (_controller.page == i) {
                  return;
                }

                _controller.animateToPage(
                  i,
                  duration: kThemeAnimationDuration,
                  curve: Curves.easeIn,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    alco.iconPath,
                    width: 64,
                    height: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(alco.name),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VolumeField extends StatelessWidget {
  const VolumeField({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      title: const Text('Объем (мл.)'),
      onChanged: (volumeStr) {
        final volume = int.tryParse(volumeStr ?? '');
        if (volume != null) {
          context.read<DrinkedDialogCubit>().setVolume(volume);
        }
      },
    );
  }
}

class AlcoholByVolumeField extends StatelessWidget {
  const AlcoholByVolumeField({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      title: const Text('Крепость (%)'),
      onChanged: (abvStr) {
        final abv = double.tryParse(abvStr ?? '');
        if (abv != null) {
          context.read<DrinkedDialogCubit>().setAlcoholByVolume(abv);
        }
      },
    );
  }
}

class NoteField extends StatelessWidget {
  const NoteField({super.key});

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final theme = Theme.of(context);

    return TextField(
      style: cupertinoTheme.textTheme.textStyle.copyWith(inherit: true),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Заметка',
        hintStyle: cupertinoTheme.textTheme.textStyle.copyWith(
          color: theme.hintColor,
        ),
        contentPadding: const EdgeInsetsDirectional.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
      ),
      maxLines: 5,
      onChanged: (note) => context.read<DrinkedDialogCubit>().setNote(note),
    );
  }
}

class PriceField extends StatelessWidget {
  const PriceField({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      title: const Text('Цена'),
      onChanged: (priceStr) {
        final price = double.tryParse(priceStr ?? '');
        if (price != null) {
          context.read<DrinkedDialogCubit>().setPrice(price);
        }
      },
    );
  }
}

class CupertinoListTileWithBottom extends StatelessWidget {
  final Widget title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? bottom;

  const CupertinoListTileWithBottom({
    required this.title,
    super.key,
    this.onTap,
    this.trailing,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
          title: title,
          onTap: onTap,
          trailing: trailing,
        ),
        AnimatedSwitcher(
          duration: kThemeAnimationDuration,
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, anim) => SizeTransition(
            sizeFactor: anim,
            axis: Axis.vertical,
            axisAlignment: -1,
            child: child,
          ),
          child: bottom ?? const SizedBox.shrink(key: ValueKey(-1994)),
        ),
      ],
    );
  }
}

class CupertinoSliverAppBar extends SliverPersistentHeaderDelegate {
  const CupertinoSliverAppBar();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return CupertinoNavigationBar(
      transitionBetweenRoutes: false,
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Отменить'),
      ),
      middle: const Text('Алкоголь'),
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

class _TrackLocationField extends StatelessWidget {
  const _TrackLocationField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrinkedDialogCubit, DrinkedDialogState>(
      builder: (context, state) {
        final isPermissionGranted = state.isLocationPermissionGranted;

        final Widget trailing;
        final Widget? subtitle;
        if (isPermissionGranted) {
          trailing = CupertinoSwitch(
            value: state.trackLocation,
            onChanged: (isEnabled) => context
                .read<DrinkedDialogCubit>()
                .setTrackLocation(trackLocation: isEnabled),
          );
          subtitle = null;
        } else {
          trailing = CupertinoButton(
            child: const Text('Разрешить'),
            onPressed: () => context
                .read<Dependencies>()
                .locationManager
                .requestPermission(),
          );
          subtitle = const Text(
            'Разрешить нам получить локацию',
            maxLines: 2,
          );
        }

        return CupertinoListTile(
          title: const Text('Локация'),
          subtitle: subtitle,
          trailing: trailing,
        );
      },
    );
  }
}
