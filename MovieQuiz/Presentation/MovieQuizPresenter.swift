import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate, StatisticServiceDelegate {
    //MARK: - Properties
    
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private let questionsAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticService(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showActivityIndicator()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        
        currentQuestion = question
        let currentQuestionConverted = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: currentQuestionConverted)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideActivityIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //MARK: - AlertPresenterDelegate
    
    func didUserTapAlertButton() {
        restartGame()
    }
    
    //MARK: - StatisticsServiceDelegate
    
    func didReceiveStoredData() {
        guard let bestGame = statisticService?.bestGame else { return }
        
        let alertMessage = """
                            Ваш результат: \(correctAnswers)/\(questionsAmount)
                            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                            Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0))% 
                        """
        
        let quizResults = AlertModel(
            title: "Этот раунд окончен!",
            message: alertMessage,
            buttonText: "Сыграть ещё раз",
            completion: {})
        
        alertPresenter?.showAlert(from: quizResults, on: viewController!)
    }
    
    //MARK: - Setup Methods
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepModel {
        return QuizStepModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func processAnswer(_ givenAnswer: Bool) {
        let isCorrectAnswer = givenAnswer == currentQuestion?.correctAnswer
        
        didAnswer(isCorrectAnswer: isCorrectAnswer)
        viewController?.tapticAnswer(isCorrectAnswer: isCorrectAnswer)
        viewController?.lockAnswerButtons()
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrectAnswer)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            viewController?.clearImageBorder()
            showNextQuestionOrResults()
            viewController?.unlockAnswerButtons()
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            self.statisticService?.store(correct: correctAnswers, total: questionsAmount)
        } else {
            self.switchToNextQuestion()
            
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        viewController?.hideActivityIndicator()
        
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: {})
        
        alertPresenter?.showAlert(from: errorModel, on: viewController!)
    }
}

