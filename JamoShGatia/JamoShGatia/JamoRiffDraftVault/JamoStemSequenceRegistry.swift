import StoreKit
import UIKit

final class JamoStemSequenceRegistry: NSObject {
    private enum JamoStemSequenceFault {
        static let JamoStemSequenceUnavailableCode = -1
        static let JamoStemSequenceMissingItemCode = -2
        static let JamoStemSequenceFailedCode = -3
        static let JamoStemSequenceCancelledCode = -999
        static let JamoStemSequenceUnavailableCopy = JamoRiffStringCipher.restore("Txhxixsx xixtxexmx xixsx xuxnxaxvxaxixlxaxbxlxex xoxnx xtxhxixsx xdxexvxixcxex.x")
        static let JamoStemSequenceMissingItemCopy = JamoRiffStringCipher.restore("Nxox xvxaxlxixdx xpxrxoxdxuxcxtx xfxoxuxnxdx.x")
        static let JamoStemSequenceCancelledCopy = JamoRiffStringCipher.restore("Axcxtxixoxnx xcxaxnxcxexlxlxexdx")
        static let JamoStemSequenceFailedCopy = JamoRiffStringCipher.restore("Txrxaxnxsxaxcxtxixoxnx xfxaxixlxexdx.x")
    }

    static let shared = JamoStemSequenceRegistry()

    var JamoStemSequenceTraceKey: String?

    private var JamoStemSequenceCompletion: ((Result<Void, Error>) -> Void)?
    private var JamoStemSequenceRequest: SKProductsRequest?
    private var JamoStemSequenceRefreshRequest: SKReceiptRefreshRequest?
    private var JamoStemSequencePendingNode: SKPaymentTransaction?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func JamoStemSequenceBegin(
        JamoStemSequenceKey: String,
        JamoStemSequenceCompletionBlock: @escaping (Result<Void, Error>) -> Void
    ) {
        guard JamoStemSequenceCanStart() else {
            JamoStemSequenceReturn(
                .failure(JamoStemSequenceError(JamoStemSequenceFault.JamoStemSequenceUnavailableCopy, code: JamoStemSequenceFault.JamoStemSequenceUnavailableCode)),
                to: JamoStemSequenceCompletionBlock
            )
            return
        }
        JamoStemSequenceCompletion = JamoStemSequenceCompletionBlock
        JamoStemSequenceStartRequest(for: JamoStemSequenceKey)
    }

    func JamoStemSequenceLocalReceipt() -> Data? {
        guard let JamoStemSequenceReceiptPath = Bundle.main.appStoreReceiptURL else { return nil }
        return try? Data(contentsOf: JamoStemSequenceReceiptPath)
    }

    private func JamoStemSequenceCanStart() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    private func JamoStemSequenceStartRequest(for JamoStemSequenceKey: String) {
        JamoStemSequenceRequest?.cancel()
        JamoStemSequenceRefreshRequest?.cancel()
        JamoStemSequencePendingNode = nil
        let JamoStemSequenceLookup = SKProductsRequest(productIdentifiers: [JamoStemSequenceKey])
        JamoStemSequenceLookup.delegate = self
        JamoStemSequenceRequest = JamoStemSequenceLookup
        JamoStemSequenceLookup.start()
    }

    private func JamoStemSequenceResolve(_ JamoStemSequenceResult: Result<Void, Error>) {
        DispatchQueue.main.async {
            self.JamoStemSequenceCompletion?(JamoStemSequenceResult)
            self.JamoStemSequenceCompletion = nil
        }
    }

    private func JamoStemSequenceReturn(
        _ JamoStemSequenceResult: Result<Void, Error>,
        to JamoStemSequenceCompletionBlock: @escaping (Result<Void, Error>) -> Void
    ) {
        DispatchQueue.main.async {
            JamoStemSequenceCompletionBlock(JamoStemSequenceResult)
        }
    }

    private func JamoStemSequenceError(_ JamoStemSequenceCopy: String, code JamoStemSequenceCode: Int) -> Error {
        NSError(domain: JamoRiffStringCipher.restore(""), code: JamoStemSequenceCode, userInfo: [NSLocalizedDescriptionKey: JamoStemSequenceCopy])
    }
}

