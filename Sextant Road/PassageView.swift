import SwiftUI

struct PassageListView: View {
    @EnvironmentObject var store: SeaStore
    @State private var open: Voyage? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passages")
                        .font(SeaFont.title(29))
                        .foregroundColor(Sea.ink)
                    Text("Eight roads across the water, each one worked day by day")
                        .font(SeaFont.italic(15))
                        .foregroundColor(Sea.inkPale)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 12)

                HStack {
                    StatBlock(value: "\(store.voyagesFinished)/\(voyages.count)", caption: "passages made")
                    StatBlock(value: "\(store.totalFixes)", caption: "fixes worked", tone: Sea.brass)
                }
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Sea.card))

                ForEach(voyages) { voyage in
                    Button(action: { open = voyage }) {
                        voyageRow(voyage)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
        .centreColumn()
        .fullScreenCover(item: $open) { voyage in
            VoyageView(voyage: voyage) { open = nil }
                .environmentObject(store)
        }
    }

    private func voyageRow(_ v: Voyage) -> some View {
        let st = store.state(for: v.slug)
        let fraction = Double(st.day) / Double(v.days.count)
        return VStack(alignment: .leading, spacing: 0) {
            Plate(name: v.vignettePlate, corner: 0)
                .frame(height: SeaMetrics.isPad ? 190 : 132)
            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(v.name)
                            .font(SeaFont.title(19))
                            .foregroundColor(Sea.ink)
                            .multilineTextAlignment(.leading)
                        Text(v.subtitle + " · " + v.era)
                            .font(SeaFont.body(13))
                            .foregroundColor(Sea.inkPale)
                    }
                    Spacer(minLength: 8)
                    if st.finished {
                        Chip(text: "Made", tone: Sea.moss, solid: true)
                    } else if st.day > 0 {
                        Chip(text: "Day \(st.day + 1)", tone: Sea.brass)
                    }
                }
                ProgressBarline(fraction: fraction,
                                tone: st.finished ? Sea.moss : Sea.brass)
                HStack {
                    Text("\(v.miles) nautical miles".uppercased())
                        .font(SeaFont.body(10)).tracking(1.4)
                        .foregroundColor(Sea.inkPale)
                    Spacer()
                    Text("\(min(st.day, v.days.count)) of \(v.days.count) days".uppercased())
                        .font(SeaFont.body(10)).tracking(1.4)
                        .foregroundColor(Sea.inkPale)
                }
            }
            .padding(14)
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Sea.card))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Sea.ink.opacity(0.18), lineWidth: 1))
    }
}

struct VoyageView: View {
    let voyage: Voyage
    let onClose: () -> Void

    @EnvironmentObject var store: SeaStore
    @State private var dayOpen: Bool = false
    @State private var showChart: Bool = false

    private var st: VoyageState { store.state(for: voyage.slug) }
    private var dayIndex: Int { min(st.day, voyage.days.count - 1) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: "Passages", onBack: onClose)

                Button(action: { showChart = true }) {
                    ZStack(alignment: .bottomTrailing) {
                        Plate(name: voyage.chartPlate)
                            .frame(height: SeaMetrics.isPad ? 320 : 210)
                        Text("Open the chart".uppercased())
                            .font(SeaFont.title(10)).tracking(1.6)
                            .foregroundColor(Sea.card)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Capsule().fill(Sea.ink.opacity(0.78)))
                            .padding(10)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(voyage.name)
                        .font(SeaFont.title(27))
                        .foregroundColor(Sea.ink)
                    Text(voyage.subtitle + " · " + voyage.era + " · \(voyage.miles) nm")
                        .font(SeaFont.body(13))
                        .foregroundColor(Sea.inkPale)
                }

