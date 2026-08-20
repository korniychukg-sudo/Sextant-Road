import SwiftUI

struct BriefRef: Identifiable {
    let id: Int
    let brief: SightBrief
}

struct SightTabView: View {
    @EnvironmentObject var store: SeaStore
    @State private var round: Int = 0
    @State private var active: BriefRef? = nil

    private var brief: SightBrief {
        SightSeeds.brief(index: round)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header

                SeaCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("The sight of the watch".uppercased())
                                    .font(SeaFont.body(11)).tracking(2.0)
                                    .foregroundColor(Sea.inkPale)
                                Text(brief.bodyName)
                                    .font(SeaFont.title(27))
                                    .foregroundColor(Sea.ink)
                            }
                            Spacer()
                            Chip(text: brief.kind.display)
                        }

                        Plate(name: brief.starSlug != nil ? "star_" + brief.starSlug!
                                                          : "sky_" + brief.skySlug,
                              anchor: .top)
                            .frame(height: SeaMetrics.isPad ? 260 : 180)

                        Text(brief.note)
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: 8) {
                            Chip(text: brief.deck.name, tone: Sea.wave)
                            Chip(text: brief.swellMinutes < 1.5 ? "Slight swell"
                                 : (brief.swellMinutes < 2.8 ? "Moderate swell" : "Heavy swell"),
                                 tone: Sea.oxblood)
                        }

                        SeaButton(title: "Take this sight") {
                            active = BriefRef(id: round, brief: brief)
                        }
                        SeaButton(title: "Another body", kind: .secondary) {
                            round += 1
                        }
                    }
                }

                SectionHead(text: "Your recent work")
                if store.sights.isEmpty {
                    SeaCard(tone: Sea.cardSunk) {
                        Text("Nothing in the log yet. Take a sight, work the corrections, and step off the intercept — the whole cycle takes about three minutes and it is the only thing that ever made an ocean crossable.")
                            .font(SeaFont.body(15))
                            .foregroundColor(Sea.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    VStack(spacing: 8) {
                        ForEach(store.sights.suffix(5).reversed()) { rec in
                            HStack {
                                StarRow(earned: rec.stars, size: 13)
                                Text(rec.body)
                                    .font(SeaFont.body(15))
                                    .foregroundColor(Sea.ink)
                                Spacer()
                                Text(formatMinutes(abs(rec.errorMinutes)))
                                    .font(SeaFont.mono(14))
                                    .foregroundColor(abs(rec.errorMinutes) <= 3 ? Sea.moss : Sea.oxblood)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 13)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Sea.card))
                        }
                    }
                }

                if let best = store.bestErrorMinutes {
                    SeaCard(tone: Sea.brass.opacity(0.10)) {
                        HStack {
                            StatBlock(value: "\(store.totalSights)", caption: "sights taken")
                            StatBlock(value: formatMinutes(best), caption: "best sight", tone: Sea.brass)
                            StatBlock(value: store.averageErrorMinutes.map { formatMinutes($0) } ?? "—",
                                      caption: "recent average")
                        }
                    }
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
        .centreColumn()
        .fullScreenCover(item: $active) { ref in
            SightSessionView(brief: ref.brief, contextLabel: "Practice sight") { result in
                store.record(SightRecord(id: UUID().uuidString, body: ref.brief.bodyName,
                                         errorMinutes: result.errorMinutes,
                                         stars: result.stars,
                                         stamp: Double(ref.id),
                                         voyage: nil,
                                         workedClean: result.workedClean))
                active = nil
                round = ref.id + 1
            } onLeave: {
                active = nil
            }
        }
        .onAppear {
            if round == 0 { round = store.totalSights }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sextant Road")
                .font(SeaFont.title(29))
                .foregroundColor(Sea.ink)
            Text("Bring a body down to the sea and find out where you stand")
                .font(SeaFont.italic(15))
                .foregroundColor(Sea.inkPale)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }
}
