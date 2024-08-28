//
//  AppIntent.swift
//  Snel Widget
//
//  Created by Jordi Bruin on 28/08/2024.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Snel"
    static var description = IntentDescription("Snel Complication.")
}
