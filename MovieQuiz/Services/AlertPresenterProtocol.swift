import UIKit

protocol AlertPresenterProtocol {
    func showAlertWithResults(quiz result: AlertModel, on viewController: UIViewController)
}
