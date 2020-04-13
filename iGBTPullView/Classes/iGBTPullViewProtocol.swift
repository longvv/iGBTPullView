//
//  iGBTPullViewProtocol.swift
//  iGBTPullView
//
//  Created by LongVu on 4/12/20.
//

import Foundation

public protocol iGBTPullViewProtocol: class {
    func pullViewModeDidChanged(_ mode: iGBTPullViewMode)
    func pullViewHeighDidChanged(_ height: CGFloat)
}
