import UIKit
import PencilKit
import Foundation

// UIColor 설정
extension UIColor {
  @nonobjc class var gray: UIColor {
    return UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1)
  }
}

// 전체 화면
class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    // 필요한 상수, 변수
    private let baseView = UIView()
    private var moduleView: ModuleScrollView!
    private var saveBtn = UIButton()
    private var landscapeConstraint = [NSLayoutConstraint]()
    private var portraitConstraint = [NSLayoutConstraint]()
    
    // init 변수
    var item = Initializers(leadingScale: 0.1, topScale: 0.1, widthScale: 0.6, heightScale: 2.0, directoryName: "문제집_id", fileName: "sample", extention: "png")
    private var longerWidth: CGFloat = 0
    private var shorterWidth: CGFloat = 0
    
    // 첫 설정: 회색 바탕 + 흰색 모듈
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        
        longerWidth = view.bounds.width > view.bounds.height ? view.bounds.width : view.bounds.height
        shorterWidth = view.bounds.width < view.bounds.height ? view.bounds.width : view.bounds.height
        let initialFrame = CGRect(x:0, y:0, width: 0, height: 0)
        moduleView = ModuleScrollView(longerWidth: longerWidth, shorterWidth: shorterWidth, initializers: item, frame: initialFrame)
        
        moduleView.loadCanvasData(directoryName: self.item.directoryName)
        self.makeDir()

        self.view.addSubview(baseView)
        setUIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // 화면 회전 시 호출
    @objc private func rotated() {
        
        let landscapeFrame = CGRect(x:0, y:0, width: self.item.quizWidthScale * self.longerWidth, height: self.item.quizHeightScale * self.longerWidth)
        let landscapeZoom = self.longerWidth / self.shorterWidth
        let portraitFrame = CGRect(x:0, y:0, width: self.item.quizWidthScale * self.shorterWidth, height: self.item.quizHeightScale * self.shorterWidth)
        let portraitZoom = self.shorterWidth / self.longerWidth
        
        DispatchQueue.main.async() {
            
            if UIDevice.current.orientation.isLandscape {
                print("Landscape")
                for constraint in self.portraitConstraint {
                    constraint.isActive = false
                }
                for constraint in self.landscapeConstraint {
                    constraint.isActive = true
                }
                self.moduleView.setLandscape(frame: landscapeFrame, zoom: landscapeZoom)
                
            } else if UIDevice.current.orientation.isPortrait {
                print("Portrait")
                for constraint in self.landscapeConstraint {
                    constraint.isActive = false
                }
                for constraint in self.portraitConstraint {
                    constraint.isActive = true
                }
                self.moduleView.setPortrait(frame: portraitFrame, zoom: portraitZoom)
            }
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    // 스크롤뷰 설정
    private func setUIView() {
        
        baseView.translatesAutoresizingMaskIntoConstraints = false
        baseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 12).isActive = true
        baseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
        baseView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12).isActive = true
        baseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -12).isActive = true
        
        baseView.backgroundColor = .gray
        
        baseView.addSubview(saveBtn)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.leadingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -100).isActive = true
        saveBtn.topAnchor.constraint(equalTo: baseView.topAnchor, constant: 20).isActive = true
        saveBtn.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -20).isActive = true
        saveBtn.bottomAnchor.constraint(equalTo: baseView.topAnchor, constant: 40).isActive = true
        
        saveBtn.setTitle("Save", for: .normal)
        saveBtn.setTitleColor(.black, for: .normal)
        saveBtn.titleLabel?.font = .systemFont(ofSize: 12)
        saveBtn.backgroundColor = .white
        saveBtn.layer.cornerRadius = 10
        saveBtn.addTarget(self, action: #selector(moduleView.saveDrawing), for: .touchUpInside)
        
        setModuleView()
    }
    
    // 모듈뷰 설정
    private func setModuleView() {
        
        baseView.addSubview(moduleView)
        moduleView.translatesAutoresizingMaskIntoConstraints = false
        
        let landscapeModuleLeading = moduleView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: self.item.canvasLeadingScale * longerWidth)
        let landscapeModuleTop = moduleView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: self.item.canvasTopScale * shorterWidth)
        let landscapeModuleWidth = moduleView.widthAnchor.constraint(equalToConstant: self.item.canvasWidthScale * longerWidth)
        var landscapeModuleHeight = moduleView.heightAnchor.constraint(equalToConstant: self.item.canvasHeightScale * longerWidth)
        if (shorterWidth <= self.item.canvasHeightScale * longerWidth + self.item.canvasTopScale * shorterWidth) {
            landscapeModuleHeight = moduleView.heightAnchor.constraint(equalToConstant: shorterWidth * 0.95 - self.item.canvasTopScale * shorterWidth)
        }
        landscapeConstraint += [landscapeModuleLeading, landscapeModuleTop, landscapeModuleWidth, landscapeModuleHeight]
        
        let portraitModuleLeading = moduleView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: self.item.canvasLeadingScale * shorterWidth)
        let portraitModuleTop = moduleView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: self.item.canvasTopScale * longerWidth)
        let portraitModuleWidth = moduleView.widthAnchor.constraint(equalToConstant: self.item.canvasWidthScale * shorterWidth)
        var portraitModuleHeight = moduleView.heightAnchor.constraint(equalToConstant: self.item.canvasHeightScale * shorterWidth)
        if (longerWidth <= self.item.canvasHeightScale * shorterWidth + self.item.canvasTopScale * longerWidth) {
            portraitModuleHeight = moduleView.heightAnchor.constraint(equalToConstant: longerWidth * 0.95 - self.item.canvasTopScale * longerWidth)
        }
        portraitConstraint += [portraitModuleLeading, portraitModuleTop, portraitModuleWidth, portraitModuleHeight]
        
        if self.item.isLandscape {
            landscapeModuleLeading.isActive = true
            landscapeModuleTop.isActive = true
            landscapeModuleWidth.isActive = true
            landscapeModuleHeight.isActive = true
        } else {
            portraitModuleLeading.isActive = true
            portraitModuleTop.isActive = true
            portraitModuleWidth.isActive = true
            portraitModuleHeight.isActive = true
        }

        moduleView.maximumZoomScale = 3.0
        moduleView.showsVerticalScrollIndicator = false
        moduleView.showsHorizontalScrollIndicator = false
        moduleView.backgroundColor = .white
        moduleView.layer.cornerRadius = 10
    
        moduleView.setStackView()
    }
    
    // 디렉토리 만들기
    private func makeDir() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = documentsURL.appendingPathComponent(self.item.directoryName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let pencilDirURL = directoryURL.appendingPathComponent("p_pencil", isDirectory: true)
        do {
            try fileManager.createDirectory(at: pencilDirURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let filePath = pencilDirURL.appendingPathComponent(self.item.fileName + ".drawing", isDirectory: true)
        do {
            try fileManager.createDirectory(at: filePath, withIntermediateDirectories: false, attributes: nil)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    class ModuleScrollView: UIScrollView {
        
        private var longerWidth: CGFloat
        private var shorterWidth: CGFloat
        private var item: Initializers
        
//        required init?(coder: NSCoder) {
//            print("init")
//        }
        
        init (longerWidth: CGFloat, shorterWidth: CGFloat, initializers: Initializers, frame: CGRect) {
            self.longerWidth = longerWidth
            self.shorterWidth = shorterWidth
            self.item = initializers
            super.init(frame: frame)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        
        private let stackView = UIStackView()
        private let canvasView: PKCanvasView = PKCanvasView()
        private let quizView: UIImageView = UIImageView()
        private var toolPicker: PKToolPicker!
        private var drawing = PKDrawing()
        private var landscapeConstraint = [NSLayoutConstraint]()
        private var portraitConstraint = [NSLayoutConstraint]()
        
        func setLandscape(frame: CGRect, zoom: CGFloat) {
            
            for constraint in self.portraitConstraint {
                constraint.isActive = false
            }
            for constraint in self.landscapeConstraint {
                constraint.isActive = true
            }
            self.quizView.frame = frame
            self.canvasView.setZoomScale(zoom, animated: false)
            self.canvasView.minimumZoomScale = zoom
            self.canvasView.setContentOffset(CGPoint.zero, animated: false)
            
        }
        
        func setPortrait(frame: CGRect, zoom: CGFloat) {
            
            for constraint in self.landscapeConstraint {
                constraint.isActive = false
            }
            for constraint in self.portraitConstraint {
                constraint.isActive = true
            }
            self.quizView.frame = frame
            self.canvasView.setZoomScale(zoom, animated: false)
            self.canvasView.minimumZoomScale = 1.0
            self.canvasView.setContentOffset(CGPoint.zero, animated: false)
            
        }
        
        // 스택뷰 설정
        func setStackView() {
            
            self.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            let landscapeStackWidth = stackView.widthAnchor.constraint(equalToConstant: self.item.quizWidthScale * longerWidth)
            let landscapeStackHeight = stackView.heightAnchor.constraint(equalToConstant: self.item.quizHeightScale * longerWidth)
            landscapeConstraint += [landscapeStackWidth, landscapeStackHeight]
            
            let portraitStackWidth = stackView.widthAnchor.constraint(equalToConstant: self.item.quizWidthScale * shorterWidth)
            let portraitStackHeight = stackView.heightAnchor.constraint(equalToConstant: self.item.quizHeightScale * shorterWidth)
            portraitConstraint += [portraitStackWidth, portraitStackHeight]

            if self.item.isLandscape {
                landscapeStackWidth.isActive = true
                landscapeStackHeight.isActive = true
            } else {
                portraitStackWidth.isActive = true
                portraitStackHeight.isActive = true
            }
            
            self.setCanvasView()
        }
        
        // 캔버스뷰 설정
        private func setCanvasView() {
            
            stackView.addArrangedSubview(canvasView)
            
            canvasView.translatesAutoresizingMaskIntoConstraints = false
            canvasView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            canvasView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            canvasView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            canvasView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            canvasView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            canvasView.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
            
            canvasView.backgroundColor = .clear
            canvasView.bouncesZoom = false
            canvasView.bounces = false
            canvasView.showsVerticalScrollIndicator = false
            canvasView.showsHorizontalScrollIndicator = false
            canvasView.drawingPolicy = PKCanvasViewDrawingPolicy.pencilOnly
            canvasView.layer.cornerRadius = 10
            canvasView.isUserInteractionEnabled = true
            canvasView.drawingGestureRecognizer.isEnabled = true
        
            self.setToolkit()
            self.setQuizView()
        }
        
        // 펜슬 설정
        private func setToolkit() {
            
            toolPicker = PKToolPicker()
            toolPicker.addObserver(canvasView)
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
            
        }
        
        // 퀴즈뷰 설정
        private func setQuizView() {

            if let contentView = canvasView.subviews.first {
                contentView.insertSubview(quizView, at: 0)
                let urlContents = try? Data(contentsOf: self.item.sampleQuizImage)
                if let imageData = urlContents {
                    quizView.image = UIImage(data: imageData)!
                }
            }
            
            quizView.accessibilityViewIsModal = true
            quizView.translatesAutoresizingMaskIntoConstraints = false
            let landscapeQuizWidth = quizView.widthAnchor.constraint(equalToConstant: self.item.quizWidthScale * longerWidth)
            let landscapeQuizHeight = quizView.heightAnchor.constraint(equalToConstant: self.item.quizHeightScale * longerWidth)
            let portraitQuizWidth = quizView.widthAnchor.constraint(equalToConstant: self.item.quizWidthScale * shorterWidth)
            let portraitQuizHeight = quizView.heightAnchor.constraint(equalToConstant: self.item.quizHeightScale * shorterWidth)

            if self.item.isLandscape {
                landscapeQuizWidth.isActive = true
                landscapeQuizHeight.isActive = true
            } else {
                portraitQuizWidth.isActive = true
                portraitQuizHeight.isActive = true
            }
            
            canvasView.contentInset = UIEdgeInsets.zero
            canvasView.setContentOffset(CGPoint.zero, animated: true)
            canvasView.maximumZoomScale = 3.0
        }
        
        // 캔버스뷰 저장
        @objc func saveDrawing(sender: UIButton!) {
            print("Save")
            let getCanvas = self.canvasView
            if getCanvas.drawing.dataRepresentation().count > 50 {
                do { let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: getCanvas.drawing, requiringSecureCoding: false)
                    let fileManager = FileManager.default
                    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let directoryURL = documentsURL.appendingPathComponent(self.item.directoryName, isDirectory: true)
                    let pencilDirURL = directoryURL.appendingPathComponent("p_pencil", isDirectory: true)
                    let fileURL = pencilDirURL.appendingPathComponent(self.item.fileName + ".drawing", isDirectory: true)
                    do {
                        try encodedData.write(to: fileURL)
                    } catch let error {
                        print(error.localizedDescription)
                    }
    //                DataBase.setValue(.init(rawValue: "prob1")!, value: encodedData)
                } catch {
                    print(error)
                }
            }
        }

        // 캔버스데이터 불러오기
        func loadCanvasData(directoryName: String) {
            let getCanvas = self.canvasView
            var planDraw = Data()
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let directoryURL = documentsURL.appendingPathComponent(directoryName, isDirectory: true)
            let pencilDirURL = directoryURL.appendingPathComponent("p_pencil", isDirectory: true)
            let filePath = pencilDirURL.appendingPathComponent(self.item.fileName, isDirectory: true)
            do {
                planDraw = try Data(contentsOf: filePath)
            } catch let error {
                print(error.localizedDescription)
            }
    //        planDraw = DataBase.getData((.init(rawValue: "prob1") ?? .prob1))
            do {
                let getDraw = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(planDraw) as? PKDrawing
                DispatchQueue.main.async {
                    getCanvas.drawing = getDraw ?? PKDrawing()
                }
            } catch {
            print(error)
            }
        }
    }

}
