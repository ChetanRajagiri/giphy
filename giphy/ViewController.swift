//
//  ViewController.swift
//  giphy
//
//  Created by chetan rajagiri on 31/08/17.
//  Copyright © 2017 chetan rajagiri. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {


    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var imgUrlArray = [String]()
    var height = [String]()
// for paging
    var offset : String {
        if offsetValue == 0 {
            return "0"
        }else {
            return "\(offsetValue)"
        }
    }
    var offsetValue = 0
    
    let sectionInsets = UIEdgeInsetsMake(10, 10, 10, 10)
    let url = "https://api.giphy.com/v1/gifs/trending?api_key=0d4f9877de6d4927943adf5a0d20e8a0&limit=25&rating=G&offset=0"
    
  override func viewDidLoad() {
        super.viewDidLoad()
         parseData(urll: url)
    
    let layout = collectionView.collectionViewLayout as! PinterestLayout
    layout.delegate = self
    layout.numberOfColumns = 2
    layout.invalidateLayout()

    }

    //searchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
        let keywords = searchBar.text
      let finalKey =  keywords?.replacingOccurrences(of: " ", with: "+")
        let finalurl = "https://api.giphy.com/v1/gifs/search?api_key=0d4f9877de6d4927943adf5a0d20e8a0&q=\(finalKey!)&limit=25&offset=0&rating=G&lang=en"
        DispatchQueue.global(qos: .background).async {
            self.parseData(urll: finalurl)
        }
        DispatchQueue.main.async {
            self.imgUrlArray.removeAll(keepingCapacity: false)
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.view.endEditing(true)
        }
    }
    
    //collectionViewDatasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgUrlArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell
        let resource = ImageResource(downloadURL: URL(string : imgUrlArray[indexPath.row])!, cacheKey: imgUrlArray[indexPath.row])
        cell?.imgview.kf.setImage(with: resource)
        if indexPath.row == imgUrlArray.count - 10  {
            offsetValue += 25
            
            let nexturl = "https://api.giphy.com/v1/gifs/trending?api_key=0d4f9877de6d4927943adf5a0d20e8a0&limit=25&rating=G&offset=\(offset)"
           self.parseData(urll: nexturl)
        }
        return cell!
    }
    
    //Parse data function
    func parseData(urll : String) {
        var request = URLRequest(url: URL(string: urll)!)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                do {
                    let fetchedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! NSDictionary
                    if  let gifArray = fetchedData.value(forKey: "data") as? NSArray {
                        if  let gifarrayImg = gifArray.value(forKey: "images") as? NSArray {
                            if let gifarrayImgFixedWdth = gifarrayImg.value(forKey: "fixed_width") as? NSArray {
                                for gif in gifarrayImgFixedWdth {
                                    if let gifDict = gif as? NSDictionary {
                                        if let imgURL = gifDict.value(forKey: "url") {
                                            print(imgURL)
                                            self.imgUrlArray.append(imgURL as! String)
                                        }
                                        if let imgHeight = gifDict.value(forKey: "height") {
                                            self.height.append(imgHeight as! String)
                                            print(imgHeight)
                                        }
                                        DispatchQueue.main.async {
                                            self.collectionView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    print("Error2")
                }
            }
        }
        task.resume()
    }
 }

extension ViewController: PinterestLayoutDelegate {
    func collectionView(collectionview: UICollectionView, heightForItemAtIndexpath indexpath: NSIndexPath) -> CGFloat {
        let imgHeight = height[indexpath.row]
        let heightNumber = NumberFormatter().number(from: imgHeight)
        let heightFloat = CGFloat(heightNumber!)
        return heightFloat
    }
    
}
