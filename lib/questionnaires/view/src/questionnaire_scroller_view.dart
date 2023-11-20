import 'package:faiadashu/faiadashu.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuestionnaireScrollerView extends StatefulWidget {
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final Widget Function(BuildContext, int) itemBuilder;

  const QuestionnaireScrollerView({
    super.key,
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.itemBuilder,
  });

  @override
  State<QuestionnaireScrollerView> createState() =>
      _QuestionnaireScrollerViewState();
}

class _QuestionnaireScrollerViewState extends State<QuestionnaireScrollerView> {
  final _scrollOffsetController = ScrollOffsetController();

  double _buttonOpacity = 0.0;
  bool _showScrollDownButton = false;

  @override
  void initState() {
    super.initState();
    widget.itemPositionsListener.itemPositions
        .addListener(_updateButtonVisibility);
  }

  @override
  void dispose() {
    super.dispose();
    widget.itemPositionsListener.itemPositions
        .removeListener(_updateButtonVisibility);
  }

  void _updateButtonVisibility() {
    final items = QuestionnaireResponseFiller.of(context).fillerItemModels;
    final positions = widget.itemPositionsListener.itemPositions.value;
    // Check if the bottom of the list is visible
    final isEndVisible = positions.any(
      (ItemPosition position) =>
          position.index == items.length - 1 && position.itemTrailingEdge <= 1,
    );

    final newValue = isEndVisible ? 0.0 : 1.0;
    if (_buttonOpacity != newValue) {
      setState(() {
        _buttonOpacity = newValue;
        _showScrollDownButton = true;
      });
    }
  }

  void _scrollToBottomItem() {
    _scrollOffsetController.animateScroll(
      offset: 250,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onAnimationEnded() {
    setState(() {
      _showScrollDownButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        QuestionnaireResponseFiller.of(context).fillerItemModels.length;

    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemScrollController: widget.itemScrollController,
          itemPositionsListener: widget.itemPositionsListener,
          scrollOffsetController: _scrollOffsetController,
          itemCount: itemCount,
          itemBuilder: (context, index) => widget.itemBuilder(context, index),
          padding: const EdgeInsets.all(8.0),
          minCacheExtent: 200,
        ),
        if (_showScrollDownButton &&
            QuestionnaireTheme.of(context).showScrollDownButton)
          QuestionnaireTheme.of(context).scrollDownButton(
            context,
            _buttonOpacity,
            _onAnimationEnded,
            _scrollToBottomItem,
          ),
      ],
    );
  }
}
