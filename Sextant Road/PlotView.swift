import SwiftUI

struct PlotView: View {
    let brief: SightBrief
    let observedHo: Double
    let interceptMiles: Double
    let onDone: () -> Void
    let onBack: () -> Void

    @State private var placed: Double = 0
    @State private var base: Double = 0
    @State private var ruled: Bool = false

    private var toward: Bool { interceptMiles >= 0 }
    private var target: Double { abs(interceptMiles) }
    private var withinTolerance: Bool { abs(placed - target) <= 1.2 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: "The plotting sheet", onBack: onBack)

                SeaCard {
                    VStack(spacing: 11) {
                        row("Observed altitude", formatAngle(observedHo), Sea.ink)
                        RuleLine()
                        row("Computed altitude", formatAngle(brief.computedAltitude), Sea.inkSoft)
                        RuleLine()
                        row("Difference",
                            formatMinutes(abs(interceptMiles)) + (toward ? " greater" : " less"),
                            Sea.brass)
                    }
                }

                SeaCard(tone: Sea.brass.opacity(0.10)) {
                    Text(toward
                         ? "Your altitude is the greater, so you are nearer the body than the assumed position. Step toward it — one nautical mile for every minute."
                         : "Your altitude is the lesser, so you are further from the body than the assumed position. Step away from it — one nautical mile for every minute.")
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionHead(text: "Step off the intercept",
                            trailing: brief.azimuthName + " " + String(format: "%.0f°", brief.azimuth))

                PlotSheet(azimuth: brief.azimuth, toward: toward, target: target,
                          placed: placed, ruled: ruled, correct: withinTolerance)
                    .frame(height: SeaMetrics.isPad ? 420 : 320)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                if g.translation == .zero { base = placed }
                                let d = Double(g.translation.width) + Double(-g.translation.height)
                                placed = max(0, min(target + 20, base + d * 0.09))
                            }
                            .onEnded { _ in base = placed }
                    )

                HStack {
                    Text("Stepped off".uppercased())
                        .font(SeaFont.body(11)).tracking(1.6)
                        .foregroundColor(Sea.inkPale)
                    Spacer()
                    Text(formatMiles(placed) + (toward ? " toward" : " away"))
                        .font(SeaFont.mono(19))
                        .foregroundColor(withinTolerance ? Sea.moss : Sea.ink)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))

                if !ruled {
                    if withinTolerance {
                        SeaButton(title: "Rule the line") {
                            withAnimation(.easeOut(duration: 0.4)) { ruled = true }
                        }
                    } else {
                        SeaCard(tone: Sea.cardSunk) {
                            Text("Drag along the sheet until the marker stands "
                                 + formatMiles(target) + " from the assumed position.")
                                .font(SeaFont.body(15))
                                .foregroundColor(Sea.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        SeaButton(title: "Step it off for me", kind: .secondary) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                placed = target
                                base = target
                            }
                        }
                    }
                } else {
                    SeaCard(tone: Sea.cardSunk) {
                        Text("There is your line of position. You are somewhere on it — this sight alone cannot say where. Two more will pin it down.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    SeaButton(title: "Close the sight", action: onDone)
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .centreColumn()
    }

    private func row(_ k: String, _ v: String, _ tone: Color) -> some View {
        HStack {
            Text(k.uppercased())
                .font(SeaFont.body(11)).tracking(1.6)
                .foregroundColor(Sea.inkPale)
            Spacer()
            Text(v).font(SeaFont.mono(17)).foregroundColor(tone)
        }
    }
}

struct PlotSheet: View {
    let azimuth: Double
    let toward: Bool
    let target: Double
    let placed: Double
    let ruled: Bool
    let correct: Bool

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let rect = CGRect(origin: .zero, size: size)
                let w = rect.width, h = rect.height
                ctx.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(Sea.card))

                var grid = Path()
                let cols = 8, rows = 7
                for c in 1..<cols {
                    let x = w * CGFloat(c) / CGFloat(cols)
                    grid.move(to: CGPoint(x: x, y: 8))
                    grid.addLine(to: CGPoint(x: x, y: h - 8))
                }
                for r in 1..<rows {
                    let y = h * CGFloat(r) / CGFloat(rows)
                    grid.move(to: CGPoint(x: 8, y: y))
                    grid.addLine(to: CGPoint(x: w - 8, y: y))
                }
                ctx.stroke(grid, with: .color(Sea.ink.opacity(0.13)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 6]))

                let ap = CGPoint(x: w * 0.34, y: h * 0.66)
                let span = max(12.0, max(target, placed) * 1.5)
                let scale: CGFloat = min(w, h) * 0.34 / CGFloat(span)

                let bearing = azimuth * .pi / 180.0
                let dirX = CGFloat(sin(bearing))
                let dirY = CGFloat(-cos(bearing))
                let stepX = toward ? dirX : -dirX
                let stepY = toward ? dirY : -dirY

                var azLine = Path()
                azLine.move(to: CGPoint(x: ap.x - dirX * w, y: ap.y - dirY * w))
                azLine.addLine(to: CGPoint(x: ap.x + dirX * w, y: ap.y + dirY * w))
                ctx.stroke(azLine, with: .color(Sea.inkSoft.opacity(0.55)),
                           style: StrokeStyle(lineWidth: 1.6, dash: [8, 6]))

                var arrow = Path()
                let tipX = ap.x + dirX * min(w, h) * 0.40
                let tipY = ap.y + dirY * min(w, h) * 0.40
                arrow.move(to: CGPoint(x: tipX, y: tipY))
                arrow.addLine(to: CGPoint(x: tipX - dirX * 16 - dirY * 8,
                                          y: tipY - dirY * 16 + dirX * 8))
                arrow.move(to: CGPoint(x: tipX, y: tipY))
                arrow.addLine(to: CGPoint(x: tipX - dirX * 16 + dirY * 8,
                                          y: tipY - dirY * 16 - dirX * 8))
                ctx.stroke(arrow, with: .color(Sea.inkSoft.opacity(0.75)),
                           style: StrokeStyle(lineWidth: 2, lineCap: .round))
                ctx.draw(Text("TO THE BODY")
                            .font(SeaFont.body(10))
                            .foregroundColor(Sea.inkPale),
                         at: CGPoint(x: tipX, y: tipY - 16))

                let mark = CGPoint(x: ap.x + stepX * CGFloat(placed) * scale,
                                   y: ap.y + stepY * CGFloat(placed) * scale)

                var stepLine = Path()
                stepLine.move(to: ap)
                stepLine.addLine(to: mark)
                ctx.stroke(stepLine, with: .color(Sea.oxblood),
                           style: StrokeStyle(lineWidth: 4, lineCap: .round))

                ctx.fill(Path(ellipseIn: CGRect(x: ap.x - 6, y: ap.y - 6,
                                                width: 12, height: 12)),
                         with: .color(Sea.ink))
                ctx.stroke(Path(ellipseIn: CGRect(x: ap.x - 13, y: ap.y - 13,
                                                  width: 26, height: 26)),
                           with: .color(Sea.ink.opacity(0.45)),
                           style: StrokeStyle(lineWidth: 1.4))
                ctx.draw(Text("AP")
                            .font(SeaFont.title(12))
                            .foregroundColor(Sea.ink),
                         at: CGPoint(x: ap.x - 22, y: ap.y + 20))

                ctx.fill(Path(ellipseIn: CGRect(x: mark.x - 7, y: mark.y - 7,
                                                width: 14, height: 14)),
                         with: .color(correct ? Sea.moss : Sea.oxblood))

                if ruled {
                    let px = -stepY, py = stepX
                    var lop = Path()
                    lop.move(to: CGPoint(x: mark.x - px * w, y: mark.y - py * w))
                    lop.addLine(to: CGPoint(x: mark.x + px * w, y: mark.y + py * w))
                    ctx.stroke(lop, with: .color(Sea.ink),
                               style: StrokeStyle(lineWidth: 3.4))
                    ctx.draw(Text("LINE OF POSITION")
                                .font(SeaFont.title(10))
                                .foregroundColor(Sea.ink),
                             at: CGPoint(x: mark.x + px * 84, y: mark.y + py * 84 - 12))
                }

                var scaleBar = Path()
                let by = h - 20
                scaleBar.move(to: CGPoint(x: 18, y: by))
                scaleBar.addLine(to: CGPoint(x: 18 + scale * 10, y: by))
                ctx.stroke(scaleBar, with: .color(Sea.ink.opacity(0.7)),
                           style: StrokeStyle(lineWidth: 2.4))
                ctx.draw(Text("10 nm")
                            .font(SeaFont.body(10))
                            .foregroundColor(Sea.inkPale),
                         at: CGPoint(x: 18 + scale * 10 + 26, y: by))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Sea.ink.opacity(0.22), lineWidth: 1)
            )
        }
    }
}
