import 'package:flutter_falconx/src/src.dart';

extension ValidateListExtension on List<ValidatorCubit<Object?>> {

  bool get isValid => all((validator) => validator.isValid);

  bool get isInvalid => !isValid;

}
