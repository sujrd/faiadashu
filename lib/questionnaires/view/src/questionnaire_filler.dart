import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:faiadashu/resource_provider/resource_provider.dart';
import 'package:fhir/r4/r4.dart';
import 'package:flutter/material.dart';

/// Fill a [QuestionnaireResponse] from a [Questionnaire].
///
/// Provides visual components to view a [Questionnaire] and fill a [QuestionnaireResponse].
/// The components are provided as a [List] of [Widget]s of type [QuestionnaireItemFiller].
/// It is up to a higher-level component to present these to the user.
///
/// see: [QuestionnaireScrollerPage]
/// see: [QuestionnaireStepperPage]
class QuestionnaireResponseFiller extends StatefulWidget {
  final WidgetBuilder builder;
  final List<Aggregator<dynamic>>? aggregators;
  final void Function(BuildContext context, Uri url)? onLinkTap;
  final void Function(QuestionnaireResponseModel)? onDataAvailable;
  final QuestionnaireThemeData questionnaireTheme;
  final QuestionnaireModelDefaults questionnaireModelDefaults;

  final FhirResourceProvider fhirResourceProvider;
  final LaunchContext launchContext;

  Future<QuestionnaireResponseModel> _createQuestionnaireResponseModel({
    required BuildContext context,
  }) async =>
      QuestionnaireResponseModel.fromFhirResourceBundle(
          locale: Localizations.localeOf(context),
          aggregators: aggregators,
          fhirResourceProvider: fhirResourceProvider,
          launchContext: launchContext,
          questionnaireModelDefaults: questionnaireModelDefaults,
          localizations: FDashLocalizations.of(context));

  const QuestionnaireResponseFiller({
    Key? key,
    required this.builder,
    required this.fhirResourceProvider,
    required this.launchContext,
    this.aggregators,
    this.onDataAvailable,
    this.onLinkTap,
    this.questionnaireTheme = const QuestionnaireThemeData(),
    this.questionnaireModelDefaults = const QuestionnaireModelDefaults(),
  }) : super(key: key);

  static QuestionnaireFillerData of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<QuestionnaireFillerData>();
    assert(result != null, 'No QuestionnaireFillerData found in context');

    return result!;
  }

  @override
  // ignore: library_private_types_in_public_api
  _QuestionnaireResponseFillerState createState() =>
      _QuestionnaireResponseFillerState();
}

