//
//  DetailViewController.swift
//  Yelp
//
//  Created by Harpreet Singh on 2/21/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate
{
    var business: Business!
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewsImageView: UIImageView!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = business.name!
        initProperties()
        setLocationManager()
        modifyView()
    }
    
    func initProperties()
    {
        businessImageView.setImageWithURL(business.imageURL!)
        nameLabel.text = business.name!
        reviewsImageView.setImageWithURL(business.ratingImageURL!)
        reviewsCountLabel.text = "\(business.reviewCount!) Reviews"
        categoriesLabel.text = business.categories!
        distanceLabel.text = business.distance!
        addressLabel.text = business.address!
        addAnnotationAtCoordinate(business.location!.coordinate, annotationTitle: business.name!, annotationSubtitle: business.address!)
    }
    
    // Map Setup
    
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


    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func modifyView()
    {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 196/255, green: 18/255, blue: 0, alpha: 1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
