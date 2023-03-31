//
//  HealthDataView.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import SwiftUI

struct SleepView: View {
    @StateObject var healthManager = HealthKitManager()
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "bed.double.fill")
                Text("Sleeping")
            }
            .foregroundColor(.cyan)
            .padding(10)
            .font(.title3)
            
            //today's sleep time
            VStack(alignment: .leading){
                Text(healthManager.sleepTimeToday)
                    .font(.title)
                    .padding(.horizontal, 10)
                
                ZStack{
                    Text("Today's sleep time")
                        .font(.footnote)
                        .padding(.horizontal, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 72/255, green: 76/255, blue: 78/255))
                .cornerRadius(20)
                .padding([.horizontal, . bottom], 10)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 36/255, blue: 38/255))
        .cornerRadius(20)
        .padding(10)
        
        .onAppear{
            healthManager.getHealthKitData()
        }
    }
}
