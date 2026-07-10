import Foundation
import WebKit
import UIKit


//public class APPPREFIX_LoginParamaKey: NSObject {
//    public var APPPREFIX_deviceID: String
//
//    public var APPPREFIX_passwordKey: String
//    public init(APPPREFIX_deviceID: String,APPPREFIX_passwordKey:String) {
//        self.APPPREFIX_deviceID = APPPREFIX_deviceID
//      
//        self.APPPREFIX_passwordKey = APPPREFIX_passwordKey
//    }
//}
// 快速登录
class JamoJamSessionScope: UIViewController  {
   
  
    override func viewDidLoad() {
        super.viewDidLoad()
        APPPREFIX_foreLoadWebContent()
        APPPREFIX_addBackgroundImageView()
        APPPREFIX_addLoginButton()
//        APPPREFIX_addSmallImageView()
    }
    
    private func APPPREFIX_addBackgroundImageView()  {
     
        let APPPREFIX_backgroundImage = UIImage(named: "sikokwwwplo")
        
       
        let APPPREFIX_BbckgroundImageView = UIImageView(image:APPPREFIX_backgroundImage )
        APPPREFIX_BbckgroundImageView.contentMode = .scaleAspectFill
        APPPREFIX_BbckgroundImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.addSubview(APPPREFIX_BbckgroundImageView)
       
    }
    
    
    private func APPPREFIX_addLoginButton()  {
        let  APPPREFIX_loginButton = UIButton.init()
        
        let APPPREFIX_backgroundImage = UIImage(named: "welldoner")
     
        APPPREFIX_loginButton.setBackgroundImage(APPPREFIX_backgroundImage, for: .normal)
     
    
        
        
        view.addSubview(APPPREFIX_loginButton)
        APPPREFIX_loginButton.addTarget(self, action: #selector(APPPREFIX_performLoginRequest(APPPREFIX_butn: )), for: .touchUpInside)
        APPPREFIX_loginButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            APPPREFIX_loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            APPPREFIX_loginButton.heightAnchor.constraint(equalToConstant: 52),
            APPPREFIX_loginButton.widthAnchor.constraint(equalToConstant: 331),
            APPPREFIX_loginButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
                                              constant: -self.view.safeAreaInsets.bottom - 55)
        ])
       
    }
   
