import Foundation
import CoreGraphics

struct StarDot {
    let x: Double
    let y: Double
    let mag: Double
}

struct Figure {
    let slug: String
    let star: String
    let constellation: String
    let dots: [StarDot]
    let links: [[Int]]
    let navIndex: Int
}

func d(_ x: Double, _ y: Double, _ m: Double) -> StarDot { StarDot(x: x, y: y, mag: m) }

let figures: [Figure] = figuresNorth + figuresEquator + figuresSouth

let figuresNorth: [Figure] = [
    Figure(slug: "polaris", star: "Polaris", constellation: "Ursa Minor",
           dots: [d(0.18, 0.18, 2.0), d(0.30, 0.30, 4.4), d(0.42, 0.44, 4.2),
                  d(0.56, 0.52, 4.3), d(0.74, 0.44, 2.1), d(0.72, 0.24, 3.0),
                  d(0.58, 0.68, 4.9)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 6], [6, 3]],
           navIndex: 0),
    Figure(slug: "dubhe", star: "Dubhe", constellation: "Ursa Major",
           dots: [d(0.14, 0.34, 1.8), d(0.16, 0.54, 2.4), d(0.34, 0.58, 2.4),
                  d(0.36, 0.38, 3.3), d(0.52, 0.32, 2.3), d(0.68, 0.28, 2.2),
                  d(0.86, 0.36, 1.9)],
           links: [[0, 1], [1, 2], [2, 3], [3, 0], [3, 4], [4, 5], [5, 6]],
           navIndex: 0),
    Figure(slug: "vega", star: "Vega", constellation: "Lyra",
           dots: [d(0.30, 0.20, 0.0), d(0.44, 0.28, 4.3), d(0.24, 0.34, 4.4),
                  d(0.36, 0.52, 3.5), d(0.54, 0.48, 3.2), d(0.46, 0.70, 3.3),
                  d(0.62, 0.66, 4.4)],
           links: [[0, 1], [0, 2], [2, 3], [1, 4], [3, 5], [4, 6], [5, 6], [3, 4]],
           navIndex: 0),
    Figure(slug: "deneb", star: "Deneb", constellation: "Cygnus",
           dots: [d(0.50, 0.14, 1.2), d(0.50, 0.40, 2.5), d(0.50, 0.62, 2.2),
                  d(0.50, 0.84, 3.2), d(0.22, 0.46, 2.9), d(0.78, 0.44, 2.5),
                  d(0.12, 0.56, 3.8), d(0.88, 0.54, 3.7)],
           links: [[0, 1], [1, 2], [2, 3], [1, 4], [1, 5], [4, 6], [5, 7]],
           navIndex: 0),
    Figure(slug: "capella", star: "Capella", constellation: "Auriga",
           dots: [d(0.28, 0.22, 0.1), d(0.52, 0.16, 1.9), d(0.70, 0.36, 2.7),
                  d(0.60, 0.62, 3.0), d(0.34, 0.60, 2.6), d(0.22, 0.42, 3.7)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]],
           navIndex: 0),
    Figure(slug: "schedar", star: "Schedar", constellation: "Cassiopeia",
           dots: [d(0.14, 0.36, 2.2), d(0.32, 0.56, 2.3), d(0.50, 0.34, 2.5),
                  d(0.68, 0.58, 2.7), d(0.88, 0.32, 3.4)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4]],
           navIndex: 0),
    Figure(slug: "alpheratz", star: "Alpheratz", constellation: "Andromeda",
           dots: [d(0.18, 0.62, 2.1), d(0.38, 0.50, 3.3), d(0.58, 0.38, 2.1),
                  d(0.78, 0.26, 2.3), d(0.44, 0.70, 4.1), d(0.64, 0.62, 3.6)],
           links: [[0, 1], [1, 2], [2, 3], [1, 4], [2, 5]],
           navIndex: 0),
    Figure(slug: "markab", star: "Markab", constellation: "Pegasus",
           dots: [d(0.26, 0.66, 2.5), d(0.26, 0.30, 2.8), d(0.66, 0.26, 2.4),
                  d(0.66, 0.62, 2.1), d(0.86, 0.74, 3.5), d(0.08, 0.78, 3.8)],
           links: [[0, 1], [1, 2], [2, 3], [3, 0], [3, 4], [0, 5]],
           navIndex: 0),
    Figure(slug: "hamal", star: "Hamal", constellation: "Aries",
           dots: [d(0.24, 0.34, 2.0), d(0.46, 0.44, 2.6), d(0.62, 0.52, 4.3),
                  d(0.78, 0.62, 3.9)],
           links: [[0, 1], [1, 2], [2, 3]],
           navIndex: 0),
]

