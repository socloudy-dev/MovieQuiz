import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepModel)
    
    func lockAnswerButtons()
    func unlockAnswerButtons()
    
    func tapticAnswer(isCorrectAnswer: Bool)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func clearImageBorder()
    
    func showActivityIndicator()
    func hideActivityIndicator()
}
