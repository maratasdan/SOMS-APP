//
//  WeightScannerView.swift
//  SOMS
//
//  Created by Dan XD on 3/3/26.
//

import SwiftUI
import AVFoundation
import Vision

struct CameraView: UIViewControllerRepresentable {
    
    var onCapture: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        var onCapture: (UIImage) -> Void
        
        init(onCapture: @escaping (UIImage) -> Void) {
            self.onCapture = onCapture
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            
            picker.dismiss(animated: true)
        }
    }
}

struct WeightScannerView: View {
    @State private var recognizedText = ""
    @State private var extractedWeight = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            CameraView { image in
                recognizeText(from: image)
            }
            .frame(height: 300)
            .cornerRadius(12)
            
            Text("Detected Text:")
                .font(.headline)
            
            Text(recognizedText)
                .padding()
            
            Divider()
            
            Text("Extracted Weight:")
                .font(.headline)
            
            Text(extractedWeight)
                .font(.largeTitle)
                .bold()
        }
        .padding()
    }
    
    func recognizeText(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        let request = VNRecognizeTextRequest { request, error in
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var detectedString = ""
            
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    detectedString += topCandidate.string + " "
                }
            }
            
            DispatchQueue.main.async {
                recognizedText = detectedString
                
                // Extract numbers + decimal only
                extractedWeight = detectedString
                    .filter { "0123456789.".contains($0) }
            }
        }
        
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
}

#Preview {
    WeightScannerView()
}
