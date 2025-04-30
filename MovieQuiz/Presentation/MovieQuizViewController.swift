import UIKit

final class MovieQuizViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewOfPosterImageView: UIImageView!
    @IBOutlet private weak var counterOfQuestionLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questions = QuizQuestionMock.questions
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayCurrentQuestion()
    }
    
    // MARK: - Setup Methods
    
    private func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepModel) {
        previewOfPosterImageView.image = step.image
        questionLabel.text = step.question
        counterOfQuestionLabel.text = step.questionNumber
    }
    
    private func displayCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let currentQuestionConverted = convert(model: currentQuestion)
        
        show(quiz: currentQuestionConverted)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        buttonsStackView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) {
            self.previewOfPosterImageView.layer.masksToBounds = true
            self.previewOfPosterImageView.layer.borderWidth = 8
            self.previewOfPosterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIView.animate(withDuration: 0.2) {
                self.showNextQuestionOrResults()
                self.previewOfPosterImageView.layer.borderWidth = 0
            }
            
            self.buttonsStackView.isUserInteractionEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let quizResults = QuizResultsModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть ещё раз")
            
            showQuizResults(quiz: quizResults)
        } else {
            currentQuestionIndex += 1
            
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            
            show(quiz: viewModel)
        }
    }
    
    private func showQuizResults(quiz result: QuizResultsModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.displayCurrentQuestion()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func processAnswer(_ givenAnswer: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        processAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        processAnswer(true)
    }
}
