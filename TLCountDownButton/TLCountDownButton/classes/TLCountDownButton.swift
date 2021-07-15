//
//  TLCountDownButton.swift
//  TLCountDownButton
//
//  Created by Biggerlens on 2021/7/15.
//

import UIKit


let TLScreenWidth = UIScreen.main.bounds.size.width
let TLScreenHeight = UIScreen.main.bounds.size.height
let TLAppDelegate = (UIApplication.shared.delegate) as? AppDelegate
let TLTextColor = UIColor.red
let TLFontSize = TLScreenWidth / 414

func TLFont(_ size: CGFloat) -> UIFont {
    UIFont.boldSystemFont(ofSize: CGFloat((size * TLFontSize)))
}
func TLSetWidth(_ frame: CGRect, _ w: CGFloat) -> CGRect{
    let tframe = CGRect(x: frame.origin.x, y: frame.origin.y, width: w, height: frame.size.height)
    return tframe
}
func TLStringWidth(_ string: NSString, _ font: UIFont) -> CGFloat {
    return string.size(withAttributes: [NSAttributedString.Key.font: font]).width
}

//// 倒计时完成时调的block
typealias CountdownSuccessBlock = (AnyObject?) -> Void
//// 倒计时开始时调的block
typealias CountdownBeginBlock = (AnyObject?) -> Void

enum TLCountDownType : Int {
    case number = 0 // 数字倒计时
    case image // 图片倒计时
}

@objc protocol TLCountDownButtonDelegate: NSObjectProtocol {
    //// 倒计时完成时调用
    @objc optional func countdownSuccess(_ button: AnyObject?)
    //// 倒计时开始时调用
    @objc optional func countdownBegin(_ button: AnyObject?)
    
}



class TLCountDownButton: UIButton {
    /// delegate
    weak var delegate: TLCountDownButtonDelegate?
    private var number = 0
    private var endTitle: String?
    private var countdownSuccessBlock: CountdownSuccessBlock?
    private var countdownBeginBlock: CountdownBeginBlock?
    private var images: [AnyHashable]?
    private var mainImageView: UIImageView? {
        let  imgView = UIImageView.init()
        imgView.isHidden = true
        return imgView
    }
    private var countDownType: TLCountDownType?
    var isAnimationing = false
    static let shared = TLCountDownButton()
    var isScaleNtoIdenty = true
    var scaleMax:CGFloat = 8
    var scaleMin:CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAnimationing = false
        isEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func hidden() {
        isAnimationing = false
        // 复原button状态，这句话必须写，不然有问题
        TLCountDownButton.shared.transform = CGAffineTransform.identity
        TLCountDownButton.shared.delegate = nil
        TLCountDownButton.shared.countdownSuccessBlock = nil
        TLCountDownButton.shared.countdownBeginBlock = nil
        TLCountDownButton.shared.isHidden = true
        
    }
    
    func play(withNumber number: Int, endTitle: String?, begin: @escaping CountdownBeginBlock, success: @escaping CountdownSuccessBlock) -> Self? {
        // isAnimationing 用来判断目前是否在动画
        let button = TLCountDownButton.shared
        if isAnimationing {
            return nil
        }
        
        button.isHidden = false
        // 给全局属性赋值
        // 默认三秒
        button.number = 3
        if number != 0 && number > 0 {
               button.number = number
           }
       if let endTitle = endTitle {
           button.endTitle = endTitle
       }
        button.countdownSuccessBlock = success
        button.countdownBeginBlock = begin

         self.setupButtonBase(button)

         // 动画倒计时部分
        self.scaleAction(with: begin, andSuccessBlock: success, button: button)
        return button as? Self
        
    }
    
    func play(withNumber number: Int, endTitle: String?, success: @escaping CountdownSuccessBlock) -> Self? {
        return self.play(withNumber: number, endTitle: endTitle, begin: TLCountDownButton.shared.countdownBeginBlock ?? {_ in }, success: success)
    }
    
    
    // button的基本属性
    private func setupButtonBase(_ button: TLCountDownButton?) {
        guard let button = button else {
            return
        }
        button.isHidden = false
        button.frame = CGRect(x: 0, y: 0, width: TLScreenWidth, height: TLScreenHeight)
        if isScaleNtoIdenty {
            button.transform = (button.transform.scaledBy(x: scaleMax, y: scaleMax))
        }else{
            
            button.transform = (button.transform.scaledBy(x: scaleMin, y: scaleMin))
        }
       
        button.alpha = 0
        if  button.countDownType != TLCountDownType.image {
                button.setTitle(String(format: "%zd", number), for: .normal)
        }
        button.setTitleColor(TLTextColor, for: .normal)
        button.titleLabel!.font = TLFont(20.0)
        
        if let curView = UIViewController.current()?.view {
            curView.addSubview(button)
        }
        button.center = CGPoint(x: Int(TLScreenWidth) / 2, y: Int(TLScreenHeight) / 2)
        button.titleLabel?.textAlignment = .center
    }
    
