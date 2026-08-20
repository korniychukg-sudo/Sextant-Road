import SwiftUI
import Combine

struct SightRecord: Codable, Identifiable {
    var id: String
    var body: String
    var errorMinutes: Double
    var stars: Int
    var stamp: Double
    var voyage: String?
    var workedClean: Bool
}

struct VoyageState: Codable {
    var day: Int
    var finished: Bool
    var bestFixMiles: Double
    var fixesMade: Int
}

final class SeaStore: ObservableObject {
    @Published var sights: [SightRecord] = []
    @Published var voyages: [String: VoyageState] = [:]
    @Published var readLessons: Set<String> = []
    @Published var metStars: Set<String> = []
    @Published var metInstruments: Set<String> = []
    @Published var awards: Set<String> = []
    @Published var quizBest: Int = 0
    @Published var quizTaken: Int = 0
    @Published var onboarded: Bool = false
    @Published var lastAward: String? = nil

    private let key = "sextant.road.state.v1"
    private var loaded = false

    init() { load() }

    struct Snapshot: Codable {
        var sights: [SightRecord]
        var voyages: [String: VoyageState]
        var readLessons: [String]
        var metStars: [String]
        var metInstruments: [String]
        var awards: [String]
        var quizBest: Int
        var quizTaken: Int
        var onboarded: Bool
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let snap = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            loaded = true
            return
        }
        sights = snap.sights
        voyages = snap.voyages
        readLessons = Set(snap.readLessons)
        metStars = Set(snap.metStars)
        metInstruments = Set(snap.metInstruments)
        awards = Set(snap.awards)
        quizBest = snap.quizBest
        quizTaken = snap.quizTaken
        onboarded = snap.onboarded
        loaded = true
    }

    func saveNow() {
        guard loaded else { return }
        let snap = Snapshot(sights: sights, voyages: voyages,
                            readLessons: Array(readLessons),
                            metStars: Array(metStars),
                            metInstruments: Array(metInstruments),
                            awards: Array(awards),
                            quizBest: quizBest, quizTaken: quizTaken,
                            onboarded: onboarded)
        if let data = try? JSONEncoder().encode(snap) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    var totalSights: Int { sights.count }

    var bestErrorMinutes: Double? {
        sights.map { abs($0.errorMinutes) }.min()
    }

    var averageErrorMinutes: Double? {
        guard !sights.isEmpty else { return nil }
        let recent = sights.suffix(20)
        return recent.map { abs($0.errorMinutes) }.reduce(0, +) / Double(recent.count)
    }

    var perfectSights: Int { sights.filter { $0.stars >= 3 }.count }

    var cleanReductions: Int { sights.filter { $0.workedClean }.count }

    var voyagesFinished: Int { voyages.values.filter { $0.finished }.count }

    var totalFixes: Int { voyages.values.reduce(0) { $0 + $1.fixesMade } }

    func bodiesShot() -> Set<String> { Set(sights.map { $0.body }) }

    func record(_ rec: SightRecord) {
        sights.append(rec)
        if sights.count > 400 { sights.removeFirst(sights.count - 400) }
        refreshAwards()
        saveNow()
    }

    func state(for slug: String) -> VoyageState {
        voyages[slug] ?? VoyageState(day: 0, finished: false, bestFixMiles: 9999, fixesMade: 0)
    }

    func setState(_ slug: String, _ st: VoyageState) {
        voyages[slug] = st
        refreshAwards()
        saveNow()
    }

    func markLesson(_ slug: String) {
        guard !readLessons.contains(slug) else { return }
        readLessons.insert(slug)
        refreshAwards()
        saveNow()
    }

    func markStar(_ slug: String) {
        guard !metStars.contains(slug) else { return }
        metStars.insert(slug)
        refreshAwards()
        saveNow()
    }

    func markInstrument(_ slug: String) {
        guard !metInstruments.contains(slug) else { return }
        metInstruments.insert(slug)
        refreshAwards()
        saveNow()
    }

    func recordQuiz(score: Int) {
        quizTaken += 1
        if score > quizBest { quizBest = score }
        refreshAwards()
        saveNow()
    }

    func finishOnboarding() {
        onboarded = true
        saveNow()
    }

    func resetProgress() {
        sights = []
        voyages = [:]
        readLessons = []
        metStars = []
        metInstruments = []
        awards = []
        quizBest = 0
        quizTaken = 0
        saveNow()
    }

    func refreshAwards() {
        var fresh: String? = nil
        for award in allAwards where !awards.contains(award.slug) {
            if award.test(self) {
                awards.insert(award.slug)
                if fresh == nil { fresh = award.slug }
            }
        }
        if let f = fresh { lastAward = f }
    }

    func award(_ slug: String) -> Award? {
        allAwards.first { $0.slug == slug }
    }
}
