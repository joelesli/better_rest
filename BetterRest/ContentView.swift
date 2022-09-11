//
//  ContentView.swift
//  BetterRest
//
//  Created by Joel Martinez on 9/5/22.
//

import CoreML
import SwiftUI


struct ContentView: View {
    @State private var wakeTime = Date.now
    @State private var hoursOfSleep = 8.0
    @State private var cupsOfCoffee = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isAlertPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Desired wakeup time")
                    .padding()
                DatePicker("Please enter a wake up time", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                
                Text("Desired amount of sleep")
                    .padding()
                Stepper("\(hoursOfSleep.formatted()) hours", value: $hoursOfSleep, in: 4...12, step: 0.25)
                    .padding()
                
                
                Text("Daily coffe intake")
                    .padding()
                Stepper("\(cupsOfCoffee) \(cupsOfCoffee == 1 ? "cup" : "cups")", value: $cupsOfCoffee, in: 1...20, step: 1)
                    .padding()
                
                
                
            }
            .navigationTitle("Better Sleep")
            .toolbar {
                Button("Calculate sleep", action: calculatedBedTime)
            }
            .alert(alertTitle, isPresented: $isAlertPresented) {
                Button("OK") {   }
            } message: {
                Text(alertMessage)
            }
            
        }
        
    }
    
    func calculatedBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
            let wakeTimeInSeconds = (components.hour ?? 0) * 60 * 60 + (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(wakeTimeInSeconds), estimatedSleep: hoursOfSleep, coffee: Double(cupsOfCoffee))
            
            let sleepTime = wakeTime - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch {
            alertTitle = "There was an error."
            alertMessage = "Sorry, there was a problem calculating your bedtime"
        }
        isAlertPresented = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
