import 'package:faiadashu/questionnaires/model/item/src/filler_item_model.dart';
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
  final QuestionnaireStepperPageViewData data;

  const QuestionnaireStepperPageView({
    super.key,
    required this.data,
  });

  static QuestionnaireStepperPageViewData of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<
        _QuestionnaireStepperPageViewInheritedWidget>();
    assert(result != null,
        'No QuestionnaireStepperInheritedWidget found in context',);
    return result!.data;
  }

  @override
  State<QuestionnaireStepperPageView> createState() =>
      _QuestionnaireStepperPageViewState();
}

class _QuestionnaireStepperPageViewState
    extends State<QuestionnaireStepperPageView> {
  final PageController _pageController = PageController();
  bool _hasRequestsRunning = false;
  QuestionnaireItemFiller? _currentQuestionnaireItemFiller;

  @override
  void initState() {
    super.initState();
    widget.data.controller._attach(this);
  }

  bool isUserInteractionAllowed() {
    return _currentQuestionnaireItemFiller?.fillerItemModel.isUserInteractionAllowed ?? true;
  }

  /// Determines if we can proceed to the next page.
  Future<BeforePageChangedData> _onBeforePageChanged() async {
    _hasRequestsRunning = true;
    final currentPage = _pageController.page!.round();
    final themeData = QuestionnaireTheme.of(context);
    final fillerData = QuestionnaireResponseFiller.of(context);

    final nextPageFillerItem = themeData.stepperQuestionnaireItemFiller(
      fillerData,
      currentPage + 1,
    );

    final defaultData = BeforePageChangedData(canProceed: true);

    if (_currentQuestionnaireItemFiller != null) {
      final data = await widget.data.onBeforePageChanged?.call(
        _currentQuestionnaireItemFiller!.fillerItemModel,
        nextPageFillerItem?.fillerItemModel,
      );
      _hasRequestsRunning = false;
      return data ?? defaultData;
    }
    _hasRequestsRunning = false;
    return defaultData;
  }

  /// Updates the currently visible item based on the provided index.
  ///
  /// This ensures that the parent context knows which item is visible and can perform any
  /// necessary actions or updates related to that item.
  void _updateVisibleItem(int index) {
    final responseFiller = QuestionnaireResponseFiller.of(context);

    final data = QuestionnaireTheme.of(context).stepperQuestionnaireItemFiller(
      responseFiller,
      index,
    );

    _currentQuestionnaireItemFiller = data;
    widget.data.onVisibleItemUpdated?.call(data?.fillerItemModel);
  }

  /// Manages tasks related to page index changes.
  ///
  /// This function is called when the user navigates to a different page.
  /// It updates the visible item, and notifies listeners of the change.
  void _handleChangedPage(int index) {
    _updateVisibleItem(index);
    widget.data.onPageChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return _QuestionnaireStepperPageViewInheritedWidget(
      data: widget.data,
      child: PageView.builder(
        /// [PageView.scrollDirection] defaults to [Axis.horizontal].
        /// Use [Axis.vertical] to scroll vertically.
        controller: _pageController,
        onPageChanged: _handleChangedPage,
        itemBuilder: (BuildContext context, int index) {
          final responseFillerData = QuestionnaireResponseFiller.of(context);

          final data =
              QuestionnaireTheme.of(context).stepperQuestionnaireItemFiller(
            responseFillerData,
            index,
          );

          _updateVisibleItem(index);
          if (data == null) return null;

          return QuestionnaireTheme.of(context).stepperPageItemBuilder(
            context,
            data,
          );
        },
        physics: widget.data.physics,
      ),
    );
  }

  @override
  void dispose() {
    widget.data.controller._detach();
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
  // ignore: use_setters_to_change_properties
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
  Future nextPage({Duration? duration, Curve? curve}) async {
    /// This will prevent racing issue
    if (_state?._hasRequestsRunning ?? false) {
      return;
    }

    if (_state?.isUserInteractionAllowed() == false) {
      return;
    }

    final data = await _state?._onBeforePageChanged();
    if (data?.canProceed ?? true) {
      _state?._pageController.nextPage(
        curve: curve ?? Curves.easeIn,
        duration: duration ?? const Duration(milliseconds: 250),
      );
    }
  }

  /// Back to the previous page in the `QuestionnaireStepperPageView`.
  void previousPage({Duration? duration, Curve? curve}) {
    /// This will prevent racing issue
    if (_state?._hasRequestsRunning ?? false) {
      return;
    }

    if (_state?.isUserInteractionAllowed() ?? false) {
      return;
    }

    _state?._pageController.previousPage(
      curve: curve ?? Curves.easeIn,
      duration: duration ?? const Duration(milliseconds: 250),
    );
  }

  /// Jump to specific page in the `QuestionnaireStepperPageView`.
  void jumpToPage(int page) {
    /// This will prevent racing issue
    if (_state?._hasRequestsRunning ?? false) {
      return;
    }
    _state?._pageController.jumpToPage(page);
  }

  /// Animated transition to specific page in the `QuestionnaireStepperPageView`.
  void animateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeIn,
  }) {
    /// This will prevent racing issue
    if (_state?._hasRequestsRunning ?? false) {
      return;
    }
    _state?._pageController.animateToPage(
      page,
      duration: duration,
      curve: curve,
    );
  }
}

/// This class is used in conjunction with the [OnBeforePageChanged] callback,
/// and currently allows you to specify whether the page transition can proceed
/// based on custom logic. This class can be extended to include more properties
/// that could affect page navigation.
class BeforePageChangedData {
  final bool canProceed;

  BeforePageChangedData({
    required this.canProceed,
  });
}

// ignore: prefer-single-widget-per-file
class _QuestionnaireStepperPageViewInheritedWidget extends InheritedWidget {
  final QuestionnaireStepperPageViewData data;

  const _QuestionnaireStepperPageViewInheritedWidget({
    required super.child,
    required this.data,
  });

  @override
  bool updateShouldNotify(
    _QuestionnaireStepperPageViewInheritedWidget oldWidget,
  ) {
    return data != oldWidget.data;
  }
}

// ignore: prefer-single-widget-per-file
class QuestionnaireStepperPageViewData {
  late final QuestionnaireStepperPageViewController controller;
  final ScrollPhysics? physics;
  final ValueChanged<int>? onPageChanged;
  final Future<BeforePageChangedData> Function(
    FillerItemModel,
    FillerItemModel?,
  )? onBeforePageChanged;
  final void Function(FillerItemModel?)? onVisibleItemUpdated;

  QuestionnaireStepperPageViewData({
    QuestionnaireStepperPageViewController? controller,
    this.physics,
    this.onPageChanged,
    this.onBeforePageChanged,
    this.onVisibleItemUpdated,
  }) {
    this.controller = controller ?? QuestionnaireStepperPageViewController();
  }
}
