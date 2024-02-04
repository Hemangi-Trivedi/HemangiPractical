//
//  GalleryViewCell.swift
//  PracticalHemangio2h
//
//  Created by Shubham's Macbook on 02/02/24.
//

import UIKit
import Gemini

class GalleryViewCell: GeminiCell {
    
    var arrStory : [Apidata] = []
    var testArr : [Apidata] = []
    @IBOutlet weak var ImgGallary: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func dataSetup(data:Apidata){
        self.ImgGallary.image = UIImage(named: data.largeImageURL)
    }
    
}