let figuresEquator: [Figure] = [
    Figure(slug: "betelgeuse", star: "Betelgeuse", constellation: "Orion",
           dots: [d(0.26, 0.22, 0.5), d(0.72, 0.26, 1.6), d(0.42, 0.50, 1.7),
                  d(0.50, 0.52, 1.7), d(0.58, 0.54, 2.2), d(0.30, 0.80, 0.2),
                  d(0.74, 0.78, 2.1), d(0.48, 0.66, 2.8)],
           links: [[0, 2], [1, 4], [2, 3], [3, 4], [2, 5], [4, 6], [3, 7]],
           navIndex: 0),
    Figure(slug: "rigel", star: "Rigel", constellation: "Orion",
           dots: [d(0.26, 0.22, 0.5), d(0.72, 0.26, 1.6), d(0.42, 0.50, 1.7),
                  d(0.50, 0.52, 1.7), d(0.58, 0.54, 2.2), d(0.30, 0.80, 0.2),
                  d(0.74, 0.78, 2.1), d(0.48, 0.66, 2.8)],
           links: [[0, 2], [1, 4], [2, 3], [3, 4], [2, 5], [4, 6], [3, 7]],
           navIndex: 5),
    Figure(slug: "sirius", star: "Sirius", constellation: "Canis Major",
           dots: [d(0.36, 0.24, -1.5), d(0.48, 0.44, 1.9), d(0.32, 0.56, 3.0),
                  d(0.58, 0.66, 1.8), d(0.72, 0.56, 2.4), d(0.24, 0.70, 3.9)],
           links: [[0, 1], [1, 2], [1, 3], [3, 4], [2, 5], [2, 3]],
           navIndex: 0),
    Figure(slug: "procyon", star: "Procyon", constellation: "Canis Minor",
           dots: [d(0.34, 0.44, 0.4), d(0.66, 0.32, 2.9), d(0.52, 0.66, 4.7)],
           links: [[0, 1], [0, 2]],
           navIndex: 0),
    Figure(slug: "pollux", star: "Pollux", constellation: "Gemini",
           dots: [d(0.30, 0.20, 1.1), d(0.56, 0.18, 1.6), d(0.28, 0.46, 3.0),
                  d(0.54, 0.44, 2.9), d(0.24, 0.72, 3.3), d(0.50, 0.74, 3.4),
                  d(0.70, 0.62, 3.6)],
           links: [[0, 2], [1, 3], [2, 4], [3, 5], [2, 3], [3, 6]],
           navIndex: 0),
    Figure(slug: "aldebaran", star: "Aldebaran", constellation: "Taurus",
           dots: [d(0.40, 0.52, 0.9), d(0.24, 0.44, 3.5), d(0.32, 0.62, 3.8),
                  d(0.58, 0.34, 3.0), d(0.74, 0.22, 1.7), d(0.62, 0.66, 3.6),
                  d(0.80, 0.72, 3.0)],
           links: [[1, 0], [0, 2], [0, 3], [3, 4], [0, 5], [5, 6]],
           navIndex: 0),
    Figure(slug: "regulus", star: "Regulus", constellation: "Leo",
           dots: [d(0.24, 0.66, 1.4), d(0.24, 0.48, 3.4), d(0.34, 0.32, 2.6),
                  d(0.48, 0.24, 3.5), d(0.56, 0.38, 3.9), d(0.44, 0.56, 2.1),
                  d(0.76, 0.52, 2.1), d(0.72, 0.72, 3.3)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 1], [5, 6], [6, 7], [7, 0]],
           navIndex: 0),
    Figure(slug: "spica", star: "Spica", constellation: "Virgo",
           dots: [d(0.32, 0.74, 1.0), d(0.44, 0.54, 3.4), d(0.60, 0.42, 2.7),
                  d(0.76, 0.30, 3.6), d(0.34, 0.42, 3.9), d(0.56, 0.68, 4.0)],
           links: [[0, 1], [1, 2], [2, 3], [1, 4], [1, 5]],
           navIndex: 0),
    Figure(slug: "arcturus", star: "Arcturus", constellation: "Bootes",
           dots: [d(0.42, 0.76, -0.1), d(0.34, 0.56, 3.5), d(0.44, 0.36, 2.7),
                  d(0.60, 0.24, 3.0), d(0.66, 0.46, 3.5), d(0.56, 0.60, 3.6)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]],
           navIndex: 0),
    Figure(slug: "altair", star: "Altair", constellation: "Aquila",
           dots: [d(0.46, 0.42, 0.8), d(0.38, 0.30, 2.7), d(0.54, 0.54, 3.7),
                  d(0.24, 0.60, 3.4), d(0.70, 0.66, 3.2), d(0.60, 0.20, 3.9)],
           links: [[1, 0], [0, 2], [2, 3], [2, 4], [1, 5]],
           navIndex: 0),
    Figure(slug: "antares", star: "Antares", constellation: "Scorpius",
           dots: [d(0.34, 0.32, 1.1), d(0.22, 0.22, 2.9), d(0.44, 0.20, 2.6),
                  d(0.40, 0.48, 2.8), d(0.48, 0.64, 2.3), d(0.62, 0.76, 1.9),
                  d(0.78, 0.72, 2.4), d(0.84, 0.56, 1.6)],
           links: [[1, 0], [2, 0], [0, 3], [3, 4], [4, 5], [5, 6], [6, 7]],
           navIndex: 0),
    Figure(slug: "fomalhaut", star: "Fomalhaut", constellation: "Piscis Austrinus",
           dots: [d(0.36, 0.62, 1.2), d(0.52, 0.50, 4.2), d(0.68, 0.56, 4.3),
                  d(0.60, 0.72, 4.5), d(0.44, 0.76, 4.9)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 0]],
           navIndex: 0),
]

