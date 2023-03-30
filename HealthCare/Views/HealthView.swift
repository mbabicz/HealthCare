//
//  HealthDataView.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import SwiftUI

struct HealthView: View {
    @StateObject var healthManager = HealthKitManager()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today's steps")
                            .font(.headline)
                        Text("\(healthManager.stepsCount)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Today's calories burned")
                            .font(.headline)
                        Text("\(healthManager.caloriesBurned, specifier: "%.1f")")
                            .font(.title)
                    }
                }
                .padding()
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Last 7 days steps avg.")
                            .font(.headline)
                        Text("\(healthManager.averageStepsLast7Days)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Last 7 days calories burned avg.")
                            .font(.headline)
                        Text("\(healthManager.averageCaloriesBurnedLast7Days)")
                            .font(.title)
                    }
                }
                .padding()
                Divider()
                HStack {
                    VStack(alignment: .leading) {
                        Text("Last 30 days steps avg.")
                            .font(.headline)
                        Text("\(healthManager.averageStepsLast30Days)")
                            .font(.title)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Last 30 days calories burned avg.")
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

