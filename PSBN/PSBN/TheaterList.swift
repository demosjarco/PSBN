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
    
    func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machine = systemInfo.machine
        let mirror = Mirror(reflecting: machine)
        var identifier = ""
        
        for child in mirror.children {
            if let value = child.value as? Int8 , value != 0 {
                identifier.append(String(UnicodeScalar(UInt8(value))))
            }
        }
        
        return identifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 180
        
        refresh(sender: self.refreshControl)
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if sender != nil {
            self.tableView.contentOffset = CGPoint(x: CGFloat(0), y: -sender!.frame.size.height)
        }
        sender?.beginRefreshing()
        sender?.attributedTitle = NSAttributedString(string: "Loading channels...", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
        events = [EventDateSection]()
        self.tableView.reloadData()
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                var countVideos = 0
                var countVideosDone = 0
                
                if remoteConfig["channel_1_enabled"].boolValue {
                    // Show channel 1
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_1_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        countVideos += upcoming_events_data.count
                        for event in upcoming_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        countVideos += past_events_data.count
                        for event in past_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                    }, failure: { (task, error) in
                        // Save error to database
                    })
                }
                
                if remoteConfig["channel_2_enabled"].boolValue {
                    // Show channel 2
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_2_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        countVideos += upcoming_events_data.count
                        for event in upcoming_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        countVideos += past_events_data.count
                        for event in past_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                    }, failure: { (task, error) in
                        // Save error to database
                    })
                }
                
                if remoteConfig["channel_liberty_enabled"].boolValue {
                    // Show channel Liberty
                    let url = remoteConfig["api_host"].stringValue! + "/accounts/" + remoteConfig["channel_liberty_id"].stringValue!
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        let upcoming_events = json["upcoming_events"] as! [String: AnyObject]
                        let upcoming_events_data = upcoming_events["data"] as! [[String: AnyObject]]
                        countVideos += upcoming_events_data.count
                        for event in upcoming_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                        let past_events = json["past_events"] as! [String: AnyObject]
                        let past_events_data = past_events["data"] as! [[String: AnyObject]]
                        countVideos += past_events_data.count
                        for event in past_events_data {
                            let url1 = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(url1, parameters: nil, progress: nil, success: { (task1, responseObject1) in
                                countVideosDone += 1
                                let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
                                sender?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + "(" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(229.0/255.0), green: CGFloat(46.0/255.0), blue: CGFloat(23.0/255.0), alpha: CGFloat(1.0))])
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Parse JSON
                                let json1 = responseObject1 as! [String: AnyObject]
                                self.parseEvent(event: json1)
                            }, failure: { (task1, error1) in
                                countVideosDone += 1
                                if countVideosDone == countVideos {
                                    sender?.endRefreshing()
                                    sender?.attributedTitle = nil
                                }
                                // Save error to database
                            })
                        }
                    }, failure: { (task, error) in
                        // Save error to database
                    })
                }
            } else {
                sender?.endRefreshing()
            }
        }
    }
    
    func updateRefreshProgress(refresher: UIRefreshControl?, countVideos: Int, countVideosDone: Int) {
        let percentage = Int((Float(countVideosDone) / Float(countVideos)) * Float(100))
        refresher?.attributedTitle = NSAttributedString(string: "Loading event " + String(countVideosDone) + " of " + String(countVideos) + " (" + String(percentage) + "% done)", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(213.0/255.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))])
        if countVideosDone == countVideos {
            refresher?.endRefreshing()
            refresher?.attributedTitle = nil
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return events.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events[section].events.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! TheaterListCell
        // Performance
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        // Reset
        cell.eventName?.text = nil
        cell.eventTime?.text = nil
        cell.eventDuration?.text = nil
        cell.eventLikesPlays?.text = nil
        cell.eventImage?.image = nil
        // Configure the cell...
        let event = events[indexPath.section].events[indexPath.row]
        
        cell.eventName?.text = event["full_name"]! as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
        let eventDate = dateFormatter.date(from: event["start_time"] as! String)
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        cell.eventTime?.text = dateFormatter.string(from: eventDate!)
        
        let feed = event["feed"] as! [String: AnyObject]
        if Int(feed["total"]! as! NSNumber) > 0 {
            let feedData = feed["data"] as! [[String: AnyObject]]
            for data in feedData {
                if data["type"] as! String == "video" {
                    
                    let data1 = data["data"] as! [String: AnyObject]
                    let milliseconds = data1["duration"] as! NSNumber
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    if milliseconds.doubleValue >= 3600000 {
                        dateFormatter.dateFormat = "H:mm:ss"
                    } else {
                        dateFormatter.dateFormat = "mm:ss"
                    }
                    cell.eventDuration?.text = dateFormatter.string(from: Date(timeIntervalSince1970: milliseconds.doubleValue / 1000))
                    
                    cell.eventLikesPlays?.text = "♥\u{0000FE0E} " + String(describing: event["likes"]!["total"]!) + " ▶\u{0000FE0E} " + String(describing: data1["views"]!)
                    break
                }
            }
        }
        
        let imageHeight = CGFloat(9.0/16.0) * tableView.bounds.size.width
        var imageUrl = "http://cdn.livestream.com/newlivestream/poster-default.jpeg"
        if event["logo"] != nil {
            let logo = event["logo"] as! [String: AnyObject]
            imageUrl = logo["url"] as! String
        }
        imageUrl = imageUrl.replacingOccurrences(of: ".png", with: "_" + String(describing: Int(tableView.bounds.size.width * UIScreen.main.scale)) + "x" + String(describing: Int(imageHeight * UIScreen.main.scale)) + ".png")
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
