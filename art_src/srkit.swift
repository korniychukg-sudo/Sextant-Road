import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

struct Spin {
    var s: UInt64
    init(_ seed: UInt64) { s = seed == 0 ? 0x9E3779B97F4A7C15 : seed }
    mutating func next() -> UInt64 { s ^= s << 13; s ^= s >> 7; s ^= s << 17; return s }
    mutating func d() -> Double { Double(next() % 1_000_000) / 1_000_000.0 }
    mutating func r(_ a: Double, _ b: Double) -> Double { a + d() * (b - a) }
    mutating func i(_ a: Int, _ b: Int) -> Int { a + Int(next() % UInt64(max(1, b - a + 1))) }
    mutating func chance(_ p: Double) -> Bool { d() < p }
    mutating func signed() -> Double { d() * 2 - 1 }
}

func u64(_ v: Int) -> UInt64 { UInt64(bitPattern: Int64(v)) }

func seedOf(_ name: String) -> UInt64 {
    var h: UInt64 = 14695981039346656037
    for b in name.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
    return h
}

struct Tint {
    var r: Double, g: Double, b: Double, a: Double = 1
    func al(_ v: Double) -> Tint { Tint(r: r, g: g, b: b, a: v) }
    func mix(_ o: Tint, _ t: Double) -> Tint {
        Tint(r: r + (o.r - r) * t, g: g + (o.g - g) * t, b: b + (o.b - b) * t, a: a + (o.a - a) * t)
    }
    func lt(_ t: Double) -> Tint { mix(Tint(r: 1, g: 1, b: 1, a: a), t) }
    func dk(_ t: Double) -> Tint { mix(Tint(r: 0, g: 0, b: 0, a: a), t) }
}

let chartSpace = CGColorSpaceCreateDeviceRGB()

func cgt(_ c: Tint) -> CGColor {
    CGColor(colorSpace: chartSpace,
            components: [CGFloat(c.r), CGFloat(c.g), CGFloat(c.b), CGFloat(c.a)])!
}

enum Chart {
    static let paper     = Tint(r: 0.906, g: 0.867, b: 0.784)
    static let paperWarm = Tint(r: 0.929, g: 0.886, b: 0.796)
    static let paperCool = Tint(r: 0.871, g: 0.855, b: 0.804)
    static let paperNight = Tint(r: 0.153, g: 0.180, b: 0.239)

    static let ink       = Tint(r: 0.114, g: 0.157, b: 0.208)
    static let inkSoft   = Tint(r: 0.216, g: 0.267, b: 0.325)
    static let inkPale   = Tint(r: 0.376, g: 0.427, b: 0.482)

    static let sea       = Tint(r: 0.302, g: 0.427, b: 0.510)
    static let seaDeep   = Tint(r: 0.184, g: 0.290, b: 0.376)
    static let land      = Tint(r: 0.541, g: 0.494, b: 0.353)
    static let brass     = Tint(r: 0.694, g: 0.541, b: 0.239)
    static let oxblood   = Tint(r: 0.545, g: 0.239, b: 0.180)
    static let sky       = Tint(r: 0.475, g: 0.565, b: 0.616)
    static let star      = Tint(r: 0.976, g: 0.949, b: 0.859)
    static let brassLight = Tint(r: 0.859, g: 0.729, b: 0.435)
}

final class Sheet {
    let ctx: CGContext
    let w: Double
    let h: Double
    var light: Double = 2.35

