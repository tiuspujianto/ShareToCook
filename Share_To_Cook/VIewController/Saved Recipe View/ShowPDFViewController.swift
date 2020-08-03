//
//  ShowPDFViewController.swift
//  Share_To_Cook
//
//  Created by Timotius Pujianto on 27/5/19.
//  Copyright © 2019 Timotius Pujianto. All rights reserved.
//

import UIKit
import PDFKit

class ShowPDFViewController: UIViewController {
    
    var fileName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdfView = PDFView(frame: view.bounds)
        pdfView.autoScales = true
        view.addSubview(pdfView)
       
        // Create a PDFDocument object and set it as PDFView's document to load the document in that view.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = (documentsDirectory as NSString).appendingPathComponent(fileName!) as String
        let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath))
        pdfView.document = pdfDocument
    }

}