                SeaCard {
                    Text(st.finished ? voyage.arrival : voyage.opening)
                        .font(SeaFont.body(16))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if st.finished {
                    SeaCard(tone: Sea.moss.opacity(0.12)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                AnchorGlyph(size: 20, colour: Sea.moss)
                                Text("Passage made".uppercased())
                                    .font(SeaFont.title(13)).tracking(2.0)
                                    .foregroundColor(Sea.moss)
                            }
                            Text(String(format: "Best fix of the passage: %.1f nautical miles from the true position.",
                                        st.bestFixMiles))
                                .font(SeaFont.body(15))
                                .foregroundColor(Sea.inkSoft)
                        }
                    }
                    SeaButton(title: "Sail it again", kind: .secondary) {
                        store.setState(voyage.slug,
                                       VoyageState(day: 0, finished: false,
                                                   bestFixMiles: st.bestFixMiles,
                                                   fixesMade: st.fixesMade))
                    }
                } else {
                    SectionHead(text: "Today's work")
                    SeaCard(tone: Sea.brass.opacity(0.10)) {
                        VStack(alignment: .leading, spacing: 9) {
                            Text(voyage.days[dayIndex].title)
                                .font(SeaFont.title(18))
                                .foregroundColor(Sea.ink)
                            Text(voyage.days[dayIndex].narration)
                                .font(SeaFont.body(15))
                                .foregroundColor(Sea.inkSoft)
                                .fixedSize(horizontal: false, vertical: true)
                            SeaButton(title: "Go on deck") { dayOpen = true }
                        }
                    }
                }

                SectionHead(text: "The passage log")
                VStack(spacing: 8) {
                    ForEach(Array(voyage.days.enumerated()), id: \.offset) { idx, day in
                        HStack(alignment: .top, spacing: 11) {
                            ZStack {
                                Circle()
                                    .fill(idx < st.day ? Sea.moss : (idx == st.day && !st.finished ? Sea.brass : Sea.ink.opacity(0.14)))
                                    .frame(width: 11, height: 11)
                            }
                            .frame(width: 14)
                            .padding(.top, 5)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(day.title)
                                    .font(SeaFont.title(14))
                                    .foregroundColor(idx <= st.day || st.finished ? Sea.ink : Sea.inkPale)
                                if idx < st.day || st.finished {
                                    Text(day.narration)
                                        .font(SeaFont.body(13))
                                        .foregroundColor(Sea.inkPale)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 9)
                        .padding(.horizontal, 12)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))
                    }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .seaPage()
        .centreColumn()
        .fullScreenCover(isPresented: $dayOpen) {
            VoyageDayView(voyage: voyage, dayIndex: dayIndex) { dayOpen = false }
                .environmentObject(store)
        }
        .sheet(isPresented: $showChart) {
            PlateZoomView(name: voyage.chartPlate, title: voyage.name,
                          subtitle: voyage.subtitle) { showChart = false }
        }
    }
}

struct VoyageDayView: View {
    let voyage: Voyage
    let dayIndex: Int
    let onClose: () -> Void

    @EnvironmentObject var store: SeaStore
    @State private var results: [SightResult] = []
    @State private var activeSlot: BriefRef? = nil
    @State private var showFix: Bool = false

