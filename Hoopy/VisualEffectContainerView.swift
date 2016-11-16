//
//  Created by Daniel Inoa on 9/24/16.
//  Copyright © 2016 Daniel Inoa. All rights reserved.
//

import UIKit

class VisualEffectContainerView: UIView {

    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure() {
        backgroundColor = .clear
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        visualEffectView.frame = bounds
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(visualEffectView)
        sendSubview(toBack: visualEffectView)
    }

}
