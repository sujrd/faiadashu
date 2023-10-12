import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MinLengthError extends ValidationError {
  final int minLength;
  MinLengthError(String nodeUid, this.minLength) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMinLength(minLength);
  }
}