    private var day: VoyageDay { voyage.days[dayIndex] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BackBar(title: voyage.name, onBack: onClose)

                VStack(alignment: .leading, spacing: 4) {
                    Text(day.title)
                        .font(SeaFont.title(25))
                        .foregroundColor(Sea.ink)
                    Text("Three sights make a fix".uppercased())
                        .font(SeaFont.body(11)).tracking(1.8)
                        .foregroundColor(Sea.inkPale)
                }

                SeaCard {
                    Text(day.narration)
                        .font(SeaFont.body(16))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionHead(text: "The round of sights")
                VStack(spacing: 9) {
                    ForEach(0..<3, id: \.self) { slot in
                        slotRow(slot)
                    }
                }

                if results.count >= 3 {
                    SeaButton(title: "Work the fix") { showFix = true }
                } else {
                    SeaCard(tone: Sea.cardSunk) {
                        Text("Twilight will not wait. Take all three bodies before the horizon goes, and spread them round the compass so their lines cross at good angles.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SeaButton(title: "Back below", kind: .quiet, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
            .padding(.top, 10)
        }
        .seaPage()
        .centreColumn()
        .fullScreenCover(item: $activeSlot) { ref in
            SightSessionView(brief: ref.brief, contextLabel: day.title) { result in
                store.record(SightRecord(id: UUID().uuidString, body: ref.brief.bodyName,
                                         errorMinutes: result.errorMinutes,
                                         stars: result.stars,
                                         stamp: Double(dayIndex),
                                         voyage: voyage.slug,
                                         workedClean: result.workedClean))
                results.append(result)
                activeSlot = nil
            } onLeave: {
                activeSlot = nil
            }
        }
        .fullScreenCover(isPresented: $showFix) {
            FixView(voyage: voyage, dayIndex: dayIndex, results: results) {
                showFix = false
                onClose()
            } onStay: {
                showFix = false
            }
            .environmentObject(store)
        }
    }

    private func slotRow(_ slot: Int) -> some View {
        let brief = SightSeeds.brief(index: day.seeds[slot])
        let done = slot < results.count
        return Button(action: {
            if !done { activeSlot = BriefRef(id: slot, brief: brief) }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(done ? Sea.moss.opacity(0.16) : Sea.brass.opacity(0.16))
                        .frame(width: 38, height: 38)
                    if done {
                        TickMark(size: 18, colour: Sea.moss)
                    } else {
                        Text("\(slot + 1)")
                            .font(SeaFont.title(16))
                            .foregroundColor(Sea.brass)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(brief.bodyName)
                        .font(SeaFont.title(17))
                        .foregroundColor(Sea.ink)
                    Text(done
                         ? formatMinutes(abs(results[slot].errorMinutes)) + " out · "
                           + formatMiles(abs(results[slot].interceptMiles))
                           + (results[slot].interceptMiles >= 0 ? " toward" : " away")
                         : brief.azimuthName + " · " + String(format: "%.0f° azimuth", brief.azimuth))
                        .font(SeaFont.body(13))
                        .foregroundColor(Sea.inkPale)
                }
                Spacer(minLength: 0)
                if done {
                    StarRow(earned: results[slot].stars, size: 13)
                } else {
                    ChevronMark(size: 15)
                }
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 11).fill(Sea.card))
            .overlay(RoundedRectangle(cornerRadius: 11)
                        .stroke(Sea.ink.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FixView: View {
    let voyage: Voyage
    let dayIndex: Int
    let results: [SightResult]
    let onAdvance: () -> Void
    let onStay: () -> Void

    @EnvironmentObject var store: SeaStore
    @State private var recorded = false

    private var errors: [Double] { results.map { abs($0.errorMinutes) } }

    private var hatMiles: Double {
        guard !errors.isEmpty else { return 0 }
        let squares = errors.map { $0 * $0 }.reduce(0, +)
        return (squares / Double(errors.count)).squareRoot()
    }

    private var verdict: String {
        if hatMiles <= 1.2 {
            return "A hat you could cover with a thumbnail. That is a fix worth altering course on."
        }
        if hatMiles <= 3.0 {
            return "A respectable triangle. On a wide ocean this is all anyone asks for."
        }
        if hatMiles <= 7.0 {
            return "A loose hat. Usable at sea, but you would want it tighter before closing a coast in the dark."
        }
        return "A hat this size is a warning, not a position. Something went into these sights that should not have."
    }

    private var lastDay: Bool { dayIndex >= voyage.days.count - 1 }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("The fix")
                    .font(SeaFont.title(28))
                    .foregroundColor(Sea.ink)
                    .padding(.top, 16)

                CockedHatSheet(errors: errors)
                    .frame(height: SeaMetrics.isPad ? 380 : 290)

                SeaCard {
                    VStack(spacing: 11) {
                        ForEach(Array(results.enumerated()), id: \.offset) { idx, r in
                            HStack {
                                Text("Sight \(idx + 1)".uppercased())
                                    .font(SeaFont.body(11)).tracking(1.6)
                                    .foregroundColor(Sea.inkPale)
                                Spacer()
                                StarRow(earned: r.stars, size: 12)
                                Text(formatMinutes(abs(r.errorMinutes)))
                                    .font(SeaFont.mono(14))
                                    .foregroundColor(abs(r.errorMinutes) <= 3 ? Sea.moss : Sea.oxblood)
                                    .frame(width: 54, alignment: .trailing)
                            }
                            if idx < results.count - 1 { RuleLine() }
                        }
                    }
                }

                SeaCard(tone: Sea.brass.opacity(0.10)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cocked hat".uppercased())
                                .font(SeaFont.title(12)).tracking(2.0)
                                .foregroundColor(Sea.brass)
                            Spacer()
                            Text(formatMiles(hatMiles))
                                .font(SeaFont.mono(18))
                                .foregroundColor(Sea.ink)
                        }
                        Text(verdict)
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                SeaButton(title: lastDay ? "Make the landfall" : "Enter it and stand on") {
                    guard !recorded else { onAdvance(); return }
                    recorded = true
                    var st = store.state(for: voyage.slug)
                    st.fixesMade += 1
                    st.bestFixMiles = min(st.bestFixMiles, hatMiles)
                    st.day = min(st.day + 1, voyage.days.count)
                    if st.day >= voyage.days.count { st.finished = true }
                    store.setState(voyage.slug, st)
                    onAdvance()
                }
                SeaButton(title: "Look at it a moment longer", kind: .quiet, action: onStay)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 40)
        }
        .seaPage()
        .centreColumn()
    }
}

struct CockedHatSheet: View {
    let errors: [Double]

    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let rect = CGRect(origin: .zero, size: size)
                let w = rect.width, h = rect.height
                ctx.fill(Path(roundedRect: rect, cornerRadius: 12), with: .color(Sea.card))

                var grid = Path()
                for c in 1..<8 {
                    let x = w * CGFloat(c) / 8
                    grid.move(to: CGPoint(x: x, y: 8))
                    grid.addLine(to: CGPoint(x: x, y: h - 8))
                }
                for r in 1..<6 {
                    let y = h * CGFloat(r) / 6
                    grid.move(to: CGPoint(x: 8, y: y))
                    grid.addLine(to: CGPoint(x: w - 8, y: y))
                }
                ctx.stroke(grid, with: .color(Sea.ink.opacity(0.12)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 6]))

                let centre = CGPoint(x: w * 0.5, y: h * 0.5)
                let scale = min(w, h) * 0.030
                let angles: [Double] = [0.35, 2.30, 4.30]
                var corners: [CGPoint] = []

                for (idx, a) in angles.enumerated() {
                    let off = CGFloat(idx < errors.count ? errors[idx] : 0) * scale
                    let dirX = CGFloat(cos(a)), dirY = CGFloat(sin(a))
                    let px = centre.x + dirX * off
                    let py = centre.y + dirY * off
                    let perpX = -dirY, perpY = dirX
                    var lop = Path()
                    lop.move(to: CGPoint(x: px - perpX * w, y: py - perpY * w))
                    lop.addLine(to: CGPoint(x: px + perpX * w, y: py + perpY * w))
                    ctx.stroke(lop, with: .color(idx == 1 ? Sea.oxblood : Sea.ink),
                               style: StrokeStyle(lineWidth: 2.6))
                    corners.append(CGPoint(x: px, y: py))
                }

                if corners.count == 3 {
                    var tri = Path()
                    let a = intersect(corners[0], angles[0], corners[1], angles[1])
                    let b = intersect(corners[1], angles[1], corners[2], angles[2])
                    let c = intersect(corners[2], angles[2], corners[0], angles[0])
                    tri.move(to: a); tri.addLine(to: b); tri.addLine(to: c)
                    tri.closeSubpath()
                    ctx.fill(tri, with: .color(Sea.oxblood.opacity(0.18)))
                    ctx.stroke(tri, with: .color(Sea.oxblood.opacity(0.65)),
                               style: StrokeStyle(lineWidth: 1.8))

                    let fx = (a.x + b.x + c.x) / 3
                    let fy = (a.y + b.y + c.y) / 3
                    ctx.fill(Path(ellipseIn: CGRect(x: fx - 6, y: fy - 6, width: 12, height: 12)),
                             with: .color(Sea.ink))
                    ctx.stroke(Path(ellipseIn: CGRect(x: fx - 14, y: fy - 14,
                                                      width: 28, height: 28)),
                               with: .color(Sea.ink.opacity(0.5)),
                               style: StrokeStyle(lineWidth: 1.4))
                    ctx.draw(Text("THE FIX").font(SeaFont.title(11))
                                .foregroundColor(Sea.ink),
                             at: CGPoint(x: fx, y: fy + 26))
                }

                ctx.fill(Path(ellipseIn: CGRect(x: centre.x - 4, y: centre.y - 4,
                                                width: 8, height: 8)),
                         with: .color(Sea.moss))
                ctx.draw(Text("TRUE POSITION").font(SeaFont.body(10))
                            .foregroundColor(Sea.moss),
                         at: CGPoint(x: centre.x, y: centre.y - 18))
            }
            .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Sea.ink.opacity(0.20), lineWidth: 1))
        }
    }

    private func intersect(_ p1: CGPoint, _ a1: Double,
                           _ p2: CGPoint, _ a2: Double) -> CGPoint {
        let d1 = CGPoint(x: CGFloat(-sin(a1)), y: CGFloat(cos(a1)))
        let d2 = CGPoint(x: CGFloat(-sin(a2)), y: CGFloat(cos(a2)))
        let det = d1.x * (-d2.y) - (-d2.x) * d1.y
        guard abs(det) > 0.0001 else { return p1 }
        let rx = p2.x - p1.x, ry = p2.y - p1.y
        let t = (rx * (-d2.y) - (-d2.x) * ry) / det
        return CGPoint(x: p1.x + d1.x * t, y: p1.y + d1.y * t)
    }
}

struct PlateZoomView: View {
    let name: String
    let title: String
    let subtitle: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: title, subtitle: subtitle, onClose: onClose)
                .padding(.horizontal, SeaMetrics.gutter)
                .padding(.top, 18)
                .padding(.bottom, 12)
            ScrollView([.horizontal, .vertical]) {
                if let img = PlateStore.image(name) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width * 2.0)
                } else {
                    Text("The plate is not aboard.")
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkPale)
                        .padding(40)
                }
            }
            SeaButton(title: "Close", kind: .secondary, action: onClose)
                .padding(.horizontal, SeaMetrics.gutter)
                .padding(.vertical, 14)
        }
        .seaPage()
    }
}
