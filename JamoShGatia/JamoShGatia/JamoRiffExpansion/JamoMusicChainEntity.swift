
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

    func APPPREFIX_startPurchase(APPPREFIX_productID: String, APPPREFIX_completion: @escaping (Result<Void, Error>) -> Void) {
        guard SKPaymentQueue.canMakePayments() else {
            DispatchQueue.main.async {
                APPPREFIX_completion(.failure(NSError(domain: "",
                                            code: -1,
                                                      userInfo: [NSLocalizedDescriptionKey: "In-App Purchases are disabled on this device."])))
            }
            
            return
        }
        
        self.APPPREFIX_purchaseCompletion = APPPREFIX_completion
        APPPREFIX_productRequest?.cancel()
        let r = SKProductsRequest(productIdentifiers: [APPPREFIX_productID])
        r.delegate = self
        self.APPPREFIX_productRequest = r
        r.start()
    }

}

// MARK: - 产品请求
extension JamoMusicChainEntity: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let p = response.products.first else {
            DispatchQueue.main.async {
                self.APPPREFIX_purchaseCompletion?(.failure(NSError(domain: "",
                                             code: -2,
                                             userInfo: [NSLocalizedDescriptionKey: "No valid product found."])))
                self.APPPREFIX_purchaseCompletion = nil
            }
            
            return
        }
        SKPaymentQueue.default().add(SKPayment(product: p))
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.APPPREFIX_purchaseCompletion?(.failure(error))
            self.APPPREFIX_purchaseCompletion = nil
        }
        
    }
}

// MARK: - 交易回调
extension JamoMusicChainEntity: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            switch t.transactionState {
            case .purchased:

                self.APPPREFIX_transactionID = t.transactionIdentifier
                SKPaymentQueue.default().finishTransaction(t)
                DispatchQueue.main.async {
                    self.APPPREFIX_purchaseCompletion?(.success(()))
                    self.APPPREFIX_purchaseCompletion = nil
                }
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(t)
                let e = (t.error as? SKError)?.code == .paymentCancelled
                ? NSError(domain: "", code: -999, userInfo: [NSLocalizedDescriptionKey: "Payment cancelled"])
                : (t.error ?? NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Transaction failed."]))
                DispatchQueue.main.async {
                    self.APPPREFIX_purchaseCompletion?(.failure(e))
                    self.APPPREFIX_purchaseCompletion = nil
                }
                
            case .restored:
                SKPaymentQueue.default().finishTransaction(t)
            default:
                break
            }
        }
    }
}

extension JamoMusicChainEntity {
    
    func APPPREFIX_obtainLocalReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        return try? Data(contentsOf: url)
    }

    
    
}

