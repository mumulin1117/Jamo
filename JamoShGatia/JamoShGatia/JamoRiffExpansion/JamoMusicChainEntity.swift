import StoreKit
import UIKit
class JamoMusicChainEntity: NSObject {
    var APPPREFIX_transactionID: String?
    static let shared = JamoMusicChainEntity()
    private var APPPREFIX_purchaseCompletion: ((Result<Void, Error>) -> Void)?
    private var APPPREFIX_productRequest: SKProductsRequest?
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    func APPPREFIX_startPurchase(
        APPPREFIX_productID: String,
        APPPREFIX_completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard SKPaymentQueue.canMakePayments() else {
            APPPREFIX_fail("In-App Purchases are disabled on this device.", code: -1, completion: APPPREFIX_completion)
            return
        }
        APPPREFIX_purchaseCompletion = APPPREFIX_completion
        APPPREFIX_productRequest?.cancel()
        let request = SKProductsRequest(productIdentifiers: [APPPREFIX_productID])
        request.delegate = self
        APPPREFIX_productRequest = request
        request.start()
    }
    private func APPPREFIX_complete(_ result: Result<Void, Error>) {
        DispatchQueue.main.async {
            self.APPPREFIX_purchaseCompletion?(result)
            self.APPPREFIX_purchaseCompletion = nil
        }
    }
    private func APPPREFIX_fail(_ message: String, code: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: message])))
        }
    }
}
extension JamoMusicChainEntity: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            APPPREFIX_complete(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No valid product found."])))
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: product))
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        APPPREFIX_complete(.failure(error))
    }
}
extension JamoMusicChainEntity: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach(APPPREFIX_handleTransaction)
    }
    private func APPPREFIX_handleTransaction(_ transaction: SKPaymentTransaction) {
        switch transaction.transactionState {
        case .purchased:
            APPPREFIX_transactionID = transaction.transactionIdentifier
            SKPaymentQueue.default().finishTransaction(transaction)
            APPPREFIX_complete(.success(()))
        case .failed:
            SKPaymentQueue.default().finishTransaction(transaction)
            APPPREFIX_complete(.failure(APPPREFIX_transactionError(transaction)))
        case .restored:
            SKPaymentQueue.default().finishTransaction(transaction)
        default:
            break
        }
    }
    private func APPPREFIX_transactionError(_ transaction: SKPaymentTransaction) -> Error {
        if (transaction.error as? SKError)?.code == .paymentCancelled {
            return NSError(domain: "", code: -999, userInfo: [NSLocalizedDescriptionKey: "Payment cancelled"])
        }
        return transaction.error ?? NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Transaction failed."])
    }
}
extension JamoMusicChainEntity {
    func APPPREFIX_obtainLocalReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: url)
    }
}
