//
//  Audio.swift
//  AimiHealth
//
//  Created by iMac for iOS on 2017/3/14.
//  Copyright © 2017年 HappinessOfToday. All rights reserved.
//

import UIKit
import AVFoundation
class Audio: UIView {
    @IBOutlet weak var rotatePic: UIImageView!
    @IBOutlet weak var articleImage: UIImageView!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var progress: UISlider!
    var delegate: MiquanDetailsController?
    var link = CADisplayLink()
    override func awakeFromNib() {
        player = AimiPlayer.share.player
        self.link = CADisplayLink.init(target: self, selector: #selector(self.update))
        self.link.add(to: RunLoop.current, forMode: .commonModes)
//        let animate = CABasicAnimation.init(keyPath: "transform.rotation")
//        animate.fromValue = 0
//        animate.toValue = Double.pi * 2
//        animate.duration = 30
//        animate.fillMode = kCAFillModeForwards
//        animate.repeatCount = HUGE
//        self.rotatePic.layer.add(animate, forKey: "RR")
        self.progress.setThumbImage(UIImage.init(named: "progress-thumb"), for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playFinish(not:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playItem)
    }
    var slidingAction = {Void()}
    @IBAction func sliding(_ sender: UISlider) {
        slidingAction()
        self.rotatePic.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2.0 * CGFloat(sender.value))
    }
    
    var endPlay = false
    func playFinish(not:NSNotification) -> Void {
        playBtn.setImage(UIImage.init(named: "bigPlay"), for: .normal)
        endPlay = true
        AVplaying = false
    }
    
    func update() -> Void {
        if let item = player.currentItem{
            playItem = item
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            let totalTime   = TimeInterval(playItem.duration.value) / TimeInterval(playItem.duration.timescale)
            self.currentTime.text = AimiPlayer.formatPlayTime(currentTime)
            self.totalTime.text = AimiPlayer.formatPlayTime(totalTime)
            if !self.isSliding{
                if self.progress.value != 0.00{
                    delegate?.hideHud()
                }
                self.progress.value = Float(currentTime/totalTime)
                self.rotatePic.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2.0 * CGFloat(self.progress.value))
            }
        }
        
    }
    
    var isSliding = false
    var playItem:AVPlayerItem!
    var player = AVPlayer()
    var playBtnAction = {Void()}
    var playing = true{
        didSet{
            AVplaying = playing
            if playing{
                playBtn.setImage(UIImage.init(named: "bigPause"), for: .normal)
            }
            else{
                playBtn.setImage(UIImage.init(named: "bigPlay"), for: .normal)
            }
        }
    }
    var shadowAction = {Void()}
    var pauseTime = CFTimeInterval()
    @IBAction func playBtnClick(_ sender: Any) {
        shadowAction()
        if endPlay{
            endPlay = false
            playBtn.setImage(UIImage.init(named: "bigPause"), for: .normal)
            let seekTime = CMTimeMake(Int64(0), 1)
            self.player.seek(to: seekTime, completionHandler: { (b) in
                self.isSliding = false
                self.player.play()
            })
        }
        else{
        if playing{
            player.pause()
            pauseTime = rotatePic.layer.convertTime(CACurrentMediaTime(), from: nil)
            rotatePic.layer.speed = 0
            playing = false
            if (delegate?.shadowTimer.isValid)!{
                delegate?.shadowTimer.fireDate = Date.distantFuture
            }
            
        }
        else{
            player.play()
            playing = true
//            let begin = CACurrentMediaTime() - pauseTime
//            rotatePic.layer.timeOffset = begin
//            rotatePic.layer.beginTime = begin
//            rotatePic.layer.speed = 1
            self.rotatePic.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2.0 * CGFloat(self.progress.value))
            if (delegate?.shadowTimer.isValid)!{
                delegate?.shadowTimer.fireDate = Date()
            }
        }
        }

    }
    
    

    
    @IBAction func onside(_ sender: UISlider) {
        isSliding = true
        self.rotatePic.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2.0 * CGFloat(sender.value))
    }
    

    @IBAction func touchinside(_ sender: UISlider) {
        if self.player.status == AVPlayerStatus.readyToPlay{
            delegate?.showHud(in: (delegate?.audioView)!)
            let duration = progress.value * Float(CMTimeGetSeconds(self.player.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            self.player.seek(to: seekTime, completionHandler: { (b) in
                self.isSliding = false
            })
        }
        self.rotatePic.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi * 2.0 * CGFloat(sender.value))
    }
    
    
    
}
