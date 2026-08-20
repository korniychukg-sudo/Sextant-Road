import Foundation
import CoreGraphics

struct LandMass {
    let pts: [(Double, Double)]
    let wobble: Double
}

struct PlaceMark {
    let x: Double
    let y: Double
    let name: String
    let align: LabelAlign
}

struct VoyageChart {
    let slug: String
    let title: String
    let subtitle: String
    let lands: [LandMass]
    let route: [(Double, Double)]
    let places: [PlaceMark]
    let rose: (Double, Double)
    let ice: Bool
}

func landPath(_ m: LandMass, W: Double, H: Double, seed: UInt64) -> [CGPoint] {
    var rng = Spin(seed)
    var raw: [CGPoint] = m.pts.map { pnt($0.0 * W, $0.1 * H) }
    raw.append(raw[0])
    let smooth = resample(raw, count: max(60, m.pts.count * 9))
    var out: [CGPoint] = []
    for p in smooth {
        out.append(pnt(Double(p.x) + rng.signed() * m.wobble,
                       Double(p.y) + rng.signed() * m.wobble))
    }
    return out
}

func drawGraticule(_ s: Sheet, inset: Double, seed: UInt64) {
    let W = s.w, H = s.h
    var rng = Spin(seed)
    let cols = 7, rows = 5
    for c in 1..<cols {
        let x = inset + (W - inset * 2) * Double(c) / Double(cols)
        s.ctx.saveGState()
        s.ctx.setLineDash(phase: 0, lengths: [3, 9])
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(0.30)))
        s.ctx.setLineWidth(1.2)
        s.ctx.beginPath()
        s.ctx.move(to: pnt(x, inset)); s.ctx.addLine(to: pnt(x, H - inset))
        s.ctx.strokePath()
        s.ctx.restoreGState()
    }
    for r in 1..<rows {
        let y = inset + (H - inset * 2) * Double(r) / Double(rows)
        s.ctx.saveGState()
        s.ctx.setLineDash(phase: 0, lengths: [3, 9])
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(0.30)))
        s.ctx.setLineWidth(1.2)
        s.ctx.beginPath()
        s.ctx.move(to: pnt(inset, y)); s.ctx.addLine(to: pnt(W - inset, y))
        s.ctx.strokePath()
        s.ctx.restoreGState()
    }
    _ = rng.d()
}

func drawRhumbs(_ s: Sheet, cx: Double, cy: Double, seed: UInt64) {
    let span = max(s.w, s.h) * 1.6
    for k in 0..<32 {
        let a = Double(k) * .pi / 16
        s.ctx.saveGState()
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(k % 4 == 0 ? 0.26 : 0.14)))
        s.ctx.setLineWidth(k % 4 == 0 ? 1.4 : 1.0)
        s.ctx.beginPath()
        s.ctx.move(to: pnt(cx, cy))
        s.ctx.addLine(to: pnt(cx + cos(a) * span, cy + sin(a) * span))
        s.ctx.strokePath()
        s.ctx.restoreGState()
    }
    _ = seed
}

func drawSeaTexture(_ s: Sheet, exclude: [CGPath], seed: UInt64) {
    var rng = Spin(seed)
    let W = s.w, H = s.h
    for _ in 0..<300 {
        let x = rng.d() * W
        let y = rng.d() * H
        var inside = false
        for p in exclude where p.contains(pnt(x, y)) { inside = true; break }
        if inside { continue }
        let len = rng.r(16, 42)
        penStroke(s, [pnt(x, y), pnt(x + len * 0.5, y - rng.r(2, 6)), pnt(x + len, y)],
                  weight: 1.4, colour: Chart.sea.al(rng.r(0.20, 0.45)),
                  wobble: 0.4, taper: true, seed: seed &+ u64(Int(x + y * 3)))
    }
}

