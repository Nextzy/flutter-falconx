// Ignore because is not necessary

import 'package:flutter_falconx/src/src.dart';

typedef DisabledWidgetBuilder = Widget Function(
  BuildContext context,
  bool disabled,
);

class DisabledCubit extends Cubit<bool> {
  new() : super(false);

  bool get disabled => state;

  set disabled(bool disable) {
    emit(disable);
  }
}

class DisabledBuilder<B extends DisabledCubit, DATA> extends StatelessWidget {
  const new({super.key, this.source, required this.builder});

  final B? source;
  final DisabledWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, bool>(
      bloc: source,
      buildWhen: (previous, current) {
        if (previous != current) {
          return true;
        } else {
          return false;
        }
      },
      builder: builder,
    );
  }
}
