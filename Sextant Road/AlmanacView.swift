import SwiftUI

enum AlmanacSection: Int, CaseIterable {
    case stars, instruments, lessons, glossary

    var title: String {
        switch self {
        case .stars: return "Stars"
        case .instruments: return "Instruments"
        case .lessons: return "Instruction"
        case .glossary: return "Glossary"
        }
    }
}

struct AlmanacView: View {
    @EnvironmentObject var store: SeaStore
    @State private var section: AlmanacSection = .stars
    @State private var openStar: NavStar? = nil
    @State private var openInstrument: InstrumentEntry? = nil
    @State private var openLesson: Lesson? = nil
    @State private var quizOpen = false
    @State private var search: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("The Almanac")
                        .font(SeaFont.title(29))
                        .foregroundColor(Sea.ink)
                    Text("Everything the sextant does not carry for you")
                        .font(SeaFont.italic(15))
                        .foregroundColor(Sea.inkPale)
                }
                .padding(.top, 12)

                picker

                switch section {
                case .stars: starList
                case .instruments: instrumentList
                case .lessons: lessonList
                case .glossary: glossaryList
                }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
        }
        .seaPage()
        .centreColumn()
        .sheet(item: $openStar) { star in
            StarDetailView(star: star) { openStar = nil }
                .environmentObject(store)
        }
        .sheet(item: $openInstrument) { inst in
            InstrumentDetailView(entry: inst) { openInstrument = nil }
                .environmentObject(store)
        }
        .sheet(item: $openLesson) { lesson in
            LessonDetailView(lesson: lesson) { openLesson = nil }
                .environmentObject(store)
        }
        .fullScreenCover(isPresented: $quizOpen) {
            QuizView { quizOpen = false }
                .environmentObject(store)
        }
    }

    private var picker: some View {
        HStack(spacing: 6) {
            ForEach(AlmanacSection.allCases, id: \.rawValue) { s in
                Button(action: { withAnimation(.easeOut(duration: 0.18)) { section = s } }) {
                    Text(s.title.uppercased())
                        .font(SeaFont.title(10))
                        .tracking(0.9)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                        .foregroundColor(section == s ? Sea.card : Sea.inkSoft)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 9)
                                .fill(section == s ? Sea.ink : Sea.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(Sea.ink.opacity(section == s ? 0 : 0.18), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var starList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(store.metStars.count) of \(navStars.count) opened".uppercased())
                    .font(SeaFont.body(11)).tracking(1.6)
                    .foregroundColor(Sea.inkPale)
                Spacer()
            }
            ProgressBarline(fraction: Double(store.metStars.count) / Double(navStars.count))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: SeaMetrics.isPad ? 200 : 150),
                                         spacing: 11)], spacing: 11) {
                ForEach(navStars) { star in
                    Button(action: { openStar = star }) {
                        VStack(alignment: .leading, spacing: 0) {
                            Plate(name: "star_" + star.slug, corner: 0, anchor: .top)
                                .frame(height: 96)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(star.name)
                                    .font(SeaFont.title(15))
                                    .foregroundColor(Sea.ink)
                                Text(star.constellation)
                                    .font(SeaFont.body(12))
                                    .foregroundColor(Sea.inkPale)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                        }
                        .background(RoundedRectangle(cornerRadius: 12).fill(Sea.card))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(store.metStars.contains(star.slug)
                                            ? Sea.brass.opacity(0.6) : Sea.ink.opacity(0.16),
                                            lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var instrumentList: some View {
        VStack(spacing: 11) {
            ForEach(instrumentEntries) { entry in
                Button(action: { openInstrument = entry }) {
                    VStack(alignment: .leading, spacing: 0) {
                        Plate(name: "inst_" + entry.slug, corner: 0, anchor: .top)
                            .frame(height: SeaMetrics.isPad ? 190 : 132)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(entry.title)
                                .font(SeaFont.title(18))
                                .foregroundColor(Sea.ink)
                            Text(entry.era.uppercased() + " · " + entry.measures)
                                .font(SeaFont.body(12))
                                .foregroundColor(Sea.inkPale)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(13)
                    }
                    .background(RoundedRectangle(cornerRadius: 13).fill(Sea.card))
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(RoundedRectangle(cornerRadius: 13)
                                .stroke(Sea.ink.opacity(0.16), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var lessonList: some View {
        VStack(spacing: 11) {
            SeaCard(tone: Sea.brass.opacity(0.10)) {
                VStack(alignment: .leading, spacing: 9) {
                    HStack {
                        Text("The examination".uppercased())
                            .font(SeaFont.title(12)).tracking(2.0)
                            .foregroundColor(Sea.brass)
                        Spacer()
                        if store.quizTaken > 0 {
                            Text("Best \(store.quizBest)/16")
                                .font(SeaFont.mono(13))
                                .foregroundColor(Sea.ink)
                        }
                    }
                    Text("Sixteen questions drawn from the whole of this instruction, in a different order every time.")
                        .font(SeaFont.body(15))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                    SeaButton(title: "Sit the examination", kind: .secondary) { quizOpen = true }
                }
            }

            ForEach(Array(lessons.enumerated()), id: \.offset) { idx, lesson in
                Button(action: { openLesson = lesson }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(store.readLessons.contains(lesson.slug)
                                      ? Sea.moss.opacity(0.16) : Sea.brass.opacity(0.14))
                                .frame(width: 40, height: 40)
                            if store.readLessons.contains(lesson.slug) {
                                TickMark(size: 18, colour: Sea.moss)
                            } else {
                                Text("\(idx + 1)")
                                    .font(SeaFont.title(16))
                                    .foregroundColor(Sea.brass)
                            }
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(lesson.title)
                                .font(SeaFont.title(16))
                                .foregroundColor(Sea.ink)
                                .multilineTextAlignment(.leading)
                            Text(lesson.standfirst)
                                .font(SeaFont.body(13))
                                .foregroundColor(Sea.inkPale)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                        ChevronMark(size: 15)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Sea.card))
                    .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Sea.ink.opacity(0.16), lineWidth: 1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private var glossaryList: some View {
        VStack(spacing: 8) {
            ForEach(glossary) { term in
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.term)
                        .font(SeaFont.title(15))
                        .foregroundColor(Sea.ink)
                    Text(term.meaning)
                        .font(SeaFont.body(14))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 11).fill(Sea.card))
                .overlay(RoundedRectangle(cornerRadius: 11)
                            .stroke(Sea.ink.opacity(0.14), lineWidth: 1))
            }
        }
    }
}

struct StarDetailView: View {
    let star: NavStar
    let onClose: () -> Void
    @EnvironmentObject var store: SeaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SheetHeader(title: star.name, subtitle: star.constellation, onClose: onClose)
                Plate(name: "star_" + star.slug)
                    .frame(height: SeaMetrics.isPad ? 340 : 220)

                HStack(spacing: 8) {
                    Chip(text: "Mag " + star.magnitude)
                    Chip(text: star.declination, tone: Sea.wave)
                    Chip(text: star.hemisphere, tone: Sea.moss)
                }

                SectionHead(text: "How to find it")
                Text(star.howToFind)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SectionHead(text: "Why a navigator cares")
                Text(star.story)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SeaButton(title: "Close", kind: .secondary, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
            .padding(.top, 18)
        }
        .seaPage()
        .onAppear { store.markStar(star.slug) }
    }
}

struct InstrumentDetailView: View {
    let entry: InstrumentEntry
    let onClose: () -> Void
    @EnvironmentObject var store: SeaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SheetHeader(title: entry.title, subtitle: entry.era, onClose: onClose)
                Plate(name: "inst_" + entry.slug)
                    .frame(height: SeaMetrics.isPad ? 340 : 220)

                SectionHead(text: "What it measures")
                Text(entry.measures)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SectionHead(text: "How it is used")
                Text(entry.howUsed)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SectionHead(text: "The point of it")
                Text(entry.story)
                    .font(SeaFont.body(16))
                    .foregroundColor(Sea.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)

                SeaButton(title: "Close", kind: .secondary, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
            .padding(.top, 18)
        }
        .seaPage()
        .onAppear { store.markInstrument(entry.slug) }
    }
}

struct LessonDetailView: View {
    let lesson: Lesson
    let onClose: () -> Void
    @EnvironmentObject var store: SeaStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                SheetHeader(title: lesson.title, subtitle: "Instruction", onClose: onClose)
                Plate(name: "diag_" + lesson.slug)
                    .frame(height: SeaMetrics.isPad ? 340 : 220)

                Text(lesson.standfirst)
                    .font(SeaFont.italic(17))
                    .foregroundColor(Sea.brass)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(Array(lesson.paragraphs.enumerated()), id: \.offset) { _, para in
                    Text(para)
                        .font(SeaFont.body(16))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SeaButton(title: "Close", kind: .secondary, action: onClose)
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 34)
            .padding(.top, 18)
        }
        .seaPage()
        .onAppear { store.markLesson(lesson.slug) }
    }
}
