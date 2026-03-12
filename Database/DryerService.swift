//
//  DryerService.swift
//  SOMS
//
//  Created by Dan XD on 2/24/26.
//

import Foundation

class DryerService {
    
    static func sendBatchToServer(dataList: [DryerData]) {
        
        guard let url = URL(string: "https://stellarseedscorp.org/system/app/DR/saveDryerData.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = dataList.map { data in
            return [
                "dhid": data.dhid,
                "noh": data.noh,
                "date": data.date,
                "time": data.time,
                "upper": data.upper,
                "lower": data.lower,
                "boiler": data.boiler,
                "mc": data.mc,
                "remarks": data.remarks,
                "status": data.status,
                "sl": data.sl,
                "startstrtime": data.startstrtime
            ]
        }
        
//        print("Going to send \(body)")
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request).resume()
    }
}
