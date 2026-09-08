import SwiftUI

struct SeaLoadingScreen: View {
    @State private var beat = false

    var body: some View {
        ZStack {
            Sea.paper.ignoresSafeArea()
            VStack(spacing: 22) {
                SextantGlyph(size: 104, colour: Sea.ink)
                    .rotationEffect(.degrees(beat ? 6 : -6), anchor: .bottom)
                    .frame(height: 132)
                Text("Sextant Road")
                    .font(SeaFont.title(22))
                    .foregroundColor(Sea.ink)
                Text("bringing her down")
                    .font(SeaFont.italic(15))
                    .foregroundColor(Sea.inkPale)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) { beat = true }
        }
    }
}
