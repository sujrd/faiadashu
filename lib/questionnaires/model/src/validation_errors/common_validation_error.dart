import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class CommonValidationError extends ValidationError {
  final String? message;
  const CommonValidationError(super.nodeUid, this.message);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return message!;
  }
}
