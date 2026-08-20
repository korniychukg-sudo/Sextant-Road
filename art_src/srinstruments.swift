import Foundation
import CoreGraphics

struct Instrument {
    let slug: String
    let title: String
    let era: String
    let draw: (Sheet, Double, Double, Double, UInt64) -> Void
}

func arcPoints(cx: Double, cy: Double, radius: Double,
               from a0: Double, to a1: Double, steps: Int = 42) -> [CGPoint] {
    var out: [CGPoint] = []
    for i in 0...steps {
        let t = Double(i) / Double(steps)
        let a = a0 + (a1 - a0) * t
        out.append(pnt(cx + cos(a) * radius, cy + sin(a) * radius))
    }
    return out
}

func sectorPath(cx: Double, cy: Double, inner: Double, outer: Double,
                from a0: Double, to a1: Double) -> [CGPoint] {
    var pts = arcPoints(cx: cx, cy: cy, radius: outer, from: a0, to: a1)
    pts += arcPoints(cx: cx, cy: cy, radius: inner, from: a1, to: a0)
    return pts
}

func brassPart(_ s: Sheet, _ pts: [CGPoint], seed: UInt64,
               tone: Tint = Chart.brass, depth: Int = 2, spacing: Double = 4.6) {
    metalPart(s, pts, SextantPalette(metal: tone,
                                     metalDark: Tint(r: 0.318, g: 0.216, b: 0.086),
                                     outline: Chart.ink, mirror: Chart.sea,
                                     glass: Chart.oxblood, wood: Chart.land, strength: 0.78),
              seed: seed, depth: max(2, depth), spacing: spacing, weight: 3.0)
}

func woodPart(_ s: Sheet, _ pts: [CGPoint], seed: UInt64, dark: Bool = false) {
    wash(s, pts, dark ? Tint(r: 0.235, g: 0.169, b: 0.125) : Tint(r: 0.522, g: 0.404, b: 0.259),
         strength: dark ? 0.82 : 0.74, bleed: 3.0, seed: seed)
    let path = polyPath(pts)
    hatch(s, path, angle: 0.10, spacing: 5.4, weight: 1.1,
          colour: Chart.inkSoft.al(0.55), coverage: 0.72, bound: path, seed: seed &+ 13)
    formShade(s, pts, inset: 8, depth: 2, spacing: 5.0,
              colour: Chart.inkSoft.al(0.7), seed: seed &+ 41)
    penContour(s, pts, weight: 2.8, colour: Chart.ink, seed: seed &+ 59)
}

func scaleTeeth(_ s: Sheet, cx: Double, cy: Double, radius: Double,
                from a0: Double, to a1: Double, count: Int, length: Double,
                seed: UInt64, everyFifth: Bool = true) {
    for i in 0...count {
        let t = Double(i) / Double(count)
        let a = a0 + (a1 - a0) * t
        let long = everyFifth && i % 5 == 0
        let len = long ? length * 1.9 : length
        penStroke(s, [pnt(cx + cos(a) * radius, cy + sin(a) * radius),
                      pnt(cx + cos(a) * (radius - len), cy + sin(a) * (radius - len))],
                  weight: long ? 2.1 : 1.3, colour: Chart.ink.al(0.86),
                  wobble: 0.3, taper: false, seed: seed &+ UInt64(i))
    }
}

func dialFace(_ s: Sheet, cx: Double, cy: Double, radius: Double, seed: UInt64,
              numerals: Bool = true) {
    let ring = ellipsePoints(cx: cx, cy: cy, rx: radius, ry: radius, steps: 60)
    wash(s, ring, Chart.paperWarm, strength: 0.72, bleed: 2.4, seed: seed)
    penContour(s, ring, weight: 2.6, colour: Chart.ink, seed: seed &+ 5)
    scaleTeeth(s, cx: cx, cy: cy, radius: radius * 0.94, from: 0, to: .pi * 2,
               count: 60, length: radius * 0.07, seed: seed &+ 21)
    if numerals {
        for k in 0..<12 {
            let a = Double(k) * .pi / 6 - .pi / 2
            let rr = radius * 0.74
            let roman = ["XII", "I", "II", "III", "IIII", "V", "VI",
                         "VII", "VIII", "IX", "X", "XI"][k]
            label(s, roman, at: cx + cos(a) * rr, cy + sin(a) * rr + radius * 0.045,
                  size: radius * 0.15, colour: Chart.ink, face: "Georgia", align: .centre)
        }
    }
    penStroke(s, [pnt(cx, cy), pnt(cx + cos(-1.05) * radius * 0.62,
                                   cy + sin(-1.05) * radius * 0.62)],
              weight: 4.2, colour: Chart.ink, wobble: 0.4, taper: true, seed: seed &+ 33)
    penStroke(s, [pnt(cx, cy), pnt(cx + cos(2.30) * radius * 0.44,
                                   cy + sin(2.30) * radius * 0.44)],
              weight: 5.0, colour: Chart.ink, wobble: 0.4, taper: true, seed: seed &+ 37)
    s.disc(cx, cy, radius * 0.05, Chart.ink)
}

func compassRoseFace(_ s: Sheet, cx: Double, cy: Double, radius: Double, seed: UInt64) {
    let ring = ellipsePoints(cx: cx, cy: cy, rx: radius, ry: radius, steps: 64)
    wash(s, ring, Chart.paperWarm, strength: 0.70, bleed: 2.4, seed: seed)
    penContour(s, ring, weight: 2.4, colour: Chart.ink, seed: seed &+ 3)
    scaleTeeth(s, cx: cx, cy: cy, radius: radius * 0.96, from: 0, to: .pi * 2,
               count: 32, length: radius * 0.10, seed: seed &+ 9)
    for k in 0..<8 {
        let a = Double(k) * .pi / 4 - .pi / 2
        let tipX = cx + cos(a) * radius * 0.80
        let tipY = cy + sin(a) * radius * 0.80
        let leftX = cx + cos(a + 0.30) * radius * 0.22
        let leftY = cy + sin(a + 0.30) * radius * 0.22
        let rightX = cx + cos(a - 0.30) * radius * 0.22
        let rightY = cy + sin(a - 0.30) * radius * 0.22
        let petal = [pnt(tipX, tipY), pnt(leftX, leftY), pnt(cx, cy), pnt(rightX, rightY)]
        if k % 2 == 0 {
            s.poly(petal, Chart.ink.al(0.80))
        } else {
            penContour(s, petal, weight: 1.8, colour: Chart.ink, seed: seed &+ UInt64(k))
        }
    }
    label(s, "N", at: cx, cy - radius * 0.86 + radius * 0.06, size: radius * 0.17,
          colour: Chart.oxblood, face: "Georgia-Bold", align: .centre)
}

let instruments: [Instrument] = instrumentsA + instrumentsB + instrumentsC

let instrumentsA: [Instrument] = [
    Instrument(slug: "sextant", title: "The Sextant", era: "from 1757", draw: drawSextant),
    Instrument(slug: "octant", title: "The Octant", era: "from 1731", draw: drawOctant),
    Instrument(slug: "backstaff", title: "The Backstaff", era: "from 1594", draw: drawBackstaff),
    Instrument(slug: "astrolabe", title: "The Mariner's Astrolabe", era: "from 1481", draw: drawAstrolabe),
    Instrument(slug: "crossstaff", title: "The Cross-Staff", era: "from 1342", draw: drawCrossStaff),
]

let instrumentsB: [Instrument] = [
    Instrument(slug: "kamal", title: "The Kamal", era: "from the 9th century", draw: drawKamal),
    Instrument(slug: "chronometer", title: "The Marine Chronometer", era: "from 1761", draw: drawChronometer),
    Instrument(slug: "chiplog", title: "The Chip Log", era: "from 1574", draw: drawChipLog),
    Instrument(slug: "leadline", title: "The Lead Line", era: "from antiquity", draw: drawLeadLine),
    Instrument(slug: "azimuthcompass", title: "The Azimuth Compass", era: "from 1680", draw: drawAzimuthCompass),
]

