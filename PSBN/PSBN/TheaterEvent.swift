//
//  TheaterEvent.swift
//  PSBN
//
//  Created by Victor Ilisei on 9/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit

class TheaterEvent: UIViewController {
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
            /*if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }*/
        }
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
