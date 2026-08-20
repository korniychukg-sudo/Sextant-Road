import Foundation

enum BodyKind: String, Codable {
    case star, sun, moon, planet

    var display: String {
        switch self {
        case .star: return "Star"
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .planet: return "Planet"
        }
    }

    var hasLimb: Bool { self == .sun || self == .moon }

    var semiDiameter: Double {
        switch self {
        case .sun: return 16.0
        case .moon: return 15.5
        default: return 0
        }
    }
}

enum Limb: String, Codable {
    case lower, upper, centre

    var display: String {
        switch self {
        case .lower: return "Lower limb"
        case .upper: return "Upper limb"
        case .centre: return "Centre"
        }
    }
}

struct DeckHeight {
    let name: String
    let metres: Double
    var dip: Double { 1.76 * metres.squareRoot() }
}

let deckHeights: [DeckHeight] = [
    DeckHeight(name: "Main deck", metres: 3),
    DeckHeight(name: "Boat deck", metres: 7),
    DeckHeight(name: "Bridge wing", metres: 12),
    DeckHeight(name: "Monkey island", metres: 18),
    DeckHeight(name: "Crosstrees", metres: 26),
]

struct RefractionBand {
    let low: Double
    let high: Double
    let minutes: Double

    var label: String {
        String(format: "%.0f° to %.0f°", low, high)
    }
}

let refractionBands: [RefractionBand] = [
    RefractionBand(low: 5, high: 8, minutes: 8.2),
    RefractionBand(low: 8, high: 12, minutes: 5.5),
    RefractionBand(low: 12, high: 18, minutes: 3.6),
    RefractionBand(low: 18, high: 26, minutes: 2.3),
    RefractionBand(low: 26, high: 38, minutes: 1.6),
    RefractionBand(low: 38, high: 55, minutes: 1.0),
    RefractionBand(low: 55, high: 90, minutes: 0.5),
]

func refractionBand(for altitude: Double) -> RefractionBand {
    for band in refractionBands where altitude >= band.low && altitude < band.high {
        return band
    }
    return altitude < 5 ? refractionBands[0] : refractionBands[refractionBands.count - 1]
}

struct SightBrief {
    let bodyName: String
    let kind: BodyKind
    let starSlug: String?
    let skySlug: String
    let perfectHs: Double
    let indexErrorMinutes: Double
    let indexOnArc: Bool
    let deckIndex: Int
    let limb: Limb
    let swellMinutes: Double
    let haze: Double
    let azimuth: Double
    let trueInterceptMiles: Double
    let note: String

    var deck: DeckHeight { deckHeights[min(deckIndex, deckHeights.count - 1)] }

    var signedIndexError: Double { indexOnArc ? indexErrorMinutes : -indexErrorMinutes }

    func apparentAltitude(fromHs hs: Double) -> Double {
        hs - signedIndexError / 60.0 - deck.dip / 60.0
    }

    func observedAltitude(fromHs hs: Double) -> Double {
        let ha = apparentAltitude(fromHs: hs)
        let refr = refractionBand(for: ha).minutes
        var ho = ha - refr / 60.0
        if kind.hasLimb {
            let sd = kind.semiDiameter / 60.0
            ho += (limb == .lower ? sd : -sd)
        }
        return ho
    }

    var perfectHo: Double { observedAltitude(fromHs: perfectHs) }

    var computedAltitude: Double { perfectHo - trueInterceptMiles / 60.0 }

    func intercept(fromHs hs: Double) -> Double {
        (observedAltitude(fromHs: hs) - computedAltitude) * 60.0
    }

    var azimuthName: String {
        let points = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let idx = Int((azimuth / 22.5).rounded()) % 16
        return points[idx]
    }
}

struct Grade {
    let stars: Int
    let title: String
    let note: String
}

func gradeSight(errorMinutes: Double) -> Grade {
    let e = abs(errorMinutes)
    if e <= 1.0 {
        return Grade(stars: 3, title: "A clean sight",
                     note: "Inside one minute. That is a mile on the chart, and no navigator asks for better at sea.")
    }
    if e <= 3.0 {
        return Grade(stars: 2, title: "A workable sight",
                     note: "Within three minutes. Three miles of doubt is a night's sleep on a wide ocean and a worry on a close one.")
    }
    if e <= 8.0 {
        return Grade(stars: 1, title: "Rough, but honest",
                     note: "Eight minutes out. Swing the arc more patiently and wait for the swell to settle before you mark.")
    }
    return Grade(stars: 0, title: "Not a sight to trust",
                 note: "This one would put you where you are not. Bring the body right down onto the horizon, and keep the instrument upright.")
}

