import 'package:faiadashu/questionnaires/view/item/src/questionnaire_item_filler.dart';
import 'package:faiadashu/questionnaires/view/src/questionnaire_filler.dart';
import 'package:faiadashu/questionnaires/view/src/questionnaire_theme.dart';
import 'package:flutter/material.dart';

/// A specialized `PageView` designed to display a series of questions
/// in a step-by-step format.
///
/// [QuestionnaireStepperPageView] seamlessly integrates with [QuestionnaireStepperPageViewController]
/// to parent widget navigating the page view, or retrieve information related the view.
class QuestionnaireStepperPageView extends StatefulWidget {
  final QuestionnaireStepperPageViewController? controller;
  final ValueChanged<int>? onPageChanged;
  final Function(bool)? onLastPageUpdated;
  final void Function(QuestionnaireItemFiller?)? onVisibleItemUpdated;

  QuestionnaireStepperPageView({
    this.controller,
    this.onPageChanged,
    this.onLastPageUpdated,
    this.onVisibleItemUpdated,
  });

  @override
  _QuestionnaireStepperPageViewState createState() =>
      _QuestionnaireStepperPageViewState();
}

class _QuestionnaireStepperPageViewState extends State<QuestionnaireStepperPageView> {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
  }

  /// Determines if the given index corresponds to the last page.
  bool _hasReachedLastPage() {
    final currentPage = _pageController.page!.round();
    final themeData = QuestionnaireTheme.of(context);
    final fillerData = QuestionnaireResponseFiller.of(context);

    /// By checking the next item from the item builder, it verifies whether we're on the last page.
    /// If there's no item for the next index, then we've reached the last page.
    return themeData.stepperQuestionnaireItemFiller(
      fillerData,
      currentPage + 1,
    ) == null;
  }

  /// Updates the currently visible item based on the provided index.
  ///
  /// This ensures that the parent context knows which item is visible and can perform any
  /// necessary actions or updates related to that item.
  void _updateVisibleItem(int index) {
    final responseFiller = QuestionnaireResponseFiller.of(context);

    widget.onVisibleItemUpdated?.call(responseFiller.visibleItemFillerAt(index));
  }

  /// Manages tasks related to page index changes.
  ///
  /// This function is called when the user navigates to a different page.
  /// It updates the visible item, checks the state of the last page, notifies listeners
  /// of the change, and updates the current index.
  void _handleChangedPage(int index) {
    _updateVisibleItem(index);
    widget.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      /// [PageView.scrollDirection] defaults to [Axis.horizontal].
      /// Use [Axis.vertical] to scroll vertically.
      controller: _pageController,
      onPageChanged: _handleChangedPage,
      itemBuilder: (BuildContext context, int index) {
        final responseFillerData = QuestionnaireResponseFiller.of(context);

        final data = QuestionnaireTheme.of(context)
            .stepperQuestionnaireItemFiller(responseFillerData, index);

        _updateVisibleItem(index);
        if (data == null) return null;

        return QuestionnaireTheme.of(context).stepperPageItemBuilder(
          context,
          data,
        );
      },
      physics: widget.controller != null
          ? const NeverScrollableScrollPhysics()
          : null,
    );
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }
}

/// A controller designed to be used with [QuestionnaireStepperPageView] to
/// manage the display and flow of questionnaire steps.
///
/// It provides methods and properties to control the form.
class QuestionnaireStepperPageViewController {
  _QuestionnaireStepperPageViewState? _state;

  /// Attaches the provided state to this controller.
  /// This internal method is used to establish a connection between the
  /// controller and the `_QuestionnaireStepperPageViewState`.
  void _attach(_QuestionnaireStepperPageViewState state) {
    _state = state;
  }

  /// Detaches the state from this controller.
  /// This is usually called when the associated `QuestionnaireStepperPageView`
  /// is getting disposed to avoid any potential memory leaks or unintended behaviors.
  void _detach() {
    _state = null;
  }

  /// Advances to the next page in the `QuestionnaireStepperPageView`.
  void nextPage() {
    _state?._pageController.nextPage(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// Back to the previous page in the `QuestionnaireStepperPageView`.
  void previousPage() {
    _state?._pageController.previousPage(
      curve: Curves.easeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// Checks if the current page in the `QuestionnaireStepperPageView` is the last one.
  ///
  /// Returns `true` if the last page has been reached, otherwise returns `false`.
  bool hasReachedLastPage() {
    return _state?._hasReachedLastPage() ?? false;
  }
}