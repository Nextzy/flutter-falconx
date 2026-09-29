import 'package:flutter_falconx/src/src.dart';

extension ValidateListExtension on List<ValidatorCubit> {

  bool get isValid => all((validator) => validator.isValid);

  bool get isInvalid => !isValid;

}
