import SwiftUI

struct FixPlotView: View {
    let round: WatchRound
    let solution: FixSolution
    let onDone: () -> Void

    @State private var reveal: Double = 0
    @State private var showTruth: Bool = false

    private var grade: FixGrade { gradeFix(errorMiles: solution.errorMiles,
                                           hatMiles: solution.hatMiles) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("The fix".uppercased())
                    .font(SeaFont.title(13)).tracking(2.6)
                    .foregroundColor(Sea.inkPale)
                    .padding(.top, 14)

                Text(grade.title)
                    .font(SeaFont.title(26))
                    .foregroundColor(Sea.ink)

                SeaCard(padding: 12) {
                    FixChart(round: round, solution: solution,
                             reveal: reveal, showTruth: showTruth)
                        .frame(height: SeaMetrics.isPad ? 420 : 300)
                }

                HStack(spacing: 10) {
                    StatBlock(value: formatMiles(solution.errorMiles), caption: "off the truth",
                              tone: solution.errorMiles <= 5 ? Sea.moss : Sea.oxblood)
                    StatBlock(value: formatMiles(solution.hatMiles), caption: "cocked hat",
                              tone: Sea.brass)
                    StatBlock(value: round.runLabel, caption: "run between sights")
                }
                .padding(.vertical, 6)

                SeaCard(tone: Sea.cardSunk) {
                    Text(grade.note)
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionHead(text: "The three lines")
                VStack(spacing: 8) {
                    ForEach(Array(solution.lines.enumerated()), id: \.offset) { pair in
                        HStack {
                            Text(pair.element.bodyName)
                                .font(SeaFont.body(15))
                                .foregroundColor(Sea.ink)
                            Spacer()
                            Text(String(format: "Zn %03.0f°", pair.element.azimuth))
                                .font(SeaFont.mono(13))
                                .foregroundColor(Sea.inkPale)
                            Text(String(format: "%+.1f nm", pair.element.intercept))
                                .font(SeaFont.mono(14))
                                .foregroundColor(Sea.wave)
                                .frame(width: 74, alignment: .trailing)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 13)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))
                    }
                }

                SeaCard(tone: Sea.brass.opacity(0.10)) {
                    Text("Each line was advanced along \(round.runLabel) for the time between its sight and the fix. That advance is what turns three separate observations into one position.")
                        .font(SeaFont.body(14))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SeaButton(title: showTruth ? "Hide the true position" : "Show the true position",
                          kind: .secondary) {
                    withAnimation(.easeInOut(duration: 0.35)) { showTruth.toggle() }
                }
                SeaButton(title: "Enter it in the log") { onDone() }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
        }
        .seaPage()
        .centreColumn()
        .onAppear {
            withAnimation(.easeOut(duration: 1.1)) { reveal = 1 }
        }
    }
}

struct FixChart: View {
    let round: WatchRound
    let solution: FixSolution
    var reveal: Double
    var showTruth: Bool

    private var scale: Double {
        var extent = 8.0
        for line in solution.lines {
            extent = max(extent, abs(line.intercept) + 4)
            extent = max(extent, (line.advanceNorth * line.advanceNorth
                                  + line.advanceEast * line.advanceEast).squareRoot() + 3)
        }
        extent = max(extent, abs(round.drNorthOffset) + 4)
        extent = max(extent, abs(round.drEastOffset) + 4)
        extent = max(extent, solution.errorMiles + 5)
        return extent
    }

