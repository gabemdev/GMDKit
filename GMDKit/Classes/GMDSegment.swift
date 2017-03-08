//
//  GMDSegment.swift
//  Pods
//
//  Created by Gabriel Morales on 3/7/17.
//
//

import UIKit

@IBDesignable
public class GMDSegment: UIControl {
    
    var selectedItem = ""
    var indexSelected: Int = 0
    private var labels = [UILabel]()
    private var containerView = UIView()
    
    private var icons = [UIImageView]()
    private var selectedLabel = UILabel()
    private var icon_image = UIImageView()
    private var selected_icon_image = UIImageView()
    private var withIcon: Bool = true
    
    
    private var icon: [UIImage] = []
    private var selected_icon : [UIImage] = []
    
    @IBInspectable public var defaultBackgroundColor: UIColor! = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    @IBInspectable public var textColor: UIColor! = #colorLiteral(red: 0, green: 0.5647058824, blue: 0.7294117647, alpha: 1) {
        didSet {
            selectedLabel.textColor = textColor
        }
    }
    
    @IBInspectable public var selectedTextColor: UIColor! = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1) {
        didSet {
            selectedLabel.textColor = selectedTextColor
        }
    }
    
    @IBInspectable public var selectedButtonColor: UIColor! = #colorLiteral(red: 0.4431372549, green: 0.3529411765, blue: 0.737254902, alpha: 1) {
        didSet {
            if (isSelected) {
                containerView.backgroundColor = selectedButtonColor
            }
        }
    }
    
    @IBInspectable public var textFont: UIFont! = UIFont.systemFont(ofSize: 10) {
        didSet {
            selectedLabel.font = textFont
        }
    }
    
    override public var isSelected : Bool {
        didSet {
            if (isSelected != oldValue) {
                if isSelected {
                    selectedLabel.textColor = selectedTextColor
                } else {
                    deselect()
                }
            }
        }
    }
    
    private var selectedIndex: Int = 0 {
        didSet {
            displaySelectedIndex()
        }
    }
    
    private func setTextColor() {
        for i in 0..<labels.count {
            labels[i].textColor = textColor
            labels[i].font = textFont
        }
    }
    
    private func setupLabels(_ titles: [String]) {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        
        for index in 1...titles.count {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = titles[index-1]
            label.addTextSpacing(0.5)
            label.backgroundColor = .clear
            label.textAlignment = .center
            label.font = textFont
            label.textColor = isSelected ? selectedTextColor : textColor
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        var calculateIndex: Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculateIndex = index
                selectedItem = "\(item.text)"
            }
        }
        
        if calculateIndex != nil {
            selectedIndex = calculateIndex!
            indexSelected = selectedIndex
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    private func displaySelectedIndex() {
        for (_ , label) in labels.enumerated() {
            label.textColor = textColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedTextColor
        isSelected = true
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.containerView.frame = label.frame
        }, completion: nil)
    }
    
    
    // MARK: Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        #if TARGET_INTERFACE_BUILDER
            addButtonsWithTitles(["One", "Two", "Three"])
        #endif
    }
    
    public func addButtonsWithTitles(_ buttonTitles: [String]) {
        setupLabels(buttonTitles)
        isUserInteractionEnabled = true
        layer.cornerRadius = frame.height / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowOpacity = 0.5
        backgroundColor = defaultBackgroundColor
        setTextColor()
        addIndividualItemConstraints(items: labels, mainView: self, padding: 0)
        insertSubview(containerView, at: 0)
    }
    
    
    public func deselect() {
        isSelected = false
    }
    
    public func select() {
        isSelected = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(labels.count)
        selectFrame.size.width = newWidth
        containerView.frame = selectFrame
        containerView.backgroundColor = selectedButtonColor
        containerView.layer.cornerRadius = containerView.frame.height / 2
        displaySelectedIndex()
    }
    
    
    
    public func addIndividualItemConstraints(items: [UIView], mainView: UIView, padding: CGFloat) {
        for (index, button) in items.enumerated() {
            
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
            
            var rightConstraint : NSLayoutConstraint!
            
            if index == items.count - 1 {
                
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: -padding)
                
            } else{
                
                let nextButton = items[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: -padding)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            
            if index == 0 {
                
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: padding)
                
            } else{
                
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevButton, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: firstItem, attribute: .width, multiplier: 1.0  , constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
}
