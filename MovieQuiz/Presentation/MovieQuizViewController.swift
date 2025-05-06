import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate, StatisticServiceDelegate {
    
    //MARK: - Properties
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewOfPosterImageView: UIImageView!
    @IBOutlet private weak var counterOfQuestionLabel: UILabel!
    @IBOutlet private weak var downloadContentActivity: UIActivityIndicatorView!
    
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    private var presenter = MovieQuizPresenter()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        let statisticService = StatisticService()
        statisticService.delegate = self
        self.statisticService = statisticService
        
        presenter.viewController = self
        
        showActivityIndicator()
        questionFactory.loadData()
    }
    
    //MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        downloadContentActivity.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    //MARK: - AlertPresenterDelegate
    
    func didUserTapAlertButton() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        
        self.questionFactory?.requestNextQuestion()
    }
    
    
    //MARK: - StatisticsServiceDelegate
    
    func didReceiveStoredData(_ bestGame: GameResultModel?) {
        guard let bestGame else { return }
        
        let alertMessage = """
                            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                            Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0.0))% 
                        """
        
        let quizResults = AlertModel(
            title: "Этот раунд окончен!",
            message: alertMessage,
            buttonText: "Сыграть ещё раз",
            completion: {})
        
        self.alertPresenter?.showAlert(from: quizResults, on: self)
    }
    
    // MARK: - Setup Methods
    
    func show(quiz step: QuizStepModel) {
        questionLabel.text = step.question
        counterOfQuestionLabel.text = step.questionNumber
        
        UIView.transition(with: previewOfPosterImageView,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.previewOfPosterImageView.image = step.image },
                          completion: nil)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        let tapticGenerator = UINotificationFeedbackGenerator()
        tapticGenerator.prepare()
        
        if isCorrect {
            correctAnswers += 1
            tapticGenerator.notificationOccurred(.success)
        } else { tapticGenerator.notificationOccurred(.error) }
        
        buttonsStackView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            
            previewOfPosterImageView.layer.masksToBounds = true
            previewOfPosterImageView.layer.borderWidth = 8
            previewOfPosterImageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            
            self.presenter.correctAnswers = self.correctAnswers
            self.presenter.questionFactory = self.questionFactory
            self.presenter.statisticService = self.statisticService
            
            UIView.animate(withDuration: 0.2) {
                self.presenter.showNextQuestionOrResults()
                self.previewOfPosterImageView.layer.borderWidth = 0
            }
            
            buttonsStackView.isUserInteractionEnabled = true
        }
    }
    
    func showActivityIndicator() {
        downloadContentActivity.isHidden = false
        downloadContentActivity.startAnimating()
    }
    
    func hideActivityIndicator() {
        downloadContentActivity.stopAnimating()
        downloadContentActivity.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideActivityIndicator()
        
        let errorModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: {})
        
        self.alertPresenter?.showAlert(from: errorModel, on: self)
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.processAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.processAnswer(true)
    }
}
