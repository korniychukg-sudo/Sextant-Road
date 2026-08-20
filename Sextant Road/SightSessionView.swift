import SwiftUI

struct SightResult {
    var errorMinutes: Double
    var stars: Int
    var workedClean: Bool
    var interceptMiles: Double
    var plotted: Bool
}

enum SightPhase {
    case brief, taking, graded, reduce, plot, summary
}

struct SightSessionView: View {
    let brief: SightBrief
    let contextLabel: String
    let onFinish: (SightResult) -> Void
    let onLeave: () -> Void

    @State private var phase: SightPhase = .brief
    @State private var degrees: Double = 20
    @State private var minutes: Double = 0
    @State private var tilt: Double = 0.45
    @State private var swellPhase: Double = 0
    @State private var markedHs: Double = 0
    @State private var errorMinutes: Double = 0
    @State private var reduceClean: Bool = true
    @State private var observedHo: Double = 0
    @State private var interceptMiles: Double = 0
    @State private var plotted: Bool = false
    @State private var attempts: Int = 0

    private let ticker = Timer.publish(every: 1.0 / 26.0, on: .main, in: .common).autoconnect()

    private var setting: Double { degrees + minutes / 60.0 }

    var body: some View {
        ZStack {
            Sea.paper.ignoresSafeArea()
            switch phase {
            case .brief: briefScreen
            case .taking: takingScreen
            case .graded: gradedScreen
            case .reduce:
                ReduceView(brief: brief, markedHs: markedHs) { ho, clean in
                    observedHo = ho
                    reduceClean = clean
                    interceptMiles = (ho - brief.computedAltitude) * 60.0
                    phase = .plot
                } onBack: {
                    phase = .graded
                }
            case .plot:
                PlotView(brief: brief, observedHo: observedHo,
                         interceptMiles: interceptMiles) {
                    plotted = true
                    phase = .summary
                } onBack: {
                    phase = .reduce
                }
            case .summary: summaryScreen
            }
        }
        .onReceive(ticker) { _ in
            if phase == .taking {
                swellPhase += 0.052
                if swellPhase > 62.83 { swellPhase -= 62.83 }
            }
        }
    }

