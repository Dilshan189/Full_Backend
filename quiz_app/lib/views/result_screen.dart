import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quiz_viewmodel.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<QuizViewModel>(context, listen: false);
    final percentage = viewModel.score / viewModel.questions.length;
    final isSuccess = percentage >= 0.5;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3B33D9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset(
                      isSuccess
                          ? 'assets/images/success.png' // Placeholders if you have images
                          : 'assets/images/fail.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isSuccess ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                          size: 100,
                          color: isSuccess ? Colors.amber : Colors.redAccent,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isSuccess ? 'Congratulations!' : 'Keep Trying!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green.shade700 : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Score',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${viewModel.score} / ${viewModel.questions.length}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          viewModel.resetQuiz();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const QuizScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
