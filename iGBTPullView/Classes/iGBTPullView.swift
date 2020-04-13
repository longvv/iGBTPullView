//
//  iGBTPullView.swift
//  iGBTPullView
//
//  Created by LongVu on 4/2/20.
//

import Foundation
import SnapKit

public class iGBTPullView: UIView {
    private weak var delegate: iGBTPullViewProtocol?
    private var elements = iGBTPullViewElements()
    private var firstPanPoint: CGPoint = CGPoint.zero
    
    // MARK: - Private methods
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit iGBTPullView")
    }
    
    private func animateViewSizeChanged(mode: iGBTPullViewMode) {
        UIView.animate(self.setPullViewMode(to: mode), completion: nil, duration: 0.3)
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    @objc private func panned(_ gesture: UIPanGestureRecognizer) {
        let point = gesture.translation(in: gesture.view?.superview)
        if gesture.state == .began {
            self.firstPanPoint = point
        }
        var newHeight = max(0, self.elements.lastPullViewContentHeight + (self.firstPanPoint.y - point.y))
        if newHeight > self.elements.maxPullViewContentHeight {
            newHeight = self.elements.maxPullViewContentHeight
        }
        if gesture.state == .cancelled || gesture.state == .failed {
            UIView.animate(self.setPullViewMode(to: iGBTPullViewMode.minimum))
        } else if gesture.state == .ended, let supView = self.superview(of: UIView.self) {
            let velocity = (0.2 * gesture.velocity(in: supView).y)
            var finalHeight = newHeight - velocity
            if velocity > 500 {
                // Swiped hard, just dimiss when really want, so don't need dismiss in this case
                finalHeight = -1
            }
            guard finalHeight >= (self.elements.minPullViewContentHeight / 2) else {
                self.animateViewSizeChanged(mode: .minimum)
                return
            }
            let currentHeightTableView = self.elements.pullViewHeight
            /// Resize to actual height in case pan up make height larger than actual one
            if (currentHeightTableView >= self.elements.actualPullViewContentHeight) ||
                ((currentHeightTableView > self.elements.lastPullViewContentHeight || (currentHeightTableView < self.elements.lastPullViewContentHeight && currentHeightTableView > (self.elements.minPullViewContentHeight * 1.2))) && self.elements.actualPullViewContentHeight < self.elements.maxPullViewContentHeight) {
                UIView.animate(self.setPullViewMode(to: iGBTPullViewMode.fit), duration: 0.3)
            }
                /// pan upward and still smaller than actual height, need to full screen
            else if currentHeightTableView > self.elements.lastPullViewContentHeight || currentHeightTableView >= self.elements.maxPullViewContentHeight * 0.6 {
                UIView.animate(self.setPullViewMode(to: iGBTPullViewMode.maximum), duration: 0.3)
            }
                /// current height smaller than 20% actual one so need to animate dismiss
            else if currentHeightTableView < (self.elements.minPullViewContentHeight) * 0.2 {
                self.animateViewSizeChanged(mode: .minimum)
            }
                /// otherwise, collapse current height to min height - default
            else {
                UIView.animate(self.setPullViewMode(to: iGBTPullViewMode.minimum))
            }
        } else {
            if newHeight > self.elements.actualPullViewContentHeight && self.elements.lastPullViewContentHeight == self.elements.actualPullViewContentHeight {
                /// Larger than maxHeight so need to decrease velocity
                self.elements.pullViewHeight = min(self.elements.maxPullViewContentHeight, self.elements.lastPullViewContentHeight + (self.firstPanPoint.y - point.y) / 3)
            }
            else {
                self.elements.pullViewHeight = newHeight
            }
        }
    }
    
    private func setupViews() {
        let cornerRadiusCartView = CGFloat(16)
        if #available(iOS 11.0, *) {
            self.elements.contentContainerView.layer.cornerRadius = cornerRadiusCartView
            self.elements.contentContainerView.clipsToBounds = true
            self.elements.contentContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            let rect = UIScreen.main.bounds
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadiusCartView, height: cornerRadiusCartView))
            let maskLayer = CAShapeLayer()
            maskLayer.frame = rect
            maskLayer.path = path.cgPath
            self.elements.contentContainerView.layer.mask = maskLayer
        }
        self.transform = CGAffineTransform.identity
        self.addSubview(self.elements.contentContainerView)
        self.addSubview(self.elements.pullView)
        self.addSubview(self.elements.introLabel)
        self.layoutViews()
    }
    
    private func layoutViews() {
        self.elements.contentContainerView.snp.remakeConstraints{(make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        self.elements.lastPullViewContentHeight = 0
    }
    
    private func setPullViewMode(to mode: iGBTPullViewMode) {
        var newMode = mode
        if mode == .fit && self.elements.actualPullViewContentHeight <= self.elements.minPullViewContentHeight {
            newMode = .minimum
        }
        if mode == .fit && self.elements.actualPullViewContentHeight >= self.elements.maxPullViewContentHeight {
            newMode = .maximum
        }
        switch newMode {
        case .zero:
            self.elements.pullViewHeight = 0
        case .minimum:
            self.elements.pullViewHeight = self.elements.minPullViewContentHeight
        case .fit:
            self.elements.pullViewHeight = self.elements.actualPullViewContentHeight
        case .maximum:
            self.elements.pullViewHeight = self.elements.maxPullViewContentHeight
        }
        self.elements.lastPullViewContentHeight = self.elements.pullViewHeight
        self.delegate?.pullViewModeDidChanged(mode)
        self.superview(of: UIView.self)?.layoutIfNeeded()
    }
    
    // MARK: - Public methods
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.elements.setDelegate(with: self)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
        panGestureRecognizer.delegate = self
        self.addGestureRecognizer(panGestureRecognizer)
        self.setupViews()
    }
    
    public func showAtView(_ view: UIView,
                           delegate: iGBTPullViewProtocol? = nil,
                           contentView: UIView,
                           contentHeight: CGFloat = 0,
                           minContentHeigh: CGFloat = 0,
                           maxContentHeigh: CGFloat = UIScreen.main.bounds.height,
                           mode: iGBTPullViewMode = .minimum,
                           introMessage: String? = nil,
                           isNeedHidePullAtLeastSize: Bool = true,
                           isNeedHideIntroMessageAtLeastSize: Bool = true) {
        self.removeFromSuperview()
        self.delegate = nil
        view.addSubview(self)
        self.delegate = delegate
        self.snp.remakeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
        }
        self.elements.setElements(with: contentView,
                                  contentHeight: contentHeight,
                                  minContentHeigh: minContentHeigh,
                                  maxContentHeigh: maxContentHeigh,
                                  introMessage: introMessage,
                                  isNeedHidePullAtLeastSize: isNeedHidePullAtLeastSize,
                                  isNeedHideIntroMessageAtLeastSize: isNeedHideIntroMessageAtLeastSize)
        self.setPullViewMode(to: mode)
    }
    
    public func dismissView() {
        self.setPullViewMode(to: .zero)
        self.elements.resetElements()
        self.removeFromSuperview()
        self.isHidden = true
    }
    
    public func hideIntroMessage() {
        self.elements.hideIntroMessage()
    }
    
    public func showIntroMessage(_ message: String) {
        self.elements.showIntroMessage(message)
    }
}

