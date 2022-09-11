//
//  ContentView.swift
//  BetterRest
//
//  Created by Joel Martinez on 9/5/22.
//

import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeTime = defaultWakeTime
    @State private var hoursOfSleep = defaultHoursOfSleep
    @State private var cupsOfCoffee = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isAlertPresented = false
    
    var sleepTime : Date {
        get {
            calculatedBedTime()
        }
    }
    
    static var defaultHoursOfSleep = 8.0
    static var defaultWakeTime: Date {
        Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("Desired wakeup time")
                        Spacer()
                        DatePicker("Please enter a wake up time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Desired amount of sleep")
                        Stepper("\(hoursOfSleep.formatted()) hours", value: $hoursOfSleep, in: 4...12, step: 0.25)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Daily coffe intake")
                        Stepper("\(cupsOfCoffee) \(cupsOfCoffee == 1 ? "cup" : "cups")", value: $cupsOfCoffee, in: 1...20, step: 1)
                    }
                }
                Section("Your ideal bedtime is...") {
                    Text(sleepTime.formatted(date: .omitted, time: .shortened))
                        .font(.title)
                }
        
            }
            .navigationTitle("Better Sleep")
            .alert(alertTitle, isPresented: $isAlertPresented) {
                Button("OK") {   }
            } message: {
                Text(alertMessage)
            }
            
        }
        
    }
    
    func calculatedBedTime() -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
            let wakeTimeInSeconds = (components.hour ?? 0) * 60 * 60 + (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(wakeTimeInSeconds), estimatedSleep: hoursOfSleep, coffee: Double(cupsOfCoffee))
            return wakeTime - prediction.actualSleep
        }
        catch {
            alertTitle = "There was an error."
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            isAlertPresented = true
        }

        return ContentView.defaultWakeTime - ContentView.defaultHoursOfSleep * 60 * 60
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
