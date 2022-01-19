//
//  AZHashtagView.swift
//  AZHashtagView
//
//  Created by minkook yoo on 2022/01/19.
//

import Foundation
import UIKit


@objc
open class AZHashtagView: UIView {
    
    // displayLineCount - default to UInt.max
    // displayLineCount - setValue to ExpandMode
    @objc
    public func updateHashtags(_ tags: Array<String>, displayLineCount: UInt = UInt.max, completion: ((_ displayHeight: CGFloat) -> Void)) {
        self.clipsToBounds = true
        _displayLineCount = displayLineCount
        setUpTagButtons(tags)
        setUpExpandMode()
        
        completion(self.displayHeight)
    }
    
    
    @objc
    public var displayHeight: CGFloat { get { return _displayHeight } }
    
    
    @objc
    public var isExpand: Bool { get { return _isExpand } }
    
    
    
    //------------------------------------------------------------------------------------
    // MARK: Design
    
    @objc
    public var designItemHeight: CGFloat = 36.0
    
    
    @objc
    public var designItemSpacing: CGFloat = 8.0
    
    
    @objc
    public var designLineSpacing: CGFloat = 8.0
    
    
    @objc
    public var designItemEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)
    
    
    @objc
    public var designItemFontSize: CGFloat = 14.0
    
    
    @objc
    public var designItemBackgroundColor: UIColor = .yellow
    
    
    @objc
    public var designItemCornerRadius: CGFloat = 18.0
    
    
    @objc
    public var designExpandItemSize: CGSize = CGSize(width: 32.0, height: 32.0)
    
    
    @objc
    public var designExpandImage: UIImage?
    
    
    @objc
    public var designCollapseImage: UIImage?
    
    
    
    //------------------------------------------------------------------------------------
    // MARK: Action Handler
    
    @objc
    public var tagActionHandler: ((_ tag: String) -> Void)?
    
    
    @objc
    public var expandActionHandler: ((_ isExpand: Bool, _ displayHeight: CGFloat) -> Void)?
    
    
    
    //------------------------------------------------------------------------------------
    // MARK: Debug
    
    @objc
    public var debug: Bool {
        get { return _debug }
        set {
            _debug = newValue
            debugLayer.isHidden = !_debug
        }
    }
    
    
    //------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------
    //------------------------------------------------------------------------------------
    // MARK: Private
    
    private var tagButtons: Array<UIButton> = []
    
    private var _displayLineCount: UInt = UInt.max
    private var maxLineCount: UInt = 0
    private var isExpandMode: Bool { get { return _displayLineCount != UInt.max } }
    private var _isExpand: Bool = false
    private var lastCollapseIndex: Int = NSNotFound
    private var expandButton: UIButton?
    private var collapseButton: UIButton?
    
    private var collapseHeight: CGFloat {
        get {
            let count = min(_displayLineCount, maxLineCount)
            return (self.designItemHeight * CGFloat(count)) + (self.designLineSpacing * CGFloat(count - 1))
        }
    }
    private var expandHeight: CGFloat {
        get {
            return (self.designItemHeight * CGFloat(maxLineCount)) + (self.designLineSpacing * CGFloat(maxLineCount - 1))
        }
    }
    
    private var _displayHeight: CGFloat {
        get {
            if isExpandMode {
                return _isExpand ? expandHeight : collapseHeight
            } else {
                return expandHeight
            }
        }
    }
    
    private var _debug: Bool = false
    private lazy var debugLayer: CALayer = {
        var layer = CALayer()
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
        layer.isHidden = true
        self.layer.addSublayer(layer)
        return layer
    }()
    
    override open func layoutSubviews() {
        debugLayer.frame = self.bounds
    }
    
    private lazy var defaultExpandImage: UIImage = {
        
        let size = designExpandItemSize
        
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        rect = rect.insetBy(dx: 1, dy: 1)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(0.5)
            
            context.addEllipse(in: rect)
            
            let pt1 = CGPoint(x: rect.midX - rect.midX/3, y: rect.midY - rect.midY/3)
            let pt2 = CGPoint(x: rect.midX, y: rect.midY + rect.midY/3)
            let pt3 = CGPoint(x: rect.midX + rect.midX/3, y: rect.midY - rect.midY/3)
            
            context.move(to: pt1)
            context.addLine(to: pt2)
            context.addLine(to: pt3)
            
            context.drawPath(using: .fillStroke)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }()
    
    private lazy var defaultCollapseImage: UIImage = {
        
        let size = designExpandItemSize
        
        var rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        rect = rect.insetBy(dx: 1, dy: 1)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(UIColor.clear.cgColor)
            context.setStrokeColor(UIColor.blue.cgColor)
            context.setLineWidth(0.5)
            
            context.addEllipse(in: rect)
            
            let pt1 = CGPoint(x: rect.midX - rect.midX/3, y: rect.midY + rect.midY/3)
            let pt2 = CGPoint(x: rect.midX, y: rect.midY - rect.midY/3)
            let pt3 = CGPoint(x: rect.midX + rect.midX/3, y: rect.midY + rect.midY/3)
            
            context.move(to: pt1)
            context.addLine(to: pt2)
            context.addLine(to: pt3)
            
            context.drawPath(using: .fillStroke)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }()
    
}


// MARK: SetUp
extension AZHashtagView {
    
    private func removeAllButtons() {
        
        for button in tagButtons {
            button.removeFromSuperview()
        }
        tagButtons.removeAll()
        
    }
    
