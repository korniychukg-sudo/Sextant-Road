import SwiftUI

enum PlateStore {
    static func image(_ name: String) -> UIImage? {
        if let path = Bundle.main.path(forResource: name, ofType: "jpg", inDirectory: "Art"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        if let path = Bundle.main.path(forResource: name, ofType: "jpg"),
           let img = UIImage(contentsOfFile: path) {
            return img
        }
        return nil
    }
}

struct Plate: View {
    let name: String
    var corner: CGFloat = 10
    var anchor: Alignment = .center

    var body: some View {
        GeometryReader { geo in
            if let img = PlateStore.image(name) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: anchor)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Sea.cardSunk)
                    .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: corner))
        .overlay(
            RoundedRectangle(cornerRadius: corner)
                .stroke(Sea.ink.opacity(0.30), lineWidth: 1)
        )
    }
}

struct SeaCard<Content: View>: View {
    var padding: CGFloat = 16
    var tone: Color = Sea.card
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(tone)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Sea.ink.opacity(0.20), lineWidth: 1)
            )
    }
}

struct SectionHead: View {
    let text: String
    var trailing: String? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text.uppercased())
                .font(SeaFont.title(13))
                .tracking(2.4)
                .foregroundColor(Sea.inkSoft)
                .fixedSize(horizontal: true, vertical: false)
            Rectangle()
                .fill(Sea.hairline)
                .frame(height: 1)
            if let t = trailing {
                Text(t.uppercased())
                    .font(SeaFont.body(12))
                    .tracking(1.6)
                    .foregroundColor(Sea.inkPale)
            }
        }
    }
}

struct SeaButton: View {
    let title: String
    var kind: Kind = .primary
    var enabled: Bool = true
    let action: () -> Void

    enum Kind { case primary, secondary, quiet, danger }

    private var fill: Color {
        switch kind {
        case .primary: return Sea.ink
        case .secondary: return Sea.brass.opacity(0.20)
        case .quiet: return Color.clear
        case .danger: return Sea.oxblood.opacity(0.16)
        }
    }

    private var textColour: Color {
        switch kind {
        case .primary: return Sea.card
        case .secondary: return Sea.ink
        case .quiet: return Sea.inkSoft
        case .danger: return Sea.oxblood
        }
    }

    var body: some View {
        Button(action: { if enabled { action() } }) {
            Text(title.uppercased())
                .font(SeaFont.title(14))
                .tracking(2.0)
                .foregroundColor(textColour.opacity(enabled ? 1 : 0.38))
                .padding(.vertical, 13)
                .padding(.horizontal, 22)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 11)
                        .fill(fill.opacity(enabled ? 1 : 0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(kind == .primary ? Color.clear : Sea.ink.opacity(0.28),
                                lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Chip: View {
    let text: String
    var tone: Color = Sea.brass
    var solid: Bool = false

    var body: some View {
        Text(text.uppercased())
            .font(SeaFont.title(11))
            .tracking(1.6)
            .lineLimit(1)
            .minimumScaleFactor(0.62)
            .foregroundColor(solid ? Sea.card : tone)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule().fill(solid ? tone : tone.opacity(0.14))
            )
            .overlay(
                Capsule().stroke(tone.opacity(solid ? 0 : 0.45), lineWidth: 1)
            )
    }
}

struct StatBlock: View {
    let value: String
    let caption: String
    var tone: Color = Sea.ink

    var body: some View {
        VStack(spacing: 3) {
            Text(value)
                .font(SeaFont.title(21))
                .foregroundColor(tone)
            Text(caption.uppercased())
                .font(SeaFont.body(10))
                .tracking(1.4)
                .foregroundColor(Sea.inkPale)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StarRow: View {
    let earned: Int
    var total: Int = 3
    var size: CGFloat = 15

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<total, id: \.self) { i in
                StarMark(size: size, colour: Sea.brass, filled: i < earned)
            }
        }
    }
}

struct RuleLine: View {
    var body: some View {
        Rectangle().fill(Sea.hairline).frame(height: 1)
    }
}

struct SheetHeader: View {
    let title: String
    var subtitle: String? = nil
    let onClose: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(SeaFont.title(21))
                    .foregroundColor(Sea.ink)
                if let s = subtitle {
                    Text(s.uppercased())
                        .font(SeaFont.body(11))
                        .tracking(1.8)
                        .foregroundColor(Sea.inkPale)
                }
            }
            Spacer(minLength: 12)
            Button(action: onClose) {
                CloseMark(size: 19)
                    .padding(9)
                    .background(Circle().fill(Sea.cardSunk))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct BackBar: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                HStack(spacing: 5) {
                    ChevronMark(size: 14, colour: Sea.inkSoft, pointsLeft: true)
                    Text("Back".uppercased())
                        .font(SeaFont.title(12))
                        .tracking(1.8)
                        .foregroundColor(Sea.inkSoft)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(Capsule().fill(Sea.cardSunk))
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            Text(title.uppercased())
                .font(SeaFont.title(12))
                .tracking(2.2)
                .foregroundColor(Sea.inkPale)
        }
    }
}

struct ProgressBarline: View {
    let fraction: Double
    var tone: Color = Sea.brass
    var height: CGFloat = 7

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Sea.ink.opacity(0.10))
                Capsule()
                    .fill(tone)
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}

func formatAngle(_ degrees: Double) -> String {
    let total = degrees * 60.0
    let d = Int(floor(total / 60.0))
    let m = total - Double(d) * 60.0
    return String(format: "%d° %04.1f'", d, m)
}

func formatMinutes(_ minutes: Double) -> String {
    String(format: "%.1f'", minutes)
}

func formatMiles(_ miles: Double) -> String {
    String(format: "%.1f nm", miles)
}

enum SeaFeel {
    static func tap() {
        let gen = UIImpactFeedbackGenerator(style: .light)
        gen.prepare()
        gen.impactOccurred(intensity: 0.55)
    }

    static func mark() {
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.prepare()
        gen.impactOccurred()
    }

    static func land(_ stars: Int) {
        let gen = UIImpactFeedbackGenerator(style: stars >= 3 ? .heavy : .soft)
        gen.prepare()
        gen.impactOccurred(intensity: stars >= 3 ? 1.0 : 0.6)
    }
}

struct RisingCard<Content: View>: View {
    let index: Int
    @ViewBuilder var content: () -> Content
    @State private var shown = false

    var body: some View {
        content()
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 16)
            .onAppear {
                withAnimation(.easeOut(duration: 0.38)
                    .delay(Double(index) * 0.06)) { shown = true }
            }
    }
}

struct Winding: View {
    let value: Double
    var format: (Double) -> String
    var font: Font
    var tone: Color

    @State private var shown: Double = 0

    var body: some View {
        Text(format(shown))
            .font(font)
            .foregroundColor(tone)
            .onAppear {
                shown = 0
                withAnimation(.easeOut(duration: 0.75)) { shown = value }
            }
            .onChange(of: value) { v in
                withAnimation(.easeOut(duration: 0.55)) { shown = v }
            }
    }
}
