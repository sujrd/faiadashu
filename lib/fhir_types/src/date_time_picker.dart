import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// TODO: Is it really advantageous to use a TextFormField? Or would a FocusableActionDetector be the better basis?

/// Present a picker for FhirDateTime, Date, or Time.
///
/// The control is displayed as a text field that can be tapped to open
/// a picker.
class FhirDateTimePicker extends StatefulWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final FhirDateTime? initialDateTime;
  final Type pickerType;
  final DatePickerEntryMode datePickerEntryMode;
  final TimePickerEntryMode timePickerEntryMode;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final bool enabled;
  final void Function(FhirDateTime?)? onChanged;

  const FhirDateTimePicker({
    required this.initialDateTime,
    required this.firstDate,
    required this.lastDate,
    required this.pickerType,
    this.datePickerEntryMode = DatePickerEntryMode.calendar,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
    this.decoration,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FhirDateTimePickerState createState() => _FhirDateTimePickerState();
}

class _FhirDateTimePickerState extends State<FhirDateTimePicker> {
  final _dateTimeFieldController = TextEditingController();
  FhirDateTime? _dateTimeValue;
  bool _fieldInitialized = false;
  final _clearFocusNode = FocusNode(skipTraversal: true);

  // All 24h TimeOFDayFormats as specified in:
  // https://api.flutter.dev/flutter/material/TimeOfDayFormat.html
  static const timeOfDay24hFormats = {
    TimeOfDayFormat.HH_colon_mm,
    TimeOfDayFormat.HH_dot_mm,
    TimeOfDayFormat.frenchCanadian,
    TimeOfDayFormat.H_colon_mm,
  };

  @override
  void initState() {
    super.initState();
    _dateTimeValue = widget.initialDateTime;
    _fieldInitialized = false;
  }

  @override
  void dispose() {
    _dateTimeFieldController.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  String _formatDateTime(FhirDateTime? value, Locale locale) {
    final dateTime = value?.valueDateTime;
    if (value == null || dateTime == null) return '';

    return (widget.pickerType == Time)
        ? DateFormat.jm(locale.toString()).format(dateTime)
        : value.format(locale, withTimeZone: widget.pickerType == FhirDateTime);
  }

  Future<void> _showPicker(Locale locale) async {
    DateTime dateTime = DateTime(1970);

    if (widget.pickerType != Time) {
      final date = await showDatePicker(
        initialDate: _dateTimeValue?.value ?? DateTime.now(),
        initialEntryMode: widget.datePickerEntryMode,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        locale: locale,
        context: context,
      );

      if (date == null) {
        return; // Cancelled, don't touch anything
      }
      dateTime = date.toLocal();
    }

    if (widget.pickerType == FhirDateTime || widget.pickerType == Time) {
      final time = await showTimePicker(
        initialTime:
            TimeOfDay.fromDateTime(_dateTimeValue?.value ?? DateTime.now()),
        initialEntryMode: widget.timePickerEntryMode,
        context: context,
        builder: (context, child) {
          return Localizations.override(
            context: context,
            locale: locale,
            child: Builder(
              // Get new BuildContext with overridden locale
              builder: (context) {
                // Get time of day format of current locale
                final timeOfDayFormat =
                    MaterialLocalizations.of(context).timeOfDayFormat();
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    // Workaround for time picker validation bug in `input` mode with locales specifying a 24h TimeOfDayFormat.
                    // - https://github.com/sujrd/faiadashu/pull/32#issuecomment-1678639964
                    // - https://github.com/flutter/flutter/issues/85527
                    alwaysUse24HourFormat:
                        timeOfDay24hFormats.contains(timeOfDayFormat),
                  ),
                  child: child!,
                );
              },
            ),
          );
        },
      );

      if (time == null) {
        return; // Cancelled, don't touch anything
      }

      dateTime = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
        time.hour,
        time.minute,
      );
    }

    final fhirDateTime = FhirDateTime.fromDateTime(
      dateTime,
      (widget.pickerType == Date)
          ? DateTimePrecision.YYYYMMDD
          : DateTimePrecision.FULL,
    );
    setState(() {
      _dateTimeFieldController.text = _formatDateTime(fhirDateTime, locale);
    });
    _dateTimeValue = fhirDateTime;
    widget.onChanged?.call(fhirDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    // There is no Locale in initState.
    if (!_fieldInitialized) {
      _dateTimeFieldController.text = _formatDateTime(_dateTimeValue, locale);
      _fieldInitialized = true;
    }

    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        TextFormField(
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          textAlignVertical: TextAlignVertical.center,
          decoration: widget.decoration?.copyWith(
            prefixIcon: (widget.pickerType == Time)
                ? const Icon(Icons.access_time)
                : const Icon(Icons.calendar_today_outlined),
          ),
          controller: _dateTimeFieldController,
          onTap: () async {
            await _showPicker(locale);
          },
          readOnly: true,
        ),
        if (widget.enabled && _dateTimeFieldController.text.isNotEmpty)
          IconButton(
            focusNode: _clearFocusNode,
            onPressed: () {
              setState(() {
                _dateTimeFieldController.text = '';
              });
              widget.onChanged?.call(null);
            },
            icon: const Icon(Icons.cancel),
          ),
      ],
    );
  }
}
