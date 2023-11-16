import 'package:fhir/r4.dart';

abstract class QuestionnaireResponseStatus {
  static const completed = FhirCode.asConst('completed');
  static const inProgress = FhirCode.asConst('in-progress');
  static const amended = FhirCode.asConst('amended');
}

abstract class QuestionnaireItemType {
  static const choice = FhirCode.asConst('choice');
  static const openChoice = FhirCode.asConst('open-choice');
  static const completed = FhirCode.asConst('completed');
  static const quantity = FhirCode.asConst('quantity');
  static const decimal = FhirCode.asConst('decimal');
  static const integer = FhirCode.asConst('integer');
  static const string = FhirCode.asConst('string');
  static const text = FhirCode.asConst('text');
  static const url = FhirCode.asConst('url');
  static const date = FhirCode.asConst('date');
  static const dateTime = FhirCode.asConst('dateTime');
  static const time = FhirCode.asConst('time');
  static const boolean = FhirCode.asConst('boolean');
  static const attachment = FhirCode.asConst('attachment');
  static const display = FhirCode.asConst('display');
  static const group = FhirCode.asConst('group');
  static const unknown = FhirCode.asConst('unknown');
  static const reference = FhirCode.asConst('reference');
}

abstract class QuestionnaireItemEnableBehavior {
  static const any = FhirCode.asConst('any');
  static const all = FhirCode.asConst('all');
  static const unknown = FhirCode.asConst('unknown');
}

abstract class QuestionnaireEnableWhenOperator {
  static const exists = FhirCode.asConst('exists');
  static const equals = FhirCode.asConst('=');
  static const notEquals = FhirCode.asConst('!=');
  static const lessThan = FhirCode.asConst('<');
  static const greaterThan = FhirCode.asConst('>');
  static const lessThanOrEquals = FhirCode.asConst('<=');
  static const greaterThanOrEquals = FhirCode.asConst('>=');
}
