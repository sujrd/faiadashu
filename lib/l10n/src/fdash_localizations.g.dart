
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'fdash_localizations_ar.dart';
import 'fdash_localizations_de.dart';
import 'fdash_localizations_en.dart';
import 'fdash_localizations_es.dart';
import 'fdash_localizations_ja.dart';

/// Callers can lookup localized strings with an instance of FDashLocalizations returned
/// by `FDashLocalizations.of(context)`.
///
/// Applications need to include `FDashLocalizations.delegate()` in their app's
/// localizationDelegates list, and the locales they support in the app's
/// supportedLocales list. For example:
///
/// ```
/// import 'src/fdash_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FDashLocalizations.localizationsDelegates,
///   supportedLocales: FDashLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FDashLocalizations.supportedLocales
/// property.
abstract class FDashLocalizations {
  FDashLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FDashLocalizations of(BuildContext context) {
    return Localizations.of<FDashLocalizations>(context, FDashLocalizations)!;
  }

  static const LocalizationsDelegate<FDashLocalizations> delegate = _FDashLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ja')
  ];

  /// No description provided for @validatorRequiredItem.
  ///
  /// In en, this message translates to:
  /// **'This question needs to be completed.'**
  String get validatorRequiredItem;

  /// No description provided for @validatorMinLength.
  ///
  /// In en, this message translates to:
  /// **'{minLength, plural, =1 {Enter at least one character.} other {Enter at least {minLength} characters.}}'**
  String validatorMinLength(int minLength);

  /// No description provided for @validatorMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{maxLength, plural, other{Enter up to {maxLength} characters.}}'**
  String validatorMaxLength(int maxLength);

  /// No description provided for @validatorUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid URL in format https://...'**
  String get validatorUrl;

  /// No description provided for @validatorRegExp.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid response.'**
  String get validatorRegExp;

  /// No description provided for @validatorEntryFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter in format {entryFormat}.'**
  String validatorEntryFormat(String entryFormat);

  /// No description provided for @validatorDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date.'**
  String get validatorDate;

  /// No description provided for @validatorTime.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid time.'**
  String get validatorTime;

  /// No description provided for @validatorDateTime.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid date and time.'**
  String get validatorDateTime;

  /// No description provided for @validatorNan.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get validatorNan;

  /// No description provided for @validatorMinValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of {minValue} or higher.'**
  String validatorMinValue(String minValue);

  /// No description provided for @validatorMaxValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a number up to {maxValue}.'**
  String validatorMaxValue(String maxValue);

  /// No description provided for @validatorMinOccurs.
  ///
  /// In en, this message translates to:
  /// **'{minOccurs, plural, =1 {Select at least one option.} other {Select {minOccurs} or more options.}}'**
  String validatorMinOccurs(int minOccurs);

  /// No description provided for @validatorMaxOccurs.
  ///
  /// In en, this message translates to:
  /// **'{maxOccurs, plural, =1 {Select up to one option.} other {Select up to {maxOccurs} options.}}'**
  String validatorMaxOccurs(int maxOccurs);

  /// No description provided for @dataAbsentReasonAskedDeclinedInputLabel.
  ///
  /// In en, this message translates to:
  /// **'I choose not to answer.'**
  String get dataAbsentReasonAskedDeclinedInputLabel;

  /// No description provided for @dataAbsentReasonAskedDeclinedOutput.
  ///
  /// In en, this message translates to:
  /// **'Declined to answer'**
  String get dataAbsentReasonAskedDeclinedOutput;

  /// No description provided for @dataAbsentReasonAsTextOutput.
  ///
  /// In en, this message translates to:
  /// **'[AS TEXT]'**
  String get dataAbsentReasonAsTextOutput;

  /// No description provided for @narrativePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Narrative'**
  String get narrativePageTitle;

  /// No description provided for @questionnaireGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Survey'**
  String get questionnaireGenericTitle;

  /// No description provided for @questionnaireUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get questionnaireUnknownTitle;

  /// No description provided for @questionnaireUnknownPublisher.
  ///
  /// In en, this message translates to:
  /// **'Unknown publisher'**
  String get questionnaireUnknownPublisher;

  /// No description provided for @autoCompleteSearchTermInput.
  ///
  /// In en, this message translates to:
  /// **'Enter search term…'**
  String get autoCompleteSearchTermInput;

  /// No description provided for @responseStatusToCompleteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get responseStatusToCompleteButtonLabel;

  /// No description provided for @responseStatusToInProgressButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Amend'**
  String get responseStatusToInProgressButtonLabel;

  /// No description provided for @progressQuestionnaireLoading.
  ///
  /// In en, this message translates to:
  /// **'The survey is loading…'**
  String get progressQuestionnaireLoading;
}

class _FDashLocalizationsDelegate extends LocalizationsDelegate<FDashLocalizations> {
  const _FDashLocalizationsDelegate();

  @override
  Future<FDashLocalizations> load(Locale locale) {
    return SynchronousFuture<FDashLocalizations>(lookupFDashLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_FDashLocalizationsDelegate old) => false;
}

FDashLocalizations lookupFDashLocalizations(Locale locale) {
  


// Lookup logic when only language code is specified.
switch (locale.languageCode) {
  case 'ar': return FDashLocalizationsAr();
    case 'de': return FDashLocalizationsDe();
    case 'en': return FDashLocalizationsEn();
    case 'es': return FDashLocalizationsEs();
    case 'ja': return FDashLocalizationsJa();
}


  throw FlutterError(
    'FDashLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}