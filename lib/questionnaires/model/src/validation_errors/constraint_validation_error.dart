import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class ConstraintValidationError extends ValidationError {
  final String? message;
  const ConstraintValidationError(String nodeUid, this.message)
      : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return message;
  }
}