    init(_ wi: Int, _ hi: Int) {
        w = Double(wi); h = Double(hi)
        ctx = CGContext(data: nil, width: wi, height: hi, bitsPerComponent: 8,
                        bytesPerRow: wi * 4, space: chartSpace,
                        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
        ctx.setShouldAntialias(true)
        ctx.interpolationQuality = .high
    }

    func flipToTopDown() {
        ctx.translateBy(x: 0, y: CGFloat(h))
        ctx.scaleBy(x: 1, y: -1)
    }

    func fillAll(_ c: Tint) {
        ctx.setFillColor(cgt(c)); ctx.fill(CGRect(x: 0, y: 0, width: w, height: h))
    }

    func rect(_ x: Double, _ y: Double, _ rw: Double, _ rh: Double, _ c: Tint) {
        ctx.setFillColor(cgt(c)); ctx.fill(CGRect(x: x, y: y, width: rw, height: rh))
    }

    func disc(_ x: Double, _ y: Double, _ rad: Double, _ c: Tint) {
        ctx.setFillColor(cgt(c))
        ctx.fillEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }

    func ring(_ x: Double, _ y: Double, _ rad: Double, _ width: Double, _ c: Tint) {
        ctx.setStrokeColor(cgt(c)); ctx.setLineWidth(CGFloat(width))
        ctx.strokeEllipse(in: CGRect(x: x - rad, y: y - rad, width: rad * 2, height: rad * 2))
    }

    func ellipse(_ x: Double, _ y: Double, _ rx: Double, _ ry: Double, _ c: Tint) {
        ctx.setFillColor(cgt(c))
        ctx.fillEllipse(in: CGRect(x: x - rx, y: y - ry, width: rx * 2, height: ry * 2))
    }

    func poly(_ pts: [CGPoint], _ c: Tint) {
        guard pts.count > 2 else { return }
        ctx.setFillColor(cgt(c)); ctx.beginPath(); ctx.move(to: pts[0])
        for p in pts.dropFirst() { ctx.addLine(to: p) }
        ctx.closePath(); ctx.fillPath()
    }

    func line(_ a: CGPoint, _ b: CGPoint, _ width: Double, _ c: Tint, dash: [CGFloat] = []) {
        ctx.saveGState()
        ctx.setStrokeColor(cgt(c)); ctx.setLineWidth(CGFloat(width))
        if !dash.isEmpty { ctx.setLineDash(phase: 0, lengths: dash) }
        ctx.beginPath(); ctx.move(to: a); ctx.addLine(to: b); ctx.strokePath()
        ctx.restoreGState()
    }

    func clip(_ path: CGPath, _ body: () -> Void) {
        guard !path.isEmpty else { return }
        ctx.saveGState(); ctx.addPath(path); ctx.clip(); body(); ctx.restoreGState()
    }

    func clipBoth(_ a: CGPath, _ b: CGPath, _ body: () -> Void) {
        guard !a.isEmpty, !b.isEmpty else { return }
        ctx.saveGState()
        ctx.beginPath(); ctx.addPath(a); ctx.clip()
        ctx.beginPath(); ctx.addPath(b); ctx.clip()
        body()
        ctx.restoreGState()
    }

    func clipRect(_ r: CGRect, _ body: () -> Void) {
        ctx.saveGState(); ctx.clip(to: r); body(); ctx.restoreGState()
    }

    func write(_ dir: String, _ name: String, quality: Double = 0.93) {
        guard let img = ctx.makeImage() else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).jpg")
        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.jpeg.identifier as CFString, 1, nil) else { return }
        let opts: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImage(dest, img, opts as CFDictionary)
        CGImageDestinationFinalize(dest)
    }

    func writePNG(_ dir: String, _ name: String) {
        guard let img = ctx.makeImage() else { return }
        let url = URL(fileURLWithPath: dir).appendingPathComponent("\(name).png")
        guard let dest = CGImageDestinationCreateWithURL(
            url as CFURL, UTType.png.identifier as CFString, 1, nil) else { return }
        CGImageDestinationAddImage(dest, img, nil)
        CGImageDestinationFinalize(dest)
    }
}

func pnt(_ x: Double, _ y: Double) -> CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }

func polyPath(_ pts: [CGPoint], close: Bool = true) -> CGPath {
    let p = CGMutablePath()
    guard let first = pts.first else { return p }
    p.move(to: first)
    for pt in pts.dropFirst() { p.addLine(to: pt) }
    if close { p.closeSubpath() }
    return p
}

func resample(_ pts: [CGPoint], count: Int) -> [CGPoint] {
    guard pts.count > 1, count > 1 else { return pts }
    var lengths: [Double] = [0]
    var total = 0.0
    for i in 1..<pts.count {
        let dx = Double(pts[i].x - pts[i - 1].x), dy = Double(pts[i].y - pts[i - 1].y)
        total += (dx * dx + dy * dy).squareRoot()
        lengths.append(total)
    }
    guard total > 0 else { return pts }
    var out: [CGPoint] = []
    var seg = 1
    for k in 0..<count {
        let target = total * Double(k) / Double(count - 1)
        while seg < lengths.count - 1 && lengths[seg] < target { seg += 1 }
        let l0 = lengths[seg - 1], l1 = lengths[seg]
        let t = l1 > l0 ? (target - l0) / (l1 - l0) : 0
        let a = pts[seg - 1], b = pts[seg]
        out.append(CGPoint(x: a.x + (b.x - a.x) * CGFloat(t),
                           y: a.y + (b.y - a.y) * CGFloat(t)))
    }
    return out
}