let figuresSouth: [Figure] = [
    Figure(slug: "acrux", star: "Acrux", constellation: "Crux",
           dots: [d(0.44, 0.78, 0.8), d(0.46, 0.30, 1.3), d(0.24, 0.52, 1.6),
                  d(0.70, 0.50, 2.8), d(0.60, 0.62, 3.6)],
           links: [[0, 1], [2, 3]],
           navIndex: 0),
    Figure(slug: "canopus", star: "Canopus", constellation: "Carina",
           dots: [d(0.28, 0.36, -0.7), d(0.48, 0.48, 1.7), d(0.66, 0.42, 1.9),
                  d(0.78, 0.58, 2.2), d(0.56, 0.68, 2.8)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 1]],
           navIndex: 0),
    Figure(slug: "achernar", star: "Achernar", constellation: "Eridanus",
           dots: [d(0.20, 0.72, 0.5), d(0.34, 0.58, 3.6), d(0.46, 0.66, 3.9),
                  d(0.60, 0.48, 3.0), d(0.74, 0.56, 3.5), d(0.86, 0.36, 2.8)],
           links: [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5]],
           navIndex: 0),
]

func drawStarPlate(_ fig: Figure, dir: String) {
    let sheet = Sheet(1800, 1350)
    let seed = seedOf("star-" + fig.slug)
    layPaper(sheet, seed: seed, tone: Chart.paperWarm)
    sheet.flipToTopDown()
    sheet.light = 2.1

    let W = sheet.w, H = sheet.h
    let field = CGRect(x: W * 0.072, y: H * 0.080, width: W * 0.856, height: H * 0.700)
    let fieldPath = CGPath(rect: field, transform: nil)
    let night = Tint(r: 0.086, g: 0.129, b: 0.204)

    sheet.clip(fieldPath) {
        sheet.ctx.setFillColor(cgt(night))
        sheet.ctx.fill(field)
        var gr = Spin(seed &+ 3)
        for _ in 0..<50 {
            let x = Double(field.minX) + gr.d() * Double(field.width)
            let y = Double(field.minY) + gr.d() * Double(field.height)
            let rr = gr.r(60, 190)
            if let g = CGGradient(colorsSpace: chartSpace,
                                  colors: [cgt(Chart.seaDeep.al(gr.r(0.10, 0.26))),
                                           cgt(night.al(0))] as CFArray,
                                  locations: [0, 1]) {
                sheet.ctx.drawRadialGradient(g, startCenter: CGPoint(x: x, y: y), startRadius: 0,
                                             endCenter: CGPoint(x: x, y: y), endRadius: rr,
                                             options: [])
            }
        }
    }

    hatch(sheet, fieldPath, angle: 0.60, spacing: 34.0, weight: 1.1,
          colour: Chart.paperCool.al(0.045), coverage: 0.42, bound: fieldPath, seed: seed &+ 11)

    var rng = Spin(seed &+ 97)
    sheet.clip(fieldPath) {
        for _ in 0..<260 {
            let x = Double(field.minX) + rng.d() * Double(field.width)
            let y = Double(field.minY) + rng.d() * Double(field.height)
            let rad = rng.r(1.4, 3.0)
            sheet.disc(x, y, rad, Chart.star.al(rng.r(0.30, 0.78)))
        }
    }

    func place(_ i: Int) -> CGPoint {
        let dot = fig.dots[i]
        return CGPoint(x: field.minX + CGFloat(dot.x) * field.width,
                       y: field.minY + CGFloat(dot.y) * field.height)
    }

    for pair in fig.links {
        guard pair.count == 2 else { continue }
        let a = place(pair[0]), b = place(pair[1])
        penStroke(sheet, [a, b], weight: 2.0, colour: Chart.brassLight.al(0.46),
                  wobble: 0.7, taper: true, seed: seed &+ u64(pair[0] * 31 + pair[1]))
    }

    for i in 0..<fig.dots.count {
        let p = place(i)
        let mag = fig.dots[i].mag
        let radius = max(3.4, 12.0 - mag * 1.9)
        starGlow(sheet, Double(p.x), Double(p.y), radius: radius, bright: mag < 2.6)
    }

    let nav = place(fig.navIndex)
    sheet.ring(Double(nav.x), Double(nav.y), 36, 3.0, Chart.brassLight.al(0.92))
    sheet.ring(Double(nav.x), Double(nav.y), 44, 1.4, Chart.brassLight.al(0.52))
    for k in 0..<4 {
        let a = Double(k) * .pi / 2 + .pi / 4
        penStroke(sheet, [pnt(Double(nav.x) + cos(a) * 44, Double(nav.y) + sin(a) * 44),
                          pnt(Double(nav.x) + cos(a) * 62, Double(nav.y) + sin(a) * 62)],
                  weight: 2.4, colour: Chart.brassLight.al(0.72), wobble: 0.4,
                  taper: true, seed: seed &+ UInt64(k))
    }

    var labelY = Double(nav.y) + 92
    if labelY > Double(field.maxY) - 40 { labelY = Double(nav.y) - 70 }
    let tw = labelWidth(fig.star.uppercased(), size: 30, face: "Georgia-Bold") + 44
    let tag = [pnt(Double(nav.x) - tw / 2, labelY - 30), pnt(Double(nav.x) + tw / 2, labelY - 30),
               pnt(Double(nav.x) + tw / 2, labelY + 12), pnt(Double(nav.x) - tw / 2, labelY + 12)]
    sheet.poly(tag, night.al(0.72))
    label(sheet, fig.star.uppercased(), at: Double(nav.x), labelY,
          size: 30, colour: Chart.star, face: "Georgia-Bold",
          align: .centre, tracking: 3.4)

    sheet.clip(fieldPath) {
        var wr = Spin(seed &+ 311)
        var y = Double(field.maxY) - H * 0.052
        while y < Double(field.maxY) {
            var x = Double(field.minX)
            while x < Double(field.maxX) {
                let len = wr.r(20, 52)
                penStroke(sheet, [pnt(x, y), pnt(x + len * 0.5, y - wr.r(2, 6)), pnt(x + len, y)],
                          weight: 1.8, colour: Chart.paperCool.al(wr.r(0.16, 0.38)),
                          wobble: 0.5, taper: true, seed: seed &+ u64(Int(x + y)))
                x += len + wr.r(16, 40)
            }
            y += wr.r(10, 15)
        }
        penStroke(sheet, [pnt(Double(field.minX), Double(field.maxY) - H * 0.052),
                          pnt(Double(field.maxX), Double(field.maxY) - H * 0.052)],
                  weight: 2.4, colour: Chart.paperCool.al(0.50), wobble: 1.4,
                  taper: false, seed: seed &+ 331)
    }

    sheet.ctx.saveGState()
    sheet.ctx.setStrokeColor(cgt(Chart.ink))
    sheet.ctx.setLineWidth(4.0)
    sheet.ctx.stroke(field)
    sheet.ctx.restoreGState()

    plateBorder(sheet, inset: W * 0.042, seed: seed &+ 7)

    label(sheet, fig.constellation.uppercased(), at: W / 2, H * 0.875,
          size: 34, colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 5.0)
    penStroke(sheet, [pnt(W * 0.30, H * 0.898), pnt(W * 0.70, H * 0.898)],
              weight: 2.2, colour: Chart.ink, wobble: 0.6, taper: true, seed: seed &+ 13)
    label(sheet, "THE NAVIGATOR'S STAR — " + fig.star.uppercased(), at: W / 2, H * 0.935,
          size: 19, colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 3.4)

    sheet.write(dir, "star_" + fig.slug)
}