let instrumentsC: [Instrument] = [
    Instrument(slug: "traverseboard", title: "The Traverse Board", era: "from 1400", draw: drawTraverseBoard),
    Instrument(slug: "nocturnal", title: "The Nocturnal", era: "from 1520", draw: drawNocturnal),
    Instrument(slug: "stationpointer", title: "The Station Pointer", era: "from 1774", draw: drawStationPointer),
    Instrument(slug: "pelorus", title: "The Pelorus", era: "from 1854", draw: drawPelorus),
]

struct SextantPalette {
    let metal: Tint
    let metalDark: Tint
    let outline: Tint
    let mirror: Tint
    let glass: Tint
    let wood: Tint
    let strength: Double
}

let sextantPlatePalette = SextantPalette(
    metal: Chart.brass, metalDark: Tint(r: 0.318, g: 0.216, b: 0.086), outline: Chart.ink,
    mirror: Chart.sea, glass: Chart.oxblood, wood: Tint(r: 0.290, g: 0.216, b: 0.157),
    strength: 0.78)

let sextantIconPalette = SextantPalette(
    metal: Tint(r: 0.878, g: 0.714, b: 0.322),
    metalDark: Tint(r: 0.353, g: 0.239, b: 0.086),
    outline: Tint(r: 0.071, g: 0.090, b: 0.125),
    mirror: Tint(r: 0.318, g: 0.443, b: 0.514),
    glass: Tint(r: 0.596, g: 0.267, b: 0.196),
    wood: Tint(r: 0.243, g: 0.180, b: 0.129),
    strength: 0.92)

func rotatedAbout(_ pts: [CGPoint], cx: Double, cy: Double, by angle: Double) -> [CGPoint] {
    guard angle != 0 else { return pts }
    let ca = cos(angle), sa = sin(angle)
    return pts.map { p -> CGPoint in
        let dx = Double(p.x) - cx, dy = Double(p.y) - cy
        return pnt(cx + dx * ca - dy * sa, cy + dx * sa + dy * ca)
    }
}

func metalPart(_ s: Sheet, _ pts: [CGPoint], _ pal: SextantPalette, seed: UInt64,
               depth: Int = 3, spacing: Double = 5.0, weight: Double = 3.0) {
    wash(s, pts, pal.metal, strength: pal.strength, bleed: 3.0, seed: seed)
    let path = polyPath(pts)
    let box = path.boundingBox
    let unit = Double(min(box.width, box.height))
    let lx = cos(s.light), ly = sin(s.light)
    var lit: [CGPoint] = []
    var cx = 0.0, cy = 0.0
    for q in pts { cx += Double(q.x); cy += Double(q.y) }
    cx /= Double(pts.count); cy /= Double(pts.count)
    for q in pts {
        var dx = Double(q.x) - cx, dy = Double(q.y) - cy
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 0 else { continue }
        dx /= len; dy /= len
        guard dx * lx + dy * ly > 0.10 else { continue }
        lit.append(q)
        lit.append(pnt(Double(q.x) - dx * unit * 0.30, Double(q.y) - dy * unit * 0.30))
    }
    if lit.count > 3 {
        s.clipBoth(polyPath(lit), path) {
            s.ctx.setFillColor(cgt(pal.metal.lt(0.42).al(0.42)))
            s.ctx.fill(box)
        }
    }
    formShade(s, pts, inset: unit * 0.40, depth: depth, spacing: spacing * 0.72,
              colour: pal.metalDark.al(0.92), seed: seed &+ 17)
    formShade(s, pts, inset: unit * 0.20, depth: max(2, depth), spacing: spacing * 0.58,
              colour: pal.metalDark.dk(0.28).al(0.85), seed: seed &+ 23)
    penContour(s, pts, weight: weight, colour: pal.outline, seed: seed &+ 31)
}

func sextantFigure(_ s: Sheet, cx: Double, cy: Double, radius R: Double,
                   tilt: Double, _ pal: SextantPalette, seed: UInt64) {
    let ax = cx
    let ay = cy - R * 0.78
    let mid = 1.5707963
    let half = 0.42
    let a0 = mid - half
    let a1 = mid + half

    func rot(_ pts: [CGPoint]) -> [CGPoint] { rotatedAbout(pts, cx: cx, cy: cy, by: tilt) }
    func rp(_ x: Double, _ y: Double) -> CGPoint {
        rotatedAbout([pnt(x, y)], cx: cx, cy: cy, by: tilt)[0]
    }
    func onArc(_ a: Double, _ f: Double) -> CGPoint {
        pnt(ax + cos(a) * R * f, ay + sin(a) * R * f)
    }

    let handle = rot([pnt(ax - R * 0.105, ay + R * 0.78), pnt(ax + R * 0.105, ay + R * 0.78),
                      pnt(ax + R * 0.155, ay + R * 0.94), pnt(ax + R * 0.135, ay + R * 1.14),
                      pnt(ax - R * 0.135, ay + R * 1.14), pnt(ax - R * 0.155, ay + R * 0.94)])
    wash(s, handle, pal.wood, strength: pal.strength * 0.94, bleed: 3.0, seed: seed &+ 3)
    formShade(s, handle, inset: 12, depth: 3, spacing: 5.4,
              colour: pal.outline.al(0.70), seed: seed &+ 7)
    penContour(s, handle, weight: 3.2, colour: pal.outline, seed: seed &+ 11)

    let limb = rot(sectorPath(cx: ax, cy: ay, inner: R * 0.80, outer: R, from: a0, to: a1))
    metalPart(s, limb, pal, seed: seed &+ 21, depth: 3, spacing: 5.2, weight: 3.4)

    for i in 0...44 {
        let t = Double(i) / 44.0
        let a = a0 + (a1 - a0) * t
        let long = i % 5 == 0
        let outerP = onArc(a, 0.995)
        let innerP = onArc(a, long ? 0.890 : 0.930)
        let seg = rot([outerP, innerP])
        penStroke(s, seg, weight: long ? R * 0.010 : R * 0.006,
                  colour: pal.outline.al(0.85), wobble: 0.3, taper: false,
                  seed: seed &+ UInt64(60 + i))
    }

    for (k, ang) in [a0 + 0.045, a1 - 0.045].enumerated() {
        let rib = rot([pnt(ax - R * 0.055, ay + R * 0.02), pnt(ax + R * 0.055, ay + R * 0.02),
                       onArc(ang, 0.90), onArc(ang + (k == 0 ? 0.10 : -0.10), 0.90)])
        metalPart(s, rib, pal, seed: seed &+ UInt64(120 + k * 9), depth: 2,
                  spacing: 6.0, weight: 3.0)
    }

    let cross = rot([onArc(a0 + 0.10, 0.46), onArc(a1 - 0.10, 0.46),
                     onArc(a1 - 0.10, 0.56), onArc(a0 + 0.10, 0.56)])
    metalPart(s, cross, pal, seed: seed &+ 141, depth: 2, spacing: 6.4, weight: 2.6)

    let armAngle = mid - 0.20
    let armTip = onArc(armAngle, 1.0)
    let perp = armAngle + 1.5707963
    let arm = rot([pnt(ax + cos(perp) * R * 0.060, ay + sin(perp) * R * 0.060),
                   pnt(ax - cos(perp) * R * 0.060, ay - sin(perp) * R * 0.060),
                   pnt(Double(armTip.x) - cos(perp) * R * 0.035,
                       Double(armTip.y) - sin(perp) * R * 0.035),
                   pnt(Double(armTip.x) + cos(perp) * R * 0.035,
                       Double(armTip.y) + sin(perp) * R * 0.035)])
    metalPart(s, arm, pal, seed: seed &+ 161, depth: 3, spacing: 4.6, weight: 3.2)

    let drumC = onArc(armAngle, 0.96)
    let drum = rot(ellipsePoints(cx: Double(drumC.x), cy: Double(drumC.y),
                                 rx: R * 0.105, ry: R * 0.105, steps: 34))
    metalPart(s, drum, pal, seed: seed &+ 181, depth: 3, spacing: 4.0, weight: 3.0)
    for i in 0..<26 {
        let a = Double(i) * .pi * 2 / 26
        let seg = rot([pnt(Double(drumC.x) + cos(a) * R * 0.100,
                           Double(drumC.y) + sin(a) * R * 0.100),
                       pnt(Double(drumC.x) + cos(a) * R * 0.072,
                           Double(drumC.y) + sin(a) * R * 0.072)])
        penStroke(s, seg, weight: R * 0.006, colour: pal.outline.al(0.72),
                  wobble: 0.2, taper: false, seed: seed &+ UInt64(200 + i))
    }

    let idx = rot([pnt(Double(armTip.x), Double(armTip.y)),
                   pnt(Double(armTip.x) + cos(perp) * R * 0.02,
                       Double(armTip.y) + sin(perp) * R * 0.02)])
    penStroke(s, idx, weight: R * 0.012, colour: pal.glass, wobble: 0.2,
              taper: false, seed: seed &+ 231)

    let mirrorA = rot([pnt(ax - R * 0.105, ay - R * 0.135), pnt(ax + R * 0.105, ay - R * 0.135),
                       pnt(ax + R * 0.105, ay + R * 0.045), pnt(ax - R * 0.105, ay + R * 0.045)])
    wash(s, mirrorA, pal.mirror, strength: pal.strength * 0.92, bleed: 2.4, seed: seed &+ 241)
    hatch(s, polyPath(mirrorA), angle: -0.78, spacing: R * 0.030, weight: R * 0.005,
          colour: pal.metal.lt(0.45).al(0.48), coverage: 0.72,
          bound: polyPath(mirrorA), seed: seed &+ 247)
    penContour(s, mirrorA, weight: 3.0, colour: pal.outline, seed: seed &+ 251)

    let capA = rot([pnt(ax - R * 0.125, ay - R * 0.165), pnt(ax + R * 0.125, ay - R * 0.165),
                    pnt(ax + R * 0.125, ay - R * 0.125), pnt(ax - R * 0.125, ay - R * 0.125)])
    metalPart(s, capA, pal, seed: seed &+ 257, depth: 2, spacing: 5.0, weight: 2.4)

    let hm = onArc(a1 - 0.045, 0.50)
    let mirrorB = rot([pnt(Double(hm.x) - R * 0.075, Double(hm.y) - R * 0.115),
                       pnt(Double(hm.x) + R * 0.075, Double(hm.y) - R * 0.115),
                       pnt(Double(hm.x) + R * 0.075, Double(hm.y) + R * 0.035),
                       pnt(Double(hm.x) - R * 0.075, Double(hm.y) + R * 0.035)])
    wash(s, mirrorB, pal.mirror, strength: pal.strength * 0.80, bleed: 2.2, seed: seed &+ 271)
    hatch(s, polyPath(mirrorB), angle: -0.78, spacing: R * 0.028, weight: R * 0.004,
          colour: pal.metal.lt(0.45).al(0.42), coverage: 0.62,
          bound: polyPath(mirrorB), seed: seed &+ 277)
    penContour(s, mirrorB, weight: 2.6, colour: pal.outline, seed: seed &+ 281)

    let scopeY = Double(hm.y) - R * 0.040
    let scopeRight = Double(hm.x) - R * 0.060
    let scope = rot([pnt(scopeRight - R * 0.52, scopeY - R * 0.070),
                     pnt(scopeRight, scopeY - R * 0.052),
                     pnt(scopeRight, scopeY + R * 0.052),
                     pnt(scopeRight - R * 0.52, scopeY + R * 0.070)])
    metalPart(s, scope, pal, seed: seed &+ 291, depth: 3, spacing: 4.4, weight: 3.0)
    let eyecup = rot([pnt(scopeRight - R * 0.575, scopeY - R * 0.088),
                      pnt(scopeRight - R * 0.500, scopeY - R * 0.070),
                      pnt(scopeRight - R * 0.500, scopeY + R * 0.070),
                      pnt(scopeRight - R * 0.575, scopeY + R * 0.088)])
    metalPart(s, eyecup, pal, seed: seed &+ 301, depth: 2, spacing: 4.8, weight: 2.6)

    for k in 0..<3 {
        let base = onArc(mid - 0.06, 0.30 + Double(k) * 0.115)
        let gx = Double(base.x) + R * 0.030
        let gy = Double(base.y) - R * 0.045
        let glass = rot([pnt(gx, gy), pnt(gx + R * 0.085, gy - R * 0.020),
                         pnt(gx + R * 0.085, gy + R * 0.085), pnt(gx, gy + R * 0.105)])
        wash(s, glass, k == 0 ? pal.glass : pal.metalDark,
             strength: pal.strength * (0.42 + Double(k) * 0.16), bleed: 2.0,
             seed: seed &+ UInt64(311 + k))
        penContour(s, glass, weight: 2.2, colour: pal.outline, seed: seed &+ UInt64(321 + k))
    }
}

