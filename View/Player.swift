//
//  Player.swift
//  test
//
//  Created by apple on 2016/12/15.
//  Copyright © 2016年 HappinessOfToday. All rights reserved.
//

import UIKit
import AVFoundation
protocol PlayerDelegate:NSObjectProtocol {

    func Player(_ playerView:Player,SliderTouchUpOut Slider:UISlider)
    func Player(_ playerView:Player,playAndPause playBtn:UIButton)
}


class Player: UIView {
    var playerLayer:AVPlayerLayer?//
//    var Slider:UISlider!
    @IBOutlet weak var Slider: UISlider!
    @IBOutlet weak var progressView: UIProgressView!
//    var progressView:UIProgressView!


    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    var sliding = false
    var playing = true
    weak var delegate:PlayerDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backBtn.layer.cornerRadius = 23
        playBtn.addTarget(self, action: #selector(playAndPause( _:)) , for: UIControlEvents.touchUpInside)
        // 按下的时候
        Slider.addTarget(self, action: #selector(SliderTouchDown( _:)), for: UIControlEvents.touchDown)
        // 弹起的时候
        Slider.addTarget(self, action: #selector(SliderTouchUpOut( _:)), for: UIControlEvents.touchUpOutside)
        Slider.addTarget(self, action: #selector(SliderTouchUpOut( _:)), for: UIControlEvents.touchUpInside)
        Slider.addTarget(self, action: #selector(SliderTouchUpOut( _:)), for: UIControlEvents.touchCancel)

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }

    var backAction = {Void()}
    @IBAction func bacnBtnClick(_ sender: Any) {
        backAction()
    }

    @IBAction func userSliding(_ sender: Any) {
        slideAction()
    }

    @IBAction func slideChange(_ sender: Any) {
        touchUpSliderAction()
    }

    var slideAction = {Void()}
    func SliderTouchDown(_ Slider:UISlider){
        self.sliding = true
    }
    var touchUpSliderAction = {Void()}
    func SliderTouchUpOut(_ Slider:UISlider){
        delegate?.Player(self, SliderTouchUpOut: Slider)
    }

    var PVhidden = false{
        didSet{
            self.barView.isHidden = PVhidden
            self.playBtn.isHidden = PVhidden
            self.timeLabel.isHidden = PVhidden
        }
    }



    func playAndPause(_ btn:UIButton){
        let tmp = !playing
        playing = tmp
        if playing {
            playBtn.setImage(UIImage(named: "暂停"), for: UIControlState())
        }else{
            playBtn.setImage(UIImage(named: "播放"), for: UIControlState())
        }
        delegate?.Player(self, playAndPause: btn)
    }
}




//MARK: - 延时执行
func delay(_ seconds: Double, completion:@escaping ()->()) {
    let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }


}