class _QuestionnaireResponseFillerState
    extends State<QuestionnaireResponseFiller> {
  static final _logger = Logger(_QuestionnaireResponseFillerState);

  QuestionnaireResponseModel? _questionnaireResponseModel;
  VoidCallback? _handleQuestionnaireResponseModelChangeListenerFunction;
  // ignore: use_late_for_private_fields_and_variables
  QuestionnaireFillerData? _questionnaireFillerData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _logger.trace('dispose');

    final qrmListener = _handleQuestionnaireResponseModelChangeListenerFunction;

    if (qrmListener != null) {
      _questionnaireResponseModel?.structuralChangeNotifier.removeListener(
        qrmListener,
      );
    }
    _questionnaireResponseModel = null;
    _handleQuestionnaireResponseModelChangeListenerFunction = null;

    super.dispose();
  }

  void _handleQuestionnaireResponseModelStructuralChange() {
    _logger
        .debug('Response model structure has changed. Updating filler views.');

    if (mounted) {
      // This operation is very expensive. Make sure the code only reaches it
      // when something truly relevant has changed.
      setState(
        () {
          _questionnaireFillerData = QuestionnaireFillerData._(
            _questionnaireResponseModel!,
            builder: widget.builder,
            onLinkTap: widget.onLinkTap,
            onDataAvailable: widget.onDataAvailable,
            questionnaireTheme: widget.questionnaireTheme,
          );
        },
      );

      // Trigger animation effects for newly added items.
      // Can only be done after initial frame has been drawn.
      // This way AnimationXXX Widgets start out in the `adding` state and then
      // animate towards the fully visible `present` state.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _questionnaireResponseModel?.structuralNextGeneration();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.trace('Enter build()');

    return FutureBuilder<QuestionnaireResponseModel>(
      future: widget._createQuestionnaireResponseModel(context: context),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            // This should never happen in our use-case (is for streaming)
            _logger.warn('FutureBuilder is active...');
            return QuestionnaireLoadingIndicator(snapshot);
          case ConnectionState.none:
            return QuestionnaireLoadingIndicator(snapshot);
          case ConnectionState.waiting:
            _logger.debug('FutureBuilder still waiting for data...');
            return QuestionnaireLoadingIndicator(snapshot);
          case ConnectionState.done:
            if (snapshot.hasError) {
              _logger.warn('FutureBuilder hasError', error: snapshot.error);

              return QuestionnaireLoadingIndicator(snapshot);
            }
            if (snapshot.hasData) {
              _logger.debug('FutureBuilder hasData');
              _questionnaireResponseModel = snapshot.data;

              // OPTIMIZE: There has got to be a more elegant way? Goal is to register the listener exactly once, after the future has completed.
              if (_handleQuestionnaireResponseModelChangeListenerFunction ==
                  null) {
                _handleQuestionnaireResponseModelChangeListenerFunction =
                    () => _handleQuestionnaireResponseModelStructuralChange();
                _questionnaireResponseModel?.structuralChangeNotifier
                    .addListener(
                  _handleQuestionnaireResponseModelChangeListenerFunction!,
                );

                _questionnaireFillerData = QuestionnaireFillerData._(
                  _questionnaireResponseModel!,
                  builder: widget.builder,
                  onLinkTap: widget.onLinkTap,
                  onDataAvailable: widget.onDataAvailable,
                  questionnaireTheme: widget.questionnaireTheme,
                );
              }

              return _questionnaireFillerData!;
            }
            throw StateError(
              'FutureBuilder snapshot has unexpected state: $snapshot',
            );
        }
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class QuestionnaireFillerData extends InheritedWidget {
  static final _logger = Logger(QuestionnaireFillerData);

  final QuestionnaireResponseModel questionnaireResponseModel;
  // TODO: Should this copy exist, or just refer to the qrm as the source of truth?
  final List<FillerItemModel> fillerItemModels;

  final void Function(BuildContext context, Uri url)? onLinkTap;
  final void Function(QuestionnaireResponseModel)? onDataAvailable;
  final QuestionnaireThemeData questionnaireTheme;
  late final List<QuestionnaireItemFiller?> _itemFillers;
  final Map<String, QuestionnaireItemFillerState> _itemFillerStates = {};
  late final int _generation;

  QuestionnaireFillerData._(
    this.questionnaireResponseModel, {
    Key? key,
    this.onDataAvailable,
    this.onLinkTap,
    required this.questionnaireTheme,
    required WidgetBuilder builder,
  })  : _generation = questionnaireResponseModel.generation,
        fillerItemModels = questionnaireResponseModel.orderedFillerItemModels(),
        _itemFillers = List<QuestionnaireItemFiller?>.filled(
          questionnaireResponseModel.orderedFillerItemModels().length,
          null,
        ),
        super(key: key, child: Builder(builder: builder)) {
    _logger.trace('constructor _');
    onDataAvailable?.call(questionnaireResponseModel);
  }

  /// INTERNAL USE ONLY: Register a [QuestionnaireItemFillerState].
  void registerQuestionnaireItemFillerState(QuestionnaireItemFillerState qifs) {
    _itemFillerStates[qifs.responseUid] = qifs;
  }

  /// INTERNAL USE ONLY: Unregister a [QuestionnaireItemFillerState].
  void unregisterQuestionnaireItemFillerState(
    QuestionnaireItemFillerState qifs,
  ) {
    _itemFillerStates.remove(qifs.responseUid);
  }

  T aggregator<T extends Aggregator>() {
    return questionnaireResponseModel.aggregator<T>();
  }

  /// Requests focus on a [QuestionnaireItemFiller].
  ///
  /// The item filler will be determined as by [itemFillerAt].
  void requestFocus(int index) {
    assert(index >= 0);
    _logger.trace('requestFocus $index');
    final fillerUid = fillerItemModels.elementAt(index).nodeUid;
    final itemFillerState = _itemFillerStates[fillerUid];
    if (itemFillerState == null) {
      _logger.warn('requestFocus $index: itemFillerState == null');
    } else {
      itemFillerState.requestFocus();
    }
  }

  /// Returns the [QuestionnaireItemFiller] at [index].
  ///
  /// The [QuestionnaireItemFiller]s are ordered based on 'pre-order'.
  ///
  /// see: https://en.wikipedia.org/wiki/Tree_traversal#Pre-order,_NLR
  QuestionnaireItemFiller itemFillerAt(BuildContext context, int index) {
    _logger.trace('itemFillerAt $index');
    final item = _itemFillers[index];

    if (item == null) {
      _logger.debug('itemFillerAt $index will be created.');
      _itemFillers[index] = questionnaireTheme.createQuestionnaireItemFiller(
        this,
        fillerItemModels.elementAt(index),
        Localizations.localeOf(context),
        key: ValueKey<String>(
          'item-filler-${fillerItemModels.elementAt(index).nodeUid}',
        ),
      );
    } else {
      _logger.debug('itemFillerAt $index already exists.');
    }

    return _itemFillers[index]!;
  }

  /// Returns the index of the [visibleIndex]-th item that is currently visible, taking into
  /// account items shown/hidden due to SDC hidden extensions, enableWhen clauses, etc.
  ///
  /// If [rootsOnly] is true, it will return the index of the [visibleIndex]-th root item
  /// that is currently visible.
  int indexOfVisibleItemAt(int visibleIndex, {bool rootsOnly = false}) {
    final visibleItems = fillerItemModels
        .where((item) => item.displayVisibility != DisplayVisibility.hidden)
        .where((item) => !rootsOnly || item.parentNode == null)
        .toList(growable: false);

    return visibleItems.length > visibleIndex
        ? fillerItemModels.indexOf(visibleItems[visibleIndex])
        : -1;
  }

  /// Returns the [QuestionnaireItemFiller] of the [visibleIndex]-th item that is currently
  /// visible.
  QuestionnaireItemFiller? visibleItemFillerAt(
      BuildContext context, int visibleIndex) {
    final index = indexOfVisibleItemAt(visibleIndex);

    return index < 0 ? null : itemFillerAt(context, index);
  }

  /// Returns the integer range of items corresponding to the [visibleRootIndex]-th root item
  /// that is currently visible and its nested subitems.
  List<int> itemRangeOfVisibleRootItemAt(int visibleRootIndex) {
    final rootIndex = indexOfVisibleItemAt(visibleRootIndex, rootsOnly: true);
    if (rootIndex < 0) return [-1, -1];

    final descendantsCount = fillerItemModels
        .where((item) => item.rootNode == fillerItemModels[rootIndex])
        .length;

    return [rootIndex, rootIndex + descendantsCount + 1];
  }

  @override
  bool updateShouldNotify(QuestionnaireFillerData oldWidget) {
    final shouldNotify = oldWidget._generation != _generation;
    _logger.debug('updateShouldNotify: $shouldNotify');

    return shouldNotify;
  }
}
