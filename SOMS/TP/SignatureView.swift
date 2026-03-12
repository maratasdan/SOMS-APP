//
//  SignatureView.swift
//  SOMS
//
//  Created by Dan XD on 3/3/26.
//
import SwiftUI

struct SignatureView: View {
    @State private var points: [CGPoint] = []
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .border(Color.gray, width: 1)
                
                Path { path in
                    for (i, point) in points.enumerated() {
                        if i == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.black, lineWidth: 2)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        points.append(value.location)
                    }
                    .onEnded { _ in
                        // do nothing
                    }
            )
            .frame(width: 400, height: 200)
            
            HStack {
                Button("Clear") {
                    points = []
                }
                
                Button("Save & Upload") {
                    saveAndUploadSignature()
                }
            }
            .padding()
        }
        .padding()
    }
    
    func saveAndUploadSignature() {
        let image = pointsToImage()
        if let data = image.pngData() {
            uploadSignature(data: data)
        }
    }
    
    func pointsToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 200))
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(x: 0, y: 0, width: 400, height: 200))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.setLineCap(.round)
            
            for (i, point) in points.enumerated() {
                if i == 0 {
                    ctx.cgContext.move(to: point)
                } else {
                    ctx.cgContext.addLine(to: point)
                }
            }
            ctx.cgContext.strokePath()
        }
    }
    
    func uploadSignature(data: Data) {
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/T%26P/uploadSig.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let filename = "signature.png"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        URLSession.shared.uploadTask(with: request, from: body) { responseData, _, error in
            if let error = error {
                print("Upload error: \(error)")
            } else {
                print("Signature uploaded successfully!")
            }
        }.resume()
    }
}

#Preview {
    SignatureView()
}
