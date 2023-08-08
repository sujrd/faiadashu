import 'package:faiadashu/faiadashu.dart';
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
  final _pageController = PageController();
  int _currentIndex = 0;
  QuestionnaireResponseModel? _questionnaireResponseModel;

  void _nextPage() {
    final item = _questionnaireResponseModel
        ?.orderedResponseItemModels()
        .elementAt(_currentIndex);
    if (item?.validate(notifyListeners: true) == null) {
      _pageController.nextPage(
        curve: Curves.easeIn,
        duration: const Duration(milliseconds: 250),
      );
    }
  }

  void _prevPage() {
    _pageController.previousPage(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  bool _hasReachedLastPage() {
    final totalPage =
        _questionnaireResponseModel?.orderedFillerItemModels().length ?? 0;
    return _currentIndex == totalPage - 1;
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
                pageController: _pageController,
                onQuestionnaireResponseChanged: (questionnaireResponseModel) {
                  _questionnaireResponseModel = questionnaireResponseModel;
                },
                onPageChanged: _onPageChanged,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
                ),
                if (_hasReachedLastPage())
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