func layPaper(_ p: Sheet, seed: UInt64, tone: Tint = Chart.paper) {
    var rng = Spin(seed)
    p.fillAll(tone)

    for _ in 0..<16 {
        let x = rng.d() * p.w, y = rng.d() * p.h
        let rr = rng.r(p.w * 0.05, p.w * 0.16)
        let warm = rng.chance(0.6)
        if let g = CGGradient(colorsSpace: chartSpace,
                              colors: [cgt(warm ? tone.lt(0.038).al(0.20) : tone.dk(0.032).al(0.16)),
                                       cgt(tone.al(0))] as CFArray,
                              locations: [0, 1]) {
            p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: x, y: y), startRadius: 0,
                                     endCenter: CGPoint(x: x, y: y), endRadius: rr, options: [])
        }
    }

    var y = 0.0
    while y < p.h {
        p.rect(0, y, p.w, 1.0, tone.dk(0.055).al(0.32))
        y += rng.r(5.4, 7.4)
    }
    var x = rng.r(0, 90)
    while x < p.w {
        p.rect(x, 0, 1.4, p.h, tone.lt(0.10).al(0.28))
        x += rng.r(84, 106)
    }

    for _ in 0..<Int(p.w * p.h / 5400) {
        let fx = rng.d() * p.w, fy = rng.d() * p.h
        let a = rng.r(0, 6.283), len = rng.r(3, 13)
        p.ctx.setStrokeColor(cgt(tone.dk(rng.r(0.05, 0.16)).al(rng.r(0.15, 0.4))))
        p.ctx.setLineWidth(rng.r(0.6, 1.3))
        p.ctx.beginPath()
        p.ctx.move(to: CGPoint(x: fx, y: fy))
        p.ctx.addLine(to: CGPoint(x: fx + cos(a) * len, y: fy + sin(a) * len))
        p.ctx.strokePath()
    }

    for _ in 0..<rng.i(1, 3) {
        let sx = rng.d() * p.w, sy = rng.d() * p.h
        let rr = rng.r(p.w * 0.05, p.w * 0.14)
        var band: [CGPoint] = []
        var a = 0.0
        while a < 6.283 {
            let rad = rr * rng.r(0.82, 1.18)
            band.append(CGPoint(x: sx + cos(a) * rad, y: sy + sin(a) * rad))
            a += 0.35
        }
        p.poly(band, Tint(r: 0.529, g: 0.451, b: 0.322, a: 0.055))
    }

    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(tone.dk(0.15).al(0)), cgt(tone.dk(0.15).al(0.55))] as CFArray,
                          locations: [0.60, 1]) {
        p.ctx.drawRadialGradient(g, startCenter: CGPoint(x: p.w / 2, y: p.h / 2), startRadius: 0,
                                 endCenter: CGPoint(x: p.w / 2, y: p.h / 2),
                                 endRadius: max(p.w, p.h) * 0.74,
                                 options: [.drawsAfterEndLocation])
    }
}

func wash(_ p: Sheet, _ region: [CGPoint], _ colour: Tint,
          strength: Double = 0.42, bleed: Double = 6, seed: UInt64) {
    guard region.count > 2 else { return }
    var rng = Spin(seed)

    var edge: [CGPoint] = []
    for pt in resample(region + [region[0]], count: max(24, region.count * 3)) {
        edge.append(CGPoint(x: pt.x + CGFloat(rng.signed() * bleed),
                            y: pt.y + CGFloat(rng.signed() * bleed)))
    }
    let path = polyPath(edge)

    p.ctx.setFillColor(cgt(colour.al(strength)))
    p.ctx.addPath(path)
    p.ctx.fillPath()

    p.ctx.setStrokeColor(cgt(colour.dk(0.18).al(strength * 0.55)))
    p.ctx.setLineWidth(CGFloat(bleed * 1.6))
    p.ctx.setLineJoin(.round)
    p.ctx.addPath(path)
    p.ctx.strokePath()

    p.clip(path) {
        let box = path.boundingBox
        let unit = Double(min(box.width, box.height))
        let count = Int(Double(box.width * box.height) / (unit * unit * 0.5)) + 18
        for _ in 0..<min(150, count) {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let rx = rng.r(unit * 0.020, unit * 0.085)
            let ry = rx * rng.r(0.35, 0.85)
            let darker = rng.chance(0.62)
            p.ellipse(x, y, rx, ry,
                      darker ? colour.dk(0.14).al(strength * 0.13)
                             : colour.lt(0.24).al(strength * 0.10))
        }
    }
}

