//
//  HealthViewModel.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    //daily
    @Published var stepsCount = Int()
    @Published var caloriesBurned = Double()
    @Published var sleepTimeToday = String()
    
    //7 days
    @Published var averageStepsLast7Days = Int()
    @Published var averageCaloriesBurnedLast7Days = Int()
    @Published var averageSleepTimeLast7Days = String()

    
    //30 days
    @Published var averageStepsLast30Days = Int()
    @Published var averageCaloriesBurnedLast30Days = Int()
    @Published var averageSleepTimeLast30Days = String()

    
    func fetchTodayStepsCount(completion: @escaping (Int?) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Error fetching steps count: ", error.localizedDescription)
                }
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(Int(sum.doubleValue(for: .count())))
            }
        }
        healthStore.execute(query)
    }
    
    func fetchAverageStepsCount(startDate: Date, endDate: Date, completion: @escaping (Int?) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepsQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Error fetching average steps count: ", error.localizedDescription)
                }
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1
                completion(Int(sum.doubleValue(for: .count())) / days)
            }
        }
        healthStore.execute(query)
    }
    
    
    func fetchTodayActiveEnergyBurned(completion: @escaping (Double?) -> Void) {
        let activeEnergyBurnedType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeEnergyBurnedType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (_, result, error) in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Error fetching active energy burned: ", error.localizedDescription)
                }
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(sum.doubleValue(for: .kilocalorie()))
            }
        }
        healthStore.execute(query)
    }
    
    func fetchAverageActiveEnergyBurned(startDate: Date, endDate: Date, completion: @escaping (Double?) -> Void) {
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { query, statistics, error in
            if let error = error {
                print("Error fetching average active energy burned: \(error.localizedDescription)")
                completion(nil)
                return
            }
            let averageCalories = statistics?.averageQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            completion(averageCalories)
        }
        healthStore.execute(query)
    }
    
    func fetchTodaySleepTime(completion: @escaping (Double?) -> Void) {

        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }

        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { (success, error) in
            guard success else {
                completion(nil)
                return
            }
            
            let now = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: now)

            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    completion(nil)
                    return
                }

                var totalTimeAsleep = 0.0

                for sample in samples {
                    let startDate = sample.startDate
                    let endDate = sample.endDate
                    let duration = endDate.timeIntervalSince(startDate)

                    totalTimeAsleep += duration
                }
                completion(totalTimeAsleep)
            }
            self.healthStore.execute(query)
        }
    }
    
    func fetchAverageSleepTime(startDate: Date, endDate: Date, completion: @escaping (Double?) -> Void) {
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [sleepType]) { (success, error) in
            guard success else {
                completion(nil)
                return
            }
            
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: startDate)
            let endOfDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: endDate)!)
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                guard let samples = samples as? [HKCategorySample], error == nil else {
                    completion(nil)
                    return
                }
                
                var totalTimeAsleep = 0.0
                var totalSamples = 0
                
                for sample in samples {
                    let startDate = sample.startDate
                    let endDate = sample.endDate
                    let duration = endDate.timeIntervalSince(startDate)
                    
                    if duration > 18000{
                        totalTimeAsleep += duration
                        totalSamples += 1
                    }
                }
                
                let averageTimeAsleep = totalSamples > 0 ? totalTimeAsleep / Double(totalSamples) : 0
                
                completion(averageTimeAsleep)
            }
            
            self.healthStore.execute(query)
        }
    }
    
   
    //MARK: getHealthKitData
    func getHealthKitData() {
        let typesToRead = Set([
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!

        ])
        let typesToShare = Set([
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!


        ])


        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                DispatchQueue.main.async {

                    self.fetchTodayStepsCount { steps in
                        self.stepsCount = steps ?? 0
                    }

                    let calendar = Calendar.current
                    let endDate = Date()
                    let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: endDate)!
                    let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: endDate)!

                    self.fetchAverageStepsCount(startDate: sevenDaysAgo, endDate: endDate) { averageSteps in
                        self.averageStepsLast7Days = averageSteps ?? 0
                    }

                    self.fetchAverageStepsCount(startDate: thirtyDaysAgo, endDate: endDate) { averageSteps in
                        self.averageStepsLast30Days = averageSteps!
                    }

                    self.fetchTodayActiveEnergyBurned { calories in
                        self.caloriesBurned = Double(calories ?? 0)
                    }

                    self.fetchAverageActiveEnergyBurned(startDate: sevenDaysAgo, endDate: endDate) { averageCalories in
                        DispatchQueue.main.async {
                            self.averageCaloriesBurnedLast7Days = Int(averageCalories ?? 0)
                        }
                    }

                    self.fetchAverageActiveEnergyBurned(startDate: thirtyDaysAgo, endDate: endDate) { averageCalories in
                        DispatchQueue.main.async {
                            self.averageCaloriesBurnedLast30Days = Int(averageCalories ?? 0)
                        }
                    }

                    self.fetchTodaySleepTime() { sleepTime in
                        DispatchQueue.main.async {
                            let sleepTimeString = sleepTime.map { self.timeString(from: $0) } ?? "00 hours 00 minutes"
                            self.sleepTimeToday = sleepTimeString
                        }
                    }

                    self.fetchAverageSleepTime(startDate: sevenDaysAgo, endDate: endDate) { averageSleepTime in
                        DispatchQueue.main.async {
                            let sleepTimeString = averageSleepTime.map { self.timeString(from: $0) } ?? "00 hours 00 minutes"
                            self.averageSleepTimeLast7Days = sleepTimeString
                        }
                    }

                    self.fetchAverageSleepTime(startDate: thirtyDaysAgo, endDate: endDate) { averageSleepTime in
                        DispatchQueue.main.async {
                            let sleepTimeString = averageSleepTime.map { self.timeString(from: $0) } ?? "00 hours 00 minutes"
                            self.averageSleepTimeLast30Days = sleepTimeString
                        }
                    }

                }
            } else {
                print("Authorization failed")
                if let error = error {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func timeString(from seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        return String(format: hours >= 10 ? "%02d hours %02d minutes" : "%2d hours %02d minutes" , hours, minutes)
    }
}
