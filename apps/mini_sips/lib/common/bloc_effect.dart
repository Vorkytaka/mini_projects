import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Provides one more stream to [BlocBase] for effects.
///
/// The problem is that bloc doesn't have any way, to send single-time events.
/// Because of that, we have some problems and boilerplate with that kind of actions.
///
/// For example: when we need to show single error, if something went wrong.
/// Without that mixin we need to:
/// - Add some field to the state, that will represent this error.
/// - Set this field with some error value, when something happening.
/// - Show error on the UI layer
/// - Don't forget to set error field to null
///
/// With this mixin we can just use [BlocEffectListener] and show error.
/// Without thinking about cleaning an error field.
///
/// _WARNING_
/// For now it's just experimental feature!
/// We will use it and see if that's work fine.
mixin BlocEffectStream<State, Effect> on BlocBase<State> {
  final StreamController<Effect> _controller = StreamController.broadcast();

  StreamSubscription<Effect> addEffectListener(ValueChanged<Effect> listener) {
    return _controller.stream.listen(listener);
  }

  void sendEffect(Effect effect) => _controller.add(effect);

  @override
  Future<void> close() async {
    await _controller.close();
    await super.close();
  }
}

/// Widget for listen effects from any [BlocEffectStream] bloc above.
///
/// _WARNING_
/// For now it's just experimental feature!
/// We will use it and see if that's work fine.
///
/// For now we have at least 2 problems:
///
/// 1. Implicit bloc generic.
/// We need to set [B] as some bloc that use [BlocEffectStream] mixin,
/// but we can't use [BlocEffectStream] as generic. If we try, then it will throw an error.
///
/// 2. Generics boilerplate.
/// We need to explicitly set generics for bloc, state and effect.
/// Not sure that we can do something with that.
class BlocEffectListener<B extends BlocEffectStream<S, E>, S, E>
    extends StatefulWidget {
  final Widget child;
  final void Function(BuildContext context, E effect) onEffect;

  const BlocEffectListener({
    required this.child,
    required this.onEffect,
    Key? key,
  }) : super(key: key);

  @override
  State<BlocEffectListener> createState() =>
      _BlocEffectListenerState<B, S, E>();
}

class _BlocEffectListenerState<B extends BlocEffectStream<S, E>, S, E>
    extends State<BlocEffectListener<B, S, E>> {
  StreamSubscription<E>? _subscription;
  B? _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<B>();
    _subscribe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void didUpdateWidget(BlocEffectListener<B, S, E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onEffect != oldWidget.onEffect) {
      _unsubscribe();
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _subscribe() {
    _subscription = _bloc?.addEffectListener((effect) {
      widget.onEffect(context, effect);
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}
