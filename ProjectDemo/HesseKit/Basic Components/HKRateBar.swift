//
//  HKRatingBar.swift
//  MobiDoc-Patient
//
//  Created by Hesse Huang on 18/5/2018.
//  Copyright © 2018 bichenkk. All rights reserved.
//

import UIKit

@objc protocol HKRateBarDelegate: NSObjectProtocol {
    @objc optional func rateBarRatingDidChange(_ rateBar: HKRateBar)
}

class HKRateBar: UIView {
    
    // The rating components are arranged inside this stack view.
    public let stackView = UIStackView()
    
    /// The maximum number of rates (stars).
    /// Setting this value could trigger relayout the whole bar object.
    open var maximumNumberOfRates: Int = 5 {
        didSet {
            relayoutRateComponent()
        }
    }
    
    /// The image used when a rating is on.
    open var onImage: UIImage?
    /// The image used when a rating is off.
    open var offImage: UIImage?
    
    open weak var delegate: HKRateBarDelegate?
    
    open private(set) var rating: Int = 0 {
        didSet {
            updateRatingButtonsAppearance()
            delegate?.rateBarRatingDidChange?(self)
        }
    }
    
    private var rateButtons = [UIButton]()
    
    init(frame: CGRect,
         presetRating: Int = 0,
         onImage: UIImage? = UIImage.withStarShape(size: CGSize(width: 36, height: 36),
                                                   strokeColor: .yellow,
                                                   fillColor: .yellow),
         offImage: UIImage? = UIImage.withStarShape(size: CGSize(width: 36, height: 36),
                                                    strokeColor: .yellow,
                                                    fillColor: .white)) {
        self.rating = presetRating
        self.onImage = onImage
        self.offImage = offImage
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = bounds
    }
    
    private func commonInit() {
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        addSubview(stackView)
        
        relayoutRateComponent()
        updateRatingButtonsAppearance()
    }
    
    private func relayoutRateComponent() {
        // Clean up
        rateButtons.forEach {
            stackView.removeArrangedSubview($0)
        }
        rateButtons.removeAll()
        
        // Add new ones
        for r in 0 ..< maximumNumberOfRates {
            let button = UIButton(type: .system)
            button.setImage(r < rating ? onImage : offImage, for: .normal)
            button.addTarget(self, action: #selector(rateButtonDidClick(_:)), for: .touchUpInside)
            rateButtons.append(button)
            stackView.addArrangedSubview(button)
        }
    }
    
    @objc private func rateButtonDidClick(_ sender: UIButton) {
        guard let i = rateButtons.firstIndex(of: sender) else {
            return
        }
        // i is in 0...4
        rating = i + 1
    }
    
    private func updateRatingButtonsAppearance() {
        for r in 0 ..< maximumNumberOfRates {
            rateButtons[r].setImage(r < rating ? onImage : offImage, for: .normal)
        }
    }
    
}
