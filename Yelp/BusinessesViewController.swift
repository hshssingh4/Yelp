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

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, FiltersViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate
{

    var businesses: [Business]!
    var searchBar = UISearchBar()
    var isMoreDataLoading = false
    var categories: [String]!
    var locationManager : CLLocationManager!
    
    let LIMIT_CONSTANT = 20
    
    @IBOutlet weak var filtersButton: UIBarButtonItem!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.addInfiniteScrollingWithActionHandler(infiniteScrollingHandler)
    
        setSearchBar()
        searchBar.delegate = self
        
        SVProgressHUD.show()
        searchBusinesses(nil, offset: 0, categories: categories, deals: false)
        SVProgressHUD.dismiss()
        
        self.mapView.delegate = self
        setLocationManager()
        hideMapView()
        modifyView()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if businesses != nil
        {
            return businesses.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        let modifiedCell = modifyCell(cell)
        
        return modifiedCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Search for Businesses
    func searchBusinesses(var term: String?, offset: Int, categories: [String]?, deals: Bool?)
    {
        
        if term == nil {
            term = "Restaurants"
        }
        
        addAnnotationForBusinesses()
        Business.searchWithTerm(term!, limit: LIMIT_CONSTANT, offset: offset, sort: nil, categories: categories, deals: deals, completion: { (businesses: [Business]!, error: NSError!) -> Void in
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
    
    func loadMoreData()
    {
        var term = String()
        if let text = searchBar.text
        {
            term = text
        }
        else
        {
            term = "Restaurants"
        }
        Business.searchWithTerm(term, limit: LIMIT_CONSTANT, offset: 5, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            if businesses != nil
            {
                for business in businesses
                {
                    self.businesses.append(business)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func infiniteScrollingHandler()
    {
        loadMoreData()
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    // Filters Return setup
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject])
    {
        SVProgressHUD.show()
        categories = filters["categories"] as? [String]
        Business.searchWithTerm(searchBar.text!, limit: LIMIT_CONSTANT, offset: 0, sort: nil, categories: categories, deals: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.addAnnotationForBusinesses()
            self.tableView.reloadData()
        }
        SVProgressHUD.dismiss()
    }

    // Map Setup
    
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
    
    // Set location manager
    func setLocationManager()
    {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 200
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Add lcoation manager methods
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            let span = MKCoordinateSpanMake(0.1, 0.1)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: false)
        }
    }
    
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D, annotationTitle: String, annotationSubtitle: String)
    {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = annotationTitle
        annotation.subtitle = annotationSubtitle
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        if control == view.rightCalloutAccessoryView
        {
            performSegueWithIdentifier("DetailViewController", sender: view)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
        if view == nil
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            view!.canShowCallout = true
            view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        return view
    }
    
    
    func addAnnotationForBusinesses()
    {
        mapView.removeAnnotations(mapView.annotations) // Remove previous annotations
        
        if businesses != nil
        {
            for business in businesses
            {
                addAnnotationAtCoordinate(business.location!.coordinate, annotationTitle: "\(business.name!)", annotationSubtitle: "\(business.address!)")
            }
        }
    }
    
    // Animations for switching between views.
    func hideTableView()
    {
        addAnnotationForBusinesses()
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "TitleViewIcon")
        UIView.transitionFromView(tableView, toView: mapView, duration: 1.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
    }
    
    func hideMapView()
    {
        self.navigationItem.rightBarButtonItem?.image = UIImage(named: "MapViewIcon")
        UIView.transitionFromView(mapView, toView: tableView, duration: 1.0, options: UIViewAnimationOptions.ShowHideTransitionViews, completion: nil)
    }
    
    // All the search bar function are beneath
    func setSearchBar()
    {
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.placeholder = "Search"
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchBusinesses(searchText, offset: 0, categories: categories, deals: false)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar)
    {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
        searchBusinesses(searchBar.text, offset: 0, categories: categories, deals: false)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        searchBar.endEditing(true)
        searchBusinesses(nil, offset: 0, categories: categories, deals: false)
    }

    
    // Modify the look of the page
    func modifyView()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196/255, green: 18/255, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.searchBar.tintColor = UIColor.whiteColor()
        let view: UIView = self.searchBar.subviews[0] 
        let subViewsArray = view.subviews
        
        for subView: UIView in subViewsArray
        {
            if subView.isKindOfClass(UITextField)
            {
                subView.tintColor = UIColor.blackColor()
            }
        }
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        print("yes")
        if let button = sender as? UIBarButtonItem
        {
            if button.image! == UIImage(named: "FiltersIcon")
            {
                let navigationController = segue.destinationViewController as! UINavigationController
                let filtersViewController = navigationController.topViewController as! FiltersViewController
                filtersViewController.delegate = self
            }
        }
        else if let cell = sender as? UITableViewCell
        {
            let indexPath = tableView.indexPathForCell(cell)
            let selectedCell = businesses![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.business = selectedCell
        }
        else if let annotationView = sender as? MKAnnotationView
        {
            let detailViewController = segue.destinationViewController as! DetailViewController
            for business in businesses
            {
                if annotationView.annotation?.title! == business.name!
                {
                    detailViewController.business = business
                }
            }
        }
        
    }
}
