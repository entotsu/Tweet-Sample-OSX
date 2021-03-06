//
//  AutoGrowingTextField.swift
//  tweetSample
//
//  Created by 岡本 拓也 on 2016/05/06.
//  Copyright © 2016年 岡本 拓也. All rights reserved.
//

import Cocoa

// for AutoLayout

// https://github.com/DouglasHeriot/AutoGrowingNSTextField

class AutoGrowingTextField: NSTextField {
    
    var minHeight: CGFloat? = 100
    let bottomSpace: CGFloat = 5
    // magic number! (the field editor TextView is offset within the NSTextField. It’s easy to get the space above (it’s origin), but it’s difficult to get the default spacing for the bottom, as we may be changing the height
    
    var heightLimit: CGFloat?
    var lastSize: NSSize?
    var isEditing = false
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        isEditing = true
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        isEditing = false
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: NSSize {
        var minSize: NSSize {
            var size = super.intrinsicContentSize
            size.height = minHeight ?? 0
            return size
        }
        // Only update the size if we’re editing the text, or if we’ve not set it yet
        // If we try and update it while another text field is selected, it may shrink back down to only the size of one line (for some reason?)
        if isEditing || lastSize == nil {
            guard
                // If we’re being edited, get the shared NSTextView field editor, so we can get more info
                let textView = self.window?.fieldEditor(false, for: self) as? NSTextView,
                let container = textView.textContainer,
                let newHeight = container.layoutManager?.usedRect(for: container).height
            else {
                return lastSize ?? minSize
            }
            var newSize = super.intrinsicContentSize
            newSize.height = newHeight + bottomSpace

            if let heightLimit = heightLimit, let lastSize = lastSize, newSize.height > heightLimit {
                newSize = lastSize
            }

            if minHeight == minHeight, newSize.height < minHeight! {
                newSize.height = minHeight!
            }
            
            lastSize = newSize
            return newSize
        }
        else {
            return lastSize ?? minSize
        }
    }
}
