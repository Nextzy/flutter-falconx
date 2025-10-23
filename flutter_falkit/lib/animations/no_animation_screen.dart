import 'package:flutter_falkit/lib.dart';

class NoAnimationPage extends MaterialPageRoute<dynamic> {
  NoAnimationPage({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }
}