func drawChartRose(_ s: Sheet, cx: Double, cy: Double, radius: Double, seed: UInt64) {
    s.ring(cx, cy, radius, 2.2, Chart.ink.al(0.85))
    s.ring(cx, cy, radius * 0.86, 1.3, Chart.ink.al(0.6))
    scaleTeeth(s, cx: cx, cy: cy, radius: radius, from: 0, to: .pi * 2,
               count: 32, length: radius * 0.12, seed: seed)
    for k in 0..<8 {
        let a = Double(k) * .pi / 4 - .pi / 2
        let tip = pnt(cx + cos(a) * radius * 0.80, cy + sin(a) * radius * 0.80)
        let l = pnt(cx + cos(a + 0.34) * radius * 0.20, cy + sin(a + 0.34) * radius * 0.20)
        let rp = pnt(cx + cos(a - 0.34) * radius * 0.20, cy + sin(a - 0.34) * radius * 0.20)
        if k % 2 == 0 {
            s.poly([tip, l, pnt(cx, cy)], Chart.ink.al(0.82))
            penContour(s, [tip, rp, pnt(cx, cy)], weight: 1.6, colour: Chart.ink, seed: seed &+ UInt64(k))
        } else {
            s.poly([tip, l, pnt(cx, cy)], Chart.oxblood.al(0.62))
            penContour(s, [tip, rp, pnt(cx, cy)], weight: 1.3, colour: Chart.ink, seed: seed &+ UInt64(k))
        }
    }
    label(s, "N", at: cx, cy - radius * 1.20 + radius * 0.08, size: radius * 0.26,
          colour: Chart.oxblood, face: "Georgia-Bold", align: .centre)
}

func drawIceField(_ s: Sheet, region: CGRect, seed: UInt64) {
    var rng = Spin(seed)
    for _ in 0..<26 {
        let x = Double(region.minX) + rng.d() * Double(region.width)
        let y = Double(region.minY) + rng.d() * Double(region.height)
        let rx = rng.r(18, 52), ry = rx * rng.r(0.4, 0.8)
        let floe = blob(cx: x, cy: y, rx: rx, ry: ry, rough: 0.30, steps: 14,
                        seed: seed &+ u64(Int(x)))
        wash(s, floe, Chart.paperCool.lt(0.35), strength: 0.50, bleed: 2.4,
             seed: seed &+ u64(Int(y)))
        penContour(s, floe, weight: 1.6, colour: Chart.inkSoft, seed: seed &+ u64(Int(x + y)))
    }
}