    private var briefScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: contextLabel, onBack: onLeave)

                if let slug = brief.starSlug {
                    Plate(name: "star_" + slug, anchor: .top)
                        .frame(height: SeaMetrics.isPad ? 300 : 210)
                } else {
                    Plate(name: "sky_" + brief.skySlug, anchor: .top)
                        .frame(height: SeaMetrics.isPad ? 300 : 210)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(brief.kind.display.uppercased())
                        .font(SeaFont.body(11)).tracking(2.4)
                        .foregroundColor(Sea.inkPale)
                    Text(brief.bodyName)
                        .font(SeaFont.title(30))
                        .foregroundColor(Sea.ink)
                }

                SeaCard {
                    Text(brief.note)
                        .font(SeaFont.body(16))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionHead(text: "The conditions")
                VStack(spacing: 8) {
                    conditionRow("Height of eye", brief.deck.name + " — "
                                 + String(format: "%.0f m", brief.deck.metres))
                    conditionRow("Index error", formatMinutes(brief.indexErrorMinutes)
                                 + (brief.indexOnArc ? " on the arc" : " off the arc"))
                    conditionRow("Swell", brief.swellMinutes < 1.5 ? "Slight"
                                 : (brief.swellMinutes < 2.8 ? "Moderate" : "Heavy"))
                    conditionRow("Horizon", brief.haze < 0.2 ? "Hard and clear"
                                 : (brief.haze < 0.5 ? "A little soft" : "Hazy"))
                    if brief.kind.hasLimb {
                        conditionRow("Bring down", brief.limb.display)
                    }
                }

                SeaCard(tone: Sea.brass.opacity(0.10)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How it is done".uppercased())
                            .font(SeaFont.title(12)).tracking(2.0)
                            .foregroundColor(Sea.brass)
                        Text("Drag up and down the glass to bring the body down to the sea. Rock your finger left and right to swing the arc — the bubble must sit in the middle. Turn the drum for the last few minutes, then mark when the swell passes the mean.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SeaButton(title: "Take the sight") {
                    degrees = max(0, (brief.perfectHs - 6).rounded())
                    minutes = 0
                    tilt = 0.42
                    swellPhase = 0
                    phase = .taking
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .centreColumn()
    }

    private func conditionRow(_ k: String, _ v: String) -> some View {
        HStack {
            Text(k.uppercased())
                .font(SeaFont.body(11)).tracking(1.6)
                .foregroundColor(Sea.inkPale)
            Spacer()
            Text(v)
                .font(SeaFont.body(15))
                .foregroundColor(Sea.ink)
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 13)
        .background(RoundedRectangle(cornerRadius: 9).fill(Sea.card))
    }

    private var takingScreen: some View {
        VStack(spacing: 10) {
            HStack {
                Button(action: { phase = .brief }) {
                    HStack(spacing: 5) {
                        ChevronMark(size: 13, colour: Sea.inkSoft, pointsLeft: true)
                        Text("Brief".uppercased())
                            .font(SeaFont.title(11)).tracking(1.6)
                            .foregroundColor(Sea.inkSoft)
                    }
                    .padding(.vertical, 6).padding(.horizontal, 11)
                    .background(Capsule().fill(Sea.cardSunk))
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Text(brief.bodyName.uppercased())
                    .font(SeaFont.title(12)).tracking(2.2)
                    .foregroundColor(Sea.inkPale)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.top, 8)

            Spacer(minLength: 0)

            SextantField(brief: brief, setting: setting, tilt: tilt,
                         swellPhase: swellPhase, showHint: attempts > 0)
                .frame(maxHeight: SeaMetrics.isPad ? 470 : 372)
                .padding(.horizontal, SeaMetrics.gutter)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            if g.translation == .zero {
                                dragBaseDegrees = degrees
                                dragBaseTilt = tilt
                            }
                            let dy = Double(g.translation.height)
                            let dx = Double(g.translation.width)
                            degrees = min(89.9, max(0, dragBaseDegrees + dy * 0.055))
                            tilt = max(-1, min(1, dragBaseTilt + dx * 0.010))
                        }
                        .onEnded { _ in
                            dragBaseDegrees = degrees
                            dragBaseTilt = tilt
                        }
                )

            Spacer(minLength: 0)

            VStack(spacing: 9) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reading".uppercased())
                            .font(SeaFont.body(10)).tracking(1.6)
                            .foregroundColor(Sea.inkPale)
                        Text(formatAngle(setting))
                            .font(SeaFont.mono(23))
                            .foregroundColor(Sea.ink)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Swing the arc".uppercased())
                            .font(SeaFont.body(10)).tracking(1.6)
                            .foregroundColor(Sea.inkPale)
                        LevelBubble(tilt: tilt).frame(width: 120)
                    }
                }

                HStack(spacing: 10) {
                    Text("Swell".uppercased())
                        .font(SeaFont.body(10)).tracking(1.6)
                        .foregroundColor(Sea.inkPale)
                    SwellTrace(phase: swellPhase, amplitude: brief.swellMinutes)
                }

                MicrometerDrum(minutes: $minutes)

                HStack(spacing: 10) {
                    SeaButton(title: "Level it", kind: .secondary) {
                        withAnimation(.easeOut(duration: 0.25)) { tilt = 0 }
                        dragBaseTilt = 0
                    }
                    SeaButton(title: "Mark") {
                        markedHs = setting
                        errorMinutes = (setting - brief.perfectHs) * 60.0
                        attempts += 1
                        phase = .graded
                    }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 12)
        }
        .centreColumn()
    }

    @State private var dragBaseDegrees: Double = 20
    @State private var dragBaseTilt: Double = 0.45

    private var gradedScreen: some View {
        let grade = gradeSight(errorMinutes: errorMinutes)
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: "The mark", onBack: { phase = .taking })

                VStack(spacing: 10) {
                    StarRow(earned: grade.stars, size: 24)
                    Text(grade.title)
                        .font(SeaFont.title(26))
                        .foregroundColor(Sea.ink)
                    Text(String(format: "%@ out", formatMinutes(abs(errorMinutes))))
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkPale)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)

                SeaCard {
                    VStack(spacing: 12) {
                        valueRow("You marked", formatAngle(markedHs), Sea.ink)
                        RuleLine()
                        valueRow("A perfect sight", formatAngle(brief.perfectHs), Sea.inkSoft)
                        RuleLine()
                        valueRow("Difference",
                                 (errorMinutes >= 0 ? "+" : "−") + formatMinutes(abs(errorMinutes)),
                                 abs(errorMinutes) <= 3 ? Sea.moss : Sea.oxblood)
                    }
                }

                SeaCard(tone: Sea.cardSunk) {
                    Text(grade.note)
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SeaButton(title: "Work the sight") { phase = .reduce }
                SeaButton(title: "Take it again", kind: .secondary) { phase = .taking }
                SeaButton(title: "Leave it there", kind: .quiet, action: onLeave)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .centreColumn()
    }

    private func valueRow(_ k: String, _ v: String, _ tone: Color) -> some View {
        HStack {
            Text(k.uppercased())
                .font(SeaFont.body(11)).tracking(1.6)
                .foregroundColor(Sea.inkPale)
            Spacer()
            Text(v).font(SeaFont.mono(17)).foregroundColor(tone)
        }
    }

    private var summaryScreen: some View {
        let grade = gradeSight(errorMinutes: errorMinutes)
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("The sight is worked")
                    .font(SeaFont.title(27))
                    .foregroundColor(Sea.ink)
                    .padding(.top, 14)

                SeaCard {
                    VStack(spacing: 12) {
                        valueRow("Sextant altitude", formatAngle(markedHs), Sea.ink)
                        RuleLine()
                        valueRow("Observed altitude", formatAngle(observedHo), Sea.ink)
                        RuleLine()
                        valueRow("Computed altitude", formatAngle(brief.computedAltitude), Sea.inkSoft)
                        RuleLine()
                        valueRow("Intercept",
                                 formatMiles(abs(interceptMiles)) + (interceptMiles >= 0 ? " toward" : " away"),
                                 Sea.brass)
                    }
                }

                SeaCard(tone: Sea.cardSunk) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            StarRow(earned: grade.stars, size: 16)
                            Text(grade.title)
                                .font(SeaFont.title(16))
                                .foregroundColor(Sea.ink)
                        }
                        Text(reduceClean
                             ? "Every correction went the right way on the first try. That is how a sight should be worked."
                             : "The corrections took a second look. Better to be slow and right than quick and lost.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SeaButton(title: "Enter it in the log") {
                    onFinish(SightResult(errorMinutes: errorMinutes, stars: grade.stars,
                                         workedClean: reduceClean,
                                         interceptMiles: interceptMiles, plotted: plotted))
                }
                SeaButton(title: "Look at the plot again", kind: .secondary) { phase = .plot }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
        }
        .centreColumn()
    }
}

