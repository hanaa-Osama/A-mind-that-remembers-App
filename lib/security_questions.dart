import 'dart:math';
import 'package:flutter/material.dart';
import 'questions_list.dart';

List<String> generateRandomQuestions(BuildContext context) {
  final random = Random();
  final questions = getLocalizedSecurityQuestions(context);
  final List<String> tempList = List.from(questions);
  tempList.shuffle(random);
  return tempList.take(3).toList();
}
