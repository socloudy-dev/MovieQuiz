import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    //MARK: - Properties
    
    weak var delegate: StatisticServiceDelegate?
    
    private let storage: UserDefaults = .standard
    
    init(delegate: StatisticServiceDelegate) {
        self.delegate = delegate
    }
    
    //MARK: - StatisticKeys
    
    private enum StatisticKeys: String {
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case gamesCount
        case totalCorrectAnswers
        case totalAnswers
        case totalAccuracy
    }
    
    //MARK: - Calculating properties
    
    var gamesCount: Int {
        get { storage.integer(forKey: StatisticKeys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: StatisticKeys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResultModel {
        get {
            let correct = storage.integer(forKey: StatisticKeys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: StatisticKeys.bestGameTotal.rawValue)
            let date = storage.object(forKey: StatisticKeys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResultModel(correct: correct, total: total, date: date)
        } set {
            storage.set(newValue.correct, forKey: StatisticKeys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: StatisticKeys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: StatisticKeys.bestGameDate.rawValue)
        }
    }
    
    private var totalCorrectAnswers: Int {
        get { storage.integer(forKey: StatisticKeys.totalCorrectAnswers.rawValue) }
        set { storage.set(newValue, forKey: StatisticKeys.totalCorrectAnswers.rawValue) }
    }
    
    private var totalAnswers: Int {
        get { storage.integer(forKey: StatisticKeys.totalAnswers.rawValue) }
        set { storage.set(newValue, forKey: StatisticKeys.totalAnswers.rawValue) }
    }
    
    var totalAccuracy: Double {
        get {
            let totalCorrectAnswers = storage.double(forKey: StatisticKeys.totalCorrectAnswers.rawValue)
            
            if gamesCount > 0 {
                let totalAmount = 10.0 * storage.double(forKey: StatisticKeys.gamesCount.rawValue)
                return Double(totalCorrectAnswers) / totalAmount * 100.0
            } else { return 0.0 }
        } set {
            storage.set(newValue, forKey: StatisticKeys.totalAccuracy.rawValue)
        }
    }
    
    // MARK: - Setup Methods
    
    func store(correct count: Int, total amount: Int) {
        let currentGame = GameResultModel(correct: count, total: amount, date: Date())
        gamesCount += 1
        totalCorrectAnswers += count
        totalAnswers += amount
        
        if currentGame.isBetterThan(bestGame) { bestGame = currentGame }
        delegate?.didReceiveStoredData()
    }
}