func drawVoyageChart(_ v: VoyageChart, dir: String) {
    let sheet = Sheet(2400, 1800)
    let seed = seedOf("chart-" + v.slug)
    layPaper(sheet, seed: seed, tone: Chart.paperWarm)
    sheet.flipToTopDown()
    sheet.light = 2.30

    let W = sheet.w, H = sheet.h
    let inset = W * 0.038

    washBand(sheet, from: 0, to: H, Chart.sea, strength: 0.20, seed: seed &+ 3)
    drawRhumbs(sheet, cx: v.rose.0 * W, cy: v.rose.1 * H, seed: seed &+ 5)
    drawGraticule(sheet, inset: inset, seed: seed &+ 7)

    var landPaths: [CGPath] = []
    for (k, m) in v.lands.enumerated() {
        let pts = landPath(m, W: W, H: H, seed: seed &+ UInt64(20 + k * 3))
        let path = polyPath(pts)
        landPaths.append(path)
        wash(sheet, pts, Chart.land, strength: 0.46, bleed: 4.0, seed: seed &+ UInt64(30 + k))
        hatch(sheet, path, angle: 0.42, spacing: 8.4, weight: 1.2,
              colour: Chart.inkSoft.al(0.42), coverage: 0.62, bound: path,
              seed: seed &+ UInt64(40 + k))
        penContour(sheet, pts, weight: 2.6, colour: Chart.ink, seed: seed &+ UInt64(50 + k))
        for step in 1...3 {
            let inner = pts.map { p -> CGPoint in
                var cx = 0.0, cy = 0.0
                for q in pts { cx += Double(q.x); cy += Double(q.y) }
                cx /= Double(pts.count); cy /= Double(pts.count)
                let dx = Double(p.x) - cx, dy = Double(p.y) - cy
                let len = max(1.0, (dx * dx + dy * dy).squareRoot())
                let pull = Double(step) * 6.5
                return pnt(Double(p.x) - dx / len * pull, Double(p.y) - dy / len * pull)
            }
            sheet.ctx.saveGState()
            sheet.ctx.setStrokeColor(cgt(Chart.ink.al(0.22 - Double(step) * 0.05)))
            sheet.ctx.setLineWidth(1.2)
            sheet.ctx.addPath(polyPath(inner))
            sheet.ctx.strokePath()
            sheet.ctx.restoreGState()
        }
    }

    if v.ice {
        drawIceField(sheet, region: CGRect(x: W * 0.06, y: H * 0.06,
                                           width: W * 0.42, height: H * 0.30),
                     seed: seed &+ 71)
    }

    drawSeaTexture(sheet, exclude: landPaths, seed: seed &+ 83)

    let routePts = v.route.map { pnt($0.0 * W, $0.1 * H) }
    let smoothed = resample(routePts, count: 160)
    sheet.ctx.saveGState()
    sheet.ctx.setLineDash(phase: 0, lengths: [16, 11])
    sheet.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.88)))
    sheet.ctx.setLineWidth(4.4)
    sheet.ctx.setLineJoin(.round)
    sheet.ctx.addPath(polyPath(smoothed, close: false))
    sheet.ctx.strokePath()
    sheet.ctx.restoreGState()

    for (k, p) in routePts.enumerated() {
        sheet.disc(Double(p.x), Double(p.y), 11, Chart.paperWarm)
        sheet.ring(Double(p.x), Double(p.y), 11, 2.6, Chart.oxblood)
        if k == 0 || k == routePts.count - 1 {
            sheet.ring(Double(p.x), Double(p.y), 18, 1.8, Chart.oxblood.al(0.7))
        }
    }

    for pl in v.places {
        let px = pl.x * W, py = pl.y * H
        sheet.disc(px, py, 6.5, Chart.ink)
        sheet.ring(px, py, 11, 1.6, Chart.ink.al(0.5))
        let dx = pl.align == .right ? -20.0 : (pl.align == .left ? 20.0 : 0.0)
        let dy = pl.align == .centre ? -22.0 : 10.0
        label(sheet, pl.name, at: px + dx, py + dy, size: 30,
              colour: Chart.ink, face: "Georgia", align: pl.align, tracking: 1.4)
    }

    drawChartRose(sheet, cx: v.rose.0 * W, cy: v.rose.1 * H, radius: W * 0.058, seed: seed &+ 97)

    let barX = W * 0.10, barY = H * 0.925
    penStroke(sheet, [pnt(barX, barY), pnt(barX + W * 0.20, barY)],
              weight: 3.0, colour: Chart.ink, wobble: 0.4, taper: false, seed: seed &+ 101)
    for k in 0...4 {
        let x = barX + W * 0.05 * Double(k)
        penStroke(sheet, [pnt(x, barY - 9), pnt(x, barY + 9)],
                  weight: 2.2, colour: Chart.ink, wobble: 0.3, taper: false,
                  seed: seed &+ UInt64(110 + k))
        if k % 2 == 0 {
            sheet.rect(x, barY - 6, W * 0.05, 12, Chart.ink.al(k % 4 == 0 ? 0.85 : 0.0))
        }
    }
    label(sheet, "0                200                400 NAUTICAL MILES",
          at: barX, barY + 34, size: 18, colour: Chart.inkSoft,
          face: "Georgia", align: .left, tracking: 1.0)

    let cartW = W * 0.42, cartH = H * 0.115
    let cartX = W - inset - cartW - W * 0.02
    let cartY = H - inset - cartH - H * 0.03
    let cart = [pnt(cartX, cartY), pnt(cartX + cartW, cartY),
                pnt(cartX + cartW, cartY + cartH), pnt(cartX, cartY + cartH)]
    wash(sheet, cart, Chart.paperWarm, strength: 0.86, bleed: 3.4, seed: seed &+ 131)
    penContour(sheet, cart, weight: 3.0, colour: Chart.ink, seed: seed &+ 137)
    penContour(sheet, [pnt(cartX + 10, cartY + 10), pnt(cartX + cartW - 10, cartY + 10),
                       pnt(cartX + cartW - 10, cartY + cartH - 10), pnt(cartX + 10, cartY + cartH - 10)],
               weight: 1.4, colour: Chart.inkSoft, seed: seed &+ 139)
    label(sheet, v.title.uppercased(), at: cartX + cartW / 2, cartY + cartH * 0.44,
          size: 34, colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 3.2)
    label(sheet, v.subtitle.uppercased(), at: cartX + cartW / 2, cartY + cartH * 0.78,
          size: 19, colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 2.6)

    plateBorder(sheet, inset: inset, seed: seed &+ 151)

    sheet.write(dir, "chart_" + v.slug, quality: 0.92)
}

