//
//  DynamicBar.swift
//  musicPlayer
//
//  Created by wearrier on 2026/03/14.
//

import SwiftUI

struct VolumeBar: View
{
    let power: Float
    let normalizedPower: CGFloat
    
    var body: some View
    {
        GeometryReader
        {
            geometry in
            let width = geometry.size.width * normalizedPower
            Spacer(minLength: 0)
            LinearGradient(gradient: Gradient(colors:[.green, Color(hue: normalizedPower, saturation: 0.3, brightness: 0.9), .red]), startPoint: .leading, endPoint: .trailing
            )
                .frame(width: width)
                .cornerRadius(0.75 * width)
                .shadow(color: .black.opacity(0.3), radius: 4)
                .animation(.interpolatingSpring(stiffness: 320, damping: 100), value: power)
        }
        .frame(width: 320, height: 20)
    }
}

#Preview {
    DynamicBar(power: 0, normalizedPower: 0)
}
