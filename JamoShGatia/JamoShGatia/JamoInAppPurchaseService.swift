import Foundation
import StoreKit

enum JamoPurchaseResult {
    case success
    case cancelled
    case pending
}

enum JamoPurchaseError: LocalizedError {
    case productNotFound
    case unverifiedTransaction
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product is unavailable."
        case .unverifiedTransaction:
            return "Purchase could not be verified."
        case .unknown:
            return "Purchase failed. Please try again."
        }
    }
}

final class JamoInAppPurchaseService {
    static let shared = JamoInAppPurchaseService()

    private init() {}

    func purchase(productID: String) async throws -> JamoPurchaseResult {
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            throw JamoPurchaseError.productNotFound
        }

        let result = try await product.purchase()
        switch result {
        case .success(let verificationResult):
            let transaction = try verified(verificationResult)
            await transaction.finish()
            return .success
        case .userCancelled:
            return .cancelled
        case .pending:
            return .pending
        @unknown default:
            throw JamoPurchaseError.unknown
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safeValue):
            return safeValue
        case .unverified:
            throw JamoPurchaseError.unverifiedTransaction
        }
    }
}
