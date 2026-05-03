import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class QuizViewModel extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isQuizCompleted = false;
  bool _isLoading = false;
  String _errorMessage = '';

  int? _selectedOptionIndex;
  bool _isAnswered = false;

  List<QuestionModel> _questions = [];

  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<QuestionModel> get questions => _questions;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get isAnswered => _isAnswered;

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty) return null;
    return _questions[_currentQuestionIndex];
  }

  Future<void> fetchQuestions() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/get-questions'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _questions = data.map((json) => QuestionModel.fromJson(json)).toList();
      } else {
        _errorMessage =
            'Failed to load questions. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error connecting to API: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> answerQuestion(int selectedIndex) async {
    if (_isAnswered) return; // Prevent multiple taps

    _isAnswered = true;
    _selectedOptionIndex = selectedIndex;
    notifyListeners();

    final question = currentQuestion;
    if (question == null) return;

    if (selectedIndex == question.correctOptionIndex) {
      _score++;
    }

    // Delay to show correct/incorrect colors
    await Future.delayed(const Duration(seconds: 1));

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    } else {
      _isQuizCompleted = true;
    }

    _isAnswered = false;
    _selectedOptionIndex = null;
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizCompleted = false;
    _questions = [];
    _isAnswered = false;
    _selectedOptionIndex = null;
    notifyListeners();
    fetchQuestions();
  }
}
