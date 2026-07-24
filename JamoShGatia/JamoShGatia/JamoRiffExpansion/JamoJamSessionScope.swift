import UIKit
class JamoJamSessionScope: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        JamoRiffBridgeKit.addBackground(named: "sikokwwwplo", to: view)
        JamoRiffBridgeKit.addBridgeButton(to: view, target: self, action: #selector(APPPREFIX_performLoginRequest(APPPREFIX_butn:)))
    }
    @objc func APPPREFIX_performLoginRequest(APPPREFIX_butn: UIButton) {
        APPPREFIX_butn.isUserInteractionEnabled = false
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
        JamoRiffChainContext.shared.APPPREFIX_postRequest("/opi/v1/jamoriffl", APPPREFIX_params: APPPREFIX_loginPayload()) { result in
            APPPREFIX_butn.isUserInteractionEnabled = true
            JamoChordProgressManager.APPPREFIX_dismiss()
            self.APPPREFIX_finishLogin(result)
        }
    }
    private func APPPREFIX_loginPayload() -> [String: Any] {
        var payload: [String: Any] = ["cocreaten": JamoRhythmLayerAdapter.APPPREFIX_getEquipmentOnlyID()]
        if let password = JamoRhythmLayerAdapter.APPPREFIX_getUserloginpassword() {
            payload["cocreated"] = password
        }
        return payload
    }
    private func APPPREFIX_finishLogin(_ result: Result<[String: Any]?, Error>) {
        guard case .success(let response) = result,
              let response,
              let token = response["token"] as? String,
              let openValue = UserDefaults.standard.object(forKey: "openValueKey") as? String,
              let url = JamoRiffBridgeKit.secureURL(openValue: openValue, token: token) else {
            if case .failure(let error) = result {
                JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: error.localizedDescription)
            } else {
                JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: "Login info invalid!")
            }
            return
        }
        if let password = response["password"] as? String {
            JamoRhythmLayerAdapter.APPPREFIX_savedUserloginpassword(password)
        }
        UserDefaults.standard.set(token, forKey: "userTokenKey")
        JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = JamouserLayer(APPPREFIX_urlString: url, APPPREFIX_quickLoginEnabled: true)
    }
}
