
import UIKit
//loading 提示框 控件

class JamoChordProgressManager {
    
    static let shared = JamoChordProgressManager()
    private let APPPREFIX_overlayTag = 12490908
    private var APPPREFIX_containerView: UIView?
    private var APPPREFIX_indicator: UIActivityIndicatorView?
    private var APPPREFIX_messageLabel: UILabel?
    private var APPPREFIX_iconView: UIImageView?

    class func APPPREFIX_show(APPPREFIX_info:String) {
        shared.APPPREFIX_present(APPPREFIX_message: APPPREFIX_info, APPPREFIX_icon: nil, APPPREFIX_isLoading: true)
    }
    
    class func APPPREFIX_showInfo(APPPREFIX_withStatus message: String) {
        shared.APPPREFIX_dismissIndicator()
        if let APPPREFIX_host = shared.APPPREFIX_currentHostView() {
            JamoRiffNoticeView.show(on: APPPREFIX_host, copy: message, style: .info)
        }
    }
    
    class func APPPREFIX_showSuccess(APPPREFIX_withStatus message: String) {
        shared.APPPREFIX_dismissIndicator()
        if let APPPREFIX_host = shared.APPPREFIX_currentHostView() {
            JamoRiffNoticeView.show(on: APPPREFIX_host, copy: message, style: .success)
        }
    }
    
    class func APPPREFIX_dismiss() {
        shared.APPPREFIX_dismissIndicator()
    }
    
    private func APPPREFIX_present(APPPREFIX_message: String, APPPREFIX_icon: UIImage?, APPPREFIX_isLoading: Bool) {
        DispatchQueue.main.async {
            self.APPPREFIX_presentOnMain(APPPREFIX_message: APPPREFIX_message, APPPREFIX_icon: APPPREFIX_icon, APPPREFIX_isLoading: APPPREFIX_isLoading)
        }
    }

