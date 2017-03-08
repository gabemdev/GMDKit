//
//  UIView+GMDKit.swift
//  Pods
//
//  Created by Gabriel Morales on 3/8/17.
//
//

import Foundation
import ObjectiveC

extension UIView {
    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        constrainEqual(attribute, to: to, attribute, multiplier: multiplier, constant: constant)
    }
    
    public func constrainEqual(_ attribute: NSLayoutAttribute, to: AnyObject, _ toAttribute: NSLayoutAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: to, attribute: toAttribute, multiplier: multiplier, constant: constant)
            ])
    }
    
    
    public func constrainEdges(to view: UIView) {
        constrainEqual(.top, to: view, .top)
        constrainEqual(.leading, to: view, .leading)
        constrainEqual(.trailing, to: view, .trailing)
        constrainEqual(.bottom, to: view, .bottom)
    }
    
    
    //MARK: - load nib file
    
    public func loadFromNib(_ nibName:String){
        
        let subviews = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let topView = subviews?.first as? UIView else {
            return
        }
        
        topView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(topView)
        topView.frame = self.bounds
    }
    
    //MARK: - frame properties
    public var frameX: CGFloat {
        get{
            return self.frame.origin.x
        }
        
        set{
            self.frame.origin.x = newValue
        }
    }
    
    public var frameY: CGFloat{
        get{
            return self.frame.origin.y
        }
        
        set{
            self.frame.origin.y = newValue
        }
    }
    
    public var frameWidth: CGFloat{
        
        get{
            return self.frame.width
        }
        
        set{
            self.frame.size.width = newValue
        }
    }
    
    public var frameHeight: CGFloat{
        get {
            return self.frame.height
        }
        
        set{
            self.frame.size.height = newValue
        }
    }
    
    public var frameSize: CGSize {
        get {
            return self.frame.size
        }
        
        set {
            self.frame.size = newValue
        }
    }
    
    
    public var frameOrigin: CGPoint {
        get{
            return self.frame.origin
        }
        
        set{
            self.frame.origin = newValue
        }
    }
    
    public var minX: CGFloat {
        get {
            return self.frameX
        }
        
        set {
            self.frameX = newValue
        }
    }
    
    public var minY: CGFloat {
        
        get{
            return self.frameY
        }
        
        set {
            self.frameY = newValue
        }
    }
    
    public var maxX: CGFloat{
        get{
            return self.frame.maxX
        }
        
        set {
            self.frame.origin.x = newValue - self.frameWidth
        }
    }
    
    public var maxY: CGFloat{
        get{
            return self.frame.maxY
        }
        
        set{
            self.frame.origin.y = newValue - self.frameHeight
        }
    }
    
    // MARK: - Background gradient color
    
    public func setBackgroundGradienVertical(color:UIColor)
    {
        self.setBackgroundGradienVertical(topColor: color.withAlphaComponent(0.0), bottomColor: color)
    }
    
    public func setBackgroundGradienVertical(topColor:UIColor, bottomColor:UIColor)
    {
        self.setBackgroundGradien(topColor: topColor, bottomColor: bottomColor, startPoint: CGPoint(x:0.5, y:0.0), endPoint: CGPoint(x:0.5, y:1.0))
    }
    
    /*
     (0, 0) is the top-left corner of the view
     startPoint is where the topColor will star
     endPoint is where the bottomColor will end
     */
    
    public func setBackgroundGradien(topColor:UIColor, bottomColor:UIColor, startPoint:CGPoint, endPoint:CGPoint)
    {
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    //MARK: - loading view
    
    private struct AssociatedKeys {
        static var activityIndicatorName = "activityIndicatorName"
    }
    
    public private(set) var activityIndicator: UIActivityIndicatorView? {
        get {
            
            let indicator = objc_getAssociatedObject(self, &AssociatedKeys.activityIndicatorName) as? UIActivityIndicatorView
            return indicator
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.activityIndicatorName,
                    newValue as UIActivityIndicatorView?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    
    public func showActivityIndicator() {
        
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            
            self.addSubview(self.activityIndicator!)
            self.activityIndicator?.hidesWhenStopped = true
            self.activityIndicator?.centerInSuperview()
        }
        
        self.activityIndicator?.startAnimating()
    }
    
    public func hideActivityIndicator(){
        self.activityIndicator?.stopAnimating()
    }
    
    
    //MARK: - postioning
    
    public func centerInSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    public func centerHorizontallyInSuperview(){
        let centerInX: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview, attribute: .centerX, multiplier: 1, constant: 0)
        self.superview?.addConstraint(centerInX)
    }
    
    public func centerVerticallyInSuperview(){
        let centerInY: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: self.superview, attribute: .centerY, multiplier: 1, constant: 0)
        self.superview?.addConstraint(centerInY)
    }
    
    
    public func mySnapshotImage() -> UIImage? {
        
        UIGraphicsBeginImageContext(self.frame.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    public func mySnapshopImageView() -> UIImageView? {
        guard let image = self.mySnapshotImage() else {
            return nil
        }
        
        return UIImageView(image: image)
        
    }
}
