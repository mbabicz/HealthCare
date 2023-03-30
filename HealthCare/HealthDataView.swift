//
//  HealthDataView.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import SwiftUI

struct HealthDataView: View {
    @StateObject var healthManager = HealthKitViewManager()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today's Steps")
                            .font(.headline)
                        Text("\(healthManager.stepsCount)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Today's Calories Burned")
                            .font(.headline)
                        Text("\(healthManager.caloriesBurned, specifier: "%.1f")")
                            .font(.title)
                    }
                }
                .padding()
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Last 7 Days Steps")
                            .font(.headline)
                        Text("\(healthManager.averageStepsLast7Days)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Last 7 Days Calories Burned")
                            .font(.headline)
                        Text("\(healthManager.averageCaloriesBurnedLast7Days)")
                            .font(.title)
                    }
                }
                .padding()
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Last 30 Days Steps")
                            .font(.headline)
                        Text("\(healthManager.averageStepsLast30Days)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Last 30 Days Calories Burned")
                            .font(.headline)
                        Text("\(healthManager.averageCaloriesBurnedLast30Days)")
                            .font(.title)
                    }
                }
                .padding()
                Spacer()
            }
            .navigationBarTitle(Text("Health Data"))
            .onAppear{
                healthManager.getHealthKitData()
            }
        }
    }
}