func washBand(_ p: Sheet, from y0: Double, to y1: Double, _ colour: Tint,
              strength: Double, seed: UInt64) {
    var rng = Spin(seed)
    let over = p.w * 0.09
    var top: [CGPoint] = []
    var x = -over
    while x <= p.w + over {
        top.append(CGPoint(x: x, y: y1 + CGFloat(rng.signed() * (p.h * 0.012))))
        x += p.w / 22
    }
    var region: [CGPoint] = [CGPoint(x: CGFloat(-over), y: y0)]
    region.append(contentsOf: top)
    region.append(CGPoint(x: CGFloat(p.w + over), y: y0))
    wash(p, region, colour, strength: strength, bleed: p.h * 0.008, seed: seed &+ 5)
}

func penStroke(_ p: Sheet, _ pts: [CGPoint], weight: Double, colour: Tint = Chart.ink,
               wobble: Double = 1.1, taper: Bool = true, seed: UInt64 = 7) {
    guard pts.count > 1, weight > 0 else { return }
    var rng = Spin(seed)
    let n = max(10, min(90, Int(weight * 14)))
    let spine = resample(pts, count: n)

    var left: [CGPoint] = []
    var right: [CGPoint] = []
    for i in 0..<spine.count {
        let t = Double(i) / Double(spine.count - 1)
        let a = spine[max(0, i - 1)], b = spine[min(spine.count - 1, i + 1)]
        var tx = Double(b.x - a.x), ty = Double(b.y - a.y)
        let len = (tx * tx + ty * ty).squareRoot()
        if len > 0 { tx /= len; ty /= len } else { tx = 1; ty = 0 }
        let nx = -ty, ny = tx

        let swell = taper ? pow(sin(.pi * t), 0.42) : 1.0
        let hw = max(0.35, weight * 0.5 * (0.55 + 0.45 * swell)) * rng.r(0.88, 1.12)
        let off = rng.signed() * wobble

        let cx = Double(spine[i].x) + nx * off
        let cy = Double(spine[i].y) + ny * off
        left.append(CGPoint(x: cx + nx * hw, y: cy + ny * hw))
        right.append(CGPoint(x: cx - nx * hw, y: cy - ny * hw))
    }
    p.poly(left + right.reversed(), colour)
}

func penBroken(_ p: Sheet, _ pts: [CGPoint], weight: Double, colour: Tint = Chart.ink,
               pieces: Int = 3, gap: Double = 0.10, wobble: Double = 1.0, seed: UInt64 = 11) {
    var rng = Spin(seed)
    let spine = resample(pts, count: 60)
    var t = 0.0
    var k = 0
    while t < 1.0 {
        let run = rng.r(0.7, 1.3) / Double(max(1, pieces))
        let end = min(1.0, t + run)
        let i0 = Int(t * 59), i1 = Int(end * 59)
        if i1 > i0 + 1 {
            penStroke(p, Array(spine[i0...i1]), weight: weight * rng.r(0.82, 1.12),
                      colour: colour, wobble: wobble, taper: true, seed: seed &+ UInt64(k) &+ 1)
        }
        t = end + rng.r(gap * 0.4, gap * 1.4)
        k += 1
    }
}

func penContour(_ p: Sheet, _ pts: [CGPoint], weight: Double, colour: Tint = Chart.ink,
                seed: UInt64 = 13) {
    guard pts.count > 2 else { return }
    let closed = pts + [pts[0]]
    for i in 0..<(closed.count - 1) {
        let a = closed[i], b = closed[i + 1]
        let ang = atan2(Double(b.y - a.y), Double(b.x - a.x))
        let facing = cos(ang + .pi / 2 - p.light)
        let wt = weight * (0.62 + 0.62 * max(0, -facing))
        penStroke(p, [a, b], weight: wt, colour: colour, wobble: weight * 0.30,
                  taper: false, seed: seed &+ UInt64(i * 17 + 3))
    }
}

