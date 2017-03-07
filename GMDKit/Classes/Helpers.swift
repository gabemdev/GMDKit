//
//  Helpers.swift
//  Pods
//
//  Created by Gabriel Morales on 3/7/17.
//
//

import UIKit
import MapKit
import ObjectiveC

let MERCATOR_OFFSET = 268435456.0
let MERCATOR_RADIUS = 85445659.44705395
let DEGREES = 180.0

class Helpers: NSObject {
    
    
    /// Get dictionary from any PLIST
    ///
    /// - Parameter plist: Any file of plist type
    /// - Returns: Optional NSDictionary
    class func getDictionaryFromPlist(plist: String) -> NSDictionary? {
        guard let path = Bundle.main.path(forResource: plist, ofType: "plist") else { return nil }
        let dict = NSDictionary(contentsOfFile: path)
        return dict
    }
}

extension UIViewController {
    
    /// Utility that presents an alert with 1 dismissal action.
    ///
    /// - Parameters:
    ///   - title: Any string for alert title.
    ///   - message: Any string for alert message.
    func showAlert(withTitle title:String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    var contentViewController: UIViewController {
        if let navController = self as? UINavigationController {
            return navController.visibleViewController!
        } else {
            return self
        }
    }
}

extension UILabel{
    func addTextSpacing(_ spacing: CGFloat){
        let attributedString = NSMutableAttributedString(string: text!)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSRange(location: 0, length: text!.characters.count))
        attributedText = attributedString
    }
}

extension UIColor {
    
    final class func color(_ r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
}

extension MKMapView {
    //MARK: Map Conversion Methods
    private func longitudeToPixelSpaceX(longitude:Double)->Double{
        return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / DEGREES)
    }
    
    private func latitudeToPixelSpaceY(latitude:Double)->Double{
        return round(MERCATOR_OFFSET - MERCATOR_RADIUS * log((1 + sin(latitude * M_PI / DEGREES)) / (1 - sin(latitude * M_PI / DEGREES))) / 2.0)
    }
    
    private func pixelSpaceXToLongitude(pixelX:Double)->Double{
        return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * DEGREES / M_PI
        
    }
    
    private func pixelSpaceYToLatitude(pixelY:Double)->Double{
        return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * DEGREES / M_PI
    }
    
