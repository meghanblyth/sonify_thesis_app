//
//  NetworkService.swift
//  Sonify
//
//  Created by Meghan Blyth on 29/07/2021.
//

import UIKit

class NetworkService: NSObject {
    
    static let shared = NetworkService()
    
    private override init() {}
    
    /// download progress with range 0 - 1
    private var downloadProgress: ((CGFloat) -> Void)?
    private var downloadFinished: ((Result<URL, Error>) -> Void)?
    
    func uploadImage(_ image: UIImage, completion: @escaping(String?) -> Void) {
        let url = URL(string: "http://40.118.11.244/sonify")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", imageDataKey: imageData, boundary: boundary)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error.localizedDescription)
                }
                return
            }
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                print("The response: \(json)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
            
        }.resume()
    }
    //downloading the audio from the back end
    func downloadImage(completion: @escaping(Result<URL, Error>) -> Void,
                       progress: @escaping(CGFloat) -> Void) {
        let url = URL(string: "http://40.118.11.244/getfile")!
        self.downloadProgress = progress
        self.downloadFinished = completion

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        session.downloadTask(with: url).resume()
    }
}

// MARK:- Session Delegate
extension NetworkService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.downloadFinished?(.success(location))
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            self.downloadFinished?(.failure(error))
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        downloadProgress?(progress)                 //a delegate notifying the view controller the % progress of the download
    }
}
    //This is required for uploading images

extension NetworkService {
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        let filename = "file.jpg"
        
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        body.append(imageDataKey)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
