import SwiftUI

struct ReduceView: View {
    let brief: SightBrief
    let markedHs: Double
    let onDone: (Double, Bool) -> Void
    let onBack: () -> Void

    @State private var step: Int = 0
    @State private var clean: Bool = true
    @State private var message: String? = nil
    @State private var running: Double = 0

    private var steps: [ReduceStep] {
        var s: [ReduceStep] = [.indexError, .dip, .refraction]
        if brief.kind.hasLimb { s.append(.semiDiameter) }
        s.append(.result)
        return s
    }

    private var current: ReduceStep { steps[min(step, steps.count - 1)] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: "Working the sight", onBack: onBack)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Step \(min(step + 1, steps.count)) of \(steps.count)".uppercased())
                        .font(SeaFont.body(11)).tracking(1.8)
                        .foregroundColor(Sea.inkPale)
                    ProgressBarline(fraction: Double(step) / Double(max(1, steps.count - 1)))
                }

                SeaCard(tone: Sea.cardSunk) {
                    HStack {
                        Text("Standing at".uppercased())
                            .font(SeaFont.body(11)).tracking(1.6)
                            .foregroundColor(Sea.inkPale)
                        Spacer()
                        Text(formatAngle(running))
                            .font(SeaFont.mono(21))
                            .foregroundColor(Sea.ink)
                    }
                }

                Text(current.title)
                    .font(SeaFont.title(25))
                    .foregroundColor(Sea.ink)

                switch current {
                case .indexError: indexStep
                case .dip: dipStep
                case .refraction: refractionStep
                case .semiDiameter: limbStep
                case .result: resultStep
                }

                if let m = message {
                    SeaCard(tone: Sea.oxblood.opacity(0.10)) {
                        Text(m)
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.oxblood)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if step > 0 && current != .result {
                    SeaButton(title: "Back a step", kind: .quiet) {
                        step = max(0, step - 1)
                        recompute()
                        message = nil
                    }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .centreColumn()
        .onAppear { running = markedHs }
    }

    private func recompute() {
        var v = markedHs
        let done = steps.prefix(step)
        if done.contains(.indexError) { v -= brief.signedIndexError / 60.0 }
        if done.contains(.dip) { v -= brief.deck.dip / 60.0 }
        if done.contains(.refraction) {
            let ha = brief.apparentAltitude(fromHs: markedHs)
            v -= refractionBand(for: ha).minutes / 60.0
        }
        if done.contains(.semiDiameter) && brief.kind.hasLimb {
            let sd = brief.kind.semiDiameter / 60.0
            v += (brief.limb == .lower ? sd : -sd)
        }
        running = v
    }

    private func advance() {
        message = nil
        step += 1
        recompute()
    }

    private func wrong(_ text: String) {
        clean = false
        message = text
    }

    private var indexStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            explain("Before you trust a single reading, you must know what your own instrument says when it should say nothing. This one reads "
                    + formatMinutes(brief.indexErrorMinutes)
                    + (brief.indexOnArc ? " on the arc." : " off the arc."))

            choice(brief.indexOnArc ? "Subtract \(formatMinutes(brief.indexErrorMinutes))"
                                    : "Add \(formatMinutes(brief.indexErrorMinutes))",
                   "The right way") {
                advance()
            }
            choice(brief.indexOnArc ? "Add \(formatMinutes(brief.indexErrorMinutes))"
                                    : "Subtract \(formatMinutes(brief.indexErrorMinutes))",
                   "The other way") {
                wrong(brief.indexOnArc
                      ? "On the arc means the sextant reads too much. What it gives you in error you must take back off. Subtract it."
                      : "Off the arc means the sextant reads too little. You have to give the error back. Add it.")
            }
        }
    }

    private var dipStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            explain("Your eye is above the sea, so the horizon you can see has dropped below the true level. The higher you stood, the more it drops. Where did you take the sight from?")
            ForEach(Array(deckHeights.enumerated()), id: \.offset) { idx, deck in
                choice(deck.name + " — " + String(format: "%.0f m", deck.metres),
                       String(format: "dip %.1f'", deck.dip)) {
                    if idx == brief.deckIndex {
                        advance()
                    } else {
                        wrong("You were on the " + brief.deck.name.lowercased()
                              + ". Choosing the wrong height puts "
                              + formatMinutes(abs(deck.dip - brief.deck.dip))
                              + " of error into every sight from that station.")
                    }
                }
            }
            SeaCard(tone: Sea.brass.opacity(0.10)) {
                Text("Dip in minutes = 1.76 × the square root of your height in metres. It is always taken off.")
                    .font(SeaFont.body(14))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var refractionStep: some View {
        let ha = brief.apparentAltitude(fromHs: markedHs)
        let right = refractionBand(for: ha)
        return VStack(alignment: .leading, spacing: 12) {
            explain(String(format: "The air lifts the body. Your apparent altitude stands at %@. Find the band it falls in and take that much off.", formatAngle(ha)))
            ForEach(Array(refractionBands.enumerated()), id: \.offset) { _, band in
                choice(band.label, String(format: "take off %.1f'", band.minutes)) {
                    if abs(band.minutes - right.minutes) < 0.01 {
                        advance()
                    } else {
                        wrong("Your apparent altitude is " + formatAngle(ha)
                              + ", which falls in the band " + right.label + ".")
                    }
                }
            }
        }
    }

    private var limbStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            explain("You cannot lay the middle of a disc on the horizon, so you brought down "
                    + brief.limb.display.lowercased()
                    + ". The centre is half a diameter away — "
                    + formatMinutes(brief.kind.semiDiameter) + ".")
            choice(brief.limb == .lower ? "Add \(formatMinutes(brief.kind.semiDiameter))"
                                        : "Subtract \(formatMinutes(brief.kind.semiDiameter))",
                   "The right way") {
                advance()
            }
            choice(brief.limb == .lower ? "Subtract \(formatMinutes(brief.kind.semiDiameter))"
                                        : "Add \(formatMinutes(brief.kind.semiDiameter))",
                   "The other way") {
                wrong(brief.limb == .lower
                      ? "The lower edge sits below the centre, so the centre is higher. Add the half-diameter."
                      : "The upper edge sits above the centre, so the centre is lower. Subtract the half-diameter.")
            }
        }
    }

    private var resultStep: some View {
        VStack(alignment: .leading, spacing: 14) {
            SeaCard {
                VStack(spacing: 11) {
                    line("Sextant altitude", formatAngle(markedHs))
                    RuleLine()
                    line("Index error",
                         (brief.indexOnArc ? "− " : "+ ") + formatMinutes(brief.indexErrorMinutes))
                    RuleLine()
                    line("Dip", "− " + formatMinutes(brief.deck.dip))
                    RuleLine()
                    line("Refraction", "− " + formatMinutes(
                        refractionBand(for: brief.apparentAltitude(fromHs: markedHs)).minutes))
                    if brief.kind.hasLimb {
                        RuleLine()
                        line("Semi-diameter",
                             (brief.limb == .lower ? "+ " : "− ")
                             + formatMinutes(brief.kind.semiDiameter))
                    }
                    RuleLine()
                    HStack {
                        Text("Observed altitude".uppercased())
                            .font(SeaFont.title(12)).tracking(1.8)
                            .foregroundColor(Sea.ink)
                        Spacer()
                        Text(formatAngle(brief.observedAltitude(fromHs: markedHs)))
                            .font(SeaFont.mono(20))
                            .foregroundColor(Sea.brass)
                    }
                }
            }

            SeaCard(tone: Sea.cardSunk) {
                Text(clean
                     ? "Clean through. Every correction went the way it should, first time."
                     : "Worked through in the end. The corrections are worth learning by heart — at sea nobody hands you the answer.")
                    .font(SeaFont.body(15))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SeaButton(title: "Take it to the chart") {
                onDone(brief.observedAltitude(fromHs: markedHs), clean)
            }
            SeaButton(title: "Work it through again", kind: .quiet) {
                step = 0
                message = nil
                recompute()
            }
        }
    }

    private func line(_ k: String, _ v: String) -> some View {
        HStack {
            Text(k.uppercased())
                .font(SeaFont.body(11)).tracking(1.6)
                .foregroundColor(Sea.inkPale)
            Spacer()
            Text(v).font(SeaFont.mono(15)).foregroundColor(Sea.inkSoft)
        }
    }

    private func explain(_ text: String) -> some View {
        Text(text)
            .font(SeaFont.body(16))
            .foregroundColor(Sea.inkSoft)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func choice(_ title: String, _ sub: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(SeaFont.title(16))
                        .foregroundColor(Sea.ink)
                    Text(sub.uppercased())
                        .font(SeaFont.body(10)).tracking(1.5)
                        .foregroundColor(Sea.inkPale)
                }
                Spacer()
                ChevronMark(size: 15)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 11).fill(Sea.card))
            .overlay(RoundedRectangle(cornerRadius: 11).stroke(Sea.ink.opacity(0.18), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
