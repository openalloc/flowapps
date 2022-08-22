//
//  ColorDict.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os.log
import SwiftUI

import FlowBase

public typealias ColorPair = (Color, Color)

public let DefaultColorPair: ColorPair = (.primary, .clear)

public func getBackgroundColor(_ colorCode: Int?) -> Color? {
    guard let _colorCode = colorCode else { return nil }
    return getColor(_colorCode).1
}

public func getColor(_ colorCode: String?) -> ColorPair {
    getColor(colorCode != nil ? Int(colorCode!) : nil)
}

public func getColor(_ colorCode: Int?) -> ColorPair {
    // os_log("colorCode=%d", colorCode ?? -1)
    if let colorCode = colorCode,
       let pairArray: [ColorPair] = colorDict[colorCode]
    {
        return pairArray[0] // TODO: support dark mode pair too
    } else {
        return DefaultColorPair //(Color.black, Color.white)
    }
}

// Entry format:
//
// colorCode: [ (fgLight, bgLight), (fgDark, bgDark) ]
//
public let colorDict: [Int: [ColorPair]] = [
    100: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.333, saturation: 1.00, brightness: 0.44)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.331, saturation: 0.50, brightness: 0.44))],
    101: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.372, saturation: 1.00, brightness: 0.45)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.370, saturation: 0.50, brightness: 0.45))],
    102: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.411, saturation: 1.00, brightness: 0.46)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.409, saturation: 0.50, brightness: 0.46))],
    103: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.450, saturation: 1.00, brightness: 0.47)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.449, saturation: 0.50, brightness: 0.47))],
    104: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.489, saturation: 1.00, brightness: 0.48)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.488, saturation: 0.50, brightness: 0.48))],
    105: [(Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.567, saturation: 1.00, brightness: 0.50)), (Color(hue: 0.125, saturation: 1.00, brightness: 0.97), Color(hue: 0.567, saturation: 0.50, brightness: 0.50))],
    106: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.333, saturation: 1.00, brightness: 0.44)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.333, saturation: 0.53, brightness: 0.33))],
    107: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.371, saturation: 1.00, brightness: 0.49)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.371, saturation: 0.53, brightness: 0.33))],
    108: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.409, saturation: 1.00, brightness: 0.54)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.409, saturation: 0.52, brightness: 0.33))],
    109: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.447, saturation: 1.00, brightness: 0.59)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.447, saturation: 0.52, brightness: 0.33))],
    110: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.485, saturation: 1.00, brightness: 0.63)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.485, saturation: 0.52, brightness: 0.33))],
    111: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.561, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.561, saturation: 0.51, brightness: 0.33))],
    112: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.106, saturation: 0.80, brightness: 0.52)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.106, saturation: 0.80, brightness: 0.52))],
    113: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.092, saturation: 0.83, brightness: 0.55)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.092, saturation: 0.83, brightness: 0.55))],
    114: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.078, saturation: 0.87, brightness: 0.58)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.078, saturation: 0.87, brightness: 0.58))],
    115: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.064, saturation: 0.90, brightness: 0.62)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.064, saturation: 0.90, brightness: 0.62))],
    116: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.050, saturation: 0.93, brightness: 0.65)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.050, saturation: 0.93, brightness: 0.65))],
    117: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.022, saturation: 1.00, brightness: 0.71)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.022, saturation: 1.00, brightness: 0.71))],
    118: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.147, saturation: 0.80, brightness: 0.98)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.147, saturation: 0.50, brightness: 0.55))],
    119: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.141, saturation: 0.81, brightness: 0.98)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.140, saturation: 0.50, brightness: 0.55))],
    120: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.134, saturation: 0.82, brightness: 0.98)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.134, saturation: 0.50, brightness: 0.54))],
    121: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.127, saturation: 0.84, brightness: 0.98)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.127, saturation: 0.50, brightness: 0.54))],
    122: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.121, saturation: 0.85, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.120, saturation: 0.49, brightness: 0.54))],
    123: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.114, saturation: 0.86, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.113, saturation: 0.49, brightness: 0.53))],
    124: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.107, saturation: 0.87, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.106, saturation: 0.49, brightness: 0.53))],
    125: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.101, saturation: 0.88, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.099, saturation: 0.49, brightness: 0.53))],
    126: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.094, saturation: 0.90, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.092, saturation: 0.49, brightness: 0.52))],
    127: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.087, saturation: 0.91, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.086, saturation: 0.49, brightness: 0.52))],
    128: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.081, saturation: 0.92, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.079, saturation: 0.49, brightness: 0.52))],
    129: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.074, saturation: 0.93, brightness: 0.99)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.072, saturation: 0.49, brightness: 0.51))],
    130: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.067, saturation: 0.94, brightness: 1.00)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.065, saturation: 0.48, brightness: 0.51))],
    131: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.061, saturation: 0.96, brightness: 1.00)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.058, saturation: 0.48, brightness: 0.51))],
    132: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.047, saturation: 0.98, brightness: 1.00)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.37), Color(hue: 0.044, saturation: 0.48, brightness: 0.50))],
    133: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.256, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.256, saturation: 0.57, brightness: 0.44))],
    134: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.265, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.265, saturation: 0.57, brightness: 0.44))],
    135: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.274, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.274, saturation: 0.56, brightness: 0.43))],
    136: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.283, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.283, saturation: 0.56, brightness: 0.43))],
    137: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.292, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.292, saturation: 0.55, brightness: 0.43))],
    138: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.301, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.301, saturation: 0.55, brightness: 0.42))],
    139: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.310, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.310, saturation: 0.54, brightness: 0.42))],
    140: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.319, saturation: 1.00, brightness: 0.70)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.319, saturation: 0.54, brightness: 0.42))],
    141: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.328, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.328, saturation: 0.53, brightness: 0.41))],
    142: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.337, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.337, saturation: 0.53, brightness: 0.41))],
    143: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.346, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.346, saturation: 0.52, brightness: 0.41))],
    144: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.355, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.355, saturation: 0.52, brightness: 0.40))],
    145: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.364, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.364, saturation: 0.51, brightness: 0.40))],
    146: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.374, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.374, saturation: 0.51, brightness: 0.40))],
    147: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.392, saturation: 1.00, brightness: 0.69)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.392, saturation: 0.50, brightness: 0.39))],
    148: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.450, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.450, saturation: 0.54, brightness: 0.46))],
    149: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.460, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.460, saturation: 0.54, brightness: 0.46))],
    150: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.470, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.470, saturation: 0.54, brightness: 0.46))],
    151: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.481, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.481, saturation: 0.54, brightness: 0.46))],
    152: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.491, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.491, saturation: 0.54, brightness: 0.46))],
    153: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.511, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.511, saturation: 0.54, brightness: 0.46))],
    154: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.561, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.561, saturation: 0.56, brightness: 0.35))],
    155: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.571, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.571, saturation: 0.56, brightness: 0.35))],
    156: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.582, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.582, saturation: 0.56, brightness: 0.35))],
    157: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.592, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.592, saturation: 0.56, brightness: 0.35))],
    158: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.603, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.603, saturation: 0.56, brightness: 0.35))],
    159: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.613, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.613, saturation: 0.56, brightness: 0.35))],
    160: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.623, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.623, saturation: 0.56, brightness: 0.35))],
    161: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.634, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.634, saturation: 0.56, brightness: 0.35))],
    162: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.644, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.644, saturation: 0.56, brightness: 0.35))],
    163: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.654, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.654, saturation: 0.56, brightness: 0.35))],
    164: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.665, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.665, saturation: 0.56, brightness: 0.35))],
    165: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.675, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.675, saturation: 0.56, brightness: 0.35))],
    166: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.686, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.686, saturation: 0.56, brightness: 0.35))],
    167: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.696, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.696, saturation: 0.56, brightness: 0.35))],
    168: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.717, saturation: 1.00, brightness: 0.73)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.717, saturation: 0.56, brightness: 0.35))],
    169: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.450, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.450, saturation: 0.56, brightness: 0.41))],
    170: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.457, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.457, saturation: 0.56, brightness: 0.41))],
    171: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.464, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.464, saturation: 0.56, brightness: 0.41))],
    172: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.470, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.470, saturation: 0.56, brightness: 0.41))],
    173: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.477, saturation: 0.99, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.477, saturation: 0.56, brightness: 0.41))],
    174: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.484, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.484, saturation: 0.56, brightness: 0.41))],
    175: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.491, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.491, saturation: 0.56, brightness: 0.41))],
    176: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.498, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.498, saturation: 0.56, brightness: 0.41))],
    177: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.511, saturation: 1.00, brightness: 0.90)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.30), Color(hue: 0.511, saturation: 0.56, brightness: 0.41))],
    178: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.728, saturation: 1.00, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.728, saturation: 0.55, brightness: 0.45))],
    179: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.735, saturation: 1.00, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.735, saturation: 0.55, brightness: 0.45))],
    180: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.742, saturation: 0.99, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.742, saturation: 0.55, brightness: 0.45))],
    181: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.749, saturation: 0.99, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.749, saturation: 0.55, brightness: 0.45))],
    182: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.756, saturation: 0.99, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.756, saturation: 0.55, brightness: 0.45))],
    183: [(Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.769, saturation: 0.98, brightness: 0.56)), (Color(hue: 0.303, saturation: 0.00, brightness: 1.00), Color(hue: 0.769, saturation: 0.55, brightness: 0.45))],
    184: [(Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    185: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    186: [(Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    187: [(Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    188: [(Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    189: [(Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    190: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.675, saturation: 0.07, brightness: 0.19)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.908, saturation: 0.84, brightness: 0.00))],
    191: [(Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    192: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    193: [(Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    194: [(Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    195: [(Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    196: [(Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    197: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.675, saturation: 0.08, brightness: 0.41)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.708, saturation: 0.03, brightness: 0.18))],
    198: [(Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.561, saturation: 0.66, brightness: 1.00), Color(hue: 0.675, saturation: 0.02, brightness: 0.28))],
    199: [(Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.478, saturation: 0.55, brightness: 0.99), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
    200: [(Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.278, saturation: 0.69, brightness: 0.98), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
    201: [(Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.167, saturation: 0.59, brightness: 0.99), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
    202: [(Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.014, saturation: 0.45, brightness: 1.00), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
    203: [(Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.917, saturation: 0.45, brightness: 1.00), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
    204: [(Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.833, saturation: 0.01, brightness: 0.37)), (Color(hue: 0.314, saturation: 0.00, brightness: 0.84), Color(hue: 0.833, saturation: 0.01, brightness: 0.37))],
]
