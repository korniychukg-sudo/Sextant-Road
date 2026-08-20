import Foundation
import CoreGraphics

private struct Limb {
    let cx: Double
    let cy: Double
    let inner: Double
    let outer: Double
    let a0: Double
    let a1: Double
}

private let limb = Limb(cx: 500, cy: 154, inner: 636, outer: 800, a0: 0.44, a1: 2.70)

private func limbPoint(_ l: Limb, _ a: Double, _ r: Double) -> CGPoint {
    pnt(l.cx + cos(a) * r, l.cy + sin(a) * r)
}

private func limbStrip(_ l: Limb, _ a0: Double, _ a1: Double,
                       _ r0: Double, _ r1: Double, steps: Int = 26) -> [CGPoint] {
    var pts: [CGPoint] = []
    for i in 0...steps {
        let a = a0 + (a1 - a0) * Double(i) / Double(steps)
        pts.append(limbPoint(l, a, r1))
    }
    for i in stride(from: steps, through: 0, by: -1) {
        let a = a0 + (a1 - a0) * Double(i) / Double(steps)
        pts.append(limbPoint(l, a, r0))
    }
    return pts
}

private let keyLight = (x: -0.58, y: -0.81)

private func alongArc(_ a: Double) -> Double {
    let dot = cos(a) * keyLight.x + sin(a) * keyLight.y
    return max(0.0, min(1.0, 0.48 + dot * 0.66))
}

private func brassAcross(_ t: Double) -> Double {
    if t < 0.05 { return 0.30 }
    if t < 0.30 { return 0.62 + (t - 0.05) / 0.25 * 0.38 }
    if t < 0.46 { return 1.00 - (t - 0.30) / 0.16 * 0.28 }
    if t < 0.86 { return 0.72 - (t - 0.46) / 0.40 * 0.44 }
    if t < 0.95 { return 0.28 - (t - 0.86) / 0.09 * 0.16 }
    return 0.12 + (t - 0.95) / 0.05 * 0.74
}

private func brassTint(_ t: Double, _ a: Double) -> Tint {
    let base = Tint(r: 0.741, g: 0.565, b: 0.220)
    let v = brassAcross(t) * (0.66 + alongArc(a) * 0.52)
    if v < 0.5 { return base.dk((0.5 - v) * 1.42) }
    return base.lt((v - 0.5) * 1.06)
}

private func drawLimbBody(_ s: Sheet, _ l: Limb) {
    let bands = 54
    let steps = 16
    var a = l.a0
    let arcStep = (l.a1 - l.a0) / 22.0
    while a < l.a1 - 1e-6 {
        let aNext = min(l.a1, a + arcStep)
        let aMid = (a + aNext) * 0.5
        for b in 0..<bands {
            let t0 = Double(b) / Double(bands)
            let t1 = Double(b + 1) / Double(bands)
            let r0 = l.inner + (l.outer - l.inner) * t0
            let r1 = l.inner + (l.outer - l.inner) * t1 + 0.9
            let strip = limbStrip(l, a - 0.004, aNext + 0.004, r0, r1, steps: steps)
            s.poly(strip, brassTint((t0 + t1) * 0.5, aMid).al(1.0))
        }
        a = aNext
    }
}

private func drawLimbGrain(_ s: Sheet, _ l: Limb, seed: UInt64) {
    var rng = Spin(seed)
    let face = polyPath(limbStrip(l, l.a0, l.a1, l.inner, l.outer, steps: 90))
    s.clip(face) {
        for _ in 0..<340 {
            let a = l.a0 + rng.d() * (l.a1 - l.a0)
            let t = rng.d()
            let r = l.inner + (l.outer - l.inner) * t
            let span = rng.r(0.02, 0.10)
            let pts = (0...6).map { k -> CGPoint in
                let aa = a + span * Double(k) / 6.0
                return limbPoint(l, aa, r + rng.r(-1.4, 1.4))
            }
            let bright = rng.d() < 0.45
            let tone = bright
                ? Tint(r: 1.0, g: 0.94, b: 0.78, a: rng.r(0.05, 0.16))
                : Tint(r: 0.16, g: 0.10, b: 0.03, a: rng.r(0.05, 0.15))
            penStroke(s, pts, weight: rng.r(1.0, 2.6), colour: tone,
                      wobble: 0.5, taper: true, seed: rng.next())
        }
    }
}

