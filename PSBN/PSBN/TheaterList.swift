//
//  TheaterList.swift
//  PSBN
//
//  Created by Victor Ilisei on 9/11/16.
//  Copyright © 2016 Tech Genius. All rights reserved.
//

import UIKit
import Firebase
import AFNetworking

class TheaterList: UITableViewController {
    var events = [EventDateSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        refresh(sender: self.refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        sender?.beginRefreshing()
        events = [EventDateSection]()
        self.tableView.reloadData()
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                var countChannels = 0
                var countChannelsDone = 0
                
                if remoteConfig["channel_1_enabled"].boolValue {
                    countChannels += 1
                    // Show channel 1
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_1_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        for event in upcoming_events_data {
                            self.parseEvent(event: event)
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        for event in past_events_data {
                            self.parseEvent(event: event)
                        }
                    }, failure: { (task, error) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                        // Save error to database
                    })
                }
                
                if remoteConfig["channel_2_enabled"].boolValue {
                    countChannels += 1
                    // Show channel 2
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_2_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        for event in upcoming_events_data {
                            self.parseEvent(event: event)
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        for event in past_events_data {
                            self.parseEvent(event: event)
                        }
                    }, failure: { (task, error) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                        // Save error to database
                    })
                }
                
                if remoteConfig["channel_liberty_enabled"].boolValue {
                    countChannels += 1
                    // Show channel Liberty
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_liberty_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        for event in upcoming_events_data {
                            self.parseEvent(event: event)
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        for event in past_events_data {
                            self.parseEvent(event: event)
                        }
                    }, failure: { (task, error) in
                        countChannelsDone += 1
                        if countChannelsDone == countChannels {
                            sender?.endRefreshing()
                        }
                            // Save error to database
                    })
                }
            } else {
                sender?.endRefreshing()
            }
        }
    }
    
    func parseEvent(event: [String: AnyObject]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let eventDate = dateFormatter.date(from: event["start_time"] as! String)
        let eventDateComponents = Calendar(identifier: .gregorian).dateComponents(Set<Calendar.Component>([.year, .month, .day]), from: eventDate!)
        if self.events.count == 0 {
            // First day section
            let eventDateSection = EventDateSection()
            eventDateSection.year = eventDateComponents.year!
            eventDateSection.month = eventDateComponents.month!
            eventDateSection.day = eventDateComponents.day!
            eventDateSection.events.append(event)
            self.events.append(eventDateSection)
            
            self.tableView.insertSections(IndexSet(integer: 0), with: .automatic)
            self.tableView.reloadSectionIndexTitles()
        } else {
            // Check if matches other day section
            var newSectionNeeded = true
            
            for eventDateSection in self.events {
                if eventDateSection.year == eventDateComponents.year && eventDateSection.month == eventDateComponents.month && eventDateSection.day == eventDateComponents.day {
                    newSectionNeeded = false
                    eventDateSection.events.append(event)
                    eventDateSection.events.sort(by: { (o1, o2) -> Bool in
                        let d1 = dateFormatter.date(from: o1["start_time"] as! String)
                        let d2 = dateFormatter.date(from: o2["start_time"] as! String)
                        return d1! > d2!
                    })
                    self.tableView.reloadSections(IndexSet(integer: self.events.index(of: eventDateSection)!), with: .automatic)
                    break;
                }
            }
            
            if newSectionNeeded {
                let eventDateSection = EventDateSection()
                eventDateSection.year = eventDateComponents.year!
                eventDateSection.month = eventDateComponents.month!
                eventDateSection.day = eventDateComponents.day!
                eventDateSection.events.append(event)
                self.events.append(eventDateSection)
                
                self.events.sort(by: { (o1, o2) -> Bool in
                    var dc1 = DateComponents()
                    dc1.year = o1.year
                    dc1.month = o1.month
                    dc1.day = o1.day
                    var dc2 = DateComponents()
                    dc2.year = o2.year
                    dc2.month = o2.month
                    dc2.day = o2.day
                    return Calendar(identifier: .gregorian).date(from: dc1)! > Calendar(identifier: .gregorian).date(from: dc2)!
                })
                self.tableView.reloadData()
                self.tableView.reloadSectionIndexTitles()
            }
        }
    }

    // MARK: - Table view data source
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var indexTitles = [String]()
        for eventSection in self.events {
            indexTitles.append(String(describing: eventSection.month) + "/" + String(describing: eventSection.day))
        }
        return indexTitles
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        var dc = DateComponents()
        dc.year = events[section].year
        dc.month = events[section].month
        dc.day = events[section].day
        return dateFormatter.string(from: Calendar(identifier: .gregorian).date(from: dc)!)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // (original height / original width) x new width = new height
        return CGFloat(9.0/16.0) * tableView.bounds.size.width
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // (original height / original width) x new width = new height
        return CGFloat(9.0/16.0) * tableView.bounds.size.width
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events[section].events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! TheaterListCell
        // Configure the cell...
        cell.eventName?.text = events[indexPath.section].events[indexPath.row]["full_name"] as! String
        
        let imageHeight = CGFloat(9.0/16.0) * tableView.bounds.size.width
        var imageUrl = "http://cdn.livestream.com/newlivestream/poster-default.jpeg"
        if events[indexPath.section].events[indexPath.row]["logo"] != nil {
            let logo = events[indexPath.section].events[indexPath.row]["logo"] as! [String: AnyObject]
            imageUrl = logo["url"] as! String
        }
        imageUrl = imageUrl.replacingOccurrences(of: ".png", with: "_" + String(describing: Int(tableView.bounds.size.width)) + "x" + String(describing: Int(imageHeight)) + ".png")
        cell.eventImage?.setImageWith(URL(string: imageUrl)!)
        
        return cell
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
