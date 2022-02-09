//
//  Initializers.swift
//  module
//
//  Created by Chaemin Lee on 2022/02/04.
//

import UIKit
import PencilKit
import Foundation

// 데이터
class DataBase {
    enum DataBaseEnum: String {
        case prob1
        case prob2
    }

    class func setValue(_ key : DataBaseEnum , value : Any?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }

    class func getData(_ key: DataBaseEnum) -> Data {
        return UserDefaults.standard.value(forKey: key.rawValue) as? Data ?? Data()
    }
}

struct Initializers {
    
    let canvasLeadingScale: CGFloat
    let canvasTopScale: CGFloat
    var canvasWidthScale: CGFloat
    var canvasHeightScale: CGFloat
    var isLandscape: Bool
    
    let sampleQuizImage: URL
    let directoryName: String
    let fileName: String
    let extention: String
    let quizImage: UIImage
    var quizWidthScale: CGFloat
    var quizHeightScale: CGFloat
    let zoomScale: CGFloat
    
    init(leadingScale: CGFloat, topScale: CGFloat, widthScale: CGFloat, heightScale: CGFloat, directoryName: String, fileName: String, extention: String) {
        
        if UIDevice.current.orientation.isLandscape {
            self.isLandscape = true
        } else {
            self.isLandscape = false
        }
        
        self.directoryName = directoryName
        self.fileName = fileName
        self.extention = extention
        self.canvasLeadingScale = leadingScale
        self.canvasTopScale = topScale
        self.sampleQuizImage = Bundle.main.url(forResource: fileName, withExtension: extention)!
        let urlContents = try? Data(contentsOf: sampleQuizImage)
        self.quizImage = UIImage(data: urlContents!)!
        self.zoomScale = widthScale / quizImage.size.width
        
        if (leadingScale + widthScale >= 1.0) {
            self.canvasWidthScale = 0.95 - leadingScale
            self.quizWidthScale = 0.95 - leadingScale
        } else {
            self.canvasWidthScale = widthScale
            self.quizWidthScale = widthScale
        }
        self.canvasHeightScale = heightScale * canvasWidthScale
        self.quizHeightScale = canvasWidthScale * quizImage.size.height / quizImage.size.width
        
        if (quizHeightScale < canvasHeightScale) {
            self.canvasHeightScale = quizHeightScale
        }
    }
}
