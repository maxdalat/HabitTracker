//
//  SettingsView.swift
//  HabitTracker
//
//  Created by Maxim Dalat on 5/26/23.
//

import SwiftUI



struct SettingsView: View {
    
    
    struct SettingsArray: Identifiable {
        var id: Int
        var name: String
        var goalToday: Int
    }
        @State var clientSettings: [SettingsArray] = [
            SettingsArray(id: 1, name: "ClientSettings", goalToday: 4)
        ]
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(clientSettings) { setting in
                        Text(setting.name)
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
    
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            SettingsView()
        }
    }