func drawSextant(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let R = 150.0 * scale * 1.31
    sextantFigure(s, cx: cx + R * 0.14, cy: cy + R * 0.24, radius: R,
                  tilt: -0.14, sextantPlatePalette, seed: seed)
}

func drawOctant(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let apexX = cx - r * 0.06
    let apexY = cy - r * 0.82

    let frameOuter = sectorPath(cx: apexX, cy: apexY, inner: r * 0.10, outer: r * 1.00,
                                from: 0.60, to: 1.36)
    woodPart(s, frameOuter, seed: seed, dark: true)

    let void = sectorPath(cx: apexX, cy: apexY, inner: r * 0.30, outer: r * 0.80,
                          from: 0.72, to: 1.24)
    wash(s, void, Chart.paperWarm, strength: 0.86, bleed: 2.4, seed: seed &+ 11)
    penContour(s, void, weight: 2.0, colour: Chart.ink, seed: seed &+ 13)

    let limb = sectorPath(cx: apexX, cy: apexY, inner: r * 0.84, outer: r * 0.99,
                          from: 0.60, to: 1.36)
    wash(s, limb, Chart.paperWarm.dk(0.06), strength: 0.72, bleed: 2.0, seed: seed &+ 17)
    penContour(s, limb, weight: 2.0, colour: Chart.ink, seed: seed &+ 19)
    scaleTeeth(s, cx: apexX, cy: apexY, radius: r * 0.98, from: 0.62, to: 1.34,
               count: 40, length: r * 0.070, seed: seed &+ 23)

    let armAngle = 1.02
    let arm = [pnt(apexX - r * 0.05, apexY),
               pnt(apexX + r * 0.05, apexY + r * 0.02),
               pnt(apexX + cos(armAngle) * r * 1.02 + r * 0.02, apexY + sin(armAngle) * r * 1.02),
               pnt(apexX + cos(armAngle) * r * 1.02 - r * 0.05, apexY + sin(armAngle) * r * 1.02)]
    woodPart(s, arm, seed: seed &+ 29)

    let mirror = [pnt(apexX - r * 0.09, apexY - r * 0.12), pnt(apexX + r * 0.09, apexY - r * 0.12),
                  pnt(apexX + r * 0.09, apexY + r * 0.06), pnt(apexX - r * 0.09, apexY + r * 0.06)]
    wash(s, mirror, Chart.sea, strength: 0.48, bleed: 2, seed: seed &+ 31)
    penContour(s, mirror, weight: 2.2, colour: Chart.ink, seed: seed &+ 37)

    let sightX = apexX + cos(0.66) * r * 0.56
    let sightY = apexY + sin(0.66) * r * 0.56
    let vane = [pnt(sightX - r * 0.05, sightY - r * 0.16), pnt(sightX + r * 0.05, sightY - r * 0.16),
                pnt(sightX + r * 0.05, sightY + r * 0.04), pnt(sightX - r * 0.05, sightY + r * 0.04)]
    brassPart(s, vane, seed: seed &+ 41, depth: 2, spacing: 4.4)
    s.disc(sightX, sightY - r * 0.07, r * 0.020, Chart.paperWarm)

    let index = pnt(apexX + cos(armAngle) * r * 0.92, apexY + sin(armAngle) * r * 0.92)
    penStroke(s, [pnt(Double(index.x), Double(index.y) - r * 0.06),
                  pnt(Double(index.x), Double(index.y) + r * 0.06)],
              weight: 2.6, colour: Chart.oxblood, wobble: 0.3, taper: false, seed: seed &+ 43)

    let brace = [pnt(apexX + cos(0.78) * r * 0.36, apexY + sin(0.78) * r * 0.36),
                 pnt(apexX + cos(1.18) * r * 0.36, apexY + sin(1.18) * r * 0.36),
                 pnt(apexX + cos(1.16) * r * 0.80, apexY + sin(1.16) * r * 0.80),
                 pnt(apexX + cos(0.80) * r * 0.80, apexY + sin(0.80) * r * 0.80)]
    penContour(s, brace, weight: 2.0, colour: Chart.ink, seed: seed &+ 47)
    hatch(s, polyPath(brace), angle: 0.5, spacing: 7.0, weight: 1.0,
          colour: Chart.inkSoft.al(0.4), coverage: 0.55, bound: polyPath(brace), seed: seed &+ 53)
}

