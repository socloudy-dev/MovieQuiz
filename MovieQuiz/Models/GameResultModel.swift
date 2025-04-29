import Foundation

struct GameResultModel {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResultModel) -> Bool {
            correct > another.correct
        }
}
