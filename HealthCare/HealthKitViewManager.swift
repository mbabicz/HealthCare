//
//  HealthViewModel.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import Foundation
import HealthKit

class HealthKitViewManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    @Published var stepsCount = Int()
    @Published var caloriesBurned = Double()
    @Published var averageStepsLast7Days = Int()
    @Published var averageCaloriesBurnedLast7Days = Int()
    
    @Published var averageStepsLast30Days = Int()
    @Published var averageCaloriesBurnedLast30Days = Int()

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

    
    func getHealthKitData() {
        let typesToRead = Set([
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ])
        let typesToShare = Set([
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
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
                        print(averageSteps!)

                    }
                    
                    self.fetchAverageStepsCount(startDate: thirtyDaysAgo, endDate: endDate) { averageSteps in
                        self.averageStepsLast30Days = averageSteps!
                        print(averageSteps!)


                    }
                    
                    self.fetchTodayActiveEnergyBurned { calories in
                        self.caloriesBurned = Double(calories ?? 0)
                    }
                    
                    self.fetchAverageActiveEnergyBurned(startDate: sevenDaysAgo, endDate: endDate) { averageCalories in
                        DispatchQueue.main.async {
                            self.averageCaloriesBurnedLast7Days = Int(averageCalories ?? 0)
                            print(averageCalories!)
                        }
                    }

                    self.fetchAverageActiveEnergyBurned(startDate: thirtyDaysAgo, endDate: endDate) { averageCalories in
                        DispatchQueue.main.async {
                            self.averageCaloriesBurnedLast30Days = Int(averageCalories ?? 0)
                            print(averageCalories!)

                        }
                    }
                }
            } else {
                print("Authorization failed.")
                if let error = error {
                    print("\(error.localizedDescription)")
                }
            }
        }
    }

                                                         
                                                         }
