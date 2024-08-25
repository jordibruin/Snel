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
    case graph
    case chart
    
    //    case simple
//    case big
//    case history
//    case rectangleHistory
    
    //    case map
    
    var id: String { self.rawValue }
    
    @ViewBuilder
    var view: some View {
        switch self {
            //        case .simple:
            //            SimpleView()
        case .graph:
            GraphView()
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

struct GraphView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.decimalCount) var decimalCount
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    
    @State var showNoMovementOverlay = false
    
    var body: some View {
        circleView
    }
    
    var circleView: some View {
        VStack {
            ZStack {
                ZStack {
                    background
                    foreground
                }
                
                Text(String(format:"%.\(decimalCount)f", (locationManager.correctSpeed)))
                    .font(decimalCount < 1 ? .system(size: 72) : decimalCount <= 2 ? .largeTitle : .title)
                    .minimumScaleFactor(0.5)
                    .bold()
                    .contentTransition(.numericText())
                    .transaction {
                        $0.animation = .default
                    }
                    .monospacedDigit()
            }
            
            if let error = locationManager.error {
                Text(error.localizedDescription)
                    .font(.caption)
            }
            
            if locationManager.correctSpeed <= 0 {
                HStack {
                    Spacer()
                    Text("No Movement Detected")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .layoutPriority(10)
                    
                    Spacer()
                    
                    Button(action: {
                        showNoMovementOverlay = true
                    }, label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    })
                    .buttonStyle(.plain)
                    .layoutPriority(10)
                    
                    Spacer()
                }
                //                .padding(.horizontal, -20)
            } else {
                Text(selectedSpeedOption.shortName)
                    .foregroundStyle(.secondary)
                    .onTapGesture {
                        selectedSpeedOption = selectedSpeedOption.next()
                    }
            }
        }
        .sheet(isPresented: $showNoMovementOverlay, content: {
            Text("Snel uses GPS to determine your speed, please move around outside if you don't see any speed measurements.")
                .multilineTextAlignment(.center)
        })
    }
    
    
    var background: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(Color(white: 140/255),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .butt,
                        lineJoin: .miter,
                        miterLimit: 0,
                        dash: [1, 4],
                        dashPhase: 0))
            .rotationEffect(.degrees(135))
    }
    
    var foreground: some View {
        Circle()
            .trim(from: 0, to: locationManager.correctSpeed / selectedSpeedOption.max)
            .stroke(
                selectedTheme.color,
                style: .init(
                    lineWidth: 20,
                    lineCap: .butt
                )
            )
            .rotationEffect(.degrees(135))
            .animation(.bouncy, value: locationManager.correctSpeed)
    }
}

#Preview(body: {
    GraphView()
        .environment(LocationManager())
})

import MapKit

struct MapView: View {
    
    @Environment(LocationManager.self) var locationManager
    @State var mapCameraPosition = MapCameraPosition.userLocation(fallback: .automatic)
    
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

#Preview(body: {
    BigView()
        .environment(LocationManager())
})



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


#Preview(body: {
    HistoryView()
        .environment(LocationManager())
})


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


#Preview(body: {
    RectangleHistoryView()
        .environment(LocationManager())
})

import Charts

struct ChartView: View {
    
    @Environment(LocationManager.self) var locationManager
    @Default(.selectedSpeedOption) var selectedSpeedOption
    @Default(.selectedTheme) var selectedTheme
    @Default(.decimalCount) var decimalCount
    
    var body: some View {
        Chart {
            ForEach(locationManager.recentSnelSpeeds.suffix(10)) { snelSpeed in
                LineMark(
                    x: .value("Time", snelSpeed.date),
                    y: .value("Speed", snelSpeed.userSelectedSpeed)
                )
                .foregroundStyle(selectedTheme.color)
                .lineStyle(.init(lineWidth: 2))
                
                AreaMark(
                    x: .value("Time", snelSpeed.date),
                    y: .value("Speed", snelSpeed.userSelectedSpeed)
                )
                .foregroundStyle(
                    LinearGradient(colors: [
                        selectedTheme.color.opacity(0.75),
                        selectedTheme.color.opacity(0.2)
                    ], startPoint: .top, endPoint: .bottom)
                )
            }
        }
        .chartXAxis(.hidden)
        .chartYScale(domain: 0...averageSpeed * 1.5)
        .onTapGesture {
            locationManager.recentSnelSpeeds.removeAll()
        }
    }
    
    var averageSpeed: Double {
        if let max = locationManager.recentSnelSpeeds.suffix(10).max() {
            let what = ceil(max.userSelectedSpeed / 5) * 5
            return what
        } else {
            return locationManager.correctMaxSpeed
        }
    }
}


#Preview(body: {
    RectangleHistoryView()
        .environment(LocationManager())
})