extension JamoStemSequenceRegistry: SKProductsRequestDelegate {
    func productsRequest(_ JamoStemSequenceLookup: SKProductsRequest, didReceive JamoStemSequenceResponse: SKProductsResponse) {
        guard let JamoStemSequenceItem = JamoStemSequenceResponse.products.first else {
            JamoStemSequenceResolve(
                .failure(JamoStemSequenceError(JamoStemSequenceFault.JamoStemSequenceMissingItemCopy, code: JamoStemSequenceFault.JamoStemSequenceMissingItemCode))
            )
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: JamoStemSequenceItem))
    }

    func request(_ JamoStemSequenceLookup: SKRequest, didFailWithError JamoStemSequenceError: Error) {
        if JamoStemSequenceLookup === JamoStemSequenceRefreshRequest {
            JamoStemSequenceCompletePendingNode()
            return
        }
        JamoStemSequenceResolve(.failure(JamoStemSequenceError))
    }

    func requestDidFinish(_ JamoStemSequenceLookup: SKRequest) {
        guard JamoStemSequenceLookup === JamoStemSequenceRefreshRequest else { return }
        JamoStemSequenceCompletePendingNode()
    }
}

extension JamoStemSequenceRegistry: SKPaymentTransactionObserver {
    func paymentQueue(_ JamoStemSequenceQueue: SKPaymentQueue, updatedTransactions JamoStemSequenceNodes: [SKPaymentTransaction]) {
        for JamoStemSequenceNode in JamoStemSequenceNodes {
            JamoStemSequenceReadNode(JamoStemSequenceNode)
        }
    }

    private func JamoStemSequenceReadNode(_ JamoStemSequenceNode: SKPaymentTransaction) {
        switch JamoStemSequenceNode.transactionState {
        case .purchased:
            JamoStemSequenceTraceKey = JamoStemSequenceNode.transactionIdentifier
            JamoStemSequenceRefreshReceipt(for: JamoStemSequenceNode)
        case .failed:
            JamoStemSequenceFinish(JamoStemSequenceNode)
            JamoStemSequenceResolve(.failure(JamoStemSequenceErrorFromNode(JamoStemSequenceNode)))
        case .restored:
            JamoStemSequenceFinish(JamoStemSequenceNode)
        default:
            break
        }
    }

    private func JamoStemSequenceFinish(_ JamoStemSequenceNode: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(JamoStemSequenceNode)
    }

    private func JamoStemSequenceRefreshReceipt(for JamoStemSequenceNode: SKPaymentTransaction) {
        JamoStemSequencePendingNode = JamoStemSequenceNode
        JamoStemSequenceRefreshRequest?.cancel()
        let JamoStemSequenceRefresh = SKReceiptRefreshRequest()
        JamoStemSequenceRefresh.delegate = self
        JamoStemSequenceRefreshRequest = JamoStemSequenceRefresh
        JamoStemSequenceRefresh.start()
    }

    private func JamoStemSequenceCompletePendingNode() {
        guard let JamoStemSequenceNode = JamoStemSequencePendingNode else {
            JamoStemSequenceResolve(.success(()))
            return
        }
        JamoStemSequencePendingNode = nil
        JamoStemSequenceRefreshRequest = nil
        JamoStemSequenceFinish(JamoStemSequenceNode)
        JamoStemSequenceResolve(.success(()))
    }

    private func JamoStemSequenceErrorFromNode(_ JamoStemSequenceNode: SKPaymentTransaction) -> Error {
        if (JamoStemSequenceNode.error as? SKError)?.code == .paymentCancelled {
            return JamoStemSequenceError(JamoStemSequenceFault.JamoStemSequenceCancelledCopy, code: JamoStemSequenceFault.JamoStemSequenceCancelledCode)
        }
        return JamoStemSequenceNode.error ?? JamoStemSequenceError(
            JamoStemSequenceFault.JamoStemSequenceFailedCopy,
            code: JamoStemSequenceFault.JamoStemSequenceFailedCode
        )
    }
}
