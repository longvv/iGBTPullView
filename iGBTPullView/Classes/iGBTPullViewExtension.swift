//
//  iGBTPullViewExtension.swift
//  iGBTPullView
//
//  Created by LongVu on 4/12/20.
//

import Foundation

public extension UIView {
    static func animate(_ animation: @autoclosure @escaping () -> Void, completion: ((Bool) -> Void)? = nil, duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: animation, completion: completion)
    }
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.flatMap { $0.superview(of: type) }
    }
}