    // 动画倒计时部分
    func scaleAction(with begin: CountdownBeginBlock?, andSuccessBlock success: CountdownSuccessBlock?, button: TLCountDownButton?) {
        if !isAnimationing {
            // 如果不在动画, 才走开始的代理和block
            if let begin = begin {
                begin(button)
            }
            if let button = button, button.delegate?.responds(to: #selector(TLCountDownButtonDelegate.countdownBegin(_:))) == true {
                button.delegate?.countdownBegin?(button)
            }
        }

        if let button = button, button.countDownType == TLCountDownType.image {
            setAnimationImage(button)
        } else {
            setAnimationNumber(button)
        }
    
    }
    // 播放倒计时图片
    func setAnimationImage(_ button: TLCountDownButton?) {
        if let button = button, let images = button.images, images.count > 0 {
            isAnimationing = true
            button.setImage(UIImage(named: images.first as? String ?? ""), for: .normal)
            UIView.animate(withDuration: 1.0, animations: { [self] in
                if isScaleNtoIdenty {
                    button.transform = CGAffineTransform.identity
                }else{
                    button.transform = CGAffineTransform(scaleX: scaleMax, y: scaleMax)
                }
                
                button.alpha = 1
            }) { [self] finished in
                if finished {
                    button.alpha = 0
                    if isScaleNtoIdenty {
                      button.transform = CGAffineTransform(scaleX: scaleMax, y: scaleMax)
                    }else{
                        button.transform = CGAffineTransform(scaleX: scaleMin, y: scaleMin)
                            //CGAffineTransform.identity
                    }
                    
                    if images.count > 0 {
                        button.images?.remove(at: 0)
                        self.scaleAction(with: button.countdownBeginBlock, andSuccessBlock: button.countdownSuccessBlock, button: button)
                    }
                }
            }

        }else{
            // 调用倒计时完成的代理和block
            if button?.delegate?.responds(to: #selector(TLCountDownButtonDelegate.countdownSuccess(_:))) == true {
                button?.delegate?.countdownSuccess?(button)
            }

            if let tcountdownSuccessBlock = button?.countdownSuccessBlock {
                tcountdownSuccessBlock(button)
            }
            hidden()
        }
    }
    
    
    func setAnimationNumber(_ button: TLCountDownButton?) {
        // 这个判断用来表示有没有结束语
        guard let button = button else {
            return
        }
        if button.number >= ((button.endTitle != nil) ? 0 : 1) {
            isAnimationing = true
            button.setTitle(button.number == 0 ? button.endTitle : String(format: "%zd", button.number), for: .normal)
            UIView.animate(withDuration: 1, animations: { [self] in
                if isScaleNtoIdenty {
                    button.transform = CGAffineTransform.identity
                }else{
                    button.transform = CGAffineTransform(scaleX: scaleMax, y: scaleMax)
                }
                
                button.alpha = 1
            }) { [self] finished in
                if finished {
                    button.number -= 1
                    button.alpha = 0
                    if isScaleNtoIdenty {
                        button.transform = CGAffineTransform(scaleX: scaleMax, y: scaleMax)
                    }else{
                        button.transform =  CGAffineTransform(scaleX: scaleMin, y: scaleMin)
                    }
                    scaleAction(with: button.countdownBeginBlock, andSuccessBlock: button.countdownSuccessBlock, button: button)
                }
            }
        }else{
            // 调用倒计时完成的代理和block
            if button.delegate?.responds(to: #selector(TLCountDownButtonDelegate.countdownSuccess(_:))) == true {
                button.delegate?.countdownSuccess?(button)
            }

            if let tcountdownSuccessBlock = button.countdownSuccessBlock {
                tcountdownSuccessBlock(button)
            }
            hidden()
        }
    }
    
    
    // MARK: - play methods
    func play() -> Self? {
        return self.play(withNumber: 0)
    }
//TLCountDownButton.shared
    func play(withNumber number: Int) -> Self? {
        return self.play(withNumber: number, endTitle: self.endTitle)
    }
    func play(withNumber number: Int, endTitle: String?) -> Self? {
        return self.play(withNumber: number, endTitle: endTitle, success: TLCountDownButton.shared.countdownSuccessBlock ?? {_ in})
    }

    func play(withNumber number: Int, success: @escaping CountdownSuccessBlock) -> Self? {
        return self.play(withNumber: number, endTitle: self.endTitle, success: success)
    }
    
    // MARK: - add block
    func addSucessBlock(_ success: @escaping CountdownSuccessBlock) {
        TLCountDownButton.shared.countdownSuccessBlock = success
    }

    func addBdginBlock(_ begin: @escaping CountdownBeginBlock) {
        TLCountDownButton.shared.countdownBeginBlock = begin
    }

    func add(_ begin: @escaping CountdownBeginBlock, successBlock success: @escaping CountdownSuccessBlock) {
        TLCountDownButton.shared.countdownSuccessBlock = success
        TLCountDownButton.shared.countdownBeginBlock = begin
    }
    
    // MARK: - add delegate
    func addDelegate(_ delegate: TLCountDownButtonDelegate?) {
        TLCountDownButton.shared.delegate = delegate
    }
    func play(withImages images: [AnyHashable]?, begin: @escaping CountdownBeginBlock, success: @escaping CountdownSuccessBlock) -> Self? {
        return self.play(withImages: images, duration: TimeInterval((images?.count ?? 0)), begin: begin, success: success)
    }

    func play(withImages images: [AnyHashable]?, duration: TimeInterval, begin: @escaping CountdownBeginBlock, success: @escaping  CountdownSuccessBlock) -> Self? {
        let countDownButton = TLCountDownButton.shared
        countDownButton.countdownBeginBlock = begin
        countDownButton.countdownSuccessBlock = success
        countDownButton.countDownType = TLCountDownType.image
        countDownButton.images = images
        setupButtonBase(countDownButton)
        scaleAction(with: begin, andSuccessBlock: success, button: countDownButton)
        return countDownButton as? Self
    }

}



