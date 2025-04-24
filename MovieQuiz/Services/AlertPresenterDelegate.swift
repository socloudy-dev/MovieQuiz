import Foundation

protocol MovieQuizViewControllerDelegate: AnyObject {
    func didUserFinishQuiz(model: AlertModel?)
}

