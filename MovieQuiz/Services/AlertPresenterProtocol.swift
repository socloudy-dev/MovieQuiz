import UIKit

protocol AlertPresenterProtocol {
    func showAlert(from model: AlertModel, on viewController: UIViewController)
}
