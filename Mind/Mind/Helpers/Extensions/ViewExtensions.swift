import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

struct PositionPreferenceKey: PreferenceKey {
  static var defaultValue: CGPoint = .zero
  static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

extension View {
  func readPosition(onChange: @escaping (CGPoint) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.blue
              .preference(key: PositionPreferenceKey.self, value: geometryProxy.frame(in: .global).origin)
      }
    )
    .onPreferenceChange(PositionPreferenceKey.self, perform: onChange)
  }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
}

extension View {
    func nkButton(isInner: Bool = false, smooth: CGFloat = 2, radius: CGFloat = 8) -> some View {
        let offset: CGFloat = isInner ? -smooth : smooth
        
        let shadowRadius: CGFloat = isInner ? smooth / 1.5 : smooth / 2 + 1
        let cornerRadius: CGFloat = radius
        
        let baseColor: Color = EntranceView.baseColor
        let lightColor: Color = EntranceView.lightColor
        let darkColor: Color = EntranceView.darkColor
        let shadowColor: Color = isInner ? lightColor : darkColor
        let textColor: Color = Color(.displayP3, red: 88/255, green: 105/255, blue: 110/255)
        
        return self.foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius , style: .continuous)
                    .fill(baseColor
                        .shadow(.inner(color: darkColor, radius: smooth / 1, x: -offset, y: -offset))
                        .shadow(.inner(color: lightColor, radius: smooth / 1, x: offset, y: offset))
                    )
                    .shadow(color: shadowColor, radius: shadowRadius)
            )
    }
}

extension Image {
    func nkMiniButton(width: CGFloat, height: CGFloat, padding: CGFloat = 2, smooth: CGFloat = 2, radius: CGFloat = 8) -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .bold()
            .frame(width: width - padding * 2, height: height - padding * 2)
            .padding(padding)
            .nkButton(smooth: smooth, radius: radius)
    }
}
