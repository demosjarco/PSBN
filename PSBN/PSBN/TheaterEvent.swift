//
//  TheaterEvent.swift
//  PSBN
//
//  Created by Victor Ilisei on 9/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking

class TheaterEvent: UIViewController {
    @IBOutlet var bgPoster:UIImageView?
    @IBOutlet var thumbnail:UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = self.navigationController?.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        self.configureView()
    }
    
    var detailItem: [String: AnyObject]? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail["full_name"] as! String
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            
            let remoteConfig = FIRRemoteConfig.remoteConfig()
            remoteConfig.fetch(completionHandler: { (status, error) in
                if status == .success {
                    remoteConfig.activateFetched()
                    
                    var imageUrl = remoteConfig["blank_poster_url"].stringValue!
                    let imageHeight = CGFloat(9.0/16.0) * self.view.bounds.size.width
                    if detail["logo"] != nil {
                        let logo = detail["logo"] as! [String: AnyObject]
                        imageUrl = logo["url"] as! String
                    }
                    imageUrl = imageUrl.replacingOccurrences(of: ".png", with: "_" + String(describing: Int(self.view.bounds.size.width * UIScreen.main.scale)) + "x" + String(describing: Int(imageHeight * UIScreen.main.scale)) + ".png")
                    self.bgPoster?.setImageWith(URL(string: imageUrl)!)
                }
            })
        }
    }
    
    @IBAction func shareButtonPressed(sender: UIBarButtonItem) {
        let eventTitle = self.detailItem!["full_name"] as! String
        let text = eventTitle + " on PSBN"
        
        let ownerAccountId = self.detailItem!["owner_account_id"] as! Int
        let eventId = self.detailItem!["id"] as! Int
        let url = URL(string: "https://livestream.com/accounts/" + String(ownerAccountId) + "/events/" + String(eventId))
        
        let activityViewController = UIActivityViewController(activityItems: [text, url!], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
