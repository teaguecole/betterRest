//
//  ContentView.swift
//  Shared
//
//  Created by Teague Cole on 2/26/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    private let maxCoffee: Int = 20
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                
                Section() {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter a time",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section() {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours",
                            value: $sleepAmount,
                            in: 4...12,
                            step: 0.25)
                }
                
                Section() {

                    Picker("Daily coffee intake", selection: $coffeeAmount) {
                        ForEach(1..<maxCoffee) {
                            Text($0 == 1 ? "\($0) cup" : "\($0) cups")
                        }
                    }
                }
                

                
            }
            .navigationBarTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedTime)
            }
            .alert(alertTitle,
                   isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute],
                                                             from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute),
                                                  estimatedSleep: sleepAmount,
                                                  coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is..."
            alertMessage = sleepTime.formatted(date: .omitted,
                                               time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating your bedtime"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