extension iGBTPullView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gesture = gestureRecognizer as? UIPanGestureRecognizer,
            let supView = self.superview(of: UIView.self) {
            let direction = gesture.velocity(in: supView).y
            if (self.elements.pullViewHeight == self.elements.maxPullViewContentHeight && direction > 0) ||
                (self.elements.pullViewHeight == self.elements.minPullViewContentHeight) ||
                self.elements.pullViewHeight == self.elements.actualPullViewContentHeight {
                return true
            }
            return false
        }
        return false
    }
}

extension iGBTPullView: iGBTPullViewElementsProtocol {
    public func pullHeightDidChanged(_ height: CGFloat) {
        if self.elements.heightContentConstraint == nil {
            self.elements.heightContentConstraint = NSLayoutConstraint(item: self.elements.contentContainerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0,  constant: 0)
            self.elements.heightContentConstraint?.isActive = true
        }
        self.elements.heightContentConstraint?.constant = height
        let needHidePullView = self.elements.isNeedHidePullAtLeastSize && (self.elements.pullViewHeight <= self.elements.minPullViewContentHeight)
        self.elements.pullView.isHidden = needHidePullView
        let heightView = needHidePullView ? 0 : iGBTPullViewConstant.pullViewHeight
        let bottomView = needHidePullView ? 0 : iGBTPullViewConstant.pullBottomPadding
        let topView = needHidePullView ? 0 : iGBTPullViewConstant.pullTopPadding
        self.elements.pullView.snp.remakeConstraints { (make) in
            make.width.equalTo(iGBTPullViewConstant.pullViewWidth)
            make.height.equalTo(heightView)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.elements.contentContainerView.snp.top).offset(-bottomView)
            make.top.equalToSuperview().offset(topView)
        }
        let introMessageEmpty = self.elements.introMessage?.isEmpty ?? true
        let needHideIntro = (introMessageEmpty || (!introMessageEmpty && self.elements.isNeedHideIntroMessageAtLeastSize && self.elements.pullViewHeight <= self.elements.minPullViewContentHeight))
        self.elements.introLabel.isHidden = needHideIntro
        self.elements.introLabel.text = needHideIntro ? nil : self.elements.introMessage
        let heightLabel = needHideIntro ? 0 : iGBTPullViewConstant.introLabelHeight
        let bottomLabel = needHideIntro ? 0 : iGBTPullViewConstant.introLabelBottomPadding
        self.elements.introLabel.snp.remakeConstraints{(make) in
            make.width.equalToSuperview()
            make.height.equalTo(heightLabel)
            make.centerX.equalTo(self.elements.pullView)
            make.bottom.equalTo(self.elements.pullView.snp.top).offset(-bottomLabel)
        }
        self.superview(of: UIView.self)?.layoutIfNeeded()
        self.delegate?.pullViewHeighDidChanged(height)
    }
}
