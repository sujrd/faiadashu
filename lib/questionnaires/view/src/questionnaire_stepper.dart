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
  final void Function(QuestionnaireItemFiller?)? onVisibleItemUpdated;

  const QuestionnaireStepper({
    this.locale,
    required this.scaffoldBuilder,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
    this.onQuestionnaireResponseChanged,
    this.onPageChanged,
    this.onLastPageUpdated,
    this.onVisibleItemUpdated,
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

  /// Notifies listeners when there are changes in the questionnaire response.
  void _handleChangedQuestionnaireResponse() {
    widget.onQuestionnaireResponseChanged?.call(_questionnaireResponseModel);
    if (_currentIndex != null) {
      _checkAndUpdatePageState(_currentIndex!);
    }
  }

  /// Determines if the given index corresponds to the last page.
  bool _hasReachedLastPage(int index) {
    if (_itemBuilderContext == null) {
      return false;
    }
    /// By checking the next item from the item builder, it verifies whether we're on the last page.
    /// If there's no item for the next index, then we've reached the last page.
    return QuestionnaireTheme.of(_itemBuilderContext!).stepperPageItemBuilder(
          _itemBuilderContext!,
          QuestionnaireResponseFiller.of(_itemBuilderContext!),
          index + 1,
        ) ==
        null;
  }

  /// Checks the current page status and updates the last page state accordingly.
  void _checkAndUpdatePageState(int index) {
    final currentState = _hasReachedLastPage(index);
    /// If the current state differs from the last known page state, listeners are notified.
    if (currentState != _lastPageState) {
      widget.onLastPageUpdated?.call(currentState);
      _lastPageState = currentState;
    }
  }

  /// Updates the currently visible item based on the provided index.
  ///
  /// This ensures that the parent context knows which item is visible and can perform any
  /// necessary actions or updates related to that item.
  void _updateVisibleItem(int index) {
    if (_itemBuilderContext == null) {
      return;
    }
    final responseFiller = QuestionnaireResponseFiller.of(_itemBuilderContext!);

    widget.onVisibleItemUpdated?.call(responseFiller.visibleItemFillerAt(index));
  }

  /// Manages tasks related to page index changes.
  ///
  /// This function is called when the user navigates to a different page.
  /// It updates the visible item, checks the state of the last page, notifies listeners
  /// of the change, and updates the current index.
  void _handleChangedPage(int index) {
    _updateVisibleItem(index);
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
                    // Store the current context of the item builder.
                    // This is done so that we can access this context outside the builder.
                    _itemBuilderContext = context;
                    // Update the state or properties associated with the currently visible item.
                    _updateVisibleItem(index);
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
