//
//  ContentView.swift
//  Snel
//
//  Created by Jordi Bruin on 13/08/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State var showMiles = false
    
    @State var old = Date()
    var body: some View {
        ZStack {
            HStack {
                VStack {
                    Spacer(minLength: (6 - locationManager.currentSpeed) * 100)
                    Color.green
                        .opacity(0.2)
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Text("\(locationManager.currentSpeed)")
                Text("\(locationManager.lastUpdatedAt.timeIntervalSince(old))")
                if locationManager.currentSpeed <= 0 {
                    Text("Sneller!")
                } else {
                    
                    if showMiles {
                        Text(String(format:"%.2f", (locationManager.currentSpeed * 2.23694))) + Text("m/h")
                            .font(.largeTitle)
                    } else {
                        Text(String(format:"%.2f", (locationManager.currentSpeed * 3.6))) + Text("km/h")
                            .font(.largeTitle)
                    }
                    
                    Group {
                        Text(String(format:"%.2f", (locationManager.currentSpeed))) + Text("m/s")
                    }
                }
                
            }
            .padding()
            .onTapGesture {
                showMiles.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
}
