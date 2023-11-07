import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MimeTypesError extends ValidationError {
  final List<String> mimeTypes;
  MimeTypesError(super.nodeUid, this.mimeTypes);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMimeTypes(mimeTypes.join(","));
  }
}
