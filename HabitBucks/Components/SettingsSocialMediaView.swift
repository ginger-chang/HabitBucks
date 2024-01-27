//
//  SettingsRowView.swift
//  HabitBucks
//
//  Created by Ginger Chang on 1/27/24.
//

import SwiftUI

struct SettingsSocialMediaView: View {
    let imageName: String
    let title: LocalizedStringKey
    let tintColor: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            Text(title)
                .font(.subheadline)
        }
    }
}

struct SettingsSocialMediaView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(imageName: "facebook", title: "Version", tintColor: Color(.systemGray))
    }
}
