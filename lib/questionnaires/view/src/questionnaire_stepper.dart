import 'package:collection/collection.dart';
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
  final bool showGroupsAsSingleSteps;

  const QuestionnaireStepper({
    this.locale,
    required this.scaffoldBuilder,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
    this.showGroupsAsSingleSteps = false,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => QuestionnaireStepperState();
}

class QuestionnaireStepperState extends State<QuestionnaireStepper> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PageView.builder(
                    /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                    /// Use [Axis.vertical] to scroll vertically.
                    controller: controller,
                    itemBuilder: (BuildContext context, int pageIndex) {
                      final responseFiller = QuestionnaireResponseFiller.of(context);
                      final questionnaireTheme = QuestionnaireTheme.of(context);

                      final showGroupsAsSingleSteps = widget.showGroupsAsSingleSteps
                        || questionnaireTheme.stepperGroupDisplayPreference == StepperGroupDisplayPreference.grouped;

                      int currentPage = -1;
                      int rootNodeIndex = -1;

                      final rootNode = responseFiller.fillerItemModels
                        .firstWhereIndexedOrNull((index, element) {
                          if (
                            element.displayVisibility != DisplayVisibility.hidden
                            && (!showGroupsAsSingleSteps || element.parentNode == null)
                          ) {
                            currentPage++;
                            rootNodeIndex = index;
                          }

                          return currentPage == pageIndex;
                        });

                      if (rootNode == null) return null;
                      if (!showGroupsAsSingleSteps) return responseFiller.itemFillerAt(rootNodeIndex);

                      final descendantsCount = responseFiller.fillerItemModels
                        .where((element) => element.rootNode == rootNode)
                        .length;

                      return ListView.builder(
                        itemCount: descendantsCount + 1,
                        itemBuilder: (context, index) => responseFiller.itemFillerAt(rootNodeIndex + index),
                      );
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
    );
  }
}
