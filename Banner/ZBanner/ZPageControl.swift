//
//  ZPageControl.swift
//  Banner
//
//  Created by zsq on 2018/4/1.
//  Copyright © 2018年 zsq. All rights reserved.
//

import UIKit

open class ZPageControl: UIControl {
    
    open var numberOfPages: Int = 0 {
        didSet{
            setNeedsCreateIndicators()
        }
    }
    
    open var currentPage: Int = 0 {
        didSet{
            setNeedsUpdateIndicators()
        }
    }
    
    open var itemSpacing: CGFloat = 6 {
        didSet{
            setNeedsUpdateIndicators()
        }
    }
    
    open var interitemSpacing: CGFloat = 6 {
        didSet{
            setNeedsLayout()
        }
    }
    
    open var contentInsets: UIEdgeInsets = .zero {
        didSet{
            setNeedsLayout()
        }
    }
    
    open override var contentHorizontalAlignment: UIControlContentHorizontalAlignment{
        didSet{
            setNeedsLayout()
        }
    }
    
    open var hidesForSinglePage: Bool = false {
        didSet{
            setNeedsUpdateIndicators()
        }
    }
    
    var strokeColors: [UIControlState: UIColor] = [:]
    var fillColors: [UIControlState: UIColor] = [:]
    var paths: [UIControlState: UIBezierPath] = [:]
    var images: [UIControlState: UIImage] = [:]
    var alphas: [UIControlState: CGFloat] = [:]
    var transforms: [UIControlState: CGAffineTransform] = [:]
    
    
    fileprivate var contentView: UIView!
    fileprivate var needsUpdateIndicators = false
    fileprivate var needsCreateIndicators = false
    fileprivate var indicatorLayers = [CAShapeLayer]()
    
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = UIColor.clear
        let view = UIView()
        view.backgroundColor = UIColor.clear
        addSubview(view)
        contentView = view
        isUserInteractionEnabled = false
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let x = contentInsets.left
        let y = contentInsets.top
        let width = frame.width - contentInsets.left - contentInsets.right
        let height = frame.height - contentInsets.bottom - contentInsets.top
        contentView.frame = CGRect(x: x, y: y, width: width, height: height)
        
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let diameter = itemSpacing
        let spacing = interitemSpacing
        var x: CGFloat = {//第一个指示器的x值
            switch contentHorizontalAlignment {
            case .left, .leading:
                return 0
            case .center, .fill:
                let midX = contentView.bounds.midX
                let amplitude = CGFloat(numberOfPages/2) * diameter + spacing * (CGFloat(numberOfPages-1)/2)
                return midX - amplitude
            case .right, .trailing:
                let contentWidth = diameter*CGFloat(numberOfPages) + CGFloat(numberOfPages-1)*spacing
                return contentView.frame.width - contentWidth
            }
        }()
        
        for (index, value) in indicatorLayers.enumerated() {
            let state: UIControlState = (index == currentPage) ? .selected : .normal
            let image = images[state]
            let size = image?.size ?? CGSize(width: diameter, height: diameter)
            let origin = CGPoint(x: x - (size.width - diameter) * 0.5, y: contentView.bounds.midY - size.height*0.5)
            value.frame = CGRect(origin: origin, size: size)
            x += diameter + spacing
        }
        
    }
    
    
    open func setStrokeColor(_ strokeColor: UIColor?, for state: UIControlState){
        guard self.strokeColors[state] != strokeColor else {
            return
        }
        strokeColors[state] = strokeColor
        setNeedsUpdateIndicators()
    }
    
    open func setFillColor(_ fillColor: UIColor?, for state: UIControlState){
        guard fillColors[state] != fillColor else {
            return
        }
        fillColors[state] = fillColor
        setNeedsUpdateIndicators()
    }
    
    open func setImage(_ image: UIImage?, for state: UIControlState){
        guard images[state] != image else {
            return
        }
        images[state] = image
        setNeedsUpdateIndicators()
    }
    
    open func setAlpha(_ alpha: CGFloat?, for state: UIControlState){
        guard alphas[state] != alpha else {
            return
        }
        alphas[state] = alpha
        setNeedsUpdateIndicators()
    }
    
    open func setPath(_ path: UIBezierPath?, for state: UIControlState){
        guard paths[state] != path else {
            return
        }
        paths[state] = path
        setNeedsUpdateIndicators()
    }
    
    
    func setNeedsUpdateIndicators() {
        needsUpdateIndicators = true
        setNeedsLayout()
        DispatchQueue.main.async {
            self.updateIndicatorsIfNecessary()
        }
    }
    
    func updateIndicatorsIfNecessary() {
        guard needsUpdateIndicators == true else {
            return
        }
        
        guard indicatorLayers.count > 0 else {
            return
        }
        
        needsUpdateIndicators = false
        contentView.isHidden = hidesForSinglePage && indicatorLayers.count <= 1
        if !contentView.isHidden{
            indicatorLayers.forEach({ (layer) in
                layer.isHidden = false
                updateIndicatorAttributes(for: layer)
            })
        }
    }
    
    func updateIndicatorAttributes(for layer: CAShapeLayer) {
        let index = indicatorLayers.index(of: layer)
        let state: UIControlState = index == currentPage ? .selected : .normal
        if let image = images[state]{
            layer.strokeColor = nil
            layer.fillColor = nil
            layer.path = nil
            
            layer.contents = image.cgImage
        } else {
            layer.contents = nil
            
            let strokeColor = strokeColors[state]
            let fillColor = fillColors[state]
            if strokeColor == nil && fillColor == nil {
                layer.fillColor = (state == .selected ? UIColor.white : UIColor.gray).cgColor
                layer.strokeColor = nil
            } else {
                layer.fillColor = fillColor?.cgColor
                layer.strokeColor = strokeColor?.cgColor
            }
            layer.path = paths[state]?.cgPath ?? UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: itemSpacing, height: itemSpacing)).cgPath
            
        }
        
        if let transform = transforms[state] {
            layer.transform = CATransform3DMakeAffineTransform(transform)
        }
        layer.opacity = Float(self.alphas[state] ?? 1.0)
    }
    
    func setNeedsCreateIndicators() {
        needsCreateIndicators = true
        DispatchQueue.main.async {
            self.createIndicatorsIfNecessary()
        }
    }
    
    func createIndicatorsIfNecessary() {
        guard needsCreateIndicators == true else {
            return
        }
        needsCreateIndicators = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if currentPage >= numberOfPages {
            currentPage = numberOfPages - 1
        }
        
        indicatorLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        indicatorLayers.removeAll()
        
        for _ in 0..<numberOfPages {
            let layer = CAShapeLayer()
            layer.actions = ["bounds": NSNull()]
            contentView.layer.addSublayer(layer)
            indicatorLayers.append(layer)
        }
        setNeedsUpdateIndicators()
        CATransaction.commit()
    }
    
}

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int((6777*self.rawValue+3777)%UInt(UInt16.max))
    }
}
