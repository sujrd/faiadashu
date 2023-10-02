import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MimeTypesError extends ValidationError {
  final List<String> mimeTypes;
  MimeTypesError(String nodeUid, this.mimeTypes) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMimeTypes(mimeTypes.join(","));
  }
}
