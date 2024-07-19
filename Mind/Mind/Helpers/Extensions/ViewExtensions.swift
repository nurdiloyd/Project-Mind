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

extension Image {
    func LCButtonMini(width: CGFloat,
                      height: CGFloat,
                      padding: CGFloat = 2,
                      smooth: CGFloat = 2,
                      radius: CGFloat = 8) -> some View {
        self.LCButton(width: width, height: height, padding: padding, smooth: smooth, radius: radius)
    }
}

extension Image {
    func LCButton(width: CGFloat,
                      height: CGFloat,
                      padding: CGFloat = 8,
                      smooth: CGFloat = 2,
                      radius: CGFloat = 8) -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .bold()
            .frame(width: width - padding * 2, height: height - padding * 2)
            .padding(padding)
            .LCContainer(smooth: smooth, radius: radius)
    }
}

extension View {
    func LCContainer(smooth: CGFloat = 2, radius: CGFloat = 8) -> some View {
        let shadowRadius: CGFloat = smooth
        let baseColor: Color = EntranceView.baseColor
        let darkColor: Color = EntranceView.darkColor
        let shadowColor: Color = darkColor
        let textColor: Color = EntranceView.textColor
        
        return self
            .foregroundColor(textColor)
            .background(
                RoundedRectangle(cornerRadius: radius , style: .continuous)
                    .fill(baseColor)
                    .shadow(color: shadowColor, radius: shadowRadius)
            )
    }
}