private func drawLimbSpecular(_ s: Sheet, _ l: Limb) {
    let face = polyPath(limbStrip(l, l.a0, l.a1, l.inner, l.outer, steps: 90))
    s.clip(face) {
        for k in 0..<9 {
            let t = 0.20 + Double(k) * 0.014
            let r = l.inner + (l.outer - l.inner) * t
            let fade = 1.0 - abs(Double(k) - 4.0) / 4.6
            var a = l.a0
            while a < l.a1 {
                let aNext = min(l.a1, a + 0.05)
                let alpha = fade * alongArc((a + aNext) * 0.5) * 0.30
                if alpha > 0.01 {
                    s.poly(limbStrip(l, a - 0.004, aNext + 0.004, r, r + 4.2, steps: 4),
                           Tint(r: 1.0, g: 0.96, b: 0.83, a: alpha))
                }
                a = aNext
            }
        }
    }
}

private func drawDivisions(_ s: Sheet, _ l: Limb) {
    let total = 62
    for i in 0...total {
        let f = Double(i) / Double(total)
        let a = l.a0 + (l.a1 - l.a0) * f
        let major = i % 5 == 0
        let deep = i % 10 == 0
        let len = deep ? 74.0 : (major ? 52.0 : 30.0)
        let width = deep ? 5.4 : (major ? 4.0 : 2.6)
        let rTop = l.outer - 22
        let rBot = rTop - len
        let lit = alongArc(a)
        let shadow = Tint(r: 0.13, g: 0.075, b: 0.018, a: 0.80)
        let gleam = Tint(r: 1.0, g: 0.95, b: 0.80, a: 0.30 + lit * 0.32)
        s.line(limbPoint(l, a, rBot), limbPoint(l, a, rTop), width, shadow)
        s.line(limbPoint(l, a + 0.0042, rBot), limbPoint(l, a + 0.0042, rTop),
               width * 0.52, gleam)
    }

    let rimTop = l.outer - 14
    var a = l.a0
    while a < l.a1 {
        let aNext = min(l.a1, a + 0.05)
        s.poly(limbStrip(l, a - 0.004, aNext + 0.004, rimTop, rimTop + 3.6, steps: 4),
               Tint(r: 0.15, g: 0.085, b: 0.02, a: 0.52))
        a = aNext
    }

    for i in stride(from: 0, through: total, by: 10) {
        let f = Double(i) / Double(total)
        let a = l.a0 + (l.a1 - l.a0) * f
        let p = limbPoint(l, a, l.outer - 116)
        let text = "\(i * 2)"
        let turn = a - .pi / 2
        label(s, text, at: Double(p.x), Double(p.y) + 14, size: 40,
              colour: Tint(r: 0.14, g: 0.08, b: 0.02, a: 0.80), face: "Georgia",
              align: .centre, rotate: turn)
        label(s, text, at: Double(p.x) + 1.8, Double(p.y) + 12.2, size: 40,
              colour: Tint(r: 1.0, g: 0.94, b: 0.78, a: 0.26), face: "Georgia",
              align: .centre, rotate: turn)
    }
}

private func radialBar(_ l: Limb, angle: Double, from r0: Double, to r1: Double,
                       half0: Double, half1: Double) -> [CGPoint] {
    let nx = -sin(angle), ny = cos(angle)
    let a = limbPoint(l, angle, r0)
    let b = limbPoint(l, angle, r1)
    return [pnt(Double(a.x) + nx * half0, Double(a.y) + ny * half0),
            pnt(Double(b.x) + nx * half1, Double(b.y) + ny * half1),
            pnt(Double(b.x) - nx * half1, Double(b.y) - ny * half1),
            pnt(Double(a.x) - nx * half0, Double(a.y) - ny * half0)]
}

