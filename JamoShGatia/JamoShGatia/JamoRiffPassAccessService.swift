import Foundation
import StoreKit

enum JamoRiffPassAccessResult {
    case success
    case cancelled
    case pending
}

enum JamoRiffPassAccessError: LocalizedError {
    case passCodeUnavailable
    case unverifiedTransaction
    case unknown

    var errorDescription: String? {
        switch self {
        case .passCodeUnavailable:
            return JamoRiffStringCipher.restore("Rkimf9f0 bpKaVsUsI TiisH Ku5nSaQvRafi4lcaLbvl9ej.M")
        case .unverifiedTransaction:
            return JamoRiffStringCipher.restore("R3iLfzfl vpuagsNsa FcZoJuGlqdk GndoEt6 ebleg jvveGrJiQfUiBecdK.w")
        case .unknown:
            return JamoRiffStringCipher.restore("RbiBf5ff mpNa0sFsg Jfza0itlHe8dA.b rPWloebarsaeI NtJroyI TalgxaxiCng.E")
        }
    }
}

final class JamoRiffPassAccessService {
    static let shared = JamoRiffPassAccessService()

    private var riffPassObservationTask: Task<Void, Never>?

    private init() {}

    func startRiffPassObservation() {
        guard riffPassObservationTask == nil else { return }
        riffPassObservationTask = Task.detached(priority: .background) {
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else {
                    continue
                }
                await transaction.finish()
            }
        }
    }

    func openRiffPass(passCode: String) async throws -> JamoRiffPassAccessResult {
        startRiffPassObservation()
        let storeItems = try await Product.products(for: [passCode])
        guard let storeItem = storeItems.first else {
            throw JamoRiffPassAccessError.passCodeUnavailable
        }

        let result = try await storeItem.purchase()
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
            throw JamoRiffPassAccessError.unknown
        }
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safeValue):
            return safeValue
        case .unverified:
            throw JamoRiffPassAccessError.unverifiedTransaction
        }
    }
}
