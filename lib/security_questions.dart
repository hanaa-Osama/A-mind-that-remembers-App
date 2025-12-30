import 'dart:math';
import 'questions_list.dart';

List<String> generateRandomQuestions() {
  final random = Random();
  final List<String> tempList = List.from(securityQuestions);
  tempList.shuffle(random);
  return tempList.take(3).toList();
}