private func shadedBar(_ s: Sheet, _ l: Limb, angle: Double, from r0: Double, to r1: Double,
                       half0: Double, half1: Double, litFrom: Double) {
    s.poly(radialBar(l, angle: angle, from: r0, to: r1, half0: half0 + 5, half1: half1 + 5)
            .map { pnt(Double($0.x) + 14, Double($0.y) + 19) },
           Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.44))
    let bars = 30
    for b in 0..<bars {
        let t0 = Double(b) / Double(bars), t1 = Double(b + 1) / Double(bars)
        let q0 = radialBar(l, angle: angle, from: r0, to: r1,
                           half0: half0 - half0 * 2 * t0, half1: half1 - half1 * 2 * t0)
        let q1 = radialBar(l, angle: angle, from: r0, to: r1,
                           half0: half0 - half0 * 2 * t1 - 0.9,
                           half1: half1 - half1 * 2 * t1 - 0.9)
        s.poly([q0[0], q0[1], q1[1], q1[0]], brassTint(0.06 + t0 * 0.82, litFrom).al(1.0))
    }
}

private func drawFrameLegs(_ s: Sheet, _ l: Limb) {
    shadedBar(s, l, angle: l.a0 + 0.185, from: 44, to: l.outer - 10,
              half0: 58, half1: 96, litFrom: l.a0 - 0.62)
    shadedBar(s, l, angle: l.a1 - 0.185, from: 44, to: l.outer - 10,
              half0: 58, half1: 96, litFrom: l.a1 + 0.62)
    shadedBar(s, l, angle: 2.06, from: 286, to: l.inner + 26,
              half0: 26, half1: 36, litFrom: 2.06)
}

private func drawApexBoss(_ s: Sheet, _ l: Limb) {
    let cx = l.cx, cy = l.cy
    s.disc(cx + 12, cy + 16, 96, Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.44))
    for k in stride(from: 92.0, through: 26.0, by: -4.0) {
        let t = (92.0 - k) / 66.0
        s.disc(cx - 11 * (1 - t), cy - 13 * (1 - t), k,
               brassTint(0.04 + t * 0.86, 2.30).al(1.0))
    }
    s.disc(cx + 2, cy + 3, 30, Tint(r: 0.180, g: 0.114, b: 0.035))
    s.disc(cx - 5, cy - 6, 17, Tint(r: 0.498, g: 0.361, b: 0.125))
    s.disc(cx - 10, cy - 12, 7, Tint(r: 0.88, g: 0.76, b: 0.48, a: 0.72))
}

private let armAngle = 1.02

private func armQuad(_ l: Limb, from r0: Double, to r1: Double, halfWidth: Double) -> [CGPoint] {
    let dir = pnt(cos(armAngle), sin(armAngle))
    let nx = -Double(dir.y) * halfWidth
    let ny = Double(dir.x) * halfWidth
    let a = limbPoint(l, armAngle, r0)
    let b = limbPoint(l, armAngle, r1)
    return [pnt(Double(a.x) + nx, Double(a.y) + ny), pnt(Double(b.x) + nx, Double(b.y) + ny),
            pnt(Double(b.x) - nx, Double(b.y) - ny), pnt(Double(a.x) - nx, Double(a.y) - ny)]
}

