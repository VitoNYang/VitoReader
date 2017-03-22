//
//  ViewController.swift
//  VitoReader
//
//  Created by hao on 2017/3/22.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    let fileNameList = ["完美世界"/*, "utf8_with_bom", "utf8_no_bom",
                    "utf16BE_with_bom", "utf16BE_no_bom",
                    "utf16LE_no_bom", "utf16LE_with_bom",
                    "gbk"*/]
    
    var txtLines = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let filePathList = fileNameList
            .map { Bundle.main.path(forResource: $0, ofType: "txt") }
            .filter { $0 != nil }
        
        filePathList.forEach { filePath in
            //getFileEncode(path: filePath!)
            //readFile(path: filePath!)
            fileHandle(path: filePath!)
        }
        
    }
    
    private func getFileEncode(path: String) {
        guard let inputStream = InputStream(fileAtPath: path) else { return }
        inputStream.open()
        var readBuffer = Array(repeating: UInt8(0), count: 2)
        inputStream.read(&readBuffer, maxLength: 2)
        inputStream.close()
        
        let result = readBuffer.reduce("", { "\($0)\(String($1, radix: 16))" })
        /*switch result {
        case "efbb":
            print("utf8")
        case "feff":
            print("utf16BE")
        case "fffe":
            print("utf16LE")
        default:
            print("other")
        }*/
        print(result)
    }
    
    private func readFile(path: String) {
        guard let inputStream = InputStream(fileAtPath: path) else { return }
        inputStream.open()
        
        let bufferLength = 1024
        var readBuffer = [UInt8](repeating: 0, count: bufferLength)
        
        while inputStream.hasBytesAvailable {
            let readLenght = inputStream.read(&readBuffer, maxLength: bufferLength)
            let readRange = readBuffer[0..<readLenght]
            let a = String.init(bytes: readRange, encoding: String.Encoding.gbk)
            print(a)
        }
        
        inputStream.close()
    }
    
    private func fileHandle(path: String) {
        guard let reader = StreamReader(path: path, encoding: .gbk) else { return }
        defer {
            reader.close()
        }
        for line in reader.makeIterator() {
            //print(line)
            txtLines.append(line)
        }
        tableView.reloadData()
        DispatchQueue.main.async {
            let lastContentOffsetY = UserDefaults.standard.float(forKey: kContentOffsetYKey)
            print("get contentOffsetY > \(lastContentOffsetY)")
            print(self.tableView.contentSize.height)
            self.tableView.scrollRectToVisible(CGRect.init(x: 0, y: CGFloat(lastContentOffsetY), width: 1, height: 1), animated: false)
        }
    }

}

let kContentOffsetYKey = "com.vito.vitoreader.content_offset_y"

extension ViewController: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        UserDefaults.standard.set(scrollView.contentOffset.y, forKey: kContentOffsetYKey)
        print("save contentOffsetY > \(scrollView.contentOffset.y)")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
        cell.txtLabel.text = txtLines[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return txtLines.count
    }
}

extension String.Encoding {
    static let gbk = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosChineseSimplif.rawValue)))
}

