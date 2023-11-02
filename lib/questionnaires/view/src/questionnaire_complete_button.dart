import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart'
    show QuestionnaireResponseFiller;
import 'package:fhir/r4.dart' show FhirCode;
import 'package:flutter/material.dart';

/// A button to complete a questionnaire.
///
/// Toggles from Complete / In-Progress
/// Requires a [QuestionnaireResponseFiller]
class QuestionnaireCompleteButton extends StatefulWidget {
  final VoidCallback? onCompleted;

  const QuestionnaireCompleteButton({this.onCompleted, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuestionnaireCompleteButtonState createState() =>
      _QuestionnaireCompleteButtonState();
}

class _QuestionnaireCompleteButtonState
    extends State<QuestionnaireCompleteButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        final qf = QuestionnaireResponseFiller.of(context);
        final qrm = qf.questionnaireResponseModel;
        final currentResponseStatus = qrm.responseStatus;

        if (currentResponseStatus != FhirCode('completed')) {
          final validationErrors = qrm.validate(
            notifyListeners: true,
          );
          qrm.invalidityNotifier.value = {
            for (var validation in validationErrors)
              validation.nodeUid:
                  validation.getMessage(FDashLocalizations.of(context)) ?? ""
          };

          if (validationErrors.isNotEmpty) {
            return;
          }
        }

        final newResponseStatus =
            (currentResponseStatus == FhirCode('completed'))
                ? FhirCode('in-progress')
                : FhirCode('completed');

        setState(() {
          qrm.responseStatus = newResponseStatus;
        });

        if (newResponseStatus == FhirCode('completed')) {
          widget.onCompleted?.call();
        }
      },
      icon: (QuestionnaireResponseFiller.of(context)
                  .questionnaireResponseModel
                  .responseStatus !=
              FhirCode('completed'))
          ? const Icon(Icons.check_circle)
          : const Icon(Icons.edit),
      label: (QuestionnaireResponseFiller.of(context)
                  .questionnaireResponseModel
                  .responseStatus !=
              FhirCode('completed'))
          ? Text(
              FDashLocalizations.of(context)
                  .responseStatusToCompleteButtonLabel,
            )
          : Text(
              FDashLocalizations.of(context)
                  .responseStatusToInProgressButtonLabel,
            ),
    );
  }
}
