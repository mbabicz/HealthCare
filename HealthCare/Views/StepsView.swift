//
//  HealthDataView.swift
//  HealthCare
//
//  Created by kz on 30/03/2023.
//

import SwiftUI

struct StepsView: View {
    @StateObject var healthManager = HealthKitManager()
    
    var body: some View {
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "flame.fill")
                    Text("Steps")
                }
                .foregroundColor(.orange)
                .padding(10)
                .font(.title3)
                
                //today's steps
                VStack(alignment: .leading){
                    HStack{
                        Text("\(healthManager.stepsCount)")
                            .font(.title)
                        Text("Steps")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 15)
                    
                    ZStack{
                        Text("Today's steps")
                            .font(.footnote)
                            .padding(.horizontal, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 72/255, green: 76/255, blue: 78/255))
                    .cornerRadius(20)
                    .padding([.horizontal, . bottom], 10)
                }
                
                //weekly avg. steps
                VStack(alignment: .leading){
                    HStack{
                        Text("\(healthManager.averageStepsLast7Days)")
                            .font(.title)
                        Text("Steps")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 15)
                    
                    ZStack{
                        Text("Weekly average")
                            .font(.footnote)
                            .padding(.horizontal, 5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 72/255, green: 76/255, blue: 78/255))
                    .cornerRadius(20)
                    .padding([.horizontal, . bottom], 10)
                }
                
                //monthly avg. steps
                VStack(alignment: .leading){
                    HStack{
                        Text("\(healthManager.averageStepsLast30Days)")
                            .font(.title)
                        Text("Steps")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 15)
                    
                    ZStack{
                        Text("Monthly average")
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