func starGlow(_ sheet: Sheet, _ x: Double, _ y: Double, radius: Double, bright: Bool) {
    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(Chart.star.al(bright ? 0.42 : 0.26)),
                                   cgt(Chart.star.al(0))] as CFArray,
                          locations: [0, 1]) {
        sheet.ctx.drawRadialGradient(g, startCenter: CGPoint(x: x, y: y), startRadius: 0,
                                     endCenter: CGPoint(x: x, y: y),
                                     endRadius: radius * (bright ? 4.6 : 3.0), options: [])
    }
    sheet.disc(x, y, radius, Chart.star.al(0.98))
    guard bright else { return }
    for k in 0..<4 {
        let a = Double(k) * .pi / 2 + 0.20
        penStroke(sheet, [pnt(x, y), pnt(x + cos(a) * radius * 3.4, y + sin(a) * radius * 3.4)],
                  weight: max(1.6, radius * 0.30), colour: Chart.star.al(0.58),
                  wobble: 0.3, taper: true, seed: u64(Int(x * 7 + y * 13) &+ k))
    }
}

func washBandTop(_ sheet: Sheet, _ field: CGRect, seed: UInt64) {
    let region = [pnt(Double(field.minX) - 20, Double(field.minY) - 16),
                  pnt(Double(field.maxX) + 20, Double(field.minY) - 16),
                  pnt(Double(field.maxX) + 20, Double(field.maxY) + 14),
                  pnt(Double(field.minX) - 20, Double(field.maxY) + 14)]
    wash(sheet, region, Chart.seaDeep, strength: 0.34, bleed: 7, seed: seed)
}

func punchStar(_ sheet: Sheet, _ x: Double, _ y: Double, radius: Double,
               rays: Int, tone: Tint) {
    sheet.disc(x, y, radius * 1.35, tone.al(0.34))
    sheet.disc(x, y, radius, tone.al(0.95))
    guard rays > 0 else { return }
    for k in 0..<rays {
        let a = Double(k) * (.pi * 2 / Double(rays)) + 0.22
        penStroke(sheet, [pnt(x, y), pnt(x + cos(a) * radius * 3.1, y + sin(a) * radius * 3.1)],
                  weight: max(1.3, radius * 0.34), colour: tone.al(0.62),
                  wobble: 0.3, taper: true, seed: u64(Int(x * 7 + y * 13) &+ k))
    }
}
