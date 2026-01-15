import SwiftUI

struct LoadingView: View {
    
    @State private var rotationDegrees: CGFloat = 0.0
    let loadingViewBackgroundColor: Color = .secondaryBackgroundColor
    let circularBackgroundColor: Color
    let overlayColor: Color
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(loadingViewBackgroundColor)
            Group {
                Circle()
                    .stroke(circularBackgroundColor, lineWidth: 8)
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(overlayColor, lineWidth: 8)
                    .rotationEffect(Angle(degrees: rotationDegrees))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotationDegrees)
                    .onAppear {
                        rotationDegrees = 360
                    }
            }
            .frame(width: 60, height: 60)
        }
    }
}

#Preview {
    LoadingView(circularBackgroundColor: .blue, overlayColor: .black)
}
