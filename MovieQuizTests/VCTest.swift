import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func animateSuccess() {
        
    }
    
    func animateError() {
        
    }
    
    func show(quiz step: MovieQuiz.QuizStepModel) {
        
    }
    
    func lockAnswerButtons() {
        
    }
    
    func unlockAnswerButtons() {
        
    }
    
    func tapticAnswer(isCorrectAnswer: Bool) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func clearImageBorder() {
        
    }
    
    func showActivityIndicator() {
        
    }
    
    func hideActivityIndicator() {
        
    }
    
    
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
