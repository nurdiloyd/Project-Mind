import Foundation
import SwiftUI

struct LCConstants {
    public static let cornerRadius: CGFloat = 11
    
    public static let shadowColor: Color = Color(.displayP3, red: 15/255, green: 15/255, blue: 15/255)
    public static let groundColor: Color = Color(.displayP3, red: 20/255, green: 20/255, blue: 20/255)
    public static let base1Color: Color = Color(.displayP3, red: 26/255, green: 26/255, blue: 26/255)
    public static let base2Color: Color = Color(.displayP3, red: 30/255, green: 30/255, blue: 30/255)
    public static let base3Color: Color = Color(.displayP3, red: 36/255, green: 36/255, blue: 36/255)
    public static let textColor: Color = Color(.displayP3, red: 226/255, green: 226/255, blue: 226/255)
    public static let lightColor: Color = Color(.displayP3, red: 43/255, green: 43/255, blue: 43/255)
    
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
        default:
            LCConstants.groundColor
        }
    }
}