//    func APPPREFIX_addSmallImageView() {
//        if JamoRiffTrackInstance.shared.APPPREFIX_smallImage != "" {
//            let backgroundImage = UIImage(named:JamoRiffTrackInstance.shared.APPPREFIX_smallImage)
//            
//            let BbckgroundImageView = UIImageView(image:backgroundImage )
//            BbckgroundImageView.contentMode = .scaleAspectFill
////            BbckgroundImageView.frame = CGRect(x: 0, y: 0, width: APPPREFIX_SDKConfig.shared.APPPREFIX_smallImageWidth, height: APPPREFIX_SDKConfig.shared.APPPREFIX_smallImageHeight)
////            BbckgroundImageView.center.x = self.view.center.x
////            BbckgroundImageView.frame.origin.y = -self.view.safeAreaInsets.bottom - 55
////
//            BbckgroundImageView.translatesAutoresizingMaskIntoConstraints = false
//            view.addSubview(BbckgroundImageView)
//            NSLayoutConstraint.activate([
//                BbckgroundImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//                BbckgroundImageView.heightAnchor.constraint(equalToConstant:JamoRiffTrackInstance.shared.APPPREFIX_smallImageHeight),
//                BbckgroundImageView.widthAnchor.constraint(equalToConstant: JamoRiffTrackInstance.shared.APPPREFIX_smallImageWidth),
//                BbckgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor,
//                                                  constant: -self.view.safeAreaInsets.bottom - 55 - JamoRiffTrackInstance.shared.APPPREFIX_logButtonHeight - 30)
//            ])
//            
//        }
//        
//    }
    //预加载
    private func APPPREFIX_foreLoadWebContent()  {
     
        let APPPREFIX_webConfig = WKWebViewConfiguration()
        APPPREFIX_webConfig.allowsAirPlayForMediaPlayback = false
        APPPREFIX_webConfig.allowsInlineMediaPlayback = true
        APPPREFIX_webConfig.preferences.javaScriptCanOpenWindowsAutomatically = true
        APPPREFIX_webConfig.mediaTypesRequiringUserActionForPlayback = []
        
       let APPPREFIX_webViewContainer = WKWebView(frame: UIScreen.main.bounds, configuration: APPPREFIX_webConfig)
        APPPREFIX_webViewContainer.isHidden = true
        APPPREFIX_webViewContainer.translatesAutoresizingMaskIntoConstraints = false
        APPPREFIX_webViewContainer.scrollView.alwaysBounceVertical = false
        APPPREFIX_webViewContainer.scrollView.contentInsetAdjustmentBehavior = .never
        
        APPPREFIX_webViewContainer.allowsBackForwardNavigationGestures = true
        view.addSubview(APPPREFIX_webViewContainer)
       
        if let APPPREFIX_openValue = UserDefaults.standard.object(
            forKey: "openValueKey"
        ) as? String, let url = URL(string: APPPREFIX_openValue) {
            APPPREFIX_webViewContainer.load(URLRequest(url: url))
            
        }
        
        
    }
    
    @objc func APPPREFIX_performLoginRequest(APPPREFIX_butn:UIButton) {
        APPPREFIX_butn.isUserInteractionEnabled = false
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
        
        var APPPREFIX_loginParams: [String: Any] = [:]
        
        // 设备 ID
        APPPREFIX_loginParams["cocreaten"] = JamoRhythmLayerAdapter.APPPREFIX_getEquipmentOnlyID()
       
        // 密码（首次登录才会存在）
        if let APPPREFIX_savedPassword = JamoRhythmLayerAdapter.APPPREFIX_getUserloginpassword() {
            APPPREFIX_loginParams["cocreated"] = APPPREFIX_savedPassword
        }
        
        // 发起登录
        JamoRiffChainContext.shared.APPPREFIX_postRequest(
            "/opi/v1/jamoriffl",
                    APPPREFIX_params: APPPREFIX_loginParams
        ) { result in
            APPPREFIX_butn.isUserInteractionEnabled = true
            JamoChordProgressManager.APPPREFIX_dismiss()
            
            switch result {
            case .success(let APPPREFIX_response):
                
                guard
                    let APPPREFIX_responseDict = APPPREFIX_response,
                    let APPPREFIX_token = APPPREFIX_responseDict["token"] as? String,
                    let APPPREFIX_openValue = UserDefaults.standard.object(
                        forKey: "openValueKey"
                    ) as? String
                else {
                    JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: "Login info invalid!")
                    return
                }
                
                // 密码仅第一次登录返回
                if let APPPREFIX_newPassword = APPPREFIX_responseDict["password"] as? String {
                    JamoRhythmLayerAdapter.APPPREFIX_savedUserloginpassword(APPPREFIX_newPassword)
                }
                
                // 保存 token
                UserDefaults.standard.set(APPPREFIX_token, forKey: "userTokenKey")
                
                
                // MARK: - 拼接加密参数
                let APPPREFIX_secureParams: [String: Any] = [
                    "token": APPPREFIX_token,
                    "timestamp": "\(Int(Date().timeIntervalSince1970))"
                ]
                
                guard let APPPREFIX_json = JamoRiffChainContext.APPPREFIX_jsonString(APPPREFIX_from: APPPREFIX_secureParams) else {
                    return
                }
                
                // AES 加密
                guard let APPPREFIX_aes = JamoAudioStitchDefinition(),
                      let APPPREFIX_encryptedString = APPPREFIX_aes.APPPREFIX_encrypt(APPPREFIX_json)
                else {
                    return
                }
                
           
                // MARK: - 拼接最终 URL
                let APPPREFIX_finalURL =
                    APPPREFIX_openValue +
                    "/?openParams=" + APPPREFIX_encryptedString +
                    "&appId=" + "\(JamoRiffTrackInstance.shared.APPPREFIX_appId)"
                
                
                // MARK: - 跳到 WebView
                let APPPREFIX_webVC = JamouserLayer(
                    APPPREFIX_urlString: APPPREFIX_finalURL,
                    APPPREFIX_quickLoginEnabled: true
                )
                JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = APPPREFIX_webVC
                
                
            case .failure(let APPPREFIX_error):
                JamoChordProgressManager.APPPREFIX_showInfo(APPPREFIX_withStatus: APPPREFIX_error.localizedDescription)
            }
        }
    }

    

}
