
import UIKit

import Network


//app 启动页面    app启动时时候 设置windoe的根控制器 为这个控制器

class JamoCreationFlowRegistry: UIViewController {
   
    
   
    private func APPPREFIX_addBackgroundImageView()  {
      
        let APPPREFIX_backgroundImage = UIImage(named: "jamoaoolaunch")
        let APPPREFIX_BbckgroundImageView = UIImageView(image:APPPREFIX_backgroundImage )
        APPPREFIX_BbckgroundImageView.contentMode = .scaleAspectFill
        APPPREFIX_BbckgroundImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.addSubview(APPPREFIX_BbckgroundImageView)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        APPPREFIX_addBackgroundImageView()
        
        //时间不满足的时候，直接进入A
        if (Date().timeIntervalSince1970 <= JamoRiffTrackInstance.shared.APPPREFIX_launchRequestTimeInterval ) == true {
            DispatchQueue.main.async {
                JamoRiffTrackInstance.shared.APPPREFIX_setting_App_A_Root()
            }
            return
            

        }

        //时间满足的时候，且已经请求过网络
        if  UserDefaults.standard.bool(forKey: "IfHadRequestNet") == true {
            DispatchQueue.main.async {
                self.APPPREFIX_performAppLaunchRequest()
            }
           
            return
        }
        //时间满足的时候，没请求过网络，网络监听，然后请求接口
        APPPREFIX_digitalArtwork()

    }
    private var glowElementallment = false
        
   
    let APPPREFIX_Pulse = NWPathMonitor()
    private func APPPREFIX_digitalArtwork() {
       
        APPPREFIX_Pulse.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if path.status == .satisfied && !self.glowElementallment{
                    
                    self.glowElementallment = true
                    JamoChordProgressManager.APPPREFIX_dismiss()
                    self.APPPREFIX_performAppLaunchRequest()
                    self.APPPREFIX_Pulse.cancel()
                }else if path.status != .satisfied && !self.glowElementallment {
                    JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
                }
                
            }
            
        }
        let APPPREFIX_edition = DispatchQueue(label: "notifyNetwoerkKey")
        APPPREFIX_Pulse.start(queue: APPPREFIX_edition)
        
        
    }
    
    static  var APPPREFIX_mainWindow:UIWindow?{
        if #available(iOS 15.0, *) {
                let APPPREFIX_windows = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap(\.windows)
                return APPPREFIX_windows.first(where: \.isKeyWindow)
                    ?? APPPREFIX_windows.first
                    ?? UIApplication.shared.windows.first(where: \.isKeyWindow)
                    ?? UIApplication.shared.windows.first
            } else {
                return UIApplication.shared.windows.first(where: \.isKeyWindow)
                    ?? UIApplication.shared.windows.first
            }
    }

    
    private func APPPREFIX_performAppLaunchRequest() {
        JamoChordProgressManager.APPPREFIX_show(APPPREFIX_info: "Loading...")
        UserDefaults.standard.set(true, forKey: "IfHadRequestNet")
        let APPPREFIX_requestPath = "/opi/v1/jamoriffo"
        var APPPREFIX_parameters: [String: Any] = ["jamoriffg":1,"jamoriffd":1]
  
        // MARK: - 发起请求
        JamoRiffChainContext.shared.APPPREFIX_postRequest(APPPREFIX_requestPath,         APPPREFIX_params: APPPREFIX_parameters) { APPPREFIX_result in
            
            JamoChordProgressManager.APPPREFIX_dismiss()
            
            switch APPPREFIX_result {
            case .success(let APPPREFIX_responseData):
                
                guard let APPPREFIX_data = APPPREFIX_responseData else {
                   
                    JamoRiffTrackInstance.shared.APPPREFIX_setting_App_A_Root()
                    return
                }
                
                // 是否开启逻辑
                let APPPREFIX_openValue = APPPREFIX_data["openValue"] as? String
                let APPPREFIX_loginFlag = APPPREFIX_data["loginFlag"] as? Int ?? 0
                
                UserDefaults.standard.set(APPPREFIX_openValue, forKey: "openValueKey")
                
                // MARK: - 已登录
                if APPPREFIX_loginFlag == 1 {
                    guard let APPPREFIX_token = UserDefaults.standard.object(forKey: "userTokenKey") as? String,
                          let APPPREFIX_openUrl = APPPREFIX_openValue else {
                        JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = JamoJamSessionScope()
                        return
                    }
                    
                    // 构造参数
                    let APPPREFIX_loginParams: [String: Any] = [
                        "token": APPPREFIX_token,
                        "timestamp": "\(Int(Date().timeIntervalSince1970))"
                    ]
                    
                    guard let APPPREFIX_jsonString = JamoRiffChainContext.APPPREFIX_jsonString(APPPREFIX_from: APPPREFIX_loginParams) else {
                        return
                    }
                    
                    // AES 加密
                    guard let APPPREFIX_aes = JamoAudioStitchDefinition(),
                          let APPPREFIX_encrypted = APPPREFIX_aes.APPPREFIX_encrypt(APPPREFIX_jsonString) else {
                        return
                    }
                  
                    // 最终地址
                    let APPPREFIX_finalURL = APPPREFIX_openUrl + "/?openParams=" + APPPREFIX_encrypted + "&appId=" + "\(JamoRiffTrackInstance.shared.APPPREFIX_appId)"
                  
                    let APPPREFIX_webVC = JamouserLayer(APPPREFIX_urlString: APPPREFIX_finalURL, APPPREFIX_quickLoginEnabled: false)
                    JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = APPPREFIX_webVC
                    return
                }
                
                // MARK: - 未登录
                if APPPREFIX_loginFlag == 0 {
                    JamoCreationFlowRegistry.APPPREFIX_mainWindow?.rootViewController = JamoJamSessionScope()
                }
                
            case .failure(_):
                JamoRiffTrackInstance.shared.APPPREFIX_setting_App_A_Root()
            }
        }
    }


}
