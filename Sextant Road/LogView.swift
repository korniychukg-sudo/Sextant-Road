import SwiftUI

struct LogView: View {
    @EnvironmentObject var store: SeaStore
    @State private var showAwards = false
    @State private var showAbout = false
    @State private var confirmReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("The Log")
                        .font(SeaFont.title(29))
                        .foregroundColor(Sea.ink)
                    Text("Every sight you have taken, and what it was worth")
                        .font(SeaFont.italic(15))
                        .foregroundColor(Sea.inkPale)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 12)

                SeaCard {
                    VStack(spacing: 14) {
                        HStack {
                            StatBlock(value: "\(store.totalSights)", caption: "sights")
                            StatBlock(value: store.bestErrorMinutes.map { formatMinutes($0) } ?? "—",
                                      caption: "best", tone: Sea.brass)
                            StatBlock(value: store.averageErrorMinutes.map { formatMinutes($0) } ?? "—",
                                      caption: "recent average")
                        }
                        RuleLine()
                        HStack {
                            StatBlock(value: "\(store.perfectSights)", caption: "three-star", tone: Sea.moss)
                            StatBlock(value: "\(store.voyagesFinished)", caption: "passages made")
                            StatBlock(value: "\(store.bodiesShot().count)", caption: "bodies shot")
                        }
                    }
                }

                Button(action: { showAwards = true }) {
                    HStack(spacing: 12) {
                        AnchorGlyph(size: 22, colour: Sea.brass)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Certificates")
                                .font(SeaFont.title(17))
                                .foregroundColor(Sea.ink)
                            Text("\(store.awards.count) of \(allAwards.count) earned")
                                .font(SeaFont.body(13))
                                .foregroundColor(Sea.inkPale)
                        }
                        Spacer()
                        ChevronMark(size: 15)
                    }
                    .padding(13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Sea.card))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Sea.ink.opacity(0.16), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())

                SectionHead(text: "Accuracy", trailing: "last 24 sights")
                AccuracyTrace(values: store.sights.suffix(24).map { abs($0.errorMinutes) })
                    .frame(height: 130)

                SectionHead(text: "The sight book")
                if store.sights.isEmpty {
                    SeaCard(tone: Sea.cardSunk) {
                        Text("The book is empty. Nothing goes into it until a sight has been taken, worked and plotted.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    VStack(spacing: 7) {
                        ForEach(store.sights.suffix(40).reversed()) { rec in
                            HStack(spacing: 10) {
                                StarRow(earned: rec.stars, size: 12)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(rec.body)
                                        .font(SeaFont.body(15))
                                        .foregroundColor(Sea.ink)
                                    if let v = rec.voyage,
                                       let voyage = voyages.first(where: { $0.slug == v }) {
                                        Text(voyage.name)
                                            .font(SeaFont.body(11))
                                            .foregroundColor(Sea.inkPale)
                                    }
                                }
                                Spacer(minLength: 0)
                                if rec.workedClean {
                                    Chip(text: "Clean", tone: Sea.moss)
                                }
                                Text(formatMinutes(abs(rec.errorMinutes)))
                                    .font(SeaFont.mono(14))
                                    .foregroundColor(abs(rec.errorMinutes) <= 3 ? Sea.moss : Sea.oxblood)
                                    .frame(width: 52, alignment: .trailing)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))
                        }
                    }
                }

                SectionHead(text: "This book")
                SeaButton(title: "About Sextant Road", kind: .secondary) { showAbout = true }
                SeaButton(title: confirmReset ? "Tap again to clear the log" : "Clear the log",
                          kind: .danger) {
                    if confirmReset {
                        store.resetProgress()
                        confirmReset = false
                    } else {
                        confirmReset = true
                    }
                }
                if confirmReset {
                    SeaButton(title: "Keep the log", kind: .quiet) { confirmReset = false }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
        .centreColumn()
        .sheet(isPresented: $showAwards) {
            AwardsView { showAwards = false }
                .environmentObject(store)
        }
        .sheet(isPresented: $showAbout) {
            AboutView { showAbout = false }
        }
    }
}

