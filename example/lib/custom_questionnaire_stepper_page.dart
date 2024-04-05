import 'package:faiadashu/faiadashu.dart';
import 'package:faiadashu_example/main.dart';
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
  QuestionnaireResponseModel? _questionnaireResponseModel;
  FillerItemModel? _fillerItemFiller;

  void _nextPage() {
    final models = _questionnaireResponseModel?.orderedResponseItemModels();

    // Filter the models to find the ones matching the desired nodeUid
    final matchingItems = models
        ?.where((el) => el.nodeUid == _fillerItemFiller?.nodeUid)
        .toList();

    // If no matching items are found, navigate to the next page
    if (matchingItems == null || matchingItems.isEmpty) {
      _navigateToNextPage();
      return;
    }

    // Validate the first matching item, and if it's valid, navigate to the next page
    final errors = matchingItems.first.validate(notifyListeners: true);
    if (errors.isEmpty) {
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
    // ignore: avoid_print
    print('Page index is changed: $index');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: QuestionnaireStepper(
                scaffoldBuilder: DefaultQuestionnairePageScaffoldBuilder(
                  persistentFooterButtons: [
                    PopupMenuButton<Locale>(
                      icon: const Icon(Icons.language),
                      onSelected: (Locale locale) {
                        LocaleInheritedWidget.of(context).updateLocale(locale);
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<Locale>>[
                        const PopupMenuItem<Locale>(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                        const PopupMenuItem<Locale>(
                          value: Locale('ar'),
                          child: Text('عَرَبِيّ'),
                        ),
                        const PopupMenuItem<Locale>(
                          value: Locale('de'),
                          child: Text('Deutsch'),
                        ),
                        const PopupMenuItem<Locale>(
                          value: Locale('es'),
                          child: Text('Español'),
                        ),
                        const PopupMenuItem<Locale>(
                          value: Locale('ja'),
                          child: Text('日本語'),
                        ),
                      ],
                    ),
                  ],
                ),
                fhirResourceProvider: widget.fhirResourceProvider,
                launchContext: widget.launchContext,
                data: QuestionnaireStepperPageViewData(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  onBeforePageChanged: (currentItemModel, nextItemModel) async {
                    return BeforePageChangedData(canProceed: true);
                  },
                  onVisibleItemUpdated: (item) {
                    _fillerItemFiller = item;
                  },
                ),
                onQuestionnaireResponseChanged: (questionnaireResponseModel) {
                  _questionnaireResponseModel = questionnaireResponseModel;
                },
                onAnswerChanged: (answerModel) {
                  debugPrint("[debug] $answerModel");
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevPage,
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
