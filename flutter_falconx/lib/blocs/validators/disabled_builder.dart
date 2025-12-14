// Ignore because is not necessary
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_falconx/lib.dart';

typedef DisabledWidgetBuilder =
    Widget Function(
      BuildContext context,
      bool disabled,
    );

class DisabledCubit extends Cubit<bool> {
  DisabledCubit() : super(false);

  bool get disabled => state;

  set disabled(bool disable) {
    emit(disable);
  }
}

class DisabledBuilder<B extends DisabledCubit, DATA> extends StatelessWidget {
  const DisabledBuilder({
    super.key,
    this.source,
    required this.builder,
  });

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