private func drawIndexArm(_ s: Sheet, _ l: Limb) {
    let r0 = 30.0
    let r1 = l.outer - 8
    let half = 46.0

    s.poly(armQuad(l, from: r0, to: r1, halfWidth: half + 4)
            .map { pnt(Double($0.x) + 15, Double($0.y) + 20) },
           Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.46))

    let bars = 30
    for b in 0..<bars {
        let t0 = Double(b) / Double(bars), t1 = Double(b + 1) / Double(bars)
        let h0 = half - half * 2 * t0
        let h1 = half - half * 2 * t1 - 0.8
        let q0 = armQuad(l, from: r0, to: r1, halfWidth: h0)
        let q1 = armQuad(l, from: r0, to: r1, halfWidth: h1)
        s.poly([q0[0], q0[1], q1[1], q1[0]],
               brassTint(0.08 + t0 * 0.78, armAngle - 1.34).al(1.0))
    }
    s.poly(armQuad(l, from: r0, to: r1, halfWidth: half * 0.20)
            .map { pnt(Double($0.x) - 5, Double($0.y) - 6) },
           Tint(r: 1.0, g: 0.95, b: 0.80, a: 0.24))

    let plate = limbStrip(l, armAngle - 0.096, armAngle + 0.096,
                          l.inner - 24, l.outer + 14, steps: 12)
    s.poly(plate.map { pnt(Double($0.x) + 13, Double($0.y) + 17) },
           Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.42))
    for b in 0..<22 {
        let t0 = Double(b) / 22.0, t1 = Double(b + 1) / 22.0
        let span = (l.outer + 14) - (l.inner - 24)
        let rr0 = l.inner - 24 + span * t0
        let rr1 = l.inner - 24 + span * t1 + 1.2
        s.poly(limbStrip(l, armAngle - 0.096, armAngle + 0.096, rr0, rr1, steps: 10),
               brassTint(0.10 + t0 * 0.72, armAngle - 0.92).al(1.0))
    }
    for k in 0...9 {
        let aa = armAngle - 0.076 + 0.0169 * Double(k)
        s.line(limbPoint(l, aa, l.inner + 6), limbPoint(l, aa, l.inner + 74),
               k % 3 == 0 ? 4.6 : 2.6, Tint(r: 0.12, g: 0.07, b: 0.02, a: 0.80))
        s.line(limbPoint(l, aa + 0.0044, l.inner + 6), limbPoint(l, aa + 0.0044, l.inner + 74),
               2.0, Tint(r: 1.0, g: 0.94, b: 0.78, a: 0.28))
    }
    penContour(s, plate, weight: 4.6,
               colour: Tint(r: 0.11, g: 0.065, b: 0.02, a: 0.62), seed: 771)
}

private func drawMirror(_ s: Sheet, _ l: Limb) {
    let centre = limbPoint(l, armAngle, 268)
    let cx = Double(centre.x), cy = Double(centre.y)
    let tilt = -0.42
    func box(_ hw: Double, _ hh: Double) -> [CGPoint] {
        rotatedAbout([pnt(cx - hw, cy - hh), pnt(cx + hw, cy - hh),
                      pnt(cx + hw, cy + hh), pnt(cx - hw, cy + hh)],
                     cx: cx, cy: cy, by: tilt)
    }
    s.poly(box(112, 132).map { pnt(Double($0.x) + 15, Double($0.y) + 20) },
           Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.46))
    s.poly(box(112, 132), Tint(r: 0.408, g: 0.290, b: 0.106))
    s.poly(box(102, 122), Tint(r: 0.678, g: 0.514, b: 0.196))
    s.poly(box(90, 110), Tint(r: 0.086, g: 0.129, b: 0.161))

    let glass = polyPath(box(90, 110))
    s.clip(glass) {
        for k in 0..<11 {
            let off = Double(k) * 21 - 118
            let strip = rotatedAbout([pnt(cx - 190 + off, cy - 210), pnt(cx - 150 + off, cy - 210),
                                      pnt(cx + 70 + off, cy + 210), pnt(cx + 30 + off, cy + 210)],
                                     cx: cx, cy: cy, by: tilt)
            let fade = 1.0 - abs(Double(k) - 3.2) / 6.4
            s.poly(strip, Tint(r: 0.78, g: 0.86, b: 0.90, a: max(0.0, fade) * 0.30))
        }
        s.poly(rotatedAbout([pnt(cx - 96, cy - 118), pnt(cx - 30, cy - 118),
                             pnt(cx + 96, cy + 40), pnt(cx + 96, cy + 118)],
                            cx: cx, cy: cy, by: tilt),
               Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.34))
    }
    penContour(s, box(102, 122), weight: 4.0,
               colour: Tint(r: 0.11, g: 0.07, b: 0.02, a: 0.60), seed: 991)
}