let voyageCharts: [VoyageChart] = chartsSetA + chartsSetB

let chartsSetA: [VoyageChart] = [
    VoyageChart(slug: "trades", title: "The Trade Wind Crossing",
                subtitle: "Canaries to Barbados",
                lands: [
                    LandMass(pts: [(0.92, 0.02), (1.04, 0.02), (1.04, 0.98), (0.90, 0.96),
                                   (0.86, 0.74), (0.90, 0.52), (0.86, 0.32), (0.90, 0.16)],
                             wobble: 5.0),
                    LandMass(pts: [(0.78, 0.24), (0.82, 0.22), (0.83, 0.27), (0.79, 0.29)],
                             wobble: 2.4),
                    LandMass(pts: [(0.74, 0.30), (0.78, 0.29), (0.78, 0.34), (0.74, 0.34)],
                             wobble: 2.4),
                    LandMass(pts: [(0.06, 0.52), (0.10, 0.48), (0.12, 0.56), (0.08, 0.60)],
                             wobble: 2.6),
                    LandMass(pts: [(0.04, 0.66), (0.09, 0.64), (0.10, 0.72), (0.05, 0.74)],
                             wobble: 2.6),
                    LandMass(pts: [(0.02, 0.80), (0.08, 0.78), (0.09, 0.88), (0.02, 0.90)],
                             wobble: 3.0),
                ],
                route: [(0.79, 0.27), (0.68, 0.34), (0.56, 0.42), (0.44, 0.50),
                        (0.30, 0.56), (0.18, 0.60), (0.10, 0.58)],
                places: [PlaceMark(x: 0.79, y: 0.27, name: "Tenerife", align: .left),
                         PlaceMark(x: 0.10, y: 0.58, name: "Barbados", align: .right),
                         PlaceMark(x: 0.94, y: 0.42, name: "Africa", align: .right),
                         PlaceMark(x: 0.44, y: 0.50, name: "Mid Ocean", align: .centre)],
                rose: (0.36, 0.24), ice: false),

    VoyageChart(slug: "horn", title: "Round the Horn",
                subtitle: "Valparaiso to Port Stanley",
                lands: [
                    LandMass(pts: [(0.16, -0.04), (0.34, -0.04), (0.36, 0.22), (0.40, 0.44),
                                   (0.46, 0.62), (0.52, 0.74), (0.44, 0.80), (0.34, 0.72),
                                   (0.26, 0.54), (0.20, 0.34), (0.14, 0.16)],
                             wobble: 5.4),
                    LandMass(pts: [(0.46, 0.80), (0.56, 0.78), (0.58, 0.86), (0.48, 0.88)],
                             wobble: 3.2),
                    LandMass(pts: [(0.80, 0.56), (0.88, 0.54), (0.90, 0.64), (0.82, 0.66)],
                             wobble: 3.0),
                ],
                route: [(0.22, 0.12), (0.28, 0.32), (0.36, 0.54), (0.44, 0.74),
                        (0.54, 0.86), (0.68, 0.78), (0.82, 0.62)],
                places: [PlaceMark(x: 0.22, y: 0.12, name: "Valparaiso", align: .left),
                         PlaceMark(x: 0.52, y: 0.86, name: "Cape Horn", align: .centre),
                         PlaceMark(x: 0.84, y: 0.60, name: "Port Stanley", align: .left),
                         PlaceMark(x: 0.30, y: 0.46, name: "Chiloe", align: .right)],
                rose: (0.70, 0.24), ice: false),

    VoyageChart(slug: "iceedge", title: "The Ice Edge",
                subtitle: "Reykjavik to Cape Farewell",
                lands: [
                    LandMass(pts: [(0.72, 0.28), (0.90, 0.22), (0.96, 0.38), (0.88, 0.50),
                                   (0.74, 0.48), (0.68, 0.38)],
                             wobble: 4.6),
                    LandMass(pts: [(-0.06, 0.10), (0.24, 0.06), (0.30, 0.30), (0.26, 0.56),
                                   (0.18, 0.72), (0.06, 0.66), (-0.06, 0.44)],
                             wobble: 5.2),
                ],
                route: [(0.74, 0.40), (0.62, 0.44), (0.50, 0.50), (0.38, 0.58),
                        (0.28, 0.64), (0.20, 0.68)],
                places: [PlaceMark(x: 0.78, y: 0.36, name: "Reykjavik", align: .left),
                         PlaceMark(x: 0.20, y: 0.70, name: "Cape Farewell", align: .left),
                         PlaceMark(x: 0.12, y: 0.34, name: "Greenland", align: .centre),
                         PlaceMark(x: 0.50, y: 0.50, name: "Denmark Strait", align: .centre)],
                rose: (0.58, 0.80), ice: true),

    VoyageChart(slug: "monsoon", title: "The Monsoon Run",
                subtitle: "Zanzibar to Cochin",
                lands: [
                    LandMass(pts: [(-0.04, 0.12), (0.14, 0.16), (0.18, 0.44), (0.16, 0.70),
                                   (0.10, 0.94), (-0.04, 0.96)],
                             wobble: 5.0),
                    LandMass(pts: [(0.72, -0.04), (1.04, -0.04), (1.04, 0.46), (0.92, 0.62),
                                   (0.82, 0.50), (0.76, 0.28)],
                             wobble: 5.0),
                    LandMass(pts: [(0.16, 0.62), (0.20, 0.60), (0.21, 0.68), (0.17, 0.70)],
                             wobble: 2.2),
                ],
                route: [(0.17, 0.66), (0.28, 0.60), (0.42, 0.52), (0.58, 0.44),
                        (0.74, 0.38), (0.86, 0.44)],
                places: [PlaceMark(x: 0.17, y: 0.66, name: "Zanzibar", align: .left),
                         PlaceMark(x: 0.88, y: 0.44, name: "Cochin", align: .right),
                         PlaceMark(x: 0.06, y: 0.42, name: "Africa", align: .centre),
                         PlaceMark(x: 0.92, y: 0.18, name: "India", align: .centre)],
                rose: (0.50, 0.78), ice: false),
]

