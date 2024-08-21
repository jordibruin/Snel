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
    
    static let decimalCount = Key<Int>("decimalCount", default: 0)
}
