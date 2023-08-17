import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:faiadashu/resource_provider/resource_provider.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

/// Fill a questionnaire through a wizard-style series of individual questions.
class QuestionnaireStepper extends StatefulWidget {
  final Locale? locale;
  final FhirResourceProvider fhirResourceProvider;
  final LaunchContext launchContext;
  final QuestionnairePageScaffoldBuilder scaffoldBuilder;
  final QuestionnaireModelDefaults questionnaireModelDefaults;
  final PageController? pageController;

  final void Function(QuestionnaireResponseModel?)?
      onQuestionnaireResponseChanged;
  final void Function(int)? onPageChanged;
  final void Function(bool)? onLastPageUpdated;

  const QuestionnaireStepper({
    this.locale,
    required this.scaffoldBuilder,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
    this.onQuestionnaireResponseChanged,
    this.onPageChanged,
    this.onLastPageUpdated,
    this.pageController,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => QuestionnaireStepperState();
}

class QuestionnaireStepperState extends State<QuestionnaireStepper> {
  BuildContext? _itemBuilderContext;
  QuestionnaireResponseModel? _questionnaireResponseModel;
  bool _isLoaded = false;
  bool _lastPageState = false;
  int? _currentIndex;

  void _handleChangedQuestionnaireResponse() {
    widget.onQuestionnaireResponseChanged?.call(_questionnaireResponseModel);
    if (_currentIndex != null) {
      _checkAndUpdatePageState(_currentIndex!);
    }
  }

  bool _hasReachedLastPage(int index) {
    if (_itemBuilderContext == null) {
      return false;
    }
    return QuestionnaireTheme.of(_itemBuilderContext!).stepperPageItemBuilder(
          _itemBuilderContext!,
          QuestionnaireResponseFiller.of(_itemBuilderContext!),
          index + 1,
        ) ==
        null;
  }

  void _checkAndUpdatePageState(int index) {
    final currentState = _hasReachedLastPage(index);
    if (currentState != _lastPageState) {
      widget.onLastPageUpdated?.call(currentState);
      _lastPageState = currentState;
    }
  }

  void _handleChangedPage(int index) {
    _checkAndUpdatePageState(index);
    widget.onPageChanged?.call(index);
    _currentIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.pageController ?? PageController();

    return QuestionnaireResponseFiller(
      locale: widget.locale ?? Localizations.localeOf(context),
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
                child: PageView.builder(
                  /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                  /// Use [Axis.vertical] to scroll vertically.
                  controller: controller,
                  onPageChanged: _handleChangedPage,
                  itemBuilder: (BuildContext context, int index) {
                    _itemBuilderContext = context;
                    return QuestionnaireTheme.of(context).stepperPageItemBuilder(
                      context,
                      QuestionnaireResponseFiller.of(context),
                      index,
                    );
                  },
                  physics: widget.pageController != null
                      ? const NeverScrollableScrollPhysics()
                      : null,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.pageController == null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => controller.previousPage(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 250),
                      ),
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
                              final scoreString = value.value!.round().toString();

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
                  if (widget.pageController == null)
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => controller.nextPage(
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 250),
                      ),
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
