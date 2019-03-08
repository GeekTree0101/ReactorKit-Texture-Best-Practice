import UIKit

extension UIImage {
    
    class func backgroundImage(color: UIColor, size: CGSize = .init(width: 1, height: 1)) -> UIImage? {
        var rect: CGRect = .zero
        rect.size = size
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