    private func APPPREFIX_presentOnMain(APPPREFIX_message: String, APPPREFIX_icon: UIImage?, APPPREFIX_isLoading: Bool) {
            guard let APPPREFIX_hostView = APPPREFIX_currentHostView() else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                    self?.APPPREFIX_presentOnMain(APPPREFIX_message: APPPREFIX_message, APPPREFIX_icon: APPPREFIX_icon, APPPREFIX_isLoading: APPPREFIX_isLoading)
                }
                return
            }
            APPPREFIX_dismissIndicator()
            
            let APPPREFIX_overlay = UIView()
            APPPREFIX_overlay.tag = APPPREFIX_overlayTag
            APPPREFIX_overlay.backgroundColor = UIColor.black.withAlphaComponent(0.12)
            APPPREFIX_overlay.translatesAutoresizingMaskIntoConstraints = false
            
            let APPPREFIX_container = UIView()
            APPPREFIX_container.backgroundColor = JamoRiffTheme.ink.withAlphaComponent(0.94)
            APPPREFIX_container.layer.cornerRadius = 18
            APPPREFIX_container.layer.shadowColor = UIColor.black.cgColor
            APPPREFIX_container.layer.shadowOpacity = 0.16
            APPPREFIX_container.layer.shadowRadius = 18
            APPPREFIX_container.layer.shadowOffset = CGSize(width: 0, height: 8)
            APPPREFIX_container.translatesAutoresizingMaskIntoConstraints = false
            
            let APPPREFIX_stack = UIStackView()
            APPPREFIX_stack.axis = .vertical
            APPPREFIX_stack.alignment = .center
            APPPREFIX_stack.spacing = 12
            APPPREFIX_stack.translatesAutoresizingMaskIntoConstraints = false
            
            let APPPREFIX_indicatorView = UIActivityIndicatorView(style: .large)
            APPPREFIX_indicatorView.color = JamoRiffTheme.yellow
            APPPREFIX_indicatorView.stopAnimating()
            let APPPREFIX_imageView = UIImageView(image: APPPREFIX_icon)
            APPPREFIX_imageView.tintColor = .white
            APPPREFIX_imageView.contentMode = .scaleAspectFit
            APPPREFIX_imageView.translatesAutoresizingMaskIntoConstraints = false
            APPPREFIX_imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
            APPPREFIX_imageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            let APPPREFIX_label = UILabel()
            APPPREFIX_label.text = APPPREFIX_message
            APPPREFIX_label.textColor = .white
            APPPREFIX_label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            APPPREFIX_label.numberOfLines = 2
            APPPREFIX_label.textAlignment = .center
            
            if APPPREFIX_isLoading {
                APPPREFIX_stack.addArrangedSubview(APPPREFIX_indicatorView)
                APPPREFIX_indicatorView.startAnimating()
            } else if let icon = APPPREFIX_icon {
                APPPREFIX_stack.addArrangedSubview(APPPREFIX_imageView)
            }
            APPPREFIX_stack.addArrangedSubview(APPPREFIX_label)
            
            APPPREFIX_container.addSubview(APPPREFIX_stack)
            APPPREFIX_overlay.addSubview(APPPREFIX_container)
            APPPREFIX_hostView.addSubview(APPPREFIX_overlay)
            
            NSLayoutConstraint.activate([
                APPPREFIX_overlay.topAnchor.constraint(equalTo: APPPREFIX_hostView.topAnchor),
                APPPREFIX_overlay.leadingAnchor.constraint(equalTo: APPPREFIX_hostView.leadingAnchor),
                APPPREFIX_overlay.trailingAnchor.constraint(equalTo: APPPREFIX_hostView.trailingAnchor),
                APPPREFIX_overlay.bottomAnchor.constraint(equalTo: APPPREFIX_hostView.bottomAnchor),
                APPPREFIX_container.centerXAnchor.constraint(equalTo: APPPREFIX_overlay.centerXAnchor),
                APPPREFIX_container.centerYAnchor.constraint(equalTo: APPPREFIX_overlay.centerYAnchor),
                APPPREFIX_container.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
                APPPREFIX_container.widthAnchor.constraint(greaterThanOrEqualToConstant: 132),
                
                APPPREFIX_stack.topAnchor.constraint(equalTo: APPPREFIX_container.topAnchor, constant: 20),
                APPPREFIX_stack.bottomAnchor.constraint(equalTo: APPPREFIX_container.bottomAnchor, constant: -20),
                APPPREFIX_stack.leadingAnchor.constraint(equalTo: APPPREFIX_container.leadingAnchor, constant: 16),
                APPPREFIX_stack.trailingAnchor.constraint(equalTo: APPPREFIX_container.trailingAnchor, constant: -16),
            ])
            
            APPPREFIX_containerView = APPPREFIX_container
            APPPREFIX_indicator = APPPREFIX_indicatorView
            APPPREFIX_messageLabel = APPPREFIX_label
            APPPREFIX_iconView = APPPREFIX_imageView
            
            APPPREFIX_container.alpha = 0
            APPPREFIX_container.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.8,
                           options: .curveEaseOut,
                           animations: {
                APPPREFIX_container.alpha = 1
                APPPREFIX_container.transform = .identity
            })
            
            // 自动隐藏非 loading 的提示
            if !APPPREFIX_isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.APPPREFIX_dismissIndicator()
                }
            }
        }
        
        private func APPPREFIX_dismissIndicator() {
            let APPPREFIX_cleanup = {
                self.APPPREFIX_currentHostView()?.subviews
                    .filter { $0.tag == self.APPPREFIX_overlayTag }
                    .forEach { $0.removeFromSuperview() }
                self.APPPREFIX_containerView = nil
                self.APPPREFIX_indicator?.stopAnimating()
                self.APPPREFIX_indicator = nil
                self.APPPREFIX_messageLabel = nil
                self.APPPREFIX_iconView = nil
            }
            if Thread.isMainThread {
                APPPREFIX_cleanup()
            } else {
                DispatchQueue.main.async(execute: APPPREFIX_cleanup)
            }
        }

        private func APPPREFIX_currentHostView() -> UIView? {
            if let APPPREFIX_window = APPPREFIX_currentWindow() {
                return APPPREFIX_window
            }
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first?.rootViewController?.view
        }

        private func APPPREFIX_currentWindow() -> UIWindow? {
            if #available(iOS 15.0, *) {
                let APPPREFIX_windows = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap(\.windows)
                return APPPREFIX_windows.first(where: \.isKeyWindow)
                    ?? APPPREFIX_windows.first(where: { !$0.isHidden && $0.windowLevel == .normal })
                    ?? APPPREFIX_windows.first
            }
            return UIApplication.shared.windows.first(where: \.isKeyWindow)
                ?? UIApplication.shared.windows.first(where: { !$0.isHidden && $0.windowLevel == .normal })
                ?? UIApplication.shared.windows.first
        }
    }