func renderIcon(_ dir: String) {
    let s = Sheet(1024, 1024)
    let seed = seedOf("sextant-road-icon-limb")

    s.fillAll(Tint(r: 0.043, g: 0.063, b: 0.106))
    s.flipToTopDown()
    s.light = 2.25

    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(Tint(r: 0.180, g: 0.224, b: 0.298)),
                                   cgt(Tint(r: 0.063, g: 0.086, b: 0.137)),
                                   cgt(Tint(r: 0.020, g: 0.031, b: 0.059))] as CFArray,
                          locations: [0, 0.50, 1]) {
        s.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 236, y: 176), startRadius: 0,
                                 endCenter: CGPoint(x: 236, y: 176), endRadius: 1140,
                                 options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    }

    var rng = Spin(seed)
    for _ in 0..<150 {
        let x = rng.d() * 1024
        let y = rng.d() * 660
        s.disc(x, y, rng.r(1.0, 3.0),
               Tint(r: 0.92, g: 0.93, b: 0.88, a: rng.r(0.10, 0.46)))
    }

    let starX = 838.0, starY = 206.0
    s.disc(starX, starY, 78, Tint(r: 0.98, g: 0.94, b: 0.80, a: 0.10))
    s.disc(starX, starY, 34, Tint(r: 0.99, g: 0.96, b: 0.87, a: 0.30))
    s.disc(starX, starY, 15, Tint(r: 1.0, g: 0.99, b: 0.95, a: 0.98))
    for k in 0..<4 {
        let a = Double(k) * .pi / 2 + 0.24
        penStroke(s, [pnt(starX, starY), pnt(starX + cos(a) * 104, starY + sin(a) * 104)],
                  weight: 7.0, colour: Tint(r: 0.99, g: 0.97, b: 0.90, a: 0.52),
                  wobble: 0.3, taper: true, seed: seed &+ UInt64(300 + k))
    }

    let cast = limbStrip(limb, limb.a0, limb.a1, limb.inner - 6, limb.outer + 8, steps: 80)
    for k in stride(from: 34, through: 6, by: -6) {
        let d = Double(k)
        s.poly(cast.map { pnt(Double($0.x) + d * 0.5, Double($0.y) + d * 0.72) },
               Tint(r: 0.0, g: 0.0, b: 0.0, a: 0.10))
    }

    drawFrameLegs(s, limb)
    drawLimbBody(s, limb)
    drawLimbGrain(s, limb, seed: seed &+ 41)
    drawLimbSpecular(s, limb)
    drawDivisions(s, limb)
    drawIndexArm(s, limb)
    drawApexBoss(s, limb)
    drawMirror(s, limb)

    let outline = limbStrip(limb, limb.a0, limb.a1, limb.inner, limb.outer, steps: 90)
    penContour(s, outline, weight: 5.0,
               colour: Tint(r: 0.086, g: 0.055, b: 0.016, a: 0.66), seed: seed &+ 77)

    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(Tint(r: 0, g: 0, b: 0, a: 0)),
                                   cgt(Tint(r: 0, g: 0, b: 0, a: 0.46))] as CFArray,
                          locations: [0.54, 1]) {
        s.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 470, y: 470), startRadius: 0,
                                 endCenter: CGPoint(x: 470, y: 470), endRadius: 800,
                                 options: [.drawsAfterEndLocation])
    }

    s.writePNG(dir, "AppIcon-1024")
}
