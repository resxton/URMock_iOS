import Alamofire
import Foundation

struct PaymentInfo: Decodable {
    let amount: Int
    let description: String
}

protocol PaymentServiceProtocol {
    func fetchPaymentInfo(
        paymentId: String,
        completion: @escaping (
            Result<PaymentInfo, Error>
        ) -> Void
    )
    func pay(
        paymentId: String,
        completion: @escaping (
            Result<Void, Error>
        ) -> Void
    )
}

class RealPaymentService: PaymentServiceProtocol {
    
    func fetchPaymentInfo(
        paymentId: String,
        completion: @escaping (
            Result<PaymentInfo, Error>
        ) -> Void
    ) {
        let url = "https://yourapi.com/payments/\(paymentId)"
        
        AF.request(url).responseDecodable(of: PaymentInfo.self) { response in
            switch response.result {
            case .success(let paymentInfo):
                completion(.success(paymentInfo))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func pay(paymentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "https://yourapi.com/payments/\(paymentId)/pay"
        
        AF.request(url, method: .post).response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class MockPaymentService: PaymentServiceProtocol {
    
    func fetchPaymentInfo(
        paymentId: String,
        completion: @escaping (
            Result<PaymentInfo, Error>
        ) -> Void
    ) {
        let mockInfo = PaymentInfo(amount: 499, description: "Пополнение баланса аккаунта (мок)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(mockInfo))
        }
    }
    
    func pay(paymentId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(.success(())) // Мокаем успешную оплату
        }
    }
}
