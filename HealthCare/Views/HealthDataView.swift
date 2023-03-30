//
//  HealthDataView.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import SwiftUI

struct HealthDataView: View {
    @StateObject var healthManager = HealthKitManager()

    var body: some View {
        NavigationView {
            ScrollView{
                VStack{
                    StepsView()
                    CaloriesView()
                }
            }
            .navigationBarTitle(Text("Health Data"))
        }
    }
}
