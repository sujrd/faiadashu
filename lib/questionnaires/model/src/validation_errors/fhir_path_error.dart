import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir_path/fhir_path.dart';

class FhirPathError extends ValidationError {
  final FhirPathEvaluationException exception;

  const FhirPathError(String nodeUid, this.exception) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return exception.message;
  }
}
