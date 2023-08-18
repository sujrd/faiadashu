import 'package:faiadashu/faiadashu.dart';
import 'package:faiadashu/questionnaires/view/src/questionnaire_stepper_page_view.dart';
import 'package:flutter/material.dart';

class CustomQuestionnaireStepperPage extends StatefulWidget {
  final Locale? locale;
  final FhirResourceProvider fhirResourceProvider;
  final LaunchContext launchContext;
  final QuestionnaireModelDefaults questionnaireModelDefaults;

  const CustomQuestionnaireStepperPage({
    super.key,
    this.locale,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
  });

  @override
  State<CustomQuestionnaireStepperPage> createState() =>
      _CustomQuestionnaireStepperPageState();
}

class _CustomQuestionnaireStepperPageState
    extends State<CustomQuestionnaireStepperPage> {
  final _controller = QuestionnaireStepperPageViewController();
  bool _hasReachedLastPage = false;
  QuestionnaireResponseModel? _questionnaireResponseModel;
  QuestionnaireItemFiller? _questionnaireItemFiller;

  void _nextPage() {
    final models = _questionnaireResponseModel?.orderedResponseItemModels();

    // Filter the models to find the ones matching the desired nodeUid
    final matchingItems = models?.where((el) => el.nodeUid == _questionnaireItemFiller?.responseUid).toList();

    // If no matching items are found, navigate to the next page
    if (matchingItems == null || matchingItems.isEmpty) {
      _navigateToNextPage();
      return;
    }

    // Validate the first matching item, and if it's valid, navigate to the next page
    if (matchingItems.first.validate(notifyListeners: true) == null) {
      _navigateToNextPage();
    }
  }

  void _navigateToNextPage() {
    _controller.nextPage();
  }
  void _prevPage() {
    _controller.previousPage();
  }

  void _onPageChanged(int index) {
    print('Page index is changed: $index');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: QuestionnaireStepper(
                scaffoldBuilder:
                    const DefaultQuestionnairePageScaffoldBuilder(),
                fhirResourceProvider: widget.fhirResourceProvider,
                launchContext: widget.launchContext,
                controller: _controller,
                onQuestionnaireResponseChanged: (questionnaireResponseModel) {
                  _questionnaireResponseModel = questionnaireResponseModel;
                },
                onPageChanged: _onPageChanged,
                onLastPageUpdated: (bool hasReachedLastPage) {
                  setState(() {
                    _hasReachedLastPage = hasReachedLastPage;
                  });
                },
                onVisibleItemUpdated: (item) {
                  _questionnaireItemFiller = item;
                }
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                ),
                if (_hasReachedLastPage)
                  const Text(
                    "Reached Last Page",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextPage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