func drawBackstaff(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let staff = [pnt(cx - r * 0.98, cy - r * 0.05), pnt(cx + r * 0.86, cy - r * 0.05),
                 pnt(cx + r * 0.86, cy + r * 0.05), pnt(cx - r * 0.98, cy + r * 0.05)]
    woodPart(s, staff, seed: seed)

    let bigX = cx - r * 0.86
    let bigArc = sectorPath(cx: bigX, cy: cy, inner: r * 0.68, outer: r * 0.80,
                            from: -0.62, to: 0.62)
    woodPart(s, bigArc, seed: seed &+ 11)
    scaleTeeth(s, cx: bigX, cy: cy, radius: r * 0.79, from: -0.60, to: 0.60,
               count: 30, length: r * 0.055, seed: seed &+ 13)

    let smallX = cx + r * 0.72
    let smallArc = sectorPath(cx: smallX, cy: cy, inner: r * 0.30, outer: r * 0.40,
                              from: 2.52, to: 3.76)
    woodPart(s, smallArc, seed: seed &+ 17)
    scaleTeeth(s, cx: smallX, cy: cy, radius: r * 0.395, from: 2.54, to: 3.74,
               count: 22, length: r * 0.045, seed: seed &+ 19)

    let braceA = [pnt(bigX + cos(-0.60) * r * 0.78, cy + sin(-0.60) * r * 0.78),
                  pnt(bigX + cos(-0.60) * r * 0.72, cy + sin(-0.60) * r * 0.72),
                  pnt(cx + r * 0.40, cy - r * 0.03), pnt(cx + r * 0.40, cy + r * 0.02)]
    penContour(s, braceA, weight: 2.2, colour: Chart.ink, seed: seed &+ 23)
    let braceB = [pnt(bigX + cos(0.60) * r * 0.78, cy + sin(0.60) * r * 0.78),
                  pnt(bigX + cos(0.60) * r * 0.72, cy + sin(0.60) * r * 0.72),
                  pnt(cx + r * 0.40, cy + r * 0.03), pnt(cx + r * 0.40, cy - r * 0.02)]
    penContour(s, braceB, weight: 2.2, colour: Chart.ink, seed: seed &+ 29)

    for (k, ang) in [(-0.30, 0), (0.34, 1)].enumerated() {
        _ = ang
        let a = k == 0 ? -0.30 : 0.34
        let vx = bigX + cos(a) * r * 0.74
        let vy = cy + sin(a) * r * 0.74
        let vane = [pnt(vx - r * 0.035, vy - r * 0.13), pnt(vx + r * 0.035, vy - r * 0.13),
                    pnt(vx + r * 0.035, vy + r * 0.03), pnt(vx - r * 0.035, vy + r * 0.03)]
        brassPart(s, vane, seed: seed &+ UInt64(31 + k * 7), depth: 2, spacing: 4.4)
    }

    let horizVane = [pnt(cx + r * 0.70, cy - r * 0.20), pnt(cx + r * 0.78, cy - r * 0.20),
                     pnt(cx + r * 0.78, cy + r * 0.20), pnt(cx + r * 0.70, cy + r * 0.20)]
    brassPart(s, horizVane, seed: seed &+ 47, depth: 2, spacing: 4.2)
    penStroke(s, [pnt(cx + r * 0.66, cy), pnt(cx + r * 0.82, cy)],
              weight: 2.0, colour: Chart.ink, wobble: 0.3, taper: false, seed: seed &+ 53)

    let sun = pnt(cx - r * 0.30, cy - r * 0.66)
    for k in 0..<10 {
        let a = Double(k) * .pi / 5
        penStroke(s, [pnt(Double(sun.x) + cos(a) * r * 0.10, Double(sun.y) + sin(a) * r * 0.10),
                      pnt(Double(sun.x) + cos(a) * r * 0.18, Double(sun.y) + sin(a) * r * 0.18)],
                  weight: 1.6, colour: Chart.brass.dk(0.15), wobble: 0.3,
                  taper: true, seed: seed &+ UInt64(60 + k))
    }
    s.ring(Double(sun.x), Double(sun.y), r * 0.09, 2.4, Chart.brass.dk(0.2))
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [7, 7])
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.6)))
    s.ctx.setLineWidth(1.8)
    s.ctx.beginPath()
    s.ctx.move(to: sun)
    s.ctx.addLine(to: pnt(cx + r * 0.74, cy))
    s.ctx.strokePath()
    s.ctx.restoreGState()
}

func drawAstrolabe(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 148.0 * scale
    let outer = ellipsePoints(cx: cx, cy: cy, rx: r * 0.92, ry: r * 0.92, steps: 64)
    let inner = ellipsePoints(cx: cx, cy: cy, rx: r * 0.74, ry: r * 0.74, steps: 64)
    let annulus = outer + inner.reversed()
    brassPart(s, annulus, seed: seed, depth: 3, spacing: 4.4)
    scaleTeeth(s, cx: cx, cy: cy, radius: r * 0.90, from: 0, to: .pi * 2,
               count: 72, length: r * 0.06, seed: seed &+ 11)

    for k in 0..<4 {
        let a = Double(k) * .pi / 2
        let spoke = [pnt(cx + cos(a) * r * 0.74 + cos(a + 1.5708) * r * 0.05,
                         cy + sin(a) * r * 0.74 + sin(a + 1.5708) * r * 0.05),
                     pnt(cx + cos(a) * r * 0.74 - cos(a + 1.5708) * r * 0.05,
                         cy + sin(a) * r * 0.74 - sin(a + 1.5708) * r * 0.05),
                     pnt(cx - cos(a + 1.5708) * r * 0.05, cy - sin(a + 1.5708) * r * 0.05),
                     pnt(cx + cos(a + 1.5708) * r * 0.05, cy + sin(a + 1.5708) * r * 0.05)]
        if k < 2 { brassPart(s, spoke, seed: seed &+ UInt64(20 + k), depth: 2, spacing: 5.0) }
    }

    let alidadeAngle = -0.62
    let alidade = [pnt(cx + cos(alidadeAngle) * r * 0.88 + cos(alidadeAngle + 1.5708) * r * 0.035,
                       cy + sin(alidadeAngle) * r * 0.88 + sin(alidadeAngle + 1.5708) * r * 0.035),
                   pnt(cx + cos(alidadeAngle) * r * 0.88 - cos(alidadeAngle + 1.5708) * r * 0.035,
                       cy + sin(alidadeAngle) * r * 0.88 - sin(alidadeAngle + 1.5708) * r * 0.035),
                   pnt(cx - cos(alidadeAngle) * r * 0.88 - cos(alidadeAngle + 1.5708) * r * 0.035,
                       cy - sin(alidadeAngle) * r * 0.88 - sin(alidadeAngle + 1.5708) * r * 0.035),
                   pnt(cx - cos(alidadeAngle) * r * 0.88 + cos(alidadeAngle + 1.5708) * r * 0.035,
                       cy - sin(alidadeAngle) * r * 0.88 + sin(alidadeAngle + 1.5708) * r * 0.035)]
    brassPart(s, alidade, seed: seed &+ 41, depth: 3, spacing: 3.8)

    for sgn in [1.0, -1.0] {
        let px = cx + cos(alidadeAngle) * r * 0.62 * sgn
        let py = cy + sin(alidadeAngle) * r * 0.62 * sgn
        let tab = [pnt(px - r * 0.045, py - r * 0.10), pnt(px + r * 0.045, py - r * 0.10),
                   pnt(px + r * 0.045, py + r * 0.02), pnt(px - r * 0.045, py + r * 0.02)]
        brassPart(s, tab, seed: seed &+ UInt64(50 + Int(sgn * 3)), depth: 2, spacing: 4.0)
        s.disc(px, py - r * 0.045, r * 0.016, Chart.paperWarm)
    }
    s.disc(cx, cy, r * 0.06, Chart.brass.dk(0.10))
    s.ring(cx, cy, r * 0.06, 2.4, Chart.ink)

    let ringX = cx
    let ringY = cy - r * 1.06
    s.ring(ringX, ringY, r * 0.10, 5.0, Chart.brass.dk(0.12))
    s.ring(ringX, ringY, r * 0.10, 2.0, Chart.ink)
    let shackle = [pnt(cx - r * 0.05, cy - r * 0.99), pnt(cx + r * 0.05, cy - r * 0.99),
                   pnt(cx + r * 0.04, cy - r * 0.88), pnt(cx - r * 0.04, cy - r * 0.88)]
    brassPart(s, shackle, seed: seed &+ 61, depth: 2, spacing: 4.0)

    for k in 0..<4 {
        let a = 0.30 + Double(k) * 1.5708
        label(s, ["0", "30", "60", "90"][k],
              at: cx + cos(a) * r * 0.83, cy + sin(a) * r * 0.83 + r * 0.02,
              size: r * 0.075, colour: Chart.ink, face: "Georgia", align: .centre)
    }
}

