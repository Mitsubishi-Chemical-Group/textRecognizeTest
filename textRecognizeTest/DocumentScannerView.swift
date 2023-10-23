import SwiftUI
import Vision
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(parent: DocumentScannerView) {
            self.parent = parent
        }
        
        //saveボタン
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard scan.pageCount >= 1 else {
                controller.dismiss(animated: true)
                return
            }
            
            let image = scan.imageOfPage(at: 0)
            print(parent.processScannedImage(image))
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    //ドキュメントカメラの表示
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    //画面表示の変更
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    //読み取った画像の解析byVisionKit
    func processScannedImage(_ image: UIImage) -> [(String, CGRect)] {
        guard let cgImage = image.cgImage else { return [] }
        
        let request = VNRecognizeTextRequest()
        request.minimumTextHeight = 0.001
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
        
        let observations = (request.results) ?? []
        return observations.compactMap {
            guard let topCandidate = $0.topCandidates(1).first else { return nil }
            return (topCandidate.string, $0.boundingBox)
        }
    }
}

struct ContentView: View {
    @State private var isScanning = false
    
    var body: some View {
        DocumentScannerView()
    }
}

struct DocumentScanner_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
