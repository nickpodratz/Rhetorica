//
//  CustomHUD.swift
//  Pods
//
//  Created by Nick Podratz on 13.04.16.
//
//

import Foundation
import PKHUD

class CustomHUDBaseView: PKHUDSquareBaseView {
    
    private let color = UIColor(white: 0.11, alpha: 1)

    override func layoutSubviews() {
        super.layoutSubviews()
        
        subtitleLabel.font = UIFont.boldSystemFontOfSize(16.0)
        subtitleLabel.textColor = color
        subtitleLabel.numberOfLines = 2
        subtitleLabel.frame.origin.y = bounds.size.height / 3 * 2
    }
    
    func animateAdded() {
        let pinLayer = PinLayer()
        pinLayer.color = color
        layer.addSublayer(pinLayer)
        
        pinLayer.frame = CGRect(
            x: self.bounds.width/3,
            y: self.bounds.height/4,
            width: self.bounds.width/3,
            height: self.bounds.height/3
        )
        pinLayer.animateHoverIn()
    }
    
    func animateRemoved() {
        let pinLayer = PinLayer()
        pinLayer.color = color

        let crossLayer = PinCrossLayer()
        crossLayer.color = color
        
        layer.addSublayer(pinLayer)
        layer.addSublayer(crossLayer)
        //            view.layer.mask = crossLayer
        pinLayer.frame = CGRect(
            x: self.bounds.width/3,
            y: self.bounds.height/4,
            width: self.bounds.width/3,
            height: self.bounds.height/3
        )
        crossLayer.frame = CGRect(
            x: self.bounds.width/3,
            y: self.bounds.height/4,
            width: self.bounds.width/3,
            height: self.bounds.height/3
        )
        crossLayer.animateCrossOut()

    }
}