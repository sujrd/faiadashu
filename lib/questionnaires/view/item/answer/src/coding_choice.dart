import 'package:faiadashu/questionnaires/model/item/answer/src/coding_answer_option_model.dart';
import 'package:flutter/material.dart';

/// This class is designed to be extended by other widgets that will provide
/// specific implementations for displaying coding choices.
abstract class CodingChoice extends StatelessWidget {
  const CodingChoice({super.key});

  CodingAnswerOptionModel? get answerOption;
}
