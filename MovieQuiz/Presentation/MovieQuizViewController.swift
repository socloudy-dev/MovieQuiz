import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    //MARK: - Properties
    
    @IBOutlet private weak var buttonsStackView: UIStackView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewOfPosterImageView: UIImageView!
    @IBOutlet private weak var counterOfQuestionLabel: UILabel!
    @IBOutlet private weak var downloadContentActivity: UIActivityIndicatorView!
    
    private let tapticGenerator = UINotificationFeedbackGenerator()
    private var presenter: MovieQuizPresenter!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        tapticGenerator.prepare()
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
    
    func lockAnswerButtons() {
        buttonsStackView.isUserInteractionEnabled = false
    }
    
    func unlockAnswerButtons() {
        buttonsStackView.isUserInteractionEnabled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            
            previewOfPosterImageView.layer.masksToBounds = true
            previewOfPosterImageView.layer.borderWidth = 8
            previewOfPosterImageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    }
    
    func animateError() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3
        animation.values = [-8, 8, -6, 6, -4, 4, -2, 2, 0]
        previewOfPosterImageView.layer.add(animation, forKey: "shake")
    }

    func animateSuccess() {
        UIView.animate(withDuration: 0.15,
                       animations: {
                           self.previewOfPosterImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                       }, completion: { _ in
                           UIView.animate(withDuration: 0.15) { self.previewOfPosterImageView.transform = .identity }
                       })
    }

    func clearImageBorder() {
        self.previewOfPosterImageView.layer.borderWidth = 0
    }
    
    func tapticAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer { tapticGenerator.notificationOccurred(.success) }
        else { tapticGenerator.notificationOccurred(.error) }
    }
    
    func showActivityIndicator() {
        downloadContentActivity.isHidden = false
        downloadContentActivity.startAnimating()
    }
    
    func hideActivityIndicator() {
        downloadContentActivity.stopAnimating()
        downloadContentActivity.isHidden = true
    }
    
    //MARK: - Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.processAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.processAnswer(true)
    }
}
