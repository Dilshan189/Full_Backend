import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizViewModel>(context, listen: false).fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3B33D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Consumer<QuizViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        "Loading Questions...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                );
              }

              if (viewModel.errorMessage.isNotEmpty) {
                return _buildErrorState(viewModel);
              }

              if (viewModel.questions.isEmpty) {
                return const Center(
                    child: Text("No questions available.",
                        style: TextStyle(color: Colors.white)));
              }

              if (viewModel.isQuizCompleted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ResultScreen()),
                  );
                });
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              final question = viewModel.currentQuestion!;
              final progress = (viewModel.currentQuestionIndex + 1) /
                  viewModel.questions.length;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${viewModel.currentQuestionIndex + 1}/${viewModel.questions.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Score: ${viewModel.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.amber),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Question Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Text(
                        question.questionText,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Options List
                    Expanded(
                      child: ListView.builder(
                        itemCount: question.options.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              viewModel.selectedOptionIndex == index;
                          final isCorrect =
                              index == question.correctOptionIndex;
                          final isAnswered = viewModel.isAnswered;

                          Color buttonColor = Colors.white;
                          Color textColor = const Color(0xFF2D2D2D);
                          Color borderColor = Colors.transparent;

                          if (isAnswered) {
                            if (isCorrect) {
                              buttonColor = Colors.green.shade50;
                              borderColor = Colors.green;
                              textColor = Colors.green.shade800;
                            } else if (isSelected) {
                              buttonColor = Colors.red.shade50;
                              borderColor = Colors.red;
                              textColor = Colors.red.shade800;
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: InkWell(
                              onTap: isAnswered
                                  ? null
                                  : () => viewModel.answerQuestion(index),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderColor == Colors.transparent
                                        ? Colors.white
                                        : borderColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    if (!isAnswered)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        question.options[index],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (isAnswered && isCorrect)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green)
                                    else if (isAnswered && isSelected && !isCorrect)
                                      const Icon(Icons.cancel, color: Colors.red)
                                    else
                                      Icon(Icons.circle_outlined,
                                          color: Colors.grey.shade400)
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(QuizViewModel viewModel) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchQuestions(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
