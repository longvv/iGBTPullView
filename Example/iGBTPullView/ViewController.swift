//
//  ViewController.swift
//  iGBTPullView
//
//  Created by long-vu-tiki on 04/12/2020.
//  Copyright (c) 2020 long-vu-tiki. All rights reserved.
//

import UIKit
import iGBTPullView

class ViewController: UIViewController {
    lazy var pullView = iGBTPullView(frame: .zero)
    lazy var contentView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .red
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.pullView.showAtView(self.view,
                                 delegate: self,
                                 contentView: contentView,
                                 contentHeight: contentView.bounds.height,
                                 minContentHeigh: 100,
                                 maxContentHeigh: UIScreen.main.bounds.height * 2/3,
                                 mode: .fit,
                                 introMessage: "Swipe down to collapse",
                                 isNeedHidePullAtLeastSize: false,
                                 isNeedHideIntroMessageAtLeastSize: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: iGBTPullViewProtocol {
    func pullViewModeDidChanged(_ mode: iGBTPullViewMode) {
        print("pullViewModeDidChanged: \(mode)")
    }
    
    func pullViewHeighDidChanged(_ height: CGFloat) {
        print("pullViewHeighDidChanged: \(height)")
    }
    
    
}

