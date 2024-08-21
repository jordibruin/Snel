//
//  ContentView.swift
//  Snel
//
//  Created by Jordi Bruin on 13/08/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    
    @State var showMiles = false
    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: (6 - locationManager.currentSpeed) * 300)
                Color.green
                    .opacity(0.2)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
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
            
            Map(coordinateRegion: $region, showsUserLocation: true)
               .onAppear {
                    region.center = locationManager.lastLocation.coordinate
               }
               .onChange(of: locationManager.lastLocation) { oldValue, newValue in
                    region.center = newValue.coordinate
               }
               .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
               .frame(height: 220)
        }
    }
}

#Preview {
    ContentView()
}