struct SightSeeds {
    static let practiceBodies: [(String, BodyKind, String?)] = [
        ("Polaris", .star, "polaris"), ("Sirius", .star, "sirius"),
        ("Vega", .star, "vega"), ("Arcturus", .star, "arcturus"),
        ("Capella", .star, "capella"), ("Rigel", .star, "rigel"),
        ("Betelgeuse", .star, "betelgeuse"), ("Aldebaran", .star, "aldebaran"),
        ("Altair", .star, "altair"), ("Antares", .star, "antares"),
        ("Spica", .star, "spica"), ("Regulus", .star, "regulus"),
        ("Deneb", .star, "deneb"), ("Fomalhaut", .star, "fomalhaut"),
        ("Canopus", .star, "canopus"), ("Achernar", .star, "achernar"),
        ("Acrux", .star, "acrux"), ("Dubhe", .star, "dubhe"),
        ("Pollux", .star, "pollux"), ("Procyon", .star, "procyon"),
        ("Schedar", .star, "schedar"), ("Markab", .star, "markab"),
        ("Hamal", .star, "hamal"), ("Alpheratz", .star, "alpheratz"),
        ("The Sun", .sun, nil), ("The Moon", .moon, nil),
    ]

    static let skies = ["dawn", "dusk", "nightclear", "moonlit", "hazy", "overcast"]

    static let notes = [
        "A quiet watch. The horizon is hard and the ship steady — no excuse for a poor one.",
        "There is a long swell running from the west. Let it pass through before you mark.",
        "Twilight is short tonight. Get the body down and take what you are given.",
        "The glass is falling. Take this one while the horizon is still worth having.",
        "Cold, clear and steady. The best conditions you will ever be handed.",
        "A little haze on the rim. Choose the line where the sea meets the grey, not the grey itself.",
        "The ship is rolling. Brace against the rail and swing the arc wide.",
        "First light. The stars are going fast — this may be the last one you get.",
    ]

    static func brief(index: Int) -> SightBrief {
        var seed = UInt64(bitPattern: Int64(index &* 2654435761 &+ 1013904223))
        func next() -> Double {
            seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17
            return Double(seed % 1_000_000) / 1_000_000.0
        }
        _ = next()
        let body = practiceBodies[abs(index) % practiceBodies.count]
        let alt = 14.0 + next() * 58.0
        let ie = (next() * 4.0).rounded() / 2.0 + 0.5
        let onArc = next() < 0.55
        let deck = Int(next() * Double(deckHeights.count)) % deckHeights.count
        let limb: Limb = body.1.hasLimb ? (next() < 0.7 ? .lower : .upper) : .centre
        let swell = 0.6 + next() * 3.4
        let haze = next() * 0.7
        let az = (next() * 360.0).rounded()
        let interceptChoices: [Double] = [-14, -9, -6, -3, 2, 4, 7, 11, 16]
        let inter = interceptChoices[Int(next() * Double(interceptChoices.count)) % interceptChoices.count]
        let sky: String
        switch body.1 {
        case .sun: sky = next() < 0.5 ? "hazy" : "dawn"
        case .moon: sky = "moonlit"
        default: sky = skies[Int(next() * Double(skies.count)) % skies.count]
        }
        return SightBrief(bodyName: body.0, kind: body.1, starSlug: body.2,
                          skySlug: sky, perfectHs: alt,
                          indexErrorMinutes: ie, indexOnArc: onArc,
                          deckIndex: deck, limb: limb,
                          swellMinutes: swell, haze: haze,
                          azimuth: az, trueInterceptMiles: inter,
                          note: notes[abs(index) % notes.count])
    }
}

enum ReduceStep: Int, CaseIterable {
    case indexError, dip, refraction, semiDiameter, result

    var title: String {
        switch self {
        case .indexError: return "Index error"
        case .dip: return "Dip of the horizon"
        case .refraction: return "Refraction"
        case .semiDiameter: return "Semi-diameter"
        case .result: return "The observed altitude"
        }
    }
}

struct ReduceOutcome {
    var afterIndex: Double = 0
    var afterDip: Double = 0
    var afterRefraction: Double = 0
    var observed: Double = 0
    var clean: Bool = true
}