let chartsSetB: [VoyageChart] = [
    VoyageChart(slug: "greatcircle", title: "The Great Circle",
                subtitle: "Yokohama to San Francisco",
                lands: [
                    LandMass(pts: [(-0.06, 0.44), (0.10, 0.38), (0.16, 0.56), (0.10, 0.76),
                                   (-0.04, 0.80)],
                             wobble: 4.4),
                    LandMass(pts: [(0.86, 0.32), (1.06, 0.28), (1.06, 0.94), (0.90, 0.92),
                                   (0.84, 0.66)],
                             wobble: 4.8),
                    LandMass(pts: [(0.24, 0.10), (0.42, 0.06), (0.44, 0.14), (0.26, 0.18)],
                             wobble: 3.4),
                    LandMass(pts: [(0.50, 0.06), (0.66, 0.04), (0.68, 0.12), (0.52, 0.14)],
                             wobble: 3.4),
                ],
                route: [(0.12, 0.58), (0.24, 0.42), (0.40, 0.28), (0.58, 0.24),
                        (0.74, 0.32), (0.86, 0.46), (0.90, 0.56)],
                places: [PlaceMark(x: 0.12, y: 0.58, name: "Yokohama", align: .left),
                         PlaceMark(x: 0.90, y: 0.56, name: "San Francisco", align: .right),
                         PlaceMark(x: 0.46, y: 0.14, name: "Aleutians", align: .centre),
                         PlaceMark(x: 0.56, y: 0.24, name: "Great Circle Track", align: .centre)],
                rose: (0.46, 0.72), ice: false),

    VoyageChart(slug: "bight", title: "The Great Bight",
                subtitle: "Fremantle to Adelaide",
                lands: [
                    LandMass(pts: [(-0.06, -0.06), (1.06, -0.06), (1.06, 0.30), (0.86, 0.34),
                                   (0.66, 0.40), (0.44, 0.42), (0.24, 0.38), (0.10, 0.30),
                                   (-0.06, 0.26)],
                             wobble: 5.0),
                    LandMass(pts: [(0.80, 0.44), (0.90, 0.42), (0.92, 0.52), (0.82, 0.54)],
                             wobble: 3.0),
                ],
                route: [(0.08, 0.30), (0.20, 0.46), (0.36, 0.56), (0.54, 0.58),
                        (0.70, 0.52), (0.84, 0.40)],
                places: [PlaceMark(x: 0.08, y: 0.30, name: "Fremantle", align: .left),
                         PlaceMark(x: 0.86, y: 0.36, name: "Adelaide", align: .right),
                         PlaceMark(x: 0.46, y: 0.36, name: "Nullarbor", align: .centre),
                         PlaceMark(x: 0.50, y: 0.70, name: "Southern Ocean", align: .centre)],
                rose: (0.24, 0.76), ice: false),

    VoyageChart(slug: "doldrums", title: "The Doldrums Passage",
                subtitle: "Freetown to Recife",
                lands: [
                    LandMass(pts: [(0.84, -0.04), (1.06, -0.04), (1.06, 0.52), (0.94, 0.62),
                                   (0.84, 0.44), (0.80, 0.20)],
                             wobble: 4.8),
                    LandMass(pts: [(-0.06, 0.56), (0.14, 0.52), (0.24, 0.70), (0.18, 0.92),
                                   (-0.06, 0.96)],
                             wobble: 4.8),
                ],
                route: [(0.86, 0.22), (0.72, 0.32), (0.58, 0.44), (0.44, 0.54),
                        (0.30, 0.62), (0.18, 0.70)],
                places: [PlaceMark(x: 0.86, y: 0.22, name: "Freetown", align: .right),
                         PlaceMark(x: 0.18, y: 0.72, name: "Recife", align: .left),
                         PlaceMark(x: 0.52, y: 0.30, name: "The Doldrums", align: .centre),
                         PlaceMark(x: 0.56, y: 0.86, name: "South Atlantic", align: .centre)],
                rose: (0.34, 0.24), ice: false),

    VoyageChart(slug: "baltic", title: "The Winter Baltic",
                subtitle: "Gdansk to Stockholm",
                lands: [
                    LandMass(pts: [(0.30, 0.82), (0.62, 0.78), (0.86, 0.84), (1.06, 0.86),
                                   (1.06, 1.06), (0.20, 1.06), (0.14, 0.94)],
                             wobble: 4.2),
                    LandMass(pts: [(-0.06, -0.06), (0.34, -0.06), (0.30, 0.22), (0.22, 0.42),
                                   (0.12, 0.58), (-0.06, 0.62)],
                             wobble: 4.6),
                    LandMass(pts: [(0.86, -0.06), (1.06, -0.06), (1.06, 0.42), (0.92, 0.46),
                                   (0.84, 0.24)],
                             wobble: 4.2),
                    LandMass(pts: [(0.48, 0.40), (0.60, 0.36), (0.64, 0.52), (0.52, 0.56)],
                             wobble: 3.0),
                ],
                route: [(0.44, 0.86), (0.44, 0.70), (0.42, 0.56), (0.36, 0.42),
                        (0.30, 0.28), (0.26, 0.16)],
                places: [PlaceMark(x: 0.44, y: 0.88, name: "Gdansk", align: .centre),
                         PlaceMark(x: 0.24, y: 0.14, name: "Stockholm", align: .left),
                         PlaceMark(x: 0.56, y: 0.48, name: "Gotland", align: .left),
                         PlaceMark(x: 0.78, y: 0.62, name: "The Baltic", align: .centre)],
                rose: (0.76, 0.24), ice: true),
]
