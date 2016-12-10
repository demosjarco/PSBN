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
        sender?.attributedTitle = NSAttributedString(string: "Loading channels...", attributes: [NSForegroundColorAttributeName : UIColor(red: CGFloat(213.0/255.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))])
        events = [EventDateSection]()
        self.tableView.reloadData()
        let remoteConfig = FIRRemoteConfig.remoteConfig()
        remoteConfig.fetch { (status, error) in
            if status == .success {
                remoteConfig.activateFetched()
                let apiUrl = remoteConfig["api_url"].stringValue!
                let enabledChannelsString = remoteConfig["enabled_channels"].stringValue!
                let enabledChannels = enabledChannelsString.characters.split(separator: ",").map(String.init)
                var countVideos = 0
                var countVideosDone = 0
                
                for channelId in enabledChannels {
                    let url = apiUrl + "/accounts/" + channelId
                    AFHTTPSessionManager().get(url, parameters: nil, progress: nil, success: { (task, responseObject) in
                        // Parse JSON
                        let json = responseObject as! [String: AnyObject]
                        
                        let upcomingEvents = json["upcoming_events"] as! [String: AnyObject]
                        let upcomingEventsData = upcomingEvents["data"] as! [[String: AnyObject]]
                        countVideos += upcomingEventsData.count
                        
                        let pastEvents = json["past_events"] as! [String: AnyObject]
                        let pastEventsData = pastEvents["data"] as! [[String: AnyObject]]
                        countVideos += pastEventsData.count
                        
                        self.updateRefreshProgress(refresher: sender, countVideos: countVideos, countVideosDone: countVideosDone)
                        
                        for event in upcomingEventsData {
                            let eventUrl = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(eventUrl, parameters: nil, progress: nil, success: { (eventTask, eventResponseObject) in
                                // Parse JSON
                                let eventJson = eventResponseObject as! [String: AnyObject]
                                self.parseEvent(event: eventJson)
                                
                                countVideosDone += 1
                                
                                self.updateRefreshProgress(refresher: sender, countVideos: countVideos, countVideosDone: countVideosDone)
                            }, failure: { (eventTask, eventError) in
                                if (eventTask != nil) {
                                    let response = eventTask!.response as! HTTPURLResponse
                                    FIRDatabase.database().reference().child("json_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": eventUrl, "deviceModel": self.getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                                }
                                
                                countVideosDone += 1
                                
                                self.updateRefreshProgress(refresher: sender, countVideos: countVideos, countVideosDone: countVideosDone)
                            })
                        }
                        
                        for event in pastEventsData {
                            let eventUrl = url + "/events/" + event["id"]!.stringValue
                            AFHTTPSessionManager().get(eventUrl, parameters: nil, progress: nil, success: { (eventTask, eventResponseObject) in
                                // Parse JSON
                                let eventJson = eventResponseObject as! [String: AnyObject]
                                self.parseEvent(event: eventJson)
                                
                                countVideosDone += 1
                                
                                self.updateRefreshProgress(refresher: sender, countVideos: countVideos, countVideosDone: countVideosDone)
                            }, failure: { (eventTask, eventError) in
                                if (eventTask != nil) {
                                    let response = eventTask!.response as! HTTPURLResponse
                                    FIRDatabase.database().reference().child("json_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": eventUrl, "deviceModel": self.getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                                }
                                
                                countVideosDone += 1
                                
                                self.updateRefreshProgress(refresher: sender, countVideos: countVideos, countVideosDone: countVideosDone)
                            })
                        }
                    }, failure: { (task, error) in
                        if (task != nil) {
                            let response = task!.response as! HTTPURLResponse
                            FIRDatabase.database().reference().child("json_error").childByAutoId().updateChildValues(["datestamp": NSDate().timeIntervalSince1970, "httpCode": response.statusCode, "url": url, "deviceModel": self.getDeviceModel(), "deviceVersion": UIDevice().systemVersion])
                        }
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
            // Stop refreshing
            refresher?.endRefreshing()
            refresher?.attributedTitle = nil
            
            // Scroll to today or closest day but not in the future
            var dateDifference:TimeInterval = DBL_MAX
            var closestSection:Int = 0
            for daySection in self.events {
                // difference is positive for past
                if Calendar(identifier: .gregorian).startOfDay(for: Date()).timeIntervalSince(daySection.date) >= 0 && Calendar(identifier: .gregorian).startOfDay(for: Date()).timeIntervalSince(daySection.date) < dateDifference {
                    dateDifference = Calendar(identifier: .gregorian).startOfDay(for: Date()).timeIntervalSince(daySection.date)
                    closestSection = self.events.index(of: daySection)!
                }
            }
            let today = IndexPath(row: 0, section: closestSection)
            self.tableView.scrollToRow(at: today, at: UITableViewScrollPosition.top, animated: true)
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
            eventDateSection.date = Calendar(identifier: .gregorian).startOfDay(for: eventDate!)
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
                eventDateSection.date = Calendar(identifier: .gregorian).startOfDay(for: eventDate!)
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
            switch 0 {
            case 1:
                indexTitles.append("Jan " + String(describing: eventSection.day))
            case 2:
                indexTitles.append("Feb " + String(describing: eventSection.day))
            case 3:
                indexTitles.append("Mar " + String(describing: eventSection.day))
            case 4:
                indexTitles.append("Apr " + String(describing: eventSection.day))
            case 5:
                indexTitles.append("May " + String(describing: eventSection.day))
            case 6:
                indexTitles.append("Jun " + String(describing: eventSection.day))
            case 7:
                indexTitles.append("Jul " + String(describing: eventSection.day))
            case 8:
                indexTitles.append("Aug " + String(describing: eventSection.day))
            case 9:
                indexTitles.append("Sep " + String(describing: eventSection.day))
            case 10:
                indexTitles.append("Oct " + String(describing: eventSection.day))
            case 11:
                indexTitles.append("Nov " + String(describing: eventSection.day))
            case 12:
                indexTitles.append("Dec " + String(describing: eventSection.day))
            default:
                indexTitles.append(String(describing: eventSection.month) + "/" + String(describing: eventSection.day))
            }
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
