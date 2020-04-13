//
//  iGBTPullViewElements.swift
//  iGBTPullView
//
//  Created by LongVu on 4/12/20.
//

import Foundation

public protocol iGBTPullViewElementsProtocol: class {
    func pullHeightDidChanged(_ height: CGFloat)
}

final class iGBTPullViewElements: NSObject {
    lazy public var introLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.numberOfLines = 1
        label.backgroundColor = .clear
        return label
    }()
    
    lazy public var pullView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3.0
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy public var contentContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private weak var delegate: iGBTPullViewElementsProtocol?
    var isNeedHidePullAtLeastSize: Bool = true
    var isNeedHideIntroMessageAtLeastSize: Bool = true
    var introMessage: String?
    var minPullViewContentHeight: CGFloat = 0
    var maxPullViewContentHeight: CGFloat = 0
    var actualPullViewContentHeight: CGFloat = 0
    var lastPullViewContentHeight: CGFloat = 0
    var heightContentConstraint: NSLayoutConstraint?
    var contentView: UIView?
    var currentSizeMode: iGBTPullViewMode = .zero
    var contentHeight: CGFloat = 0
    var pullViewHeight: CGFloat = 0 {
        didSet {
            self.delegate?.pullHeightDidChanged(pullViewHeight)
        }
    }
    
    public func setDelegate(with delegate: iGBTPullViewElementsProtocol) {
        self.delegate = delegate
    }
    
    public func setElements(with contentView: UIView,
                            contentHeight: CGFloat,
                            minContentHeigh: CGFloat,
                            maxContentHeigh: CGFloat,
                            introMessage: String?,
                            isNeedHidePullAtLeastSize: Bool,
                            isNeedHideIntroMessageAtLeastSize: Bool) {
        self.setContentView(contentView)
        self.isNeedHidePullAtLeastSize = isNeedHidePullAtLeastSize
        self.isNeedHideIntroMessageAtLeastSize = isNeedHideIntroMessageAtLeastSize
        self.introMessage = introMessage
        self.contentHeight = contentHeight
        self.minPullViewContentHeight = minContentHeigh
        self.actualPullViewContentHeight = contentHeight
        self.maxPullViewContentHeight = maxContentHeigh
    }
    
    public func setContentView(_ view: UIView) {
        self.contentView = view
        if let view = self.contentView {
            self.contentContainerView.addSubview(view)
            view.snp.remakeConstraints{(make) in
                make.top.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    public func hideIntroMessage() {
        self.introLabel.isHidden = true
        self.introMessage = nil
    }
    
    public func showIntroMessage(_ message: String) {
        self.introLabel.isHidden = false
        self.introMessage = message
        self.introLabel.text = message
    }
    
    public func resetElements() {
        self.contentHeight = 0
        self.heightContentConstraint = nil
        self.introMessage = nil
        self.contentView = nil
        self.pullViewHeight = 0
    }
}
