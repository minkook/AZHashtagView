//
//  ViewController.swift
//  AZHashtagView
//
//  Created by minkook on 01/19/2022.
//  Copyright (c) 2022 minkook. All rights reserved.
//

import UIKit
import AZHashtagView

class ViewController: UIViewController {

    @IBOutlet weak var hashtagView: AZHashtagView!
    @IBOutlet weak var hashtagViewLayoutConstraintHeight: NSLayoutConstraint!
    
    let tags = ["apple", "banana", "cloud", "dvd", "egg toast", "food", "game", "hard", "iu"
                ,"jack", "kind", "love", "man", "news", "orange", "potato", "quiz"
                , "range", "sky", "talk", "ultra", "victory", "wow", "x-man", "yoo", "zoo"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // usage 1
//        setUpHashtagView_1()
        
        // usage 2
        setUpHashtagView_2()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpHashtagView_1() {
        
        // update 1
        hashtagView.updateHashtags(self.tags) { [weak self] displayHeight in
            guard let self = self else { return }
            self.hashtagViewLayoutConstraintHeight.constant = displayHeight
        }
        
        setUpHashtagViewCore()
    }
    
    func setUpHashtagView_2() {
        
        // update 2
        hashtagView.updateHashtags(self.tags, displayLineCount: 2) { [weak self] displayHeight in
            guard let self = self else { return }
            self.hashtagViewLayoutConstraintHeight.constant = displayHeight
        }
        
        setUpHashtagViewCore()
    }
    
    func setUpHashtagViewCore() {
        
        // button action
        hashtagView.tagActionHandler = { tag in
            print("button action - tag: \(tag)")
        }
        
        // expand action
        hashtagView.expandActionHandler = { [weak self] isExpand, displayHeight in
            guard let self = self else { return }
            self.hashtagViewLayoutConstraintHeight.constant = displayHeight
            
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}


extension ViewController {
    
    @IBAction func testButtonAction(_ sender: Any) {
        
        let tags = ["a", "b", "c"]
        
        hashtagView.updateHashtags(tags) { [weak self] displayHeight in
            guard let self = self else { return }
            self.hashtagViewLayoutConstraintHeight.constant = displayHeight
        }
        
    }
    
}