struct AccuracyTrace: View {
    let values: [Double]

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let rect = CGRect(origin: .zero, size: size)
                let w = rect.width, h = rect.height
                ctx.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(Sea.card))

                let bands: [(Double, Color)] = [(1.0, Sea.moss), (3.0, Sea.brass), (8.0, Sea.oxblood)]
                let maxV = 10.0
                for (v, colour) in bands {
                    let y = h - CGFloat(min(v, maxV) / maxV) * (h - 26) - 14
                    var line = Path()
                    line.move(to: CGPoint(x: 12, y: y))
                    line.addLine(to: CGPoint(x: w - 40, y: y))
                    ctx.stroke(line, with: .color(colour.opacity(0.42)),
                               style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                    ctx.draw(Text(String(format: "%.0f'", v))
                                .font(SeaFont.body(10))
                                .foregroundColor(colour.opacity(0.85)),
                             at: CGPoint(x: w - 20, y: y))
                }

                guard values.count > 0 else {
                    ctx.draw(Text("No sights yet")
                                .font(SeaFont.body(13))
                                .foregroundColor(Sea.inkPale),
                             at: CGPoint(x: w / 2, y: h / 2))
                    return
                }

                let step = values.count > 1 ? (w - 56) / CGFloat(values.count - 1) : 0
                var line = Path()
                for (i, v) in values.enumerated() {
                    let x = 12 + CGFloat(i) * step
                    let y = h - CGFloat(min(v, maxV) / maxV) * (h - 26) - 14
                    if i == 0 { line.move(to: CGPoint(x: x, y: y)) }
                    else { line.addLine(to: CGPoint(x: x, y: y)) }
                }
                ctx.stroke(line, with: .color(Sea.ink.opacity(0.75)),
                           style: StrokeStyle(lineWidth: 2, lineJoin: .round))

                for (i, v) in values.enumerated() {
                    let x = 12 + CGFloat(i) * step
                    let y = h - CGFloat(min(v, maxV) / maxV) * (h - 26) - 14
                    let colour: Color = v <= 1 ? Sea.moss : (v <= 3 ? Sea.brass : Sea.oxblood)
                    ctx.fill(Path(ellipseIn: CGRect(x: x - 3.5, y: y - 3.5,
                                                    width: 7, height: 7)),
                             with: .color(colour))
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Sea.ink.opacity(0.16), lineWidth: 1))
        }
    }
}

struct AwardsView: View {
    let onClose: () -> Void
    @EnvironmentObject var store: SeaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SheetHeader(title: "Certificates",
                            subtitle: "\(store.awards.count) of \(allAwards.count) earned",
                            onClose: onClose)
                    .padding(.top, 18)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: SeaMetrics.isPad ? 220 : 158),
                                             spacing: 10)], spacing: 10) {
                    ForEach(allAwards) { award in
                        let earned = store.awards.contains(award.slug)
                        VStack(alignment: .leading, spacing: 7) {
                            AnchorGlyph(size: 24,
                                        colour: earned ? Sea.brass : Sea.ink.opacity(0.22))
                            Text(award.name)
                                .font(SeaFont.title(15))
                                .foregroundColor(earned ? Sea.ink : Sea.inkPale)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                            Text(award.requirement)
                                .font(SeaFont.body(12))
                                .foregroundColor(Sea.inkPale)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12)
                                        .fill(earned ? Sea.card : Sea.cardSunk))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(earned ? Sea.brass.opacity(0.5) : Sea.ink.opacity(0.12),
                                            lineWidth: 1))
                    }
                }

                SeaButton(title: "Close", kind: .secondary, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
    }
}

struct AboutView: View {
    let onClose: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SheetHeader(title: "About Sextant Road", subtitle: "Version 1.0", onClose: onClose)
                    .padding(.top, 18)

                Plate(name: "inst_sextant")
                    .frame(height: SeaMetrics.isPad ? 300 : 200)

                Text("Sextant Road teaches the one skill that made oceans crossable: taking the height of a body above the horizon, correcting it honestly, and turning it into a line on a chart.")
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Every plate in the app — the star charts, the instrument plates, the expedition charts and the diagrams — is drawn by the app itself in pen, wash and hatching. Nothing is photographed and nothing is downloaded.")
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                Text("The app keeps no account, asks for no permissions and collects nothing about you. Your log lives on this device only.")
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SeaCard(tone: Sea.cardSunk) {
                    Text("The sights in this app are self-consistent exercises in method, not a nautical almanac. Real navigation needs real ephemeris data and a real horizon.")
                        .font(SeaFont.body(14))
                        .foregroundColor(Sea.inkPale)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SeaButton(title: "Close", kind: .secondary, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
    }
}