func drawCrossStaff(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let staff = [pnt(cx - r * 1.02, cy - r * 0.045), pnt(cx + r * 1.02, cy - r * 0.045),
                 pnt(cx + r * 1.02, cy + r * 0.045), pnt(cx - r * 1.02, cy + r * 0.045)]
    woodPart(s, staff, seed: seed)

    for k in 0...16 {
        let x = cx - r * 0.96 + Double(k) * r * 0.12
        let long = k % 4 == 0
        penStroke(s, [pnt(x, cy - r * 0.045), pnt(x, cy - r * 0.045 + (long ? r * 0.05 : r * 0.028))],
                  weight: long ? 2.0 : 1.2, colour: Chart.ink.al(0.8),
                  wobble: 0.3, taper: false, seed: seed &+ UInt64(k))
    }

    let transomX = cx + r * 0.18
    let transom = [pnt(transomX - r * 0.05, cy - r * 0.62), pnt(transomX + r * 0.05, cy - r * 0.62),
                   pnt(transomX + r * 0.05, cy + r * 0.62), pnt(transomX - r * 0.05, cy + r * 0.62)]
    woodPart(s, transom, seed: seed &+ 21, dark: true)

    let collar = [pnt(transomX - r * 0.10, cy - r * 0.09), pnt(transomX + r * 0.10, cy - r * 0.09),
                  pnt(transomX + r * 0.10, cy + r * 0.09), pnt(transomX - r * 0.10, cy + r * 0.09)]
    brassPart(s, collar, seed: seed &+ 31, depth: 2, spacing: 4.2)

    let eye = pnt(cx - r * 0.98, cy)
    s.ring(Double(eye.x), Double(eye.y), r * 0.055, 2.6, Chart.ink)
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [8, 7])
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.62)))
    s.ctx.setLineWidth(1.8)
    s.ctx.beginPath()
    s.ctx.move(to: eye); s.ctx.addLine(to: pnt(transomX, cy - r * 0.60))
    s.ctx.move(to: eye); s.ctx.addLine(to: pnt(transomX, cy + r * 0.60))
    s.ctx.strokePath()
    s.ctx.restoreGState()

    label(s, "HORIZON", at: transomX + r * 0.28, cy + r * 0.62, size: r * 0.075,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.6)
    label(s, "STAR", at: transomX + r * 0.28, cy - r * 0.58, size: r * 0.075,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.6)
}

func drawKamal(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let plateX = cx + r * 0.34
    let board = [pnt(plateX - r * 0.34, cy - r * 0.24), pnt(plateX + r * 0.34, cy - r * 0.24),
                 pnt(plateX + r * 0.34, cy + r * 0.24), pnt(plateX - r * 0.34, cy + r * 0.24)]
    woodPart(s, board, seed: seed)

    let hole = ellipsePoints(cx: plateX, cy: cy, rx: r * 0.030, ry: r * 0.030, steps: 24)
    s.poly(hole, Chart.ink)

    var rng = Spin(seed &+ 11)
    var cordPts: [CGPoint] = []
    for k in 0...30 {
        let t = Double(k) / 30.0
        let x = plateX - t * r * 1.20
        let y = cy + sin(t * 3.4) * r * 0.03 + rng.signed() * 1.4
        cordPts.append(pnt(x, y))
    }
    penStroke(s, cordPts, weight: 3.0, colour: Chart.ink, wobble: 0.6,
              taper: false, seed: seed &+ 17)

    for k in 1...7 {
        let t = Double(k) / 8.0
        let idx = Int(t * 30)
        let p = cordPts[min(idx, cordPts.count - 1)]
        s.disc(Double(p.x), Double(p.y), r * 0.028, Chart.ink)
        s.disc(Double(p.x) - r * 0.008, Double(p.y) - r * 0.008, r * 0.012, Chart.paperWarm.al(0.6))
        label(s, "\(k)", at: Double(p.x), Double(p.y) + r * 0.115, size: r * 0.068,
              colour: Chart.inkSoft, face: "Georgia", align: .centre)
    }

    let eye = pnt(cx - r * 0.96, cy)
    s.ring(Double(eye.x), Double(eye.y), r * 0.05, 2.4, Chart.ink)
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [8, 7])
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.6)))
    s.ctx.setLineWidth(1.7)
    s.ctx.beginPath()
    s.ctx.move(to: eye); s.ctx.addLine(to: pnt(plateX, cy - r * 0.22))
    s.ctx.move(to: eye); s.ctx.addLine(to: pnt(plateX, cy + r * 0.22))
    s.ctx.strokePath()
    s.ctx.restoreGState()

    label(s, "POLE STAR", at: plateX + r * 0.42, cy - r * 0.22, size: r * 0.072,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.4)
    label(s, "HORIZON", at: plateX + r * 0.42, cy + r * 0.26, size: r * 0.072,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.4)
}

func drawChronometer(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let box = [pnt(cx - r * 0.86, cy - r * 0.72), pnt(cx + r * 0.86, cy - r * 0.72),
               pnt(cx + r * 0.86, cy + r * 0.78), pnt(cx - r * 0.86, cy + r * 0.78)]
    woodPart(s, box, seed: seed, dark: true)

    let lid = [pnt(cx - r * 0.86, cy - r * 0.72), pnt(cx + r * 0.86, cy - r * 0.72),
               pnt(cx + r * 0.78, cy - r * 0.60), pnt(cx - r * 0.78, cy - r * 0.60)]
    wash(s, lid, Chart.land.dk(0.10), strength: 0.44, bleed: 2.4, seed: seed &+ 11)
    penContour(s, lid, weight: 2.2, colour: Chart.ink, seed: seed &+ 13)

    let inner = [pnt(cx - r * 0.70, cy - r * 0.54), pnt(cx + r * 0.70, cy - r * 0.54),
                 pnt(cx + r * 0.70, cy + r * 0.62), pnt(cx - r * 0.70, cy + r * 0.62)]
    wash(s, inner, Chart.paperWarm.dk(0.10), strength: 0.60, bleed: 2.2, seed: seed &+ 17)
    penContour(s, inner, weight: 2.0, colour: Chart.ink, seed: seed &+ 19)

    let gimbal = ellipsePoints(cx: cx, cy: cy + r * 0.02, rx: r * 0.58, ry: r * 0.58, steps: 56)
    let gimbalIn = ellipsePoints(cx: cx, cy: cy + r * 0.02, rx: r * 0.50, ry: r * 0.50, steps: 56)
    brassPart(s, gimbal + gimbalIn.reversed(), seed: seed &+ 23, depth: 2, spacing: 4.4)

    dialFace(s, cx: cx, cy: cy + r * 0.02, radius: r * 0.46, seed: seed &+ 29)

    let subX = cx
    let subY = cy + r * 0.02 + r * 0.22
    s.ring(subX, subY, r * 0.13, 2.0, Chart.ink)
    scaleTeeth(s, cx: subX, cy: subY, radius: r * 0.125, from: 0, to: .pi * 2,
               count: 20, length: r * 0.028, seed: seed &+ 31, everyFifth: false)
    penStroke(s, [pnt(subX, subY), pnt(subX + cos(-0.4) * r * 0.10, subY + sin(-0.4) * r * 0.10)],
              weight: 2.2, colour: Chart.oxblood, wobble: 0.3, taper: true, seed: seed &+ 37)

    for sgn in [-1.0, 1.0] {
        let px = cx + sgn * r * 0.60
        let piv = ellipsePoints(cx: px, cy: cy + r * 0.02, rx: r * 0.055, ry: r * 0.055, steps: 22)
        brassPart(s, piv, seed: seed &+ UInt64(41 + Int(sgn * 2)), depth: 2, spacing: 3.4)
    }

    label(s, "GREENWICH", at: cx, cy - r * 0.20, size: r * 0.065,
          colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 2.2)
}

