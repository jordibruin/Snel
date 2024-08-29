//
//  LocationManager.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import CoreLocation
import SwiftUI
import Defaults
import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var currentSpeed: CLLocationSpeed = 0.0
    
    var recentSpeeds: [Double] = [0,0,0,0,0,0,0,0,0,0]
    
    
    var currentSnelSpeed: SnelSpeed = .zeroSpeed
    var recentSnelSpeeds: [SnelSpeed] = []
    
    var speedInMetersSecond: Double = 0.0
    var speedInKilometersHour: Double = 0.0
    var speedInMilesHour: Double = 0.0
    
    var horizontalAccuracy: Double = 0.0
    
    var lastLocation: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var lastMapCameraPosition: MapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        )
    )
    
    var lastUpdatedAt: Date = Date()
    
    var noSpeedReceivedCount = 0
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    var averageSpeed: SnelSpeed {
        let average = recentSnelSpeeds.map { $0.meterPerSecond } .reduce(0, +) / Double(recentSnelSpeeds.count)
        return SnelSpeed(meterPerSecond: average, date: Date())
    }
    
    private var timer: Timer?
    
    override init() {
        super.init()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.denied ) {
            print("denied")
        }
        
//        for i in 1...100 {
//            recentSnelSpeeds.append(
//                SnelSpeed(meterPerSecond: 0 + (Double(i) * Double.random(in: 0.1...0.2)),
//                date: Date()
//                    .addingTimeInterval(Double(i) * 0.1)
//            ))
//        }
        
        self.authorizationStatus = authorizationStatus
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
        Task {
            await startLocationManager()
        }
        
        // Start the timer to call `generateFakeSpeeds` every second
//            startTimer()
    }
    
    var updatesStarted = false
    
    func startLocationManager() async {
        if self.locationManager.authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        print("Start Location Fetching")
        
        let updates = CLLocationUpdate.liveUpdates(.fitness)
        
        do {
            self.updatesStarted = true
            for try await update in updates {
                if !self.updatesStarted { break }
                
                if let location = update.location {
                    
                    var currentSpeed = 0.0
                    
                    if location.speed > 0 {
                        currentSpeed = location.speed
                    }
                    
                    if Defaults[.maxSpeedInMetersPerSecond] < currentSpeed {
                        Defaults[.maxSpeedInMetersPerSecond] = currentSpeed
                    }
                    
                    // Snel Speeds
                    let snelSpeed = SnelSpeed(meterPerSecond: currentSpeed, date: Date())
                    currentSnelSpeed = snelSpeed
                    recentSnelSpeeds.append(snelSpeed)
                    
                    if recentSnelSpeeds.count > 60 {
                        recentSnelSpeeds.removeFirst()
                    }
                    
                    speedInMetersSecond = currentSpeed
                    recentSpeeds.append(currentSpeed)
                    recentSpeeds.removeFirst()
                    
                    speedInKilometersHour = Measurement(value: currentSpeed, unit: UnitSpeed.metersPerSecond).converted(to: .kilometersPerHour).value
                    speedInMilesHour = Measurement(value: currentSpeed, unit: UnitSpeed.metersPerSecond).converted(to: .milesPerHour).value
                    horizontalAccuracy = location.horizontalAccuracy
                    self.lastLocation = location
                    self.lastUpdatedAt = Date()
                }
                
            }
        } catch {
            print(error.localizedDescription)
            self.error = error
        }
    }
    
    var error: Error?

    // To generate fake speed data
    func generateFakeSpeeds(range: ClosedRange<Double>) {
        // Generate a random speed within the provided range
        let fakeSpeed = CLLocationSpeed(Double.random(in: range))
        
        // Update current s  peed and lastUpdatedAt
        currentSpeed = fakeSpeed
        
        if currentSpeed <= 0 {
            noSpeedReceivedCount += 1
        } else {
            noSpeedReceivedCount = 0
        }
        
        lastUpdatedAt = Date()
    }
    
    // Start the timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.generateFakeSpeeds(range: 5.0...10.0)
        }
    }
    
    // Invalidate the timer when the object is deallocated
    deinit {
        timer?.invalidate()
    }
    
    var correctSpeed: Double {
        switch Defaults[.selectedSpeedOption] {
            
        case .metersPerSecond:
            speedInMetersSecond
        case .kilometsPerHour:
            speedInKilometersHour
        case .milesPerHour:
            speedInMilesHour
        }
    }
    var correctMaxSpeed: Double {
        switch Defaults[.selectedSpeedOption] {
            
        case .metersPerSecond:
            Defaults[.maxSpeedInMetersPerSecond]
            
        case .kilometsPerHour:
            Measurement(
                value: Defaults[.maxSpeedInMetersPerSecond],
                unit: UnitSpeed.metersPerSecond
            ).converted(to: .kilometersPerHour).value
            
        case .milesPerHour:
            Measurement(
                value: Defaults[.maxSpeedInMetersPerSecond],
                unit: UnitSpeed.metersPerSecond
            ).converted(to: .milesPerHour).value
        }
    }
}

struct SnelSpeed: Identifiable, Codable, Defaults.Serializable, Comparable {
    static func < (lhs: SnelSpeed, rhs: SnelSpeed) -> Bool {
        lhs.meterPerSecond < rhs.meterPerSecond
    }
    
    
    let id: UUID
    let date: Date
    
    var meterPerSecond: Double
    
    var milePerHour: Double {
        Measurement(value: meterPerSecond, unit: UnitSpeed.metersPerSecond).converted(to: .milesPerHour).value
    }
    
    var kmPerHour: Double {
        Measurement(value: meterPerSecond, unit: UnitSpeed.metersPerSecond).converted(to: .kilometersPerHour).value
    }
    
    var userSelectedSpeed: Double {
        switch Defaults[.selectedSpeedOption] {
        case .metersPerSecond:
            return meterPerSecond
        case .milesPerHour:
            return milePerHour
        case .kilometsPerHour:
            return kmPerHour
        }
    }
    
    init(meterPerSecond: Double, date: Date) {
        self.id = UUID()
        self.meterPerSecond = meterPerSecond
        self.date = date
    }
    
    static let zeroSpeed = SnelSpeed(meterPerSecond: 0, date: Date())
}
