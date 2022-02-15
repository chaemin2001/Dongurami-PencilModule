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
    enum DataBaseEnum: String, CaseIterable {
        case problem
        case solution
        func make(for id: String) -> String {
            return self.rawValue + "_" + id
        }
    }
    
    let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    class func setValue(_ key : DataBaseEnum, value : Any?, id: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(value, forKey: key.make(for: id))
        userDefaults.synchronize()
    }

    class func getData(_ key: DataBaseEnum, id: String) -> Data {
        return UserDefaults.standard.value(forKey: key.make(for: id)) as? Data ?? Data()
    }
}

struct Initializers {
    
    let canvasLeadingScale: CGFloat
    let canvasTopScale: CGFloat
    var canvasWidthScale: CGFloat
    var canvasHeightScale: CGFloat
    var isLandscape: Bool
    
    let sampleQuizImage: URL
    let saveCase: String
    let id: String
    let fileName: String
    let extention: String
    let quizImage: UIImage
    var quizWidthScale: CGFloat
    var quizHeightScale: CGFloat
    let zoomScale: CGFloat
    
    init(leadingScale: CGFloat, topScale: CGFloat, widthScale: CGFloat, heightScale: CGFloat, saveCase: String, id: String, fileName: String, extention: String) {
        
        if UIDevice.current.orientation.isLandscape {
            self.isLandscape = true
        } else {
            self.isLandscape = false
        }
        
        self.saveCase = saveCase
        self.id = id
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