    private func coordinateSpanWithCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double)->MKCoordinateSpan{
        
        // convert center coordiate to pixel space
        let centerPixelX = longitudeToPixelSpaceX(longitude: centerCoordinate.longitude)
        let centerPixelY = latitudeToPixelSpaceY(latitude: centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent:Double = 20.0 - zoomLevel
        let zoomScale:Double = pow(2.0, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSizeInPixels = self.bounds.size
        let scaledMapWidth = Double(mapSizeInPixels.width) * zoomScale
        let scaledMapHeight = Double(mapSizeInPixels.height) * zoomScale
        
        // figure out the position of the top-left pixel
        let topLeftPixelX = centerPixelX - (scaledMapWidth / 2.0)
        let topLeftPixelY = centerPixelY - (scaledMapHeight / 2.0)
        
        // find delta between left and right longitudes
        let minLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX)
        let maxLng = pixelSpaceXToLongitude(pixelX: topLeftPixelX + scaledMapWidth)
        let longitudeDelta = maxLng - minLng
        
        let minLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY)
        let maxLat = pixelSpaceYToLatitude(pixelY: topLeftPixelY + scaledMapHeight)
        let latitudeDelta = -1.0 * (maxLat - minLat)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func setCenterCoordinate(centerCoordinate:CLLocationCoordinate2D, zoomLevel:Double, animated:Bool){
        // clamp large numbers to 28
        var zoomLevel = zoomLevel
        zoomLevel = min(zoomLevel, 28)
        
        // use the zoom level to compute the region
        let span = self.coordinateSpanWithCenterCoordinate(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        if region.center.longitude == -180.00000000{
            debugPrint("Invalid Region")
        }
        else{
            self.setRegion(region, animated: animated)
        }
    }
}

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {return UIImage()}
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else {return UIImage()}
        UIGraphicsEndImageContext()
        return img
    }
    
    public func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        
        if(widthRatio > heightRatio) {
            newSize = CGSize(width:size.width * heightRatio, height: size.height * heightRatio)
        }
        else {
            newSize = CGSize(width:size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

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
    
    /// If the `view` is nil, we take the superview.
    public func center(in view: UIView? = nil) {
        guard let container = view ?? self.superview else { fatalError() }
        if #available(iOS 9.0, *) {
            centerXAnchor.constrainEqual(container.centerXAnchor)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            centerYAnchor.constrainEqual(container.centerYAnchor)
        } else {
            // Fallback on earlier versions
        }
    }
    
    //MARK: - load nib file
    
    open func loadFromNib(_ nibName:String){
        
        let subviews = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        guard let topView = subviews?.first as? UIView else {
            return
        }
        
        topView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(topView)
        topView.frame = self.bounds
    }
    
    //MARK: - frame properties
    open var frameX: CGFloat {
        get{
            return self.frame.origin.x
        }
        
        set{
            self.frame.origin.x = newValue
        }
    }
    
    open var frameY: CGFloat{
        get{
            return self.frame.origin.y
        }
        
        set{
            self.frame.origin.y = newValue
        }
    }
    
    open var frameWidth: CGFloat{
        
        get{
            return self.frame.width
        }
        
        set{
            self.frame.size.width = newValue
        }
    }
    
    open var frameHeight: CGFloat{
        get {
            return self.frame.height
        }
        
        set{
            self.frame.size.height = newValue
        }
    }
    
    open var frameSize: CGSize {
        get {
            return self.frame.size
        }
        
        set {
            self.frame.size = newValue
        }
    }
    
    
    open var frameOrigin: CGPoint {
        get{
            return self.frame.origin
        }
        
        set{
            self.frame.origin = newValue
        }
    }
    
    open var minX: CGFloat {
        get {
            return self.frameX
        }
        
        set {
            self.frameX = newValue
        }
    }
    
    open var minY: CGFloat {
        
        get{
            return self.frameY
        }
        
        set {
            self.frameY = newValue
        }
    }
    
    open var maxX: CGFloat{
        get{
            return self.frame.maxX
        }
        
        set {
            self.frame.origin.x = newValue - self.frameWidth
        }
    }
    
    open var maxY: CGFloat{
        get{
            return self.frame.maxY
        }
        
        set{
            self.frame.origin.y = newValue - self.frameHeight
        }
    }
    
    // MARK: - Background gradient color
    
    open func setBackgroundGradienVertical(color:UIColor)
    {
        self.setBackgroundGradienVertical(topColor: color.withAlphaComponent(0.0), bottomColor: color)
    }
    
    func setBackgroundGradienVertical(topColor:UIColor, bottomColor:UIColor)
    {
        self.setBackgroundGradien(topColor: topColor, bottomColor: bottomColor, startPoint: CGPoint(x:0.5, y:0.0), endPoint: CGPoint(x:0.5, y:1.0))
    }
    
    /*
     (0, 0) is the top-left corner of the view
     startPoint is where the topColor will star
     endPoint is where the bottomColor will end
     */
    
    open func setBackgroundGradien(topColor:UIColor, bottomColor:UIColor, startPoint:CGPoint, endPoint:CGPoint)
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
    
    open private(set) var activityIndicator: UIActivityIndicatorView? {
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
    
    
    open func showActivityIndicator() {
        
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
            
            self.addSubview(self.activityIndicator!)
            self.activityIndicator?.hidesWhenStopped = true
            self.activityIndicator?.centerInSuperview()
        }
        
        self.activityIndicator?.startAnimating()
    }
    
    open func hideActivityIndicator(){
        self.activityIndicator?.stopAnimating()
    }
    
    
    //MARK: - postioning
    
    open func centerInSuperview() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerHorizontallyInSuperview()
        self.centerVerticallyInSuperview()
    }
    
    open func centerHorizontallyInSuperview(){
        let centerInX: NSLayoutConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: self.superview, attribute: .centerX, multiplier: 1, constant: 0)
        self.superview?.addConstraint(centerInX)
    }
    
    open func centerVerticallyInSuperview(){
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

@available(iOS 9.0, *)
extension NSLayoutAnchor {
    public func constrainEqual(_ anchor: NSLayoutAnchor, constant: CGFloat = 0) {
        let constraint = self.constraint(equalTo: anchor, constant: constant)
        constraint.isActive = true
    }
    
}

extension Date {
    
    static let formatter = DateFormatter()
    
    static func yesterday() -> Date {
        
        return Date().dateWith(daysToAdd: -1, monthsToAdd: 0)
    }
    
    static func today() -> Date {
        
        return Date().dateWith(daysToAdd: 0, monthsToAdd: 0).dateByZeroOutTimeComponents()
    }
    
    static func tomorrow() -> Date {
        
        return Date().dateWith(daysToAdd: 1, monthsToAdd: 0)
    }
    
    public func dateByAddingDays(days: Int) -> Date {
        return self.days(days: days)
    }
    
    public func dateBySubstractingDays(days: Int) -> Date {
        return self.days(days: -days)
    }
    
    public func days(days:Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
    
    func dateWith(daysToAdd:Int, monthsToAdd:Int) -> Date{
        let gregorian = NSCalendar.current
        var components = DateComponents()
        components.day = daysToAdd
        components.month = monthsToAdd
        
        return gregorian.date(byAdding: components, to: self)!
    }
    
    func dateByZeroOutTimeComponents() -> Date{
        
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(Set([.year, .month, .day]), from: self)
        self.zeroOutTimeComponents(&components)
        return calendar.date(from: components)!
    }
    
    func zeroOutTimeComponents( _ components:inout DateComponents) {
        components.hour = 0
        components.minute = 0
        components.second = 0
    }
    
    func timelessCompare(date:Date) -> ComparisonResult? {
        
        let date1 = self.dateByZeroOutTimeComponents()
        let date2 = date.dateByZeroOutTimeComponents()
        return date1.compare(date2)
    }
    
    func isSameDayAs(_ date:Date) -> Bool {
        
        Date.formatter.dateFormat = "MM/dd/yyyy"
        Date.formatter.timeZone = TimeZone(identifier: "America/Chicago")
        
        let selfDateString = Date.formatter.string(from: self)
        let otherDateString = Date.formatter.string(from: date)
        
        return selfDateString == otherDateString
        
    }
    
}

