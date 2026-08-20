import SwiftUI

struct LegRef: Identifiable {
    let id: Int
    let leg: RoundLeg
}

struct TodayView: View {
    @EnvironmentObject var store: SeaStore

    @State private var now: Date = Date()
    @State private var errors: [Double] = []
    @State private var activeLeg: LegRef? = nil
    @State private var solution: FixSolution? = nil
    @State private var showPlot: Bool = false
    @State private var appeared: Bool = false

    private let clock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var day: Int { SeaDay.index(for: now) }
    private var round: WatchRound { WatchSeeds.round(day: day) }
    private var done: RoundRecord? { store.round(for: day) }
    private var standing: (rank: SeaRank, next: SeaRank?, progress: Double) {
        rankFor(points: store.seaPoints)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                RisingCard(index: 0) { scene }
                RisingCard(index: 1) { heading }
                RisingCard(index: 2) {
                    if let rec = done { finishedCard(rec) } else { roundCard }
                }
                RisingCard(index: 3) { standingCard }
                if !store.rounds.isEmpty {
                    RisingCard(index: 4) { historyCard }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
        .centreColumn()
        .onReceive(clock) { t in now = t }
        .onAppear {
            now = Date()
            if !appeared {
                appeared = true
                withAnimation(.easeOut(duration: 0.5)) { }
            }
        }
        .fullScreenCover(item: $activeLeg) { ref in
            SightSessionView(brief: ref.leg.brief,
                             contextLabel: legLabel(ref.id)) { result in
                var next = errors
                while next.count <= ref.id { next.append(0) }
                next[ref.id] = result.errorMinutes
                errors = next
                store.record(SightRecord(id: UUID().uuidString,
                                         body: ref.leg.brief.bodyName,
                                         errorMinutes: result.errorMinutes,
                                         stars: result.stars,
                                         stamp: Double(day),
                                         voyage: "watch",
                                         workedClean: result.workedClean))
                activeLeg = nil
                SeaFeel.land(result.stars)
                if errors.count >= round.legs.count && !errors.isEmpty {
                    finishRound()
                }
            } onLeave: {
                activeLeg = nil
            }
        }
        .fullScreenCover(isPresented: $showPlot) {
            if let sol = solution {
                FixPlotView(round: round, solution: sol) {
                    let rec = RoundRecord(id: UUID().uuidString, dayIndex: day,
                                          errorMiles: sol.errorMiles,
                                          hatMiles: sol.hatMiles,
                                          stars: gradeFix(errorMiles: sol.errorMiles,
                                                          hatMiles: sol.hatMiles).stars,
                                          bodies: round.legs.map { $0.brief.bodyName })
                    store.recordRound(rec)
                    showPlot = false
                    errors = []
                }
            }
        }
    }

    private func legLabel(_ index: Int) -> String {
        "Sight \(index + 1) of \(round.legs.count)"
    }

    private func finishRound() {
        let lines = linesFor(round: round, sightErrors: errors)
        solution = solveFix(round: round, lines: lines)
        showPlot = true
    }

    private var scene: some View {
        ZStack(alignment: .bottomLeading) {
            HorizonScene(hour: SeaDay.hour(for: now),
                         swell: 0.4 + Double(abs(day) % 5) * 0.16,
                         seed: day)
                .frame(height: SeaMetrics.isPad ? 230 : 168)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Sea.ink.opacity(0.28), lineWidth: 1))

            HStack(spacing: 8) {
                Text(moodFor(hour: SeaDay.hour(for: now)).caption.uppercased())
                    .font(SeaFont.title(11)).tracking(1.8)
                    .foregroundColor(.white.opacity(0.92))
                Text(String(format: "%02d%02d", Int(SeaDay.hour(for: now)),
                            Int((SeaDay.hour(for: now).truncatingRemainder(dividingBy: 1)) * 60)))
                    .font(SeaFont.mono(12))
                    .foregroundColor(.white.opacity(0.78))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.black.opacity(0.42)))
            .padding(12)
        }
        .padding(.top, 10)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(SeaDay.title(for: now))
                .font(SeaFont.title(24))
                .foregroundColor(Sea.ink)
            Text("\(round.twilight) · \(round.seaState) sea · running \(round.runLabel)")
                .font(SeaFont.italic(14))
                .foregroundColor(Sea.inkPale)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var roundCard: some View {
        SeaCard {
            VStack(alignment: .leading, spacing: 13) {
                HStack {
                    Text("The round of the day".uppercased())
                        .font(SeaFont.title(12)).tracking(2.2)
                        .foregroundColor(Sea.inkPale)
                    Spacer()
                    Chip(text: "\(errors.count) of \(round.legs.count) taken",
                         tone: errors.count == round.legs.count ? Sea.moss : Sea.brass)
                }

                Text(round.remark)
                    .font(SeaFont.body(15))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 8) {
                    ForEach(Array(round.legs.enumerated()), id: \.offset) { pair in
                        legRow(pair.offset, pair.element)
                    }
                }

                if errors.count >= round.legs.count {
                    SeaButton(title: "Work the fix") { finishRound() }
                } else {
                    SeaButton(title: errors.isEmpty ? "Begin the round" : "Take the next sight") {
                        activeLeg = LegRef(id: errors.count,
                                           leg: round.legs[min(errors.count,
                                                               round.legs.count - 1)])
                    }
                }
            }
        }
    }

    private func legRow(_ index: Int, _ leg: RoundLeg) -> some View {
        let taken = index < errors.count
        return HStack(spacing: 11) {
            ZStack {
                Circle()
                    .fill(taken ? Sea.moss.opacity(0.18) : Sea.ink.opacity(0.07))
                    .frame(width: 30, height: 30)
                if taken {
                    TickMark(size: 14, colour: Sea.moss)
                } else {
                    Text("\(index + 1)")
                        .font(SeaFont.title(13))
                        .foregroundColor(Sea.inkPale)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(leg.brief.bodyName)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.ink)
                Text(String(format: "Bearing %@ · %.0f minutes before the fix",
                            leg.bearingLabel, leg.minutesBeforeFix))
                    .font(SeaFont.body(12))
                    .foregroundColor(Sea.inkPale)
            }
            Spacer()
            if taken {
                Text(formatMinutes(abs(errors[index])))
                    .font(SeaFont.mono(13))
                    .foregroundColor(abs(errors[index]) <= 3 ? Sea.moss : Sea.oxblood)
            }
        }
        .padding(.vertical, 9)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(taken ? Sea.moss.opacity(0.07) : Sea.cardSunk))
    }

    private func finishedCard(_ rec: RoundRecord) -> some View {
        SeaCard(tone: Sea.moss.opacity(0.10)) {
            VStack(alignment: .leading, spacing: 11) {
                HStack {
                    Text("Today's round is in the log".uppercased())
                        .font(SeaFont.title(12)).tracking(2.0)
                        .foregroundColor(Sea.inkSoft)
                    Spacer()
                    StarRow(earned: rec.stars, size: 14)
                }
                HStack(spacing: 8) {
                    StatBlock(value: formatMiles(rec.errorMiles), caption: "fix error",
                              tone: rec.errorMiles <= 5 ? Sea.moss : Sea.oxblood)
                    StatBlock(value: formatMiles(rec.hatMiles), caption: "cocked hat",
                              tone: Sea.brass)
                    StatBlock(value: "\(store.liveStreak)", caption: "day streak",
                              tone: Sea.ink)
                }
                Text("Come back at the next twilight — a fresh round of three bodies is set every day, and the streak holds as long as you do not miss one.")
                    .font(SeaFont.body(14))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var standingCard: some View {
        let s = standing
        return SeaCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(s.rank.name)
                        .font(SeaFont.title(21))
                        .foregroundColor(Sea.ink)
                    Spacer()
                    Text("\(store.seaPoints) pts")
                        .font(SeaFont.mono(13))
                        .foregroundColor(Sea.inkPale)
                }
                Text(s.rank.note)
                    .font(SeaFont.italic(14))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                ProgressBarline(fraction: s.progress)
                if let n = s.next {
                    Text("\(n.threshold - store.seaPoints) points to \(n.name)".uppercased())
                        .font(SeaFont.body(11)).tracking(1.4)
                        .foregroundColor(Sea.inkPale)
                } else {
                    Text("The top of the list. Nothing above this.".uppercased())
                        .font(SeaFont.body(11)).tracking(1.4)
                        .foregroundColor(Sea.brass)
                }
                RuleLine()
                HStack(spacing: 8) {
                    StatBlock(value: "\(store.liveStreak)", caption: "streak")
                    StatBlock(value: "\(store.bestStreak)", caption: "best streak",
                              tone: Sea.brass)
                    StatBlock(value: "\(store.roundsMade)", caption: "rounds worked")
                }
            }
        }
    }

    private var historyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHead(text: "Recent rounds")
            VStack(spacing: 8) {
                ForEach(store.rounds.suffix(5).reversed()) { rec in
                    HStack {
                        StarRow(earned: rec.stars, size: 12)
                        Text(rec.bodies.joined(separator: " · "))
                            .font(SeaFont.body(13))
                            .foregroundColor(Sea.inkSoft)
                            .lineLimit(1)
                        Spacer()
                        Text(formatMiles(rec.errorMiles))
                            .font(SeaFont.mono(13))
                            .foregroundColor(rec.errorMiles <= 5 ? Sea.moss : Sea.oxblood)
                    }
                    .padding(.vertical, 9)
                    .padding(.horizontal, 12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))
                }
            }
        }
    }
}
