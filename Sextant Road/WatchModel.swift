import Foundation

enum SeaDay {
    static let epoch: TimeInterval = 1_767_225_600

    static func index(for date: Date = Date()) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let start = cal.startOfDay(for: date)
        return Int(floor((start.timeIntervalSince1970 - epoch) / 86_400.0))
    }

    static func hour(for date: Date = Date()) -> Double {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let parts = cal.dateComponents([.hour, .minute], from: date)
        return Double(parts.hour ?? 12) + Double(parts.minute ?? 0) / 60.0
    }

    static func title(for date: Date = Date()) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "EEEE d MMMM"
        return f.string(from: date)
    }
}

struct SeaSpin {
    private var s: UInt64

    init(_ seed: Int) {
        let v = UInt64(bitPattern: Int64(seed &* 2_654_435_761 &+ 1_013_904_223))
        s = v == 0 ? 0x9E37_79B9_7F4A_7C15 : v
    }

    mutating func next() -> UInt64 {
        s ^= s << 13; s ^= s >> 7; s ^= s << 17
        return s
    }

    mutating func unit() -> Double { Double(next() % 1_000_000) / 1_000_000.0 }
    mutating func range(_ a: Double, _ b: Double) -> Double { a + unit() * (b - a) }
    mutating func pick(_ n: Int) -> Int { n <= 1 ? 0 : Int(next() % UInt64(n)) }
}

struct SeaRank {
    let name: String
    let threshold: Int
    let note: String
}

let seaRanks: [SeaRank] = [
    SeaRank(name: "Second Mate", threshold: 0,
            note: "You keep a watch and you are learning to trust the arc."),
    SeaRank(name: "First Mate", threshold: 70,
            note: "The corrections come without the book open beside you."),
    SeaRank(name: "Navigator", threshold: 210,
            note: "Three bodies, three lines, and a fix you would put your name to."),
    SeaRank(name: "Sailing Master", threshold: 460,
            note: "You can bring a ship in on stars alone and sleep the same night."),
    SeaRank(name: "Master Mariner", threshold: 900,
            note: "There is nothing left on this arc that you have not already met."),
]

func rankFor(points: Int) -> (rank: SeaRank, next: SeaRank?, progress: Double) {
    var current = seaRanks[0]
    var next: SeaRank? = nil
    for (i, r) in seaRanks.enumerated() where points >= r.threshold {
        current = r
        next = i + 1 < seaRanks.count ? seaRanks[i + 1] : nil
    }
    guard let n = next else { return (current, nil, 1.0) }
    let span = Double(n.threshold - current.threshold)
    let done = Double(points - current.threshold)
    return (current, n, max(0, min(1, done / max(1, span))))
}

struct RoundLeg {
    let brief: SightBrief
    let minutesBeforeFix: Double
    let bearingLabel: String
}

struct WatchRound {
    let dayIndex: Int
    let legs: [RoundLeg]
    let courseDegrees: Double
    let speedKnots: Double
    let drNorthOffset: Double
    let drEastOffset: Double
    let twilight: String
    let seaState: String
    let remark: String

    var runLabel: String {
        String(format: "%03.0f° at %.0f knots", courseDegrees, speedKnots)
    }
}

struct LinePosition {
    let azimuth: Double
    let intercept: Double
    let advanceNorth: Double
    let advanceEast: Double
    let bodyName: String
}

enum WatchSeeds {
    static let twilights = ["Morning twilight", "Evening twilight", "Nautical twilight"]
    static let seaStates = ["Glassy", "Slight", "Moderate", "Rough"]
    static let remarks = [
        "Three bodies before the horizon goes. Take them in the order they are given and keep the run in your head.",
        "The mate has the log and the clock. All you owe him is three honest altitudes.",
        "A long run between the first and the last. The advance will matter more than the sights.",
        "Short twilight. Whatever you get in the next twenty minutes is the fix.",
        "Clear rim all round tonight. There will be no excuse for a wide hat.",
        "The ship is steady on her course. If the triangle is big, it was the arc, not the sea.",
        "Well spread in azimuth. Cut like this, even a rough sight tells the truth.",
        "Two of these are close in bearing. Trust the third to hold the fix down.",
    ]

    static func round(day: Int) -> WatchRound {
        var rng = SeaSpin(day &* 7919 &+ 3)
        let course = (rng.range(0, 36).rounded() * 10).truncatingRemainder(dividingBy: 360)
        let speed = (rng.range(6, 18)).rounded()
        let drN = rng.range(-9, 9)
        let drE = rng.range(-9, 9)

        var used = Set<Int>()
        var legs: [RoundLeg] = []
        let spacing: [Double] = [46, 24, 0]
        var wanted: [Double] = []
        let firstAz = rng.range(0, 360)
        wanted.append(firstAz)
        wanted.append((firstAz + rng.range(95, 145)).truncatingRemainder(dividingBy: 360))
        wanted.append((firstAz + rng.range(215, 265)).truncatingRemainder(dividingBy: 360))

        for k in 0..<3 {
            var idx = 0
            var guard0 = 0
            repeat {
                idx = rng.pick(SightSeeds.practiceBodies.count)
                guard0 += 1
            } while used.contains(idx) && guard0 < 40
            used.insert(idx)

            let base = SightSeeds.brief(index: day &* 31 &+ k &* 7 &+ idx)
            let az = wanted[k]
            let brief = SightBrief(bodyName: base.bodyName, kind: base.kind,
                                   starSlug: base.starSlug, skySlug: base.skySlug,
                                   perfectHs: base.perfectHs,
                                   indexErrorMinutes: base.indexErrorMinutes,
                                   indexOnArc: base.indexOnArc,
                                   deckIndex: base.deckIndex, limb: base.limb,
                                   swellMinutes: base.swellMinutes, haze: base.haze,
                                   azimuth: az.rounded(),
                                   trueInterceptMiles: base.trueInterceptMiles,
                                   note: base.note)
            legs.append(RoundLeg(brief: brief, minutesBeforeFix: spacing[k],
                                 bearingLabel: brief.azimuthName))
        }

        return WatchRound(dayIndex: day, legs: legs,
                          courseDegrees: course, speedKnots: speed,
                          drNorthOffset: drN, drEastOffset: drE,
                          twilight: twilights[abs(day) % twilights.count],
                          seaState: seaStates[abs(day / 3) % seaStates.count],
                          remark: remarks[abs(day) % remarks.count])
    }
}