func hatch(_ p: Sheet, _ path: CGPath, angle: Double, spacing: Double,
           weight: Double = 1.2, colour: Tint = Chart.inkSoft,
           coverage: Double = 0.9, bound: CGPath? = nil, seed: UInt64 = 17) {
    guard !path.isEmpty else { return }
    var rng = Spin(seed)
    let box = path.boundingBox.insetBy(dx: -6, dy: -6)
    guard box.width > 1, box.height > 1 else { return }
    let dx = cos(angle), dy = sin(angle)
    let span = Double(box.width + box.height) * 1.2

    let body: () -> Void = {
        var t = -span / 2
        while t < span / 2 {
            if rng.d() <= coverage {
                let cx = Double(box.midX) - dy * t
                let cy = Double(box.midY) + dx * t
                let pieces = rng.i(2, 4)
                var u = -0.5 + rng.r(0, 0.10)
                for k in 0..<pieces {
                    let run = rng.r(0.08, 0.20)
                    let a = CGPoint(x: cx + dx * span * u, y: cy + dy * span * u)
                    let b = CGPoint(x: cx + dx * span * (u + run), y: cy + dy * span * (u + run))
                    penStroke(p, [a, b], weight: weight * rng.r(0.7, 1.25),
                              colour: colour.al(rng.r(0.55, 0.95)),
                              wobble: 0.9, taper: true,
                              seed: seed &+ u64(Int(t) &* 31 &+ k &+ 101))
                    u += run + rng.r(0.03, 0.13)
                }
            }
            t += spacing * rng.r(0.86, 1.18)
        }
    }

    if let b = bound { p.clipBoth(path, b, body) } else { p.clip(path, body) }
}

func shade(_ p: Sheet, _ path: CGPath, depth: Int, spacing: Double,
           colour: Tint = Chart.inkSoft, bound: CGPath? = nil, seed: UInt64 = 23) {
    let base = p.light + .pi / 2
    hatch(p, path, angle: base, spacing: spacing, weight: 1.1, colour: colour,
          coverage: 0.92, bound: bound, seed: seed)
    if depth >= 2 {
        hatch(p, path, angle: base + 1.0, spacing: spacing * 1.15, weight: 1.0,
              colour: colour, coverage: 0.80, bound: bound, seed: seed &+ 71)
    }
    if depth >= 3 {
        hatch(p, path, angle: base - 0.9, spacing: spacing * 1.35, weight: 0.9,
              colour: colour, coverage: 0.65, bound: bound, seed: seed &+ 131)
    }
}

func formShade(_ p: Sheet, _ pts: [CGPoint], inset: Double, depth: Int, spacing: Double,
               colour: Tint = Chart.inkSoft, seed: UInt64 = 53) {
    guard pts.count > 3 else { return }
    var cx = 0.0, cy = 0.0
    for pt in pts { cx += Double(pt.x); cy += Double(pt.y) }
    cx /= Double(pts.count); cy /= Double(pts.count)
    let lx = cos(p.light), ly = sin(p.light)

    var outer: [CGPoint] = []
    var inner: [CGPoint] = []
    for pt in pts {
        var dx = Double(pt.x) - cx, dy = Double(pt.y) - cy
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 0 else { continue }
        dx /= len; dy /= len
        let facing = dx * lx + dy * ly
        guard facing < 0.12 else { continue }
        let pull = inset * min(1.0, -facing + 0.12) * 1.4
        outer.append(pt)
        inner.append(CGPoint(x: pt.x - CGFloat(dx * pull), y: pt.y - CGFloat(dy * pull)))
    }
    guard outer.count > 2 else { return }
    let band = outer + inner.reversed()
    shade(p, polyPath(band), depth: depth, spacing: spacing, colour: colour,
          bound: polyPath(pts), seed: seed)
}

func stipple(_ p: Sheet, _ path: CGPath, density: Double, sizeMin: Double, sizeMax: Double,
             colour: Tint = Chart.inkSoft, seed: UInt64 = 29) {
    guard !path.isEmpty else { return }
    var rng = Spin(seed)
    let box = path.boundingBox
    let count = Int(Double(box.width * box.height) * density)
    p.clip(path) {
        for _ in 0..<max(0, count) {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            p.disc(x, y, rng.r(sizeMin, sizeMax), colour.al(rng.r(0.3, 0.85)))
        }
    }
}