func drawChipLog(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale

    let reelX = cx - r * 0.46
    let reelY = cy - r * 0.06
    let rim = ellipsePoints(cx: reelX, cy: reelY, rx: r * 0.42, ry: r * 0.42, steps: 52)
    woodPart(s, rim, seed: seed)
    let hub = ellipsePoints(cx: reelX, cy: reelY, rx: r * 0.13, ry: r * 0.13, steps: 26)
    wash(s, hub, Chart.paperWarm, strength: 0.60, bleed: 2, seed: seed &+ 7)
    penContour(s, hub, weight: 2.2, colour: Chart.ink, seed: seed &+ 11)
    for k in 0..<8 {
        let a = Double(k) * .pi / 4 + 0.2
        penStroke(s, [pnt(reelX + cos(a) * r * 0.14, reelY + sin(a) * r * 0.14),
                      pnt(reelX + cos(a) * r * 0.40, reelY + sin(a) * r * 0.40)],
                  weight: 2.4, colour: Chart.ink.al(0.72), wobble: 0.4,
                  taper: false, seed: seed &+ UInt64(20 + k))
    }
    for k in 0..<7 {
        s.ring(reelX, reelY, r * (0.18 + Double(k) * 0.030), 1.5, Chart.inkSoft.al(0.5))
    }

    var rng = Spin(seed &+ 41)
    var line: [CGPoint] = []
    for k in 0...36 {
        let t = Double(k) / 36.0
        let x = reelX + r * 0.40 + t * r * 0.88
        let y = reelY + sin(t * 4.2) * r * 0.10 + rng.signed() * 1.6 + t * r * 0.22
        line.append(pnt(x, y))
    }
    penStroke(s, line, weight: 2.6, colour: Chart.ink, wobble: 0.7, taper: false, seed: seed &+ 43)
    for k in 1...5 {
        let idx = k * 6
        let p = line[min(idx, line.count - 1)]
        penStroke(s, [pnt(Double(p.x), Double(p.y) - r * 0.045),
                      pnt(Double(p.x), Double(p.y) + r * 0.045)],
                  weight: 2.6, colour: Chart.oxblood.al(0.85), wobble: 0.3,
                  taper: true, seed: seed &+ UInt64(50 + k))
    }

    let chipX = cx + r * 0.72
    let chipY = cy + r * 0.34
    let chip = [pnt(chipX - r * 0.24, chipY + r * 0.20), pnt(chipX + r * 0.24, chipY + r * 0.20),
                pnt(chipX, chipY - r * 0.24)]
    woodPart(s, chip, seed: seed &+ 61)
    for k in 0..<3 {
        let corner = chip[k]
        penStroke(s, [corner, pnt(chipX, chipY)], weight: 1.8,
                  colour: Chart.ink.al(0.7), wobble: 0.4, taper: true, seed: seed &+ UInt64(70 + k))
    }
    let lead = [pnt(chipX - r * 0.20, chipY + r * 0.14), pnt(chipX + r * 0.20, chipY + r * 0.14),
                pnt(chipX + r * 0.20, chipY + r * 0.21), pnt(chipX - r * 0.20, chipY + r * 0.21)]
    wash(s, lead, Chart.inkSoft, strength: 0.55, bleed: 1.8, seed: seed &+ 73)
    penContour(s, lead, weight: 1.9, colour: Chart.ink, seed: seed &+ 79)

    let glassX = cx + r * 0.60
    let glassY = cy - r * 0.56
    let bulbTop = [pnt(glassX - r * 0.13, glassY - r * 0.26), pnt(glassX + r * 0.13, glassY - r * 0.26),
                   pnt(glassX + r * 0.02, glassY), pnt(glassX - r * 0.02, glassY)]
    let bulbLow = [pnt(glassX - r * 0.02, glassY), pnt(glassX + r * 0.02, glassY),
                   pnt(glassX + r * 0.13, glassY + r * 0.26), pnt(glassX - r * 0.13, glassY + r * 0.26)]
    penContour(s, bulbTop, weight: 2.2, colour: Chart.ink, seed: seed &+ 83)
    penContour(s, bulbLow, weight: 2.2, colour: Chart.ink, seed: seed &+ 89)
    stipple(s, polyPath(bulbLow), density: 0.020, sizeMin: 1.0, sizeMax: 2.4,
            colour: Chart.brass.dk(0.10), seed: seed &+ 97)
    penStroke(s, [pnt(glassX, glassY), pnt(glassX, glassY + r * 0.20)],
              weight: 1.4, colour: Chart.brass.dk(0.2), wobble: 0.5, taper: true, seed: seed &+ 101)
    for sgn in [-1.0, 1.0] {
        let cap = [pnt(glassX - r * 0.16, glassY + sgn * r * 0.30),
                   pnt(glassX + r * 0.16, glassY + sgn * r * 0.30),
                   pnt(glassX + r * 0.14, glassY + sgn * r * 0.24),
                   pnt(glassX - r * 0.14, glassY + sgn * r * 0.24)]
        woodPart(s, cap, seed: seed &+ UInt64(103 + Int(sgn * 4)), dark: true)
    }
}

func drawLeadLine(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    var rng = Spin(seed)

    var rope: [CGPoint] = []
    for k in 0...44 {
        let t = Double(k) / 44.0
        let x = cx - r * 0.30 + sin(t * 5.0) * r * 0.30 + rng.signed() * 1.8
        let y = cy - r * 0.92 + t * r * 1.34
        rope.append(pnt(x, y))
    }
    penStroke(s, rope, weight: 4.2, colour: Chart.ink, wobble: 0.9, taper: false, seed: seed &+ 5)
    penStroke(s, rope, weight: 1.6, colour: Chart.paperWarm.al(0.35), wobble: 2.4,
              taper: false, seed: seed &+ 9)

    let marks: [(Double, String, Tint)] = [
        (0.14, "2", Chart.oxblood), (0.30, "3", Chart.inkSoft),
        (0.48, "5", Chart.ink), (0.66, "7", Chart.oxblood), (0.82, "10", Chart.inkSoft)
    ]
    for (k, m) in marks.enumerated() {
        let idx = Int(m.0 * 44)
        let p = rope[min(idx, rope.count - 1)]
        let tag = [pnt(Double(p.x) + r * 0.02, Double(p.y) - r * 0.035),
                   pnt(Double(p.x) + r * 0.20, Double(p.y) - r * 0.055),
                   pnt(Double(p.x) + r * 0.21, Double(p.y) + r * 0.020),
                   pnt(Double(p.x) + r * 0.02, Double(p.y) + r * 0.035)]
        wash(s, tag, m.2, strength: 0.44, bleed: 1.8, seed: seed &+ UInt64(20 + k))
        penContour(s, tag, weight: 1.8, colour: Chart.ink, seed: seed &+ UInt64(30 + k))
        label(s, m.1 + " FATHOM", at: Double(p.x) + r * 0.28, Double(p.y) + r * 0.02,
              size: r * 0.062, colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.2)
    }

    let leadX = Double(rope[rope.count - 1].x)
    let leadY = Double(rope[rope.count - 1].y) + r * 0.24
    let body = [pnt(leadX - r * 0.11, leadY - r * 0.24), pnt(leadX + r * 0.11, leadY - r * 0.24),
                pnt(leadX + r * 0.14, leadY + r * 0.22), pnt(leadX - r * 0.14, leadY + r * 0.22)]
    wash(s, body, Chart.inkSoft, strength: 0.58, bleed: 2.4, seed: seed &+ 61)
    formShade(s, body, inset: 10, depth: 3, spacing: 4.0,
              colour: Chart.ink.al(0.8), seed: seed &+ 67)
    penContour(s, body, weight: 3.0, colour: Chart.ink, seed: seed &+ 71)

    let hollow = ellipsePoints(cx: leadX, cy: leadY + r * 0.20, rx: r * 0.08, ry: r * 0.035, steps: 22)
    wash(s, hollow, Chart.paperWarm, strength: 0.66, bleed: 1.6, seed: seed &+ 73)
    penContour(s, hollow, weight: 1.8, colour: Chart.ink, seed: seed &+ 79)
    label(s, "TALLOW", at: leadX + r * 0.24, leadY + r * 0.24, size: r * 0.060,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.2)
}

