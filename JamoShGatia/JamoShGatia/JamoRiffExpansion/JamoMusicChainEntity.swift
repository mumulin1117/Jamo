import StoreKit
import UIKit
class JamoMusicChainEntity: NSObject {
    var JamoMusicChainEntitySequenceKey: String?
    static let shared = JamoMusicChainEntity()
    private var JamoMusicChainEntityCompletion: ((Result<Void, Error>) -> Void)?
    private var JamoMusicChainEntityRequest: SKProductsRequest?
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    func JamoMusicChainEntityBeginStemFile(
        JamoMusicChainEntityStemFileKey: String,
        JamoMusicChainEntityCompletionBlock: @escaping (Result<Void, Error>) -> Void
    ) {
        guard SKPaymentQueue.canMakePayments() else {
            JamoMusicChainEntityReject("This item is unavailable on this device.", JamoMusicChainEntityCode: -1, JamoMusicChainEntityCompletionBlock: JamoMusicChainEntityCompletionBlock)
            return
        }
        JamoMusicChainEntityCompletion = JamoMusicChainEntityCompletionBlock
        JamoMusicChainEntityRequest?.cancel()
        let JamoMusicChainEntityStemRequest = SKProductsRequest(productIdentifiers: [JamoMusicChainEntityStemFileKey])
        JamoMusicChainEntityStemRequest.delegate = self
        JamoMusicChainEntityRequest = JamoMusicChainEntityStemRequest
        JamoMusicChainEntityStemRequest.start()
    }
    private func JamoMusicChainEntityResolve(_ JamoMusicChainEntityResult: Result<Void, Error>) {
        DispatchQueue.main.async {
            self.JamoMusicChainEntityCompletion?(JamoMusicChainEntityResult)
            self.JamoMusicChainEntityCompletion = nil
        }
    }
    private func JamoMusicChainEntityReject(
        _ JamoMusicChainEntityPhrase: String,
        JamoMusicChainEntityCode: Int,
        JamoMusicChainEntityCompletionBlock: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            JamoMusicChainEntityCompletionBlock(.failure(NSError(domain: "", code: JamoMusicChainEntityCode, userInfo: [NSLocalizedDescriptionKey: JamoMusicChainEntityPhrase])))
        }
    }
}
extension JamoMusicChainEntity: SKProductsRequestDelegate {
    func productsRequest(_ JamoMusicChainEntityStemRequest: SKProductsRequest, didReceive JamoMusicChainEntityStemResponse: SKProductsResponse) {
        guard let JamoMusicChainEntityStemItem = JamoMusicChainEntityStemResponse.products.first else {
            JamoMusicChainEntityResolve(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No valid product found."])))
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: JamoMusicChainEntityStemItem))
    }
    func request(_ JamoMusicChainEntityStemRequest: SKRequest, didFailWithError JamoMusicChainEntityError: Error) {
        JamoMusicChainEntityResolve(.failure(JamoMusicChainEntityError))
    }
}
extension JamoMusicChainEntity: SKPaymentTransactionObserver {
    func paymentQueue(_ JamoMusicChainEntityQueue: SKPaymentQueue, updatedTransactions JamoMusicChainEntityNodes: [SKPaymentTransaction]) {
        JamoMusicChainEntityNodes.forEach(JamoMusicChainEntityHandleSequenceNode)
    }
    private func JamoMusicChainEntityHandleSequenceNode(_ JamoMusicChainEntityNode: SKPaymentTransaction) {
        switch JamoMusicChainEntityNode.transactionState {
        case .purchased:
            JamoMusicChainEntitySequenceKey = JamoMusicChainEntityNode.transactionIdentifier
            SKPaymentQueue.default().finishTransaction(JamoMusicChainEntityNode)
            JamoMusicChainEntityResolve(.success(()))
        case .failed:
            SKPaymentQueue.default().finishTransaction(JamoMusicChainEntityNode)
            JamoMusicChainEntityResolve(.failure(JamoMusicChainEntitySequenceError(JamoMusicChainEntityNode)))
        case .restored:
            SKPaymentQueue.default().finishTransaction(JamoMusicChainEntityNode)
        default:
            break
        }
    }
    private func JamoMusicChainEntitySequenceError(_ JamoMusicChainEntityNode: SKPaymentTransaction) -> Error {
        if (JamoMusicChainEntityNode.error as? SKError)?.code == .paymentCancelled {
            return NSError(domain: "", code: -999, userInfo: [NSLocalizedDescriptionKey: "Action cancelled"])
        }
        return JamoMusicChainEntityNode.error ?? NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Transaction failed."])
    }
}
extension JamoMusicChainEntity {
    func JamoMusicChainEntityLocalStemData() -> Data? {
        guard let JamoMusicChainEntityReceiptPath = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: JamoMusicChainEntityReceiptPath)
    }
}