struct FixSolution {
    let north: Double
    let east: Double
    let hatMiles: Double
    let errorMiles: Double
    let lines: [LinePosition]
}

func runVector(course: Double, speed: Double, minutes: Double) -> (north: Double, east: Double) {
    let rad = course * .pi / 180.0
    let distance = speed * minutes / 60.0
    return (cos(rad) * distance, sin(rad) * distance)
}

func linesFor(round: WatchRound, sightErrors: [Double]) -> [LinePosition] {
    var out: [LinePosition] = []
    for (k, leg) in round.legs.enumerated() {
        let run = runVector(course: round.courseDegrees, speed: round.speedKnots,
                            minutes: leg.minutesBeforeFix)
        let trueNorthAtObs = -run.north
        let trueEastAtObs = -run.east
        let apNorth = round.drNorthOffset - run.north
        let apEast = round.drEastOffset - run.east
        let rad = leg.brief.azimuth * .pi / 180.0
        let toward = (north: cos(rad), east: sin(rad))
        let clean = (trueNorthAtObs - apNorth) * toward.north
            + (trueEastAtObs - apEast) * toward.east
        let err = k < sightErrors.count ? sightErrors[k] : 0
        out.append(LinePosition(azimuth: leg.brief.azimuth,
                                intercept: clean + err,
                                advanceNorth: run.north,
                                advanceEast: run.east,
                                bodyName: leg.brief.bodyName))
    }
    return out
}

func lineOffset(round: WatchRound, line: LinePosition) -> Double {
    let rad = line.azimuth * .pi / 180.0
    return round.drNorthOffset * cos(rad) + round.drEastOffset * sin(rad) + line.intercept
}

func crossPoint(round: WatchRound, _ a: LinePosition, _ b: LinePosition) -> (Double, Double)? {
    let ra = a.azimuth * .pi / 180.0, rb = b.azimuth * .pi / 180.0
    let a1 = cos(ra), b1 = sin(ra), c1 = lineOffset(round: round, line: a)
    let a2 = cos(rb), b2 = sin(rb), c2 = lineOffset(round: round, line: b)
    let det = a1 * b2 - a2 * b1
    guard abs(det) > 1e-6 else { return nil }
    return ((c1 * b2 - c2 * b1) / det, (a1 * c2 - a2 * c1) / det)
}

func solveFix(round: WatchRound, lines: [LinePosition]) -> FixSolution {
    var sumA = 0.0, sumB = 0.0, sumC = 0.0, sumD = 0.0, sumE = 0.0
    for line in lines {
        let rad = line.azimuth * .pi / 180.0
        let un = cos(rad), ue = sin(rad)
        let d = lineOffset(round: round, line: line)
        sumA += un * un
        sumB += un * ue
        sumC += ue * ue
        sumD += un * d
        sumE += ue * d
    }
    let det = sumA * sumC - sumB * sumB
    var north = 0.0, east = 0.0
    if abs(det) > 1e-9 {
        north = (sumD * sumC - sumE * sumB) / det
        east = (sumA * sumE - sumB * sumD) / det
    }

    var corners: [(Double, Double)] = []
    for i in 0..<lines.count {
        for j in (i + 1)..<lines.count {
            if let p = crossPoint(round: round, lines[i], lines[j]) { corners.append(p) }
        }
    }
    var hat = 0.0
    for i in 0..<corners.count {
        for j in (i + 1)..<corners.count {
            let dn = corners[i].0 - corners[j].0
            let de = corners[i].1 - corners[j].1
            hat = max(hat, (dn * dn + de * de).squareRoot())
        }
    }

    let err = (north * north + east * east).squareRoot()
    return FixSolution(north: north, east: east, hatMiles: hat,
                       errorMiles: err, lines: lines)
}

struct FixGrade {
    let stars: Int
    let title: String
    let note: String
}

func gradeFix(errorMiles: Double, hatMiles: Double) -> FixGrade {
    if errorMiles <= 2.0 && hatMiles <= 4.0 {
        return FixGrade(stars: 3, title: "A fix worth the name",
                        note: "A tight hat and the ship inside it. This is the round every navigator is trying to have.")
    }
    if errorMiles <= 5.0 {
        return FixGrade(stars: 2, title: "A working fix",
                        note: "Close enough to shape a course on and correct at the next twilight.")
    }
    if errorMiles <= 12.0 {
        return FixGrade(stars: 1, title: "A loose fix",
                        note: "You would run on this, but you would not close a coast with it.")
    }
    return FixGrade(stars: 0, title: "Not a fix",
                    note: "The hat is wide and the ship is not in it. One of the three sights carried the others away.")
}