    private func setUpTagButtons(_ tags: Array<String>) {
        
        removeAllButtons()
        
        let maxWidth = self.bounds.width
        var posX: CGFloat = 0
        var posY: CGFloat = 0
        maxLineCount = 1
        lastCollapseIndex = NSNotFound
        
        for tag in tags {
            
            let button = createTagButton(tag)
            
            // calc item
            let calcSize = button.sizeThatFits(self.bounds.size)
            let size = CGSize(width: calcSize.width + self.designItemEdgeInsets.left + self.designItemEdgeInsets.right, height: self.designItemHeight)
            
            if posX + size.width > maxWidth {
                posX = 0
                posY += (size.height + self.designLineSpacing)
                
                if _displayLineCount == maxLineCount {
                    lastCollapseIndex = tagButtons.count - 1
                }
                
                maxLineCount += 1
            }
            
            button.frame = CGRect(x: posX, y: posY, width: size.width, height: size.height)
            
//            print("button tag: \(tag), calcSize: \(calcSize), size: \(size), frame: \(button.frame)")
            
            posX += (size.width + self.designItemSpacing)
            
            tagButtons.append(button)
            self.addSubview(button)
            
        }
        
//        print("button maxLineCount: \(maxLineCount)")
//        print("button displayHeight: \(self.displayHeight)")
//        print("button lastCollapseIndex: \(lastCollapseIndex)")
        
    }
    
    private func createTagButton(_ tag: String) -> UIButton {
        
        let button = UIButton(type: .custom)
        button.setTitle(tag, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: self.designItemFontSize)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = self.designItemBackgroundColor
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.cornerRadius = self.designItemCornerRadius
        button.addTarget(self, action: #selector(tagButtonAction), for: .touchUpInside)
        
        return button
    }
    
    @objc func tagButtonAction(_ sender: UIButton) {
        if let title = sender.title(for: .normal) {
            if let action = tagActionHandler {
                action(title)
            }
        }
    }
    
}


// MARK: Expand Mode
extension AZHashtagView {
    
    private func setUpExpandMode() {
        
        if !isExpandMode { return }
        
        // expand button
        setUpExpandButton()
        
        // collapse button
        setUpCollapseButton()
        
    }
    
    private func setUpExpandButton() {
        
        if lastCollapseIndex == NSNotFound { return }
        
        let targetTagButton = tagButtons[lastCollapseIndex]
        
        if let button = expandButton {
            button.removeFromSuperview()
            expandButton = nil
        }
        
        expandButton = createExpandButton()
        
        guard let expandButton = expandButton else { return }
        
        var x = targetTagButton.frame.maxX + self.designItemSpacing
        if (isOverLayoutExpandButton()) {
            x = targetTagButton.frame.minX
        }
        
        var frame = targetTagButton.frame
        frame.origin.x = x
        frame.origin.y = frame.origin.y + controlButtonPosY()
        frame.size = self.designExpandItemSize
        expandButton.frame = frame
        
        hiddenExpandAndLastCollapseButton(false)
        
        self.addSubview(expandButton)
        
    }
    
    private func setUpCollapseButton() {
        
        guard let targetTagButton = tagButtons.last else { return }
        
        if let button = collapseButton {
            button.removeFromSuperview()
            collapseButton = nil
        }
        
        collapseButton = createCollapseButton()
        
        guard let collapseButton = collapseButton else { return }
        
        // MARK: !!!!!! collapse button frame
        var frame = targetTagButton.frame
        frame.origin.x = targetTagButton.frame.maxX + self.designItemSpacing
        frame.origin.y = frame.origin.y + controlButtonPosY()
        frame.size = self.designExpandItemSize
        collapseButton.frame = frame
        
        self.addSubview(collapseButton)
        
    }
    
    private func controlButtonPosY() -> CGFloat {
        var y: CGFloat = 0
        if self.designExpandItemSize.height < self.designItemHeight {
            y = (self.designItemHeight - self.designExpandItemSize.height) / 2
        }
        return y
    }
    
    private func createExpandButton() -> UIButton {
        
        let button = UIButton(type: .custom)
        let image = designExpandImage ?? defaultExpandImage
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(expandButtonAction), for: .touchUpInside)
        
        return button
    }
    
    @objc
    private func expandButtonAction(_ sender: UIButton) {
        
        hiddenExpandAndLastCollapseButton(true)
        
        if let action = expandActionHandler {
            _isExpand = true
            action(isExpand, displayHeight)
        }
    }
    
    private func createCollapseButton() -> UIButton {
        
        let button = UIButton(type: .custom)
        let image = designCollapseImage ?? defaultCollapseImage
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(collapseButtonAction), for: .touchUpInside)
        
        return button
    }
    
    @objc
    private func collapseButtonAction(_ sender: UIButton) {
        
        hiddenExpandAndLastCollapseButton(false)
        
        if let action = expandActionHandler {
            _isExpand = false
            action(isExpand, displayHeight)
        }
    }
    
    private func isOverLayoutExpandButton() -> Bool {
        let targetTagButton = tagButtons[lastCollapseIndex]
        
        let maxWidth = self.bounds.width
        let x = targetTagButton.frame.maxX + self.designItemSpacing
        
        if x + self.designExpandItemSize.width > maxWidth {
            return true
        }
        
        return false
    }
    
    private func hiddenExpandAndLastCollapseButton(_ isExpand: Bool) {
        
        if lastCollapseIndex == NSNotFound { return }
        guard let expandButton = expandButton else { return }
        
        expandButton.isHidden = isExpand
        
        let targetTagButton = tagButtons[lastCollapseIndex]
        if (isOverLayoutExpandButton()) {
            targetTagButton.isHidden = !isExpand
        }
        
    }
    
}