struct MicrometerDrum: View {
    @Binding var minutes: Double
    @State private var base: Double = 0

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("Micrometer drum".uppercased())
                    .font(SeaFont.body(10)).tracking(1.6)
                    .foregroundColor(Sea.inkPale)
                Spacer()
                Text(String(format: "%04.1f'", minutes))
                    .font(SeaFont.mono(14))
                    .foregroundColor(Sea.ink)
            }
            GeometryReader { geo in
                let w = geo.size.width, h = geo.size.height
                Canvas { ctx, _ in
                    let bg = Path(roundedRect: CGRect(x: 0, y: 0, width: w, height: h),
                                  cornerRadius: 8)
                    ctx.fill(bg, with: .color(Sea.cardSunk))
                    ctx.stroke(bg, with: .color(Sea.ink.opacity(0.24)),
                               style: StrokeStyle(lineWidth: 1))
                    let spacing: CGFloat = 13
                    let offset = CGFloat(minutes / 60.0) * spacing * 60
                    var x = -offset.truncatingRemainder(dividingBy: spacing * 5) - spacing * 5
                    var idx = 0
                    while x < w + spacing {
                        var tick = Path()
                        let long = idx % 5 == 0
                        tick.move(to: CGPoint(x: x, y: h * (long ? 0.24 : 0.38)))
                        tick.addLine(to: CGPoint(x: x, y: h * (long ? 0.76 : 0.62)))
                        ctx.stroke(tick, with: .color(Sea.inkSoft.opacity(long ? 0.75 : 0.42)),
                                   style: StrokeStyle(lineWidth: long ? 1.8 : 1.1))
                        x += spacing
                        idx += 1
                    }
                    var centre = Path()
                    centre.move(to: CGPoint(x: w / 2, y: 2))
                    centre.addLine(to: CGPoint(x: w / 2, y: h - 2))
                    ctx.stroke(centre, with: .color(Sea.oxblood),
                               style: StrokeStyle(lineWidth: 2.2))
                }
            }
            .frame(height: 46)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        if g.translation == .zero { base = minutes }
                        var v = base + Double(g.translation.width) * -0.13
                        while v < 0 { v += 60 }
                        while v >= 60 { v -= 60 }
                        minutes = v
                    }
                    .onEnded { _ in base = minutes }
            )
        }
    }
}
