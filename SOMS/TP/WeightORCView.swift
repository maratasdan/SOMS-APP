//
//  WeightOCRView.swift
//  SOMS
//
//  Live Camera + Guide Box + OCR (Digital-Friendly, Capture Button)
//

import SwiftUI
import AVFoundation
import Vision
import Combine
import CoreImage

struct WeightOCRView: View {
    @StateObject private var cameraModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()
            
            // Guide box sa center
            Rectangle()
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 260, height: 120)
            
            VStack {
                Spacer()
                
                // 🔹 Display sa baba
                VStack(spacing: 10) {
                    Text("Detected Weight")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(cameraModel.extractedWeight)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.yellow)
                    
                    // Capture button
                    Button(action: {
                        cameraModel.captureCurrentFrame()
                    }) {
                        Text("📸 Capture Weight")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.7))
            }
        }
        .onAppear { cameraModel.startSession() }
        .onDisappear { cameraModel.stopSession() }
    }
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Camera + OCR ViewModel
class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @Published var extractedWeight: String = "0.000"
    
    let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    
    private var lastSampleBuffer: CMSampleBuffer?
    private let ciContext = CIContext()
    
    override init() {
        super.init()
        
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
    }
    
    func startSession() { session.startRunning() }
    func stopSession() { session.stopRunning() }
    
    // Save last frame for manual capture
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        self.lastSampleBuffer = sampleBuffer
    }
    
    // Called when button is tapped
    func captureCurrentFrame() {
        guard let sampleBuffer = lastSampleBuffer,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // 🔹 Preprocess for digital display
        if let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(1.8, forKey: kCIInputContrastKey)   // enhance contrast
            filter.setValue(0, forKey: kCIInputSaturationKey)   // grayscale
            if let output = filter.outputImage {
                ciImage = output
            }
        }
        
        // Optional: invert colors if dark display
        if let invertFilter = CIFilter(name: "CIColorInvert") {
            invertFilter.setValue(ciImage, forKey: kCIInputImageKey)
            if let output = invertFilter.outputImage {
                ciImage = output
            }
        }
        
        // Convert to CGImage
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // Crop sa center rectangle (match sa guide box)
        let cropRect = CGRect(
            x: width * 0.35,
            y: height * 0.4,
            width: width * 0.3,
            height: height * 0.15
        )
        guard let croppedCG = cgImage.cropping(to: cropRect) else { return }
        
        // OCR request
        let request = VNRecognizeTextRequest { [weak self] request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var fullText = ""
            for obs in observations {
                if let top = obs.topCandidates(1).first {
                    fullText += top.string + " "
                }
            }
            
            DispatchQueue.main.async {
                // Extract decimal number only
                let pattern = "\\d+(\\.\\d+)?"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    if let match = regex.firstMatch(in: fullText, options: [], range: NSRange(fullText.startIndex..., in: fullText)),
                       let range = Range(match.range, in: fullText) {
                        self?.extractedWeight = String(fullText[range])
                    } else {
                        self?.extractedWeight = "0.000" // fallback
                    }
                }
            }
        }
        
        request.recognitionLevel = .accurate
        try? VNImageRequestHandler(cgImage: croppedCG, options: [:]).perform([request])
    }
}

#Preview {
    WeightOCRView()
}
