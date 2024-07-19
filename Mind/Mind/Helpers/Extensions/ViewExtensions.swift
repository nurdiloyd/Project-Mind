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
                      level: Int = 1) -> some View {
        self.LCButton(width: width, height: height, padding: 2, level: level)
    }
}

extension Image {
    func LCButton(width: CGFloat,
                  height: CGFloat,
                  padding: CGFloat = 8,
                  level: Int = 1) -> some View {
        self.resizable()
            .aspectRatio(contentMode: .fit)
            .bold()
            .frame(width: width - padding * 2, height: height - padding * 2)
            .padding(padding)
            .LCContainer(level: level)
    }
}

extension View {
    func LCContainer(smooth: CGFloat = 4, 
                     radius: CGFloat = LCConstants.cornerRadius,
                     level: Int = 1) -> some View {
        
        let color: Color = LCConstants.getColor(level)
        
        return self
            .foregroundColor(LCConstants.textColor)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: LCConstants.shadowColor, radius: smooth)
            
    }
}
