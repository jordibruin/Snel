//
//  LocationManager.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentSpeed: CLLocationSpeed = 0.0
    @Published var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    @Published var lastUpdatedAt: Date = Date()
    
    private var timer: Timer?
    
    override init() {
        super.init()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.denied ) {
          print("denied")
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Start the timer to call `generateFakeSpeeds` every second
        startTimer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        currentSpeed = lastLocation.speed
        self.lastLocation = lastLocation
        self.lastUpdatedAt = Date()
    }
    
    // To generate fake speed data
    func generateFakeSpeeds(range: ClosedRange<Double>) {
        // Generate a random speed within the provided range
        let fakeSpeed = CLLocationSpeed(Double.random(in: range))
        
        // Update current speed and lastUpdatedAt
        currentSpeed = fakeSpeed
        lastUpdatedAt = Date()
    }
    
    // Start the timer
        private func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.generateFakeSpeeds(range: 0.0...100.0)
            }
        }
        
        // Invalidate the timer when the object is deallocated
        deinit {
            timer?.invalidate()
        }
}