func drawAzimuthCompass(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let bowlOut = ellipsePoints(cx: cx, cy: cy, rx: r * 0.92, ry: r * 0.92, steps: 64)
    let bowlIn = ellipsePoints(cx: cx, cy: cy, rx: r * 0.80, ry: r * 0.80, steps: 64)
    brassPart(s, bowlOut + bowlIn.reversed(), seed: seed, depth: 3, spacing: 4.2)

    compassRoseFace(s, cx: cx, cy: cy, radius: r * 0.78, seed: seed &+ 11)

    for sgn in [-1.0, 1.0] {
        let vx = cx + sgn * r * 0.86
        let vane = [pnt(vx - r * 0.045, cy - r * 0.62), pnt(vx + r * 0.045, cy - r * 0.62),
                    pnt(vx + r * 0.045, cy + r * 0.06), pnt(vx - r * 0.045, cy + r * 0.06)]
        brassPart(s, vane, seed: seed &+ UInt64(21 + Int(sgn * 3)), depth: 2, spacing: 4.4)
        penStroke(s, [pnt(vx, cy - r * 0.60), pnt(vx, cy + r * 0.04)],
                  weight: 1.6, colour: Chart.ink.al(0.8), wobble: 0.3,
                  taper: false, seed: seed &+ UInt64(31 + Int(sgn * 3)))
    }

    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [8, 7])
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.62)))
    s.ctx.setLineWidth(1.8)
    s.ctx.beginPath()
    s.ctx.move(to: pnt(cx - r * 0.86, cy - r * 0.52))
    s.ctx.addLine(to: pnt(cx + r * 0.86, cy - r * 0.52))
    s.ctx.strokePath()
    s.ctx.restoreGState()

    let stand = [pnt(cx - r * 0.30, cy + r * 0.90), pnt(cx + r * 0.30, cy + r * 0.90),
                 pnt(cx + r * 0.44, cy + r * 1.12), pnt(cx - r * 0.44, cy + r * 1.12)]
    woodPart(s, stand, seed: seed &+ 51, dark: true)
}

func drawTraverseBoard(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let boardY = cy - r * 0.26
    let disc = ellipsePoints(cx: cx, cy: boardY, rx: r * 0.68, ry: r * 0.68, steps: 60)
    woodPart(s, disc, seed: seed)

    for k in 0..<32 {
        let a = Double(k) * .pi / 16 - .pi / 2
        for ring in 0..<8 {
            let rr = r * (0.16 + Double(ring) * 0.066)
            let px = cx + cos(a) * rr
            let py = boardY + sin(a) * rr
            s.disc(px, py, r * 0.012, Chart.ink.al(0.72))
        }
        if k % 4 == 0 {
            penStroke(s, [pnt(cx + cos(a) * r * 0.13, boardY + sin(a) * r * 0.13),
                          pnt(cx + cos(a) * r * 0.64, boardY + sin(a) * r * 0.64)],
                      weight: 1.6, colour: Chart.inkSoft.al(0.5), wobble: 0.4,
                      taper: false, seed: seed &+ UInt64(k))
        }
    }
    compassRoseFace(s, cx: cx, cy: boardY, radius: r * 0.13, seed: seed &+ 21)

    var rng = Spin(seed &+ 31)
    for k in 0..<4 {
        let a = Double(rng.i(0, 31)) * .pi / 16 - .pi / 2
        let rr = r * (0.16 + Double(k) * 0.066)
        let px = cx + cos(a) * rr
        let py = boardY + sin(a) * rr
        s.disc(px, py, r * 0.030, Chart.oxblood)
        s.ring(px, py, r * 0.030, 1.6, Chart.ink)
    }

    let grid = [pnt(cx - r * 0.62, cy + r * 0.50), pnt(cx + r * 0.62, cy + r * 0.50),
                pnt(cx + r * 0.62, cy + r * 1.02), pnt(cx - r * 0.62, cy + r * 1.02)]
    woodPart(s, grid, seed: seed &+ 41)
    for row in 0...4 {
        let y = cy + r * 0.50 + Double(row) * r * 0.13
        penStroke(s, [pnt(cx - r * 0.60, y), pnt(cx + r * 0.60, y)],
                  weight: 1.4, colour: Chart.inkSoft.al(0.6), wobble: 0.4,
                  taper: false, seed: seed &+ UInt64(50 + row))
    }
    for col in 0...8 {
        let x = cx - r * 0.60 + Double(col) * r * 0.15
        penStroke(s, [pnt(x, cy + r * 0.50), pnt(x, cy + r * 1.00)],
                  weight: 1.2, colour: Chart.inkSoft.al(0.5), wobble: 0.4,
                  taper: false, seed: seed &+ UInt64(60 + col))
        for row in 0..<4 {
            s.disc(x, cy + r * 0.565 + Double(row) * r * 0.13, r * 0.010, Chart.ink.al(0.65))
        }
    }
    label(s, "KNOTS", at: cx, cy + r * 1.12, size: r * 0.075,
          colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 2.6)
}

func drawNocturnal(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let discY = cy - r * 0.18
    let big = ellipsePoints(cx: cx, cy: discY, rx: r * 0.70, ry: r * 0.70, steps: 60)
    brassPart(s, big, seed: seed, depth: 2, spacing: 4.6)
    scaleTeeth(s, cx: cx, cy: discY, radius: r * 0.68, from: 0, to: .pi * 2,
               count: 48, length: r * 0.055, seed: seed &+ 11)

    for k in 0..<12 {
        let a = Double(k) * .pi / 6 - .pi / 2
        label(s, ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"][k],
              at: cx + cos(a) * r * 0.56, discY + sin(a) * r * 0.56 + r * 0.026,
              size: r * 0.075, colour: Chart.ink, face: "Georgia", align: .centre)
    }

    let mid = ellipsePoints(cx: cx, cy: discY, rx: r * 0.44, ry: r * 0.44, steps: 48)
    wash(s, mid, Chart.paperWarm, strength: 0.68, bleed: 2.2, seed: seed &+ 21)
    penContour(s, mid, weight: 2.2, colour: Chart.ink, seed: seed &+ 23)
    scaleTeeth(s, cx: cx, cy: discY, radius: r * 0.42, from: 0, to: .pi * 2,
               count: 24, length: r * 0.04, seed: seed &+ 27, everyFifth: false)

    let armAngle = -1.15
    let arm = [pnt(cx + cos(armAngle + 1.5708) * r * 0.035, discY + sin(armAngle + 1.5708) * r * 0.035),
               pnt(cx - cos(armAngle + 1.5708) * r * 0.035, discY - sin(armAngle + 1.5708) * r * 0.035),
               pnt(cx + cos(armAngle) * r * 0.78 - cos(armAngle + 1.5708) * r * 0.025,
                   discY + sin(armAngle) * r * 0.78 - sin(armAngle + 1.5708) * r * 0.025),
               pnt(cx + cos(armAngle) * r * 0.78 + cos(armAngle + 1.5708) * r * 0.025,
                   discY + sin(armAngle) * r * 0.78 + sin(armAngle + 1.5708) * r * 0.025)]
    brassPart(s, arm, seed: seed &+ 31, depth: 2, spacing: 4.0)

    let hole = ellipsePoints(cx: cx, cy: discY, rx: r * 0.055, ry: r * 0.055, steps: 24)
    s.poly(hole, Chart.paperWarm)
    penContour(s, hole, weight: 2.2, colour: Chart.ink, seed: seed &+ 37)

    let handle = [pnt(cx - r * 0.09, discY + r * 0.68), pnt(cx + r * 0.09, discY + r * 0.68),
                  pnt(cx + r * 0.07, discY + r * 1.22), pnt(cx - r * 0.07, discY + r * 1.22)]
    brassPart(s, handle, seed: seed &+ 41, depth: 2, spacing: 4.4)
    label(s, "GUARDS", at: cx + cos(armAngle) * r * 0.86, discY + sin(armAngle) * r * 0.86,
          size: r * 0.068, colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 1.8)
}

