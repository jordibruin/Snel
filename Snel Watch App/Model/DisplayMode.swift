//
//  DisplayMode.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import SwiftUI
import Defaults

enum DisplayMode: String, CaseIterable, Identifiable {
    
    case speedometer
    case chart
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .speedometer:
            SpeedometerView()
        case .chart:
            ChartView()
//        case .big:
//            BigView()
//        case .history:
//            HistoryView()
//        case .rectangleHistory:
//            RectangleHistoryView()
        }
    }
}

extension CaseIterable where Self: Equatable {
    func next() -> Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

struct SimpleView: View {
    
    @Environment(LocationManager.self) var locationManager
    
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        VStack {
            Text(String(format:"%.\(decimalCount)f", (locationManager.correctMaxSpeed)))
                .font(.largeTitle)
            
            Text("SimpleView")
            Text("No speed: \(locationManager.noSpeedReceivedCount)")
                .font(.caption)
        }
    }
}



import MapKit

struct MapView: View {
    
    @Environment(LocationManager.self) var locationManager
    @State var mapCameraPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        Map(position: $mapCameraPosition, content: {
            UserAnnotation()
        })
        .animation(.easeInOut, value: locationManager.lastLocation)
        .disabled(true)
    }
}


struct BigView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.decimalCount) var decimalCount
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    
    @State var showNoMovementOverlay = false
    @State var showDesignOverlay = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
//                    Text("43")
                        .monospacedDigit()
                        .font(.system(size: decimalCount > 0 ? 80 : 120))
                        .fontWidth(.expanded)
                        .bold()
                )
//                
//                designView
            }
//            .onTapGesture {
//                showDesignOverlay.toggle()
//            }
            .toolbar(content: {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showDesignOverlay.toggle()
                        }, label: {
                            Image(systemName: "paintbrush.fill")
                        })
                    }
                }
            })
        }
        .sheet(isPresented: $showDesignOverlay, content: {
            designView
        })
    }
    
    @Default(.slowThreshold) var slowThreshold
    @Default(.mediumThreshold) var mediumThreshold
    @Default(.fastThreshold) var fastThreshold
    
    var backgroundColor: Color {
        if locationManager.correctSpeed < slowThreshold.userSelectedSpeed {
            return slowColor
        } else if locationManager.correctSpeed > fastThreshold.userSelectedSpeed {
            return fastColor
        } else {
            return mediumColor
        }
    }
    
    @State var slowColor: Color = .red
    @State var mediumColor: Color = .orange
    @State var fastColor: Color = .green
    
    var designView: some View {
        VStack {
            VelaPicker(color: $slowColor, label: {
                Text("Slow")
                    .padding(.leading, 4)
            })
            
            VelaPicker(color: $mediumColor, label: {
                Text("Medium")
                    .padding(.leading, 4)
            })
            
            VelaPicker(color: $fastColor, label: {
                Text("Fast")
                    .padding(.leading, 4)
            })
        }
        .bold()
        .padding(.top, 12)
    }
}

//#Preview(body: {
//    BigView()
//        .environment(LocationManager())
//})



import Vela


struct HistoryView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        VStack {
            
            HStack {
                Spacer()
                Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.horizontal)
            
            Spacer()
            

            HStack(alignment: .bottom, spacing: 1) {
                ForEach(locationManager.recentSnelSpeeds) { speed in
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 4, height: (speed.userSelectedSpeed / selectedSpeedOption.max) * 140)
                        .foregroundColor(backgroundColorFor(speed: speed.userSelectedSpeed))
                }
            }
//            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func backgroundColorFor(speed: Double) -> Color {
        let percentage = speed / selectedSpeedOption.max
        
        if percentage < 0.2 {
            return .red
        } else if percentage < 0.6 {
            return .orange
        } else {
            return .green
        }
    }
}


//#Preview(body: {
//    HistoryView()
//        .environment(LocationManager())
//})


struct RectangleHistoryView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.horizontal)
            
            Spacer()
            

            HStack(alignment: .bottom, spacing: 1) {
                ForEach(locationManager.recentSnelSpeeds) { speed in
                    Rectangle()
                        .frame(width: 6, height: (speed.userSelectedSpeed / selectedSpeedOption.max) * 160)
                        .foregroundColor(backgroundColorFor(speed: speed.userSelectedSpeed).opacity(0.6))
                        .overlay(
                            VStack {
                                Rectangle()
                                    .frame(width: 6, height: 2)
                                    .foregroundColor(backgroundColorFor(speed: speed.userSelectedSpeed))
                                Spacer()
                            }
                        )
                }
            }
//            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func backgroundColorFor(speed: Double) -> Color {
        let percentage = speed / selectedSpeedOption.max
        
        if percentage < 0.2 {
            return .red
        } else if percentage < 0.6 {
            return .orange
        } else {
            return .green
        }
    }
}

//
//#Preview(body: {
//    RectangleHistoryView()
//        .environment(LocationManager())
//})
//
//
//
//
//#Preview(body: {
//    RectangleHistoryView()
//        .environment(LocationManager())
//})
//
