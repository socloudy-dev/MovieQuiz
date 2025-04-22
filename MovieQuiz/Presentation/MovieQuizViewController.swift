import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //MARK: - Properties
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewOfPosterImageView: UIImageView!
    @IBOutlet private weak var counterOfQuestionLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        questionFactory.requestNextQuestion()
        displayCurrentQuestion()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let currentQuestionConverted = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: currentQuestionConverted)
        }
    }
    
    // MARK: - Setup Methods
    
    private func convert(model: QuizQuestion) -> QuizStepModel {
        let questionStep = QuizStepModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepModel) {
        previewOfPosterImageView.image = step.image
        questionLabel.text = step.question
        counterOfQuestionLabel.text = step.questionNumber
    }
    
    private func displayCurrentQuestion() {
        //if let firstQuestion = questionFactory.requestNextQuestion() {
        //self.currentQuestion = firstQuestion
        guard let currentQuestion else { return }
        let currentQuestionConverted = convert(model: currentQuestion)
        
        show(quiz: currentQuestionConverted)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        buttonsStackView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            
            previewOfPosterImageView.layer.masksToBounds = true
            previewOfPosterImageView.layer.borderWidth = 8
            previewOfPosterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
            
            //MARK: - УКОРОТИТЬ КОД ВИБРАЦИИ
            if isCorrect {
                let tapticGenerator = UINotificationFeedbackGenerator()
                tapticGenerator.notificationOccurred(.success)
            } else {
                let tapticGenerator = UINotificationFeedbackGenerator()
                tapticGenerator.notificationOccurred(.error)
            }
            
            /* либо так, либо чуть поменять, но в общем и целом чет типо того. Можно проверить в верхнем if или рядом с ним кинуть переменную, а тернарный закинуть в анимэйт
             let tapticGenerator = UINotificationFeedbackGenerator()
             
             tapticGenerator.notificationOccurred = isCorrect ? .success : .error
             */
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                
                showNextQuestionOrResults()
                previewOfPosterImageView.layer.borderWidth = 0
            }
            
            buttonsStackView.isUserInteractionEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let quizResults = QuizResultsModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(correctAnswers)/\(questionsAmount)",
                buttonText: "Сыграть ещё раз")
            
            showQuizResults(quiz: quizResults)
        } else {
            currentQuestionIndex += 1
            
            self.questionFactory?.requestNextQuestion()
            guard let currentQuestion else { return }
            let currentQuestionConverted = convert(model: currentQuestion)
                
            show(quiz: currentQuestionConverted)
            }
        }
    
    private func showQuizResults(quiz result: QuizResultsModel) {
        let alert = UIAlertController(title: result.title,
                                      message: result.text,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            currentQuestionIndex = 0
            correctAnswers = 0
            
            displayCurrentQuestion()
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func processAnswer(_ givenAnswer: Bool) {
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        processAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        processAnswer(true)
    }
}