func drawStationPointer(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let discOut = ellipsePoints(cx: cx, cy: cy, rx: r * 0.50, ry: r * 0.50, steps: 56)
    let discIn = ellipsePoints(cx: cx, cy: cy, rx: r * 0.38, ry: r * 0.38, steps: 56)
    brassPart(s, discOut + discIn.reversed(), seed: seed, depth: 2, spacing: 4.4)
    scaleTeeth(s, cx: cx, cy: cy, radius: r * 0.48, from: 0, to: .pi * 2,
               count: 72, length: r * 0.045, seed: seed &+ 11)

    let angles = [1.5708, 1.5708 + 2.05, 1.5708 - 2.30]
    for (k, a) in angles.enumerated() {
        let len = r * (k == 0 ? 1.02 : 0.92)
        let arm = [pnt(cx + cos(a + 1.5708) * r * 0.045, cy + sin(a + 1.5708) * r * 0.045),
                   pnt(cx - cos(a + 1.5708) * r * 0.045, cy - sin(a + 1.5708) * r * 0.045),
                   pnt(cx + cos(a) * len - cos(a + 1.5708) * r * 0.022,
                       cy + sin(a) * len - sin(a + 1.5708) * r * 0.022),
                   pnt(cx + cos(a) * len + cos(a + 1.5708) * r * 0.022,
                       cy + sin(a) * len + sin(a + 1.5708) * r * 0.022)]
        brassPart(s, arm, seed: seed &+ UInt64(21 + k * 5), depth: 2, spacing: 4.2)
        penStroke(s, [pnt(cx, cy), pnt(cx + cos(a) * len, cy + sin(a) * len)],
                  weight: 1.3, colour: Chart.ink.al(0.75), wobble: 0.3,
                  taper: false, seed: seed &+ UInt64(41 + k))
        label(s, ["A", "B", "C"][k], at: cx + cos(a) * (len + r * 0.10),
              cy + sin(a) * (len + r * 0.10) + r * 0.024,
              size: r * 0.085, colour: Chart.oxblood, face: "Georgia-Bold", align: .centre)
    }

    s.disc(cx, cy, r * 0.045, Chart.paperWarm)
    s.ring(cx, cy, r * 0.045, 2.4, Chart.ink)
    for k in 0..<2 {
        let a = angles[k + 1]
        let clampX = cx + cos(a) * r * 0.44
        let clampY = cy + sin(a) * r * 0.44
        let clamp = ellipsePoints(cx: clampX, cy: clampY, rx: r * 0.055, ry: r * 0.055, steps: 22)
        brassPart(s, clamp, seed: seed &+ UInt64(61 + k), depth: 2, spacing: 3.4)
    }
}

func drawPelorus(_ s: Sheet, cx: Double, cy: Double, scale: Double, seed: UInt64) {
    let r = 150.0 * scale
    let topY = cy - r * 0.22
    let ringOut = ellipsePoints(cx: cx, cy: topY, rx: r * 0.72, ry: r * 0.72, steps: 60)
    let ringIn = ellipsePoints(cx: cx, cy: topY, rx: r * 0.62, ry: r * 0.62, steps: 60)
    brassPart(s, ringOut + ringIn.reversed(), seed: seed, depth: 2, spacing: 4.2)
    scaleTeeth(s, cx: cx, cy: topY, radius: r * 0.70, from: 0, to: .pi * 2,
               count: 72, length: r * 0.045, seed: seed &+ 11)

    compassRoseFace(s, cx: cx, cy: topY, radius: r * 0.60, seed: seed &+ 17)

    let barAngle = -0.42
    let bar = [pnt(cx + cos(barAngle + 1.5708) * r * 0.030, topY + sin(barAngle + 1.5708) * r * 0.030),
               pnt(cx - cos(barAngle + 1.5708) * r * 0.030, topY - sin(barAngle + 1.5708) * r * 0.030),
               pnt(cx - cos(barAngle) * r * 0.74 - cos(barAngle + 1.5708) * r * 0.030,
                   topY - sin(barAngle) * r * 0.74 - sin(barAngle + 1.5708) * r * 0.030),
               pnt(cx - cos(barAngle) * r * 0.74 + cos(barAngle + 1.5708) * r * 0.030,
                   topY - sin(barAngle) * r * 0.74 + sin(barAngle + 1.5708) * r * 0.030)]
    brassPart(s, bar, seed: seed &+ 23, depth: 2, spacing: 4.0)
    let bar2 = [pnt(cx + cos(barAngle + 1.5708) * r * 0.030, topY + sin(barAngle + 1.5708) * r * 0.030),
                pnt(cx - cos(barAngle + 1.5708) * r * 0.030, topY - sin(barAngle + 1.5708) * r * 0.030),
                pnt(cx + cos(barAngle) * r * 0.74 - cos(barAngle + 1.5708) * r * 0.030,
                    topY + sin(barAngle) * r * 0.74 - sin(barAngle + 1.5708) * r * 0.030),
                pnt(cx + cos(barAngle) * r * 0.74 + cos(barAngle + 1.5708) * r * 0.030,
                    topY + sin(barAngle) * r * 0.74 + sin(barAngle + 1.5708) * r * 0.030)]
    brassPart(s, bar2, seed: seed &+ 29, depth: 2, spacing: 4.0)

    for sgn in [-1.0, 1.0] {
        let vx = cx + cos(barAngle) * r * 0.70 * sgn
        let vy = topY + sin(barAngle) * r * 0.70 * sgn
        let vane = [pnt(vx - r * 0.035, vy - r * 0.30), pnt(vx + r * 0.035, vy - r * 0.30),
                    pnt(vx + r * 0.035, vy + r * 0.04), pnt(vx - r * 0.035, vy + r * 0.04)]
        brassPart(s, vane, seed: seed &+ UInt64(41 + Int(sgn * 3)), depth: 2, spacing: 4.0)
    }

    let column = [pnt(cx - r * 0.10, topY + r * 0.70), pnt(cx + r * 0.10, topY + r * 0.70),
                  pnt(cx + r * 0.13, topY + r * 1.14), pnt(cx - r * 0.13, topY + r * 1.14)]
    brassPart(s, column, seed: seed &+ 51, depth: 2, spacing: 4.6)
    let base = [pnt(cx - r * 0.40, topY + r * 1.14), pnt(cx + r * 0.40, topY + r * 1.14),
                pnt(cx + r * 0.46, topY + r * 1.28), pnt(cx - r * 0.46, topY + r * 1.28)]
    woodPart(s, base, seed: seed &+ 61, dark: true)
}

func drawInstrumentPlate(_ inst: Instrument, dir: String) {
    let sheet = Sheet(1800, 1350)
    let seed = seedOf("inst-" + inst.slug)
    layPaper(sheet, seed: seed, tone: Chart.paper)
    sheet.flipToTopDown()
    sheet.light = 2.30

    let W = sheet.w, H = sheet.h
    plateBorder(sheet, inset: W * 0.042, seed: seed &+ 3)

    let shadow = ellipsePoints(cx: W * 0.545, cy: H * 0.715,
                               rx: W * 0.26, ry: H * 0.028, steps: 32)
    hatch(sheet, polyPath(shadow), angle: 0.20, spacing: 4.6, weight: 1.2,
          colour: Chart.inkSoft.al(0.46), coverage: 0.88,
          bound: polyPath(shadow), seed: seed &+ 5)

    inst.draw(sheet, W * 0.50, H * 0.400, 2.30, seed &+ 101)

    penStroke(sheet, [pnt(W * 0.22, H * 0.848), pnt(W * 0.78, H * 0.848)],
              weight: 2.4, colour: Chart.ink, wobble: 0.7, taper: true, seed: seed &+ 7)
    label(sheet, inst.title.uppercased(), at: W / 2, H * 0.900,
          size: 34, colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 4.6)
    label(sheet, inst.era.uppercased(), at: W / 2, H * 0.940,
          size: 18, colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 3.6)

    sheet.write(dir, "inst_" + inst.slug)
}
