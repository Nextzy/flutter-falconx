import 'package:flutter_falconx/lib.dart';

extension ValidateListExtension on List<ValidatorCubit> {

  bool get isValid => all((validator) => validator.isValid);

  bool get isInvalid => !isValid;

}
