//
//  ContentView.swift
//  HealthCare
//
//  Created by kz on 28/03/2023.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @State var stepsCount: Int? = nil
    let healthStore = HKHealthStore()
    
    var body: some View {
        VStack {
            if let steps = stepsCount {
                Text("steps: \(steps)")
            } else {
                Text("Loading...")
            }
        }
        .onAppear(perform: fetchTodayStepsCount)
    }
    
    func fetchTodayStepsCount() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Eror: \(error.localizedDescription)")
                }
                return
            }
            DispatchQueue.main.async {
                self.stepsCount = Int(sum.doubleValue(for: .count()))
            }
        }
        
        healthStore.requestAuthorization(toShare: [], read: [stepsQuantityType]) { (success, error) in
            if success {
                healthStore.execute(query)
            } else {
                print("User doesn't allow to share healthkit data")
            }
        }
    }

}
