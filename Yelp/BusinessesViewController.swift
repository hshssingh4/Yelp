//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import SVPullToRefresh
import SVProgressHUD
import MapKit
import CoreLocation

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, FiltersViewControllerDelegate, CLLocationManagerDelegate {

    var businesses: [Business]!
    var searchBar = UISearchBar()
    var isMoreDataLoading = false
    var categories: [String]!
    let LIMIT_CONSTANT = 20
    var locationManager : CLLocationManager!
    var userLocation: CLLocation!
    
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.addInfiniteScrollingWithActionHandler(infiniteScrollingHandler)
    
        setSearchBar()
        searchBar.delegate = self
        
        SVProgressHUD.show()
        searchBusinesses(nil, offset: 0)
        SVProgressHUD.dismiss()
        
        setLocationManager()
        hideMapView()
        modifyView()
        
/* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            
            for business in businesses {
                print(business.name!)
                print(business.address!)
            }
        }
*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        let modifiedCell = modifyCell(cell)
        
        return modifiedCell
    }
    
    // Search for Businesses
    
    func searchBusinesses(var term: String?, offset: Int) {
        
        if term == nil {
            term = "Restaurants"
        }
        
        Business.searchWithTerm(term!, limit: LIMIT_CONSTANT, offset: offset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                self.businesses = businesses
                self.tableView.reloadData()
            
            if businesses != nil
            {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
        })
    }
    
    // Search Bar Functions
    
    func setSearchBar() {
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.placeholder = "Search"
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBusinesses(searchText, offset: 0)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBusinesses(searchBar.text, offset: 0)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBusinesses(nil, offset: 0)
    }
    
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        /*let requestUrl = NSURL(string: "https://api.yelp.com/v2/search")
        let myRequest = NSURLRequest(URL: requestUrl!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                
                // Update flag
                self.isMoreDataLoading = false
                
                // ... Use the new data to update the data source ...
                
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
        });
        task.resume()*/
        Business.searchWithTerm("Restaurants", limit: LIMIT_CONSTANT, offset: 5, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            if businesses != nil
            {
                for business in businesses {
                    self.businesses.append(business)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func infiniteScrollingHandler() {
        loadMoreData()
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    @IBAction func mapButtonClicked(sender: AnyObject)
    {
        if(mapView.hidden)
        {
            hideTableView()
        }
        else
        {
            hideMapView()
        }
    }
    
    func hideTableView()
    {
        addAnnotationForBusinesses()
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "TitleViewIcon")
        self.navigationItem.titleView = nil
        self.navigationItem.title = "Map"
        UIView.transitionFromView(tableView, toView: mapView, duration: 1.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
    }
    
    func hideMapView()
    {
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "MapViewIcon")
        self.navigationItem.titleView = searchBar
        UIView.transitionFromView(mapView, toView: tableView, duration: 1.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
    }
    
    // Modify the look of the page
    func modifyView()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196/255, green: 18/255, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        self.filtersButton.tintColor = UIColor.whiteColor()
        self.mapButton.tintColor = UIColor.whiteColor()
        self.searchBar.tintColor = UIColor.whiteColor()
    }
    
    func modifyCell(cell: BusinessCell) -> BusinessCell
    {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let button = sender as? UIBarButtonItem
        {
            if button.image! == UIImage(named: "FiltersIcon")
            {
                let navigationController = segue.destinationViewController as! UINavigationController
                let filtersViewController = navigationController.topViewController as! FiltersViewController
                filtersViewController.delegate = self
            }
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject])
    {
        SVProgressHUD.show()
        categories = filters["categories"] as? [String]
        Business.searchWithTerm("Restaurants", limit: LIMIT_CONSTANT, offset: 0, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.addAnnotationForBusinesses()
            self.tableView.reloadData()
        }
        SVProgressHUD.dismiss()
    }
    
    // Set location manager
    func setLocationManager()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
        
        addAnnotationForBusinesses()
    }
    
    // Add lcoation manager methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            userLocation = location
            mapView.setRegion(region, animated: false)
        }
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, annotationTitle: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = annotationTitle
        mapView.addAnnotation(annotation)
    }


    func addAnnotationForBusinesses()
    {
        mapView.removeAnnotations(mapView.annotations) // Remove previous annotations
        
        if businesses != nil
        {
            for business in businesses
            {
                addAnnotationAtCoordinate(business.location!.coordinate, annotationTitle: business.name!)
            }
        }
    }
    

}