    var body: some View {
        Canvas { ctx, size in
            let rect = CGRect(origin: .zero, size: size)
            let cx = rect.midX, cy = rect.midY
            let radius = min(rect.width, rect.height) * 0.44
            let k = radius / CGFloat(scale)

            func place(_ north: Double, _ east: Double) -> CGPoint {
                CGPoint(x: cx + CGFloat(east) * k, y: cy - CGFloat(north) * k)
            }

            ctx.fill(Path(rect), with: .color(Sea.paperDeep))

            let step = max(2.0, (scale / 4).rounded())
            var g = 0.0
            while g <= scale {
                let rr = CGFloat(g) * k
                if rr > 2 {
                    ctx.stroke(Path(ellipseIn: CGRect(x: cx - rr, y: cy - rr,
                                                      width: rr * 2, height: rr * 2)),
                               with: .color(Sea.ink.opacity(0.10)),
                               style: StrokeStyle(lineWidth: 1, dash: [3, 5]))
                }
                g += step
            }
            for a in stride(from: 0.0, to: 360.0, by: 45.0) {
                let rad = a * .pi / 180
                var spoke = Path()
                spoke.move(to: CGPoint(x: cx, y: cy))
                spoke.addLine(to: CGPoint(x: cx + CGFloat(sin(rad)) * radius,
                                          y: cy - CGFloat(cos(rad)) * radius))
                ctx.stroke(spoke, with: .color(Sea.ink.opacity(0.07)),
                           style: StrokeStyle(lineWidth: 1))
            }

            let drPoint = place(round.drNorthOffset, round.drEastOffset)
            let runEnd = place(round.drNorthOffset - solution.lines[0].advanceNorth,
                               round.drEastOffset - solution.lines[0].advanceEast)
            var track = Path()
            track.move(to: runEnd)
            track.addLine(to: drPoint)
            ctx.stroke(track, with: .color(Sea.inkPale.opacity(0.62)),
                       style: StrokeStyle(lineWidth: 1.6, dash: [6, 4]))

            let tones = [Sea.wave, Sea.oxblood, Sea.moss]
            for (i, line) in solution.lines.enumerated() {
                let rad = line.azimuth * .pi / 180
                let un = cos(rad), ue = sin(rad)
                let d = lineOffset(round: round, line: line)
                let footN = un * d, footE = ue * d
                let along = scale * 1.4
                let a = place(footN - ue * along, footE + un * along)
                let b = place(footN + ue * along, footE - un * along)
                let mid = CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
                let ta = CGPoint(x: mid.x + (a.x - mid.x) * CGFloat(reveal),
                                 y: mid.y + (a.y - mid.y) * CGFloat(reveal))
                let tb = CGPoint(x: mid.x + (b.x - mid.x) * CGFloat(reveal),
                                 y: mid.y + (b.y - mid.y) * CGFloat(reveal))
                var lop = Path()
                lop.move(to: ta)
                lop.addLine(to: tb)
                ctx.stroke(lop, with: .color(tones[i % tones.count]),
                           style: StrokeStyle(lineWidth: 2.4, lineCap: .round))

                var arrow = Path()
                let foot = place(footN, footE)
                arrow.move(to: CGPoint(x: cx, y: cy))
                arrow.addLine(to: foot)
                ctx.stroke(arrow, with: .color(tones[i % tones.count].opacity(0.34)),
                           style: StrokeStyle(lineWidth: 1.2, dash: [2, 4]))
            }

            let fix = place(solution.north, solution.east)
            let fr: CGFloat = 7
            ctx.stroke(Path(ellipseIn: CGRect(x: fix.x - fr, y: fix.y - fr,
                                              width: fr * 2, height: fr * 2)),
                       with: .color(Sea.ink), style: StrokeStyle(lineWidth: 2.4))
            var cross = Path()
            cross.move(to: CGPoint(x: fix.x - fr * 1.9, y: fix.y))
            cross.addLine(to: CGPoint(x: fix.x + fr * 1.9, y: fix.y))
            cross.move(to: CGPoint(x: fix.x, y: fix.y - fr * 1.9))
            cross.addLine(to: CGPoint(x: fix.x, y: fix.y + fr * 1.9))
            ctx.stroke(cross, with: .color(Sea.ink), style: StrokeStyle(lineWidth: 1.4))

            if showTruth {
                let truth = place(0, 0)
                let tr: CGFloat = 9
                ctx.fill(Path(ellipseIn: CGRect(x: truth.x - 3.5, y: truth.y - 3.5,
                                                width: 7, height: 7)),
                         with: .color(Sea.brass))
                ctx.stroke(Path(ellipseIn: CGRect(x: truth.x - tr, y: truth.y - tr,
                                                  width: tr * 2, height: tr * 2)),
                           with: .color(Sea.brass), style: StrokeStyle(lineWidth: 1.8))
                var link = Path()
                link.move(to: truth)
                link.addLine(to: fix)
                ctx.stroke(link, with: .color(Sea.brass.opacity(0.70)),
                           style: StrokeStyle(lineWidth: 1.4, dash: [4, 3]))
            }
        }
        .background(Sea.paperDeep)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Sea.ink.opacity(0.24), lineWidth: 1))
    }
}
