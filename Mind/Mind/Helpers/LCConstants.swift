import Foundation
import SwiftUI

struct LCConstants {
    public static let cornerRadius: CGFloat = 11
    
    public static let shadowColor: Color = Color(.displayP3, white: 25/255)
    public static let groundColor: Color = Color(.displayP3, white: 40/255)
    public static let base1Color: Color = Color(.displayP3, white: 45/255)
    public static let base2Color: Color = Color(.displayP3, white: 50/255)
    public static let base3Color: Color = Color(.displayP3, white: 70/255)
    public static let base4Color: Color = Color(.displayP3, white: 120/255)
    public static let lightColor: Color = Color(.displayP3, white: 60/255)
    public static let textColor: Color = Color(.displayP3, white: 220/255)
    
    public static func getColor(_ level: Int) -> Color
    {
        return switch level {
        case 0:
            LCConstants.groundColor
        case 1:
            LCConstants.base1Color
        case 2:
            LCConstants.base2Color
        case 3:
            LCConstants.base3Color
        case 4:
            LCConstants.base4Color
        default:
            LCConstants.groundColor
        }
    }
}
