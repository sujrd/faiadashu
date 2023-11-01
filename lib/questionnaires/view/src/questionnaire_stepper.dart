import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:faiadashu/resource_provider/resource_provider.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

/// Fill a questionnaire through a wizard-style series of individual questions.
class QuestionnaireStepper extends StatefulWidget {
  final FhirResourceProvider fhirResourceProvider;
  final LaunchContext launchContext;
  final QuestionnairePageScaffoldBuilder scaffoldBuilder;
  final QuestionnaireModelDefaults questionnaireModelDefaults;
  final QuestionnaireStepperPageViewData? data;

  final void Function(QuestionnaireResponseModel?)?
      onQuestionnaireResponseChanged;

  const QuestionnaireStepper({
    super.key,
    required this.scaffoldBuilder,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.data,
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
    this.onQuestionnaireResponseChanged,
  });

  @override
  State<StatefulWidget> createState() => QuestionnaireStepperState();
}

class QuestionnaireStepperState extends State<QuestionnaireStepper> {
  late QuestionnaireStepperPageViewController _controller;
  QuestionnaireResponseModel? _questionnaireResponseModel;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.data?.controller ?? QuestionnaireStepperPageViewController();
  }

  /// Notifies listeners when there are changes in the questionnaire response.
  void _handleChangedQuestionnaireResponse() {
    widget.onQuestionnaireResponseChanged?.call(_questionnaireResponseModel);
  }

  @override
  Widget build(BuildContext context) {
    return QuestionnaireResponseFiller(
      fhirResourceProvider: widget.fhirResourceProvider,
      launchContext: widget.launchContext,
      questionnaireModelDefaults: widget.questionnaireModelDefaults,
      builder: (BuildContext context) {
        return widget.scaffoldBuilder.build(
          context,
          setStateCallback: (fn) => setState(fn),
          child: Column(
            children: [
              Expanded(
                child: QuestionnaireStepperPageView(
                  data: widget.data ??
                      QuestionnaireStepperPageViewData(
                        controller: _controller,
                      ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.data?.controller == null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _controller.previousPage(),
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        if (QuestionnaireTheme.of(context).showScore)
                          ValueListenableBuilder<Decimal>(
                            builder: (
                              BuildContext context,
                              Decimal value,
                              Widget? child,
                            ) {
                              final scoreString =
                                  value.value!.round().toString();

                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  FDashLocalizations.of(context)
                                      .aggregationScore(scoreString),
                                  key: ValueKey<String>(scoreString),
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              );
                            },
                            valueListenable:
                                QuestionnaireResponseFiller.of(context)
                                    .aggregator<TotalScoreAggregator>(),
                          ),
                        if (QuestionnaireTheme.of(context).showProgress)
                          const QuestionnaireFillerProgressBar(),
                      ],
                    ),
                  ),
                  if (widget.data?.controller == null)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => _controller.nextPage(),
                    ),
                ],
              ),
            ],
          ),
        );
      },
      // TODO: Refactor some of this logic with QuestionnaireScroller
      onDataAvailable: (questionnaireResponseModel) {
        // Upon initial load: Locate the first unanswered or invalid question
        if (!_isLoaded) {
          _isLoaded = true;

          _questionnaireResponseModel = questionnaireResponseModel;

          if (widget.onQuestionnaireResponseChanged != null) {
            // Broadcast initial response state.
            _handleChangedQuestionnaireResponse();

            // FIXME: What is this listening for???
            _questionnaireResponseModel?.valueChangeNotifier
                .addListener(_handleChangedQuestionnaireResponse);
          }
        }
      },
    );
  }
}
