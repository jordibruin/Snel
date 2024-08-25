//
//  Defaults.swift
//  Snel
//
//  Created by Jordi Bruin on 21/08/2024.
//

import Foundation
import Defaults

extension Defaults.Keys {
    static let selectedSpeedOption = Key<SpeedOption>("selectedSpeedOption", default: .kilometsPerHour)
    
    // After first launch we should set the speed setting based on the user locale
    static let autoSetSpeedOptionBasedOnLocale = Key<Bool>("autoSetSpeedOptionBasedOnLocale", default: false)
    
    static let maxSpeedInMetersPerSecond = Key<Double>("maxSpeedInMetersPerSecond", default: 0.0)
    
    static let decimalCount = Key<Int>("decimalCount", default: 1)
    static let selectedTheme = Key<Theme>("selectedTheme", default: .blue)
    
    static let slowThreshold = Key<SnelSpeed>("slowThreshold", default: SnelSpeed(meterPerSecond: 2, date: Date()))
    static let mediumThreshold = Key<SnelSpeed>("mediumThreshold", default: SnelSpeed(meterPerSecond: 4, date: Date()))
    static let fastThreshold = Key<SnelSpeed>("fastThreshold", default: SnelSpeed(meterPerSecond: 6, date: Date()))
}