func flicks(_ p: Sheet, _ path: CGPath, count: Int, length: Double, weight: Double,
            spread: Double, colour: Tint = Chart.ink, seed: UInt64 = 31) {
    guard !path.isEmpty else { return }
    var rng = Spin(seed)
    let box = path.boundingBox
    p.clip(path) {
        for k in 0..<count {
            let x = Double(box.minX) + rng.d() * Double(box.width)
            let y = Double(box.minY) + rng.d() * Double(box.height)
            let a = rng.r(-spread, spread) - .pi / 2
            let len = length * rng.r(0.6, 1.4)
            let mid = CGPoint(x: x + cos(a + 0.4) * len * 0.5, y: y - sin(a) * len * 0.5)
            penStroke(p, [CGPoint(x: x, y: y), mid,
                          CGPoint(x: x + cos(a) * len * 0.4, y: y - sin(a) * len)],
                      weight: weight * rng.r(0.7, 1.3), colour: colour,
                      wobble: 0.5, taper: true, seed: seed &+ UInt64(k))
        }
    }
}

func ellipsePoints(cx: Double, cy: Double, rx: Double, ry: Double, steps: Int) -> [CGPoint] {
    var out: [CGPoint] = []
    for i in 0..<steps {
        let a = Double(i) / Double(steps) * 6.283185
        out.append(CGPoint(x: cx + cos(a) * rx, y: cy + sin(a) * ry))
    }
    return out
}

func blob(cx: Double, cy: Double, rx: Double, ry: Double, rough: Double,
          steps: Int = 26, seed: UInt64 = 41) -> [CGPoint] {
    var rng = Spin(seed)
    var out: [CGPoint] = []
    for i in 0..<steps {
        let a = Double(i) / Double(steps) * 6.283185
        let k = 1.0 + rng.signed() * rough
        out.append(CGPoint(x: cx + cos(a) * rx * k, y: cy + sin(a) * ry * k))
    }
    return out
}

enum LabelAlign { case left, centre, right }

func label(_ p: Sheet, _ text: String, at x: Double, _ y: Double,
           size: Double, colour: Tint = Chart.ink,
           face: String = "Georgia", align: LabelAlign = .centre,
           tracking: Double = 0, rotate: Double = 0) {
    guard !text.isEmpty else { return }
    let font = CTFontCreateWithName(face as CFString, CGFloat(size), nil)
    var attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): cgt(colour)
    ]
    if tracking != 0 {
        attrs[NSAttributedString.Key(kCTKernAttributeName as String)] = CGFloat(tracking)
    }
    let attributed = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(attributed)
    let bounds = CTLineGetBoundsWithOptions(line, .useOpticalBounds)
    var dx = 0.0
    switch align {
    case .left: dx = 0
    case .centre: dx = -Double(bounds.width) / 2
    case .right: dx = -Double(bounds.width)
    }

    p.ctx.saveGState()
    p.ctx.translateBy(x: CGFloat(x), y: CGFloat(y))
    if rotate != 0 { p.ctx.rotate(by: CGFloat(rotate)) }
    p.ctx.scaleBy(x: 1, y: -1)
    p.ctx.textPosition = CGPoint(x: CGFloat(dx), y: 0)
    CTLineDraw(line, p.ctx)
    p.ctx.restoreGState()
}

func labelWidth(_ text: String, size: Double, face: String = "Georgia") -> Double {
    let font = CTFontCreateWithName(face as CFString, CGFloat(size), nil)
    let attrs: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): font
    ]
    let attributed = NSAttributedString(string: text, attributes: attrs)
    let line = CTLineCreateWithAttributedString(attributed)
    return Double(CTLineGetBoundsWithOptions(line, .useOpticalBounds).width)
}

func plateBorder(_ p: Sheet, inset: Double, seed: UInt64) {
    var rng = Spin(seed)
    func frame(_ i: Double, _ wgt: Double, _ tone: Tint) {
        let c: [CGPoint] = [pnt(i, i), pnt(p.w - i, i), pnt(p.w - i, p.h - i), pnt(i, p.h - i)]
        for k in 0..<4 {
            penStroke(p, [c[k], c[(k + 1) % 4]], weight: wgt, colour: tone,
                      wobble: 0.8, taper: false, seed: seed &+ UInt64(k * 7 + 1))
        }
    }
    frame(inset, 3.0, Chart.ink)
    frame(inset + rng.r(9, 13), 1.4, Chart.inkSoft)
}
