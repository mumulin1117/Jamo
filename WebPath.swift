//A模版 path

enum TOWINKLIopVibeRoute: String {


    case TOWINKLIopSparkAI = "pages/DynamicDetails/index?dynamicId=?" // 动态详情  动态ID
    case TOWINKLIopVibeVault = "pages/ReleaseDynamic/index?"// 发布动态
    case TOWINKLIopAromaDetail = "pages/screenplay/index?" // AI创作
    case TOWINKLIopMomentDetail = "pages/CreateRole/index?" // AI虚拟角色
   
    case TOWINKLIopPostArticle = "pages/privateChat/index?userId="// 私聊 用户ID (拨打视频时增加参数 CallVideo=1 )
    case TOWINKLIopPostVisual = "pages/HomePage/index?userId="// 他人主页  用户ID
    case TOWINKLIopUserCore = "pages/Setting/index?"// 设置
    case TOWINKLIopReportNode = "pages/EditData/index?"// 编辑资料
    case TOWINKLIopAuthVerify = "pages/attention/index?type="// 1互关 2 关注 3粉丝 4黑名单
    case TOWINKLIopProfileModify = "pages/Agreement/index?type=1"//用户协议
    
    case TOWINKLIopFollowGroup = "pages/Agreement/index?type=2"//隐私政策
    case TOWINKLIopFanGroup = "pages/Report/index?"//举报页面
    case TOWINKLIopBalanceVault = "pages/VoucherCenter/index?"//充值页面
    case TOWINKLIopMasterConfig = "pages/VideoDetails/index?dynamicId="//视频详情 动态ID
    case TOWINKLIopLegalTerms = "pages/releaseVideos/index?"//发布视频
    
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
