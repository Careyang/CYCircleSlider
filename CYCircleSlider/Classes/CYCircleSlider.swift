//
//  CYCircleSlider.swift
//  CYCircleSlider_Example
//
//  Created by careyang on 21/7/2022.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import SnapKit

open class CYCircleSlider: UIView {
    open weak var delegate: CYCircleProtocol?

    @IBInspectable open var minimumValue: Float = 0
    @IBInspectable open var maximumValue: Float = 500

    fileprivate var rotationGesture: CYRotateGestureRecognizer?
    fileprivate var backingValue: Float = 0
    fileprivate var backingKnobAngle: CGFloat = 0
    fileprivate var backingFractionDigits: NSInteger = 2
    fileprivate let maxFractionDigits: NSInteger = 4
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        sliderConfigure()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        sliderConfigure()
    }
    // MARK: - config
    func sliderConfigure() {
        setupUI()
        configureGesture()
        configureBackgroundLayer()
        configureProgressLayer()
        configureKnobLayer()
    }

    /// 配置滑动手势
    fileprivate func configureGesture() {
        rotationGesture = CYRotateGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)), arcRadius: arcRadius, knobRadius:  knobRadius)
        addGestureRecognizer(rotationGesture!)
    }
    fileprivate func appearanceKnobLayer() {
        knobLayer.lineWidth = 2
        knobLayer.fillColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        knobLayer.strokeColor = UIColor.white.cgColor
    }
    fileprivate func configureBackgroundLayer() {
        backgroundLayer.frame = bounds
        layer.addSublayer(backgroundLayer)
        appearanceBackgroundLayer()
    }

    fileprivate func configureProgressLayer() {
        progressLayer.frame = bounds
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        appearanceProgressLayer()
    }

    fileprivate func configureKnobLayer() {
        knobLayer.frame = bounds
        knobLayer.position = arcCenter
        layer.addSublayer(knobLayer)
        appearanceKnobLayer()
    }
    // MARK: - attributes
    @IBInspectable open var logo: UIImage? = UIImage() {
        didSet {
            logoImageView.image = logo
        }
    }

    /// 进度条宽度
    @IBInspectable open var progressWidth: CGFloat = 6 {
        didSet {
            appearanceBackgroundLayer()
            appearanceProgressLayer()
        }
    }

    /// 弧度偏移量
    @IBInspectable open var radiansOffset: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 设置数字是否可以手动编辑
    @IBInspectable open var textCanEdit: Bool = true {
        didSet {
            valueTextField.isEnabled = textCanEdit
        }
    }
    /// 设置整数部分字体大小
    @IBInspectable open var intFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .regular) {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 设置小数部分字体大小
    @IBInspectable open var decimalFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .regular) {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 滑块大小
    @IBInspectable open var knobRadius: CGFloat = 24 {
        didSet {
            appearanceKnobLayer()
        }
    }
    /// 进度条背景色
    @IBInspectable open var bgColor: UIColor = .lightGray {
        didSet {
            appearanceBackgroundLayer()
        }
    }
    /// 控制滑块颜色,默认为 true
    /// false : (滑块颜色 = 进度条颜色)
    @IBInspectable open var highlighted: Bool = true {
        didSet {
            appearanceProgressLayer()
            appearanceKnobLayer()
        }
    }

    /// highlighted = false,  滑块和进度条颜色
    @IBInspectable open var pgNormalColor: UIColor = .darkGray {
        didSet {
            appearanceProgressLayer()
        }
    }

    /// highlighted = true, 进度条颜色
    @IBInspectable open var pgHighlightedColor: UIColor = .green {
        didSet {
            appearanceProgressLayer()
        }
    }
    /// 是否隐藏分割线
    @IBInspectable open var hiddenLine: Bool = false {
        didSet {
            lineView.isHidden = hiddenLine
            setNeedsDisplay()
        }
    }

    /// 分割线颜色
    @IBInspectable open var lineColor: UIColor = .gray {
        didSet {
            lineView.backgroundColor = lineColor
        }
    }

    /// 小数点后位数
    @IBInspectable open var fractionDigits: NSInteger {
        get {
            return backingFractionDigits
        }
        set {
            backingFractionDigits = min(maxFractionDigits, max(0, newValue))
        }
    }

    /// 整数与小数分割符
    @IBInspectable open var customDecimalSeparator: String? = nil {
        didSet {
            if let c = self.customDecimalSeparator, c.count > 1 {
                self.customDecimalSeparator = nil
            }
        }
    }
    @IBInspectable open var value: Float {
        get {
            return backingValue
        }
        set {
            backingValue = min(maximumValue, max(minimumValue, newValue))
        }
    }
    fileprivate func getCirclePath() -> CGPath {
        return UIBezierPath(arcCenter: arcCenter,
                            radius: arcRadius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }

    fileprivate func getKnobPath() -> CGPath {
        return UIBezierPath(roundedRect:
            CGRect(x: arcCenter.x + arcRadius - knobRadius / 2, y: arcCenter.y - knobRadius / 2, width: knobRadius, height: knobRadius),
                            cornerRadius: knobRadius / 2).cgPath
    }
    // MARK: - update
    open func setValue(_ value: Float, animated: Bool) {
        self.value = delegate?.circularSlider?(self, valueForValue: value) ?? value

        updateLabels()

        setStrokeEnd(animated: animated)
        setKnobRotation(animated: animated)
    }

    /// 更新数字
    fileprivate func updateLabels() {
        valueTextField.attributedText = value.formatWithFractionDigits(fractionDigits, customDecimalSeparator: customDecimalSeparator).sliderAttributeString(intFont: intFont, decimalFont: decimalFont, customDecimalSeparator: customDecimalSeparator )
    }

    fileprivate func setStrokeEnd(animated: Bool) {

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = animated ? 0.66 : 0
        strokeAnimation.repeatCount = 1
        strokeAnimation.fromValue = progressLayer.strokeEnd
        strokeAnimation.toValue = CGFloat(normalizedValue)
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.fillMode = kCAFillModeRemoved
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        progressLayer.add(strokeAnimation, forKey: "strokeAnimation")
        progressLayer.strokeEnd = CGFloat(normalizedValue)
        CATransaction.commit()
    }

    fileprivate func setKnobRotation(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = animated ? 0.66 : 0
        animation.values = [backingKnobAngle, knobAngle]
        knobLayer.add(animation, forKey: "knobRotationAnimation")
        knobLayer.transform = knobRotationTransform

        CATransaction.commit()

        backingKnobAngle = knobAngle
    }
    // MARK: - gesture handler
    @objc fileprivate func handleRotationGesture(_ sender: AnyObject) {
        guard let gesture = sender as? CYRotateGestureRecognizer else { return }

        if gesture.state == UIGestureRecognizer.State.began {
            cancelAnimation()
        }

        var rotationAngle = gesture.rotation
        if rotationAngle > knobMidAngle {
            rotationAngle -= 2 * CGFloat(Double.pi)
        } else if rotationAngle < (knobMidAngle - 2 * CGFloat(Double.pi)) {
            rotationAngle += 2 * CGFloat(Double.pi)
        }
        rotationAngle = min(endAngle, max(startAngle, rotationAngle))

        guard abs(Double(rotationAngle - knobAngle)) < Double.pi / 2 else { return }

        let valueForAngle = Float(rotationAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
        setValue(valueForAngle, animated: false)
    }

    func cancelAnimation() {
        progressLayer.removeAllAnimations()
        knobLayer.removeAllAnimations()
    }

    fileprivate func appearanceBackgroundLayer() {
        backgroundLayer.lineWidth = progressWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = bgColor.cgColor
        backgroundLayer.lineCap = kCALineCapRound
    }

    fileprivate func appearanceProgressLayer() {
        progressLayer.lineWidth = progressWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        progressLayer.lineCap = kCALineCapRound
    }
    func setupUI() {
        self.addSubview(logoImageView)
        self.addSubview(centerView)
        centerView.addSubview(valueTextField)
        centerView.addSubview(lineView)

        logoImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(-10)
        }
        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        valueTextField.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(1)
            make.height.greaterThanOrEqualTo(24)
        }
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.equalTo(valueTextField.snp.bottom)
            make.height.equalTo(1.0)
        }
  
    }
    // MARK: - drawing methods
    override open func draw(_ rect: CGRect) {
        print("drawRect")
        backgroundLayer.bounds = bounds
        progressLayer.bounds = bounds
        knobLayer.bounds = bounds

        backgroundLayer.position = arcCenter
        progressLayer.position = arcCenter
        knobLayer.position = arcCenter

        rotationGesture?.arcRadius = arcRadius

        backgroundLayer.path = getCirclePath()
        progressLayer.path = getCirclePath()
        knobLayer.path = getKnobPath()

        setValue(value, animated: false)
    }

    // MARK: - lazy init
    private lazy var divisaLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    private lazy var centerView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = lineColor
        return view
    }()
    private lazy var valueTextField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.textAlignment = .center
        return view
    }()
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private lazy var knobLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    private var startAngle: CGFloat {
        return -CGFloat(Double.pi / 2) + radiansOffset
    }
    private var endAngle: CGFloat {
        return 3 * CGFloat(Double.pi / 2) - radiansOffset
    }
    private var angleRange: CGFloat {
        return endAngle - startAngle
    }
    private var valueRange: Float {
        return maximumValue - minimumValue
    }
    private var arcCenter: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    private var arcRadius: CGFloat {
        return min(frame.width,frame.height) / 2 - progressWidth / 2
    }
    private var normalizedValue: Float {
        return (value - minimumValue) / (maximumValue - minimumValue)
    }
    private var knobAngle: CGFloat {
        return CGFloat(normalizedValue) * angleRange + startAngle
    }
    private var knobMidAngle: CGFloat {
        return (2 * CGFloat(Double.pi) + startAngle - endAngle) / 2 + endAngle
    }
    private var knobRotationTransform: CATransform3D {
        return CATransform3DMakeRotation(knobAngle, 0.0, 0.0, 1)
    }
}

extension CYCircleSlider: UITextFieldDelegate {

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.circularSlider?(self, didBeginEditing: textField)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.circularSlider?(self, didEndEditing: textField)
        layoutIfNeeded()
        setValue(textField.text!.toFloat(), animated: true)
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if newString.count > 0 {

            let fmt = NumberFormatter()
            let scanner: Scanner = Scanner(string:newString.replacingOccurrences(of: customDecimalSeparator ?? fmt.decimalSeparator, with: "."))
            let isNumeric = scanner.scanDecimal(nil) && scanner.isAtEnd

            if isNumeric {
                var decimalFound = false
                var charactersAfterDecimal = 0



                for ch in newString.reversed() {
                    if ch == fmt.decimalSeparator.first {
                        decimalFound = true
                        break
                    }
                    charactersAfterDecimal += 1
                }
                if decimalFound && charactersAfterDecimal > fractionDigits {
                    return false
                }
                else {
                    return true
                }
            }
            else {
                return false
            }
        }
        else {
            return true
        }
    }
}
