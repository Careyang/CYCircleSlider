//
//  ViewController.swift
//  CYCircleSlider
//
//  Created by careyang on 07/21/2022.
//  Copyright (c) 2022 careyang. All rights reserved.
//

import UIKit
import CYCircleSlider

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        view.backgroundColor = .white
        view.addSubview(circleSlider)
//        circleSlider.snp.makeConstraints { make in
//            make.size.equalTo(CGSize(width: 150, height: 150))
//            make.centerX.equalToSuperview()
//            make.top.equalTo(view).offset(100)
//        }
    }

    lazy var circleSlider: CYCircleSlider = {
        let view = CYCircleSlider(frame: CGRect(x: 10, y: 100, width: 150, height: 150))
        view.logo = UIImage(named: "apple")
        view.hiddenLine = false
        view.lineColor = UIColor.green
        view.radiansOffset = 0.8
        view.knobRadius = 24
        view.delegate = self
        view.bgColor = UIColor.red
        view.fractionDigits = 1
        view.customDecimalSeparator = "#"
        view.intFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        view.decimalFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        return view
    }()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: CYCircleProtocol {
    func circularSlider(_ circularSlider: CYCircleSlider, valueForValue value: Float) -> Float {
        print("===========\(floorf(value))")
        return floorf(value)
    }
}
