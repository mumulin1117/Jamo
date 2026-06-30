

enum TOWINKLIopVibeRoute: String {


    case TOWINKLIopSparkAI = "pages/DynamicDetails/index?dynamicId=?" 
    case TOWINKLIopVibeVault = "pages/ReleaseDynamic/index?"
    case TOWINKLIopAromaDetail = "pages/screenplay/index?" 
    case TOWINKLIopMomentDetail = "pages/CreateRole/index?" 
   
    case TOWINKLIopPostArticle = "pages/privateChat/index?userId="
    case TOWINKLIopPostVisual = "pages/HomePage/index?userId="
    case TOWINKLIopUserCore = "pages/Setting/index?"
    case TOWINKLIopReportNode = "pages/EditData/index?"
    case TOWINKLIopAuthVerify = "pages/attention/index?type="
    case TOWINKLIopProfileModify = "pages/Agreement/index?type=1"
    
    case TOWINKLIopFollowGroup = "pages/Agreement/index?type=2"
    case TOWINKLIopFanGroup = "pages/Report/index?"
    case TOWINKLIopBalanceVault = "pages/VoucherCenter/index?"
    case TOWINKLIopMasterConfig = "pages/VideoDetails/index?dynamicId="
    case TOWINKLIopLegalTerms = "pages/releaseVideos/index?"
    
    case TOWINKLIopVoidChannel = ""
  
    func TOWINKLIopConstructFinalPath(TOWINKLIopQuery: String) -> String {
        let TOWINKLIopBaseGateway = "http://modernlifestylehub99globalmarket.shop/#"
        
        if self != .TOWINKLIopVoidChannel {
            let TOWINKLIopAuthToken = Network.TOWINKLIopSessionToken ?? ""
            let TOWINKLIopUniqueAppId = "81266843"
            
            let TOWINKLIopMergedPath = String(
                format: "%@%@%@&token=%@&appID=%@",
                TOWINKLIopBaseGateway,
                self.rawValue,
                TOWINKLIopQuery,
                TOWINKLIopAuthToken,
                TOWINKLIopUniqueAppId
            )
            
            return TOWINKLIopMergedPath
        }
        
        return TOWINKLIopBaseGateway
    }
   

}
