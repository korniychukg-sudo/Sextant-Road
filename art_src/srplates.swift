import Foundation
import CoreGraphics

struct Diagram {
    let slug: String
    let title: String
    let draw: (Sheet, UInt64) -> Void
}

func dashLine(_ s: Sheet, _ a: CGPoint, _ b: CGPoint, _ colour: Tint,
              width: Double = 1.8, pattern: [CGFloat] = [9, 8]) {
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: pattern)
    s.ctx.setStrokeColor(cgt(colour))
    s.ctx.setLineWidth(CGFloat(width))
    s.ctx.beginPath(); s.ctx.move(to: a); s.ctx.addLine(to: b); s.ctx.strokePath()
    s.ctx.restoreGState()
}

func angleArc(_ s: Sheet, at c: CGPoint, radius: Double, from a0: Double, to a1: Double,
              text: String, colour: Tint = Chart.oxblood, seed: UInt64 = 3) {
    let pts = arcPoints(cx: Double(c.x), cy: Double(c.y), radius: radius,
                        from: a0, to: a1, steps: 30)
    penStroke(s, pts, weight: 2.2, colour: colour, wobble: 0.4, taper: false, seed: seed)
    let mid = (a0 + a1) / 2
    label(s, text, at: Double(c.x) + cos(mid) * radius * 1.24,
          Double(c.y) + sin(mid) * radius * 1.24 + 8,
          size: 26, colour: colour, face: "Georgia-Bold", align: .centre)
}

func observerFigure(_ s: Sheet, at p: CGPoint, height: Double, seed: UInt64) {
    let x = Double(p.x), y = Double(p.y)
    let hull = [pnt(x - height * 0.52, y), pnt(x + height * 0.52, y),
                pnt(x + height * 0.38, y + height * 0.24), pnt(x - height * 0.38, y + height * 0.24)]
    wash(s, hull, Chart.land, strength: 0.44, bleed: 2.2, seed: seed)
    penContour(s, hull, weight: 2.6, colour: Chart.ink, seed: seed &+ 5)
    penStroke(s, [pnt(x - height * 0.10, y), pnt(x - height * 0.10, y - height * 0.70)],
              weight: 3.2, colour: Chart.ink, wobble: 0.4, taper: false, seed: seed &+ 11)
    penStroke(s, [pnt(x - height * 0.10, y - height * 0.60), pnt(x + height * 0.26, y - height * 0.34)],
              weight: 2.2, colour: Chart.ink, wobble: 0.4, taper: true, seed: seed &+ 13)
    s.disc(x + height * 0.24, y - height * 0.10, height * 0.075, Chart.ink)
}

func seaLine(_ s: Sheet, y: Double, from x0: Double, to x1: Double, seed: UInt64) {
    var rng = Spin(seed)
    var pts: [CGPoint] = []
    var x = x0
    while x <= x1 {
        pts.append(pnt(x, y + rng.signed() * 2.0))
        x += (x1 - x0) / 40
    }
    penStroke(s, pts, weight: 2.6, colour: Chart.ink, wobble: 0.5, taper: false, seed: seed &+ 7)
    var y2 = y + 14
    while y2 < y + 70 {
        var wx = x0
        while wx < x1 {
            let len = rng.r(18, 44)
            penStroke(s, [pnt(wx, y2), pnt(wx + len * 0.5, y2 - rng.r(2, 5)), pnt(wx + len, y2)],
                      weight: 1.4, colour: Chart.sea.al(rng.r(0.25, 0.55)),
                      wobble: 0.4, taper: true, seed: seed &+ u64(Int(wx + y2)))
            wx += len + rng.r(16, 40)
        }
        y2 += rng.r(11, 17)
    }
}

let diagrams: [Diagram] = diagramsA + diagramsB + diagramsC

let diagramsA: [Diagram] = [
    Diagram(slug: "altitude", title: "What an Altitude Is", draw: diagAltitude),
    Diagram(slug: "horizon", title: "The Visible Horizon", draw: diagHorizon),
    Diagram(slug: "dip", title: "The Dip of the Horizon", draw: diagDip),
    Diagram(slug: "refraction", title: "How the Air Bends the Light", draw: diagRefraction),
]

let diagramsB: [Diagram] = [
    Diagram(slug: "semidiameter", title: "Limb and Centre", draw: diagSemidiameter),
    Diagram(slug: "circleposition", title: "The Circle of Position", draw: diagCircle),
    Diagram(slug: "intercept", title: "The Intercept Method", draw: diagIntercept),
    Diagram(slug: "noonsight", title: "The Noon Sight", draw: diagNoon),
]

let diagramsC: [Diagram] = [
    Diagram(slug: "longitudetime", title: "Longitude Is Time", draw: diagLongitude),
    Diagram(slug: "staridentify", title: "Finding the Star", draw: diagStarFind),
    Diagram(slug: "cockedhat", title: "The Cocked Hat", draw: diagCockedHat),
    Diagram(slug: "runningfix", title: "The Running Fix", draw: diagRunningFix),
]

func diagAltitude(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let eye = pnt(W * 0.24, H * 0.62)
    seaLine(s, y: H * 0.66, from: W * 0.08, to: W * 0.94, seed: seed)
    observerFigure(s, at: pnt(W * 0.24, H * 0.66), height: H * 0.20, seed: seed &+ 3)

    dashLine(s, eye, pnt(W * 0.92, H * 0.66), Chart.inkSoft.al(0.75))
    let body = pnt(W * 0.80, H * 0.20)
    penStroke(s, [eye, body], weight: 3.0, colour: Chart.ink, wobble: 0.5,
              taper: false, seed: seed &+ 11)
    punchStar(s, Double(body.x), Double(body.y), radius: 15, rays: 6, tone: Chart.brass)
    s.ring(Double(body.x), Double(body.y), 26, 2.0, Chart.brass.dk(0.2))

    angleArc(s, at: eye, radius: W * 0.20,
             from: atan2(Double(body.y - eye.y), Double(body.x - eye.x)),
             to: 0.03, text: "Ho", seed: seed &+ 17)

    label(s, "THE BODY", at: Double(body.x), Double(body.y) - 44, size: 22,
          colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 2.4)
    label(s, "VISIBLE HORIZON", at: W * 0.78, H * 0.72, size: 22,
          colour: Chart.inkSoft, face: "Georgia", align: .centre, tracking: 2.4)
    label(s, "An altitude is the angle between the horizon and the body,",
          at: W / 2, H * 0.85, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "measured at your eye. Everything else is correction.",
          at: W / 2, H * 0.89, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagHorizon(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let cx = W * 0.50, cy = H * 1.62
    let radius = H * 1.20
    let earth = arcPoints(cx: cx, cy: cy, radius: radius, from: -2.36, to: -0.78, steps: 70)
    penStroke(s, earth, weight: 3.4, colour: Chart.ink, wobble: 0.6, taper: false, seed: seed)
    let below = earth + [pnt(W * 1.06, H * 1.10), pnt(-W * 0.06, H * 1.10)]
    hatch(s, polyPath(below), angle: 0.5, spacing: 12.0, weight: 1.1,
          colour: Chart.inkSoft.al(0.35), coverage: 0.6, bound: polyPath(below), seed: seed &+ 5)

    let mastX = W * 0.30
    let deckY = cy - radius * cos((mastX - cx) / radius) + 0
    let surfaceY = H * 0.60
    _ = deckY
    let eyeHigh = pnt(mastX, surfaceY - H * 0.30)
    let eyeLow = pnt(mastX, surfaceY - H * 0.08)
    penStroke(s, [pnt(mastX, surfaceY), pnt(mastX, surfaceY - H * 0.32)],
              weight: 3.4, colour: Chart.ink, wobble: 0.4, taper: false, seed: seed &+ 11)
    s.disc(Double(eyeHigh.x), Double(eyeHigh.y), 9, Chart.oxblood)
    s.disc(Double(eyeLow.x), Double(eyeLow.y), 9, Chart.sea)

    dashLine(s, eyeHigh, pnt(W * 0.92, surfaceY - H * 0.02), Chart.oxblood.al(0.8))
    dashLine(s, eyeLow, pnt(W * 0.72, surfaceY + H * 0.02), Chart.sea.al(0.8))

    label(s, "CROSSTREES", at: mastX - 22, Double(eyeHigh.y) - 16, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .right, tracking: 2.0)
    label(s, "DECK", at: mastX - 22, Double(eyeLow.y) + 6, size: 21,
          colour: Chart.sea.dk(0.15), face: "Georgia", align: .right, tracking: 2.0)
    label(s, "The higher your eye, the further the horizon runs —",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "and the further below true level it falls.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagDip(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let eye = pnt(W * 0.22, H * 0.34)
    let sea = H * 0.62
    seaLine(s, y: sea, from: W * 0.06, to: W * 0.96, seed: seed)
    penStroke(s, [pnt(W * 0.22, sea), pnt(W * 0.22, H * 0.34)],
              weight: 3.4, colour: Chart.ink, wobble: 0.4, taper: false, seed: seed &+ 3)
    s.disc(Double(eye.x), Double(eye.y), 10, Chart.ink)

    dashLine(s, eye, pnt(W * 0.94, H * 0.34), Chart.inkSoft.al(0.8))
    penStroke(s, [eye, pnt(W * 0.92, sea)], weight: 2.8, colour: Chart.oxblood,
              wobble: 0.4, taper: false, seed: seed &+ 7)

    angleArc(s, at: eye, radius: W * 0.30, from: 0.0,
             to: atan2(sea - Double(eye.y), W * 0.92 - Double(eye.x)),
             text: "Dip", seed: seed &+ 11)

    label(s, "TRUE HORIZONTAL", at: W * 0.94, H * 0.31, size: 21,
          colour: Chart.inkSoft, face: "Georgia", align: .right, tracking: 2.0)
    label(s, "LINE OF SIGHT TO THE SEA HORIZON", at: W * 0.94, sea - 16, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .right, tracking: 2.0)

    let box = [pnt(W * 0.10, H * 0.74), pnt(W * 0.90, H * 0.74),
               pnt(W * 0.90, H * 0.86), pnt(W * 0.10, H * 0.86)]
    wash(s, box, Chart.paperWarm, strength: 0.80, bleed: 3, seed: seed &+ 13)
    penContour(s, box, weight: 2.2, colour: Chart.ink, seed: seed &+ 17)
    label(s, "DIP IN MINUTES  =  1.76  x  SQUARE ROOT OF HEIGHT IN METRES",
          at: W / 2, H * 0.815, size: 24, colour: Chart.ink,
          face: "Georgia-Bold", align: .centre, tracking: 1.6)
    label(s, "It is always subtracted. The horizon is never level with your eye.",
          at: W / 2, H * 0.925, size: 24, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagRefraction(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let eye = pnt(W * 0.18, H * 0.72)
    for k in 0..<5 {
        let y = H * (0.20 + Double(k) * 0.10)
        dashLine(s, pnt(W * 0.06, y), pnt(W * 0.96, y), Chart.sea.al(0.30),
                 width: 1.4, pattern: [4, 10])
    }
    let bandTop = [pnt(W * 0.04, H * 0.16), pnt(W * 0.98, H * 0.16),
                   pnt(W * 0.98, H * 0.68), pnt(W * 0.04, H * 0.68)]
    wash(s, bandTop, Chart.sky, strength: 0.16, bleed: 8, seed: seed &+ 3)

    seaLine(s, y: H * 0.72, from: W * 0.06, to: W * 0.96, seed: seed &+ 5)
    s.disc(Double(eye.x), Double(eye.y) - 6, 10, Chart.ink)

    var bent: [CGPoint] = []
    for k in 0...40 {
        let t = Double(k) / 40.0
        let x = Double(eye.x) + t * (W * 0.78)
        let base = Double(eye.y) - t * (H * 0.46)
        let sag = sin(t * 1.4) * H * 0.055
        bent.append(pnt(x, base - sag))
    }
    penStroke(s, bent, weight: 3.0, colour: Chart.oxblood, wobble: 0.4,
              taper: false, seed: seed &+ 11)
    dashLine(s, eye, pnt(W * 0.96, H * 0.26), Chart.inkSoft.al(0.75))

    let trueBody = pnt(W * 0.92, H * 0.30)
    let seenBody = pnt(W * 0.92, H * 0.22)
    punchStar(s, Double(trueBody.x), Double(trueBody.y), radius: 12, rays: 0, tone: Chart.inkSoft)
    s.ring(Double(trueBody.x), Double(trueBody.y), 20, 1.6, Chart.inkSoft.al(0.7))
    punchStar(s, Double(seenBody.x), Double(seenBody.y), radius: 14, rays: 6, tone: Chart.brass)

    label(s, "WHERE IT LOOKS", at: Double(seenBody.x) - 34, Double(seenBody.y) - 22,
          size: 21, colour: Chart.oxblood, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "WHERE IT IS", at: Double(trueBody.x) - 34, Double(trueBody.y) + 30,
          size: 21, colour: Chart.inkSoft, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "Air lifts every body a little. Low down it lifts a great deal —",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "which is why sights below fifteen degrees are not to be trusted.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagSemidiameter(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let cx = W * 0.42, cy = H * 0.42
    let r = H * 0.20
    let ringPts = ellipsePoints(cx: cx, cy: cy, rx: r, ry: r, steps: 56)
    wash(s, ringPts, Chart.brass, strength: 0.32, bleed: 3, seed: seed)
    penContour(s, ringPts, weight: 3.0, colour: Chart.ink, seed: seed &+ 3)
    for k in 0..<16 {
        let a = Double(k) * .pi / 8
        penStroke(s, [pnt(cx + cos(a) * r * 1.08, cy + sin(a) * r * 1.08),
                      pnt(cx + cos(a) * r * 1.26, cy + sin(a) * r * 1.26)],
                  weight: 1.8, colour: Chart.brass.dk(0.2), wobble: 0.3,
                  taper: true, seed: seed &+ UInt64(k))
    }

    seaLine(s, y: H * 0.70, from: W * 0.06, to: W * 0.96, seed: seed &+ 7)
    dashLine(s, pnt(W * 0.08, cy), pnt(W * 0.96, cy), Chart.inkSoft.al(0.7))
    dashLine(s, pnt(W * 0.08, cy - r), pnt(W * 0.96, cy - r), Chart.oxblood.al(0.7))
    dashLine(s, pnt(W * 0.08, cy + r), pnt(W * 0.96, cy + r), Chart.sea.al(0.7))

    penStroke(s, [pnt(W * 0.86, cy - r), pnt(W * 0.86, cy + r)],
              weight: 2.4, colour: Chart.ink, wobble: 0.3, taper: false, seed: seed &+ 11)
    label(s, "UPPER LIMB", at: W * 0.92, cy - r - 14, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "CENTRE", at: W * 0.92, cy - 12, size: 21,
          colour: Chart.inkSoft, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "LOWER LIMB", at: W * 0.92, cy + r + 28, size: 21,
          colour: Chart.sea.dk(0.15), face: "Georgia", align: .right, tracking: 1.8)
    label(s, "16.0'", at: W * 0.80, cy - r * 0.5, size: 26,
          colour: Chart.ink, face: "Georgia-Bold", align: .right)

    label(s, "You cannot bring the middle of the Sun to the horizon.",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "Bring an edge, then add or subtract the half-diameter.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagCircle(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let cx = W * 0.46, cy = H * 0.46
    let r = H * 0.32
    let globe = ellipsePoints(cx: cx, cy: cy, rx: r, ry: r, steps: 64)
    wash(s, globe, Chart.sea, strength: 0.28, bleed: 4, seed: seed)
    penContour(s, globe, weight: 3.2, colour: Chart.ink, seed: seed &+ 3)
    for k in 1..<5 {
        let ry = r * cos(Double(k) * 0.42)
        let yy = cy - r * sin(Double(k) * 0.42)
        s.ctx.saveGState()
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(0.35)))
        s.ctx.setLineWidth(1.3)
        s.ctx.strokeEllipse(in: CGRect(x: cx - ry, y: yy - ry * 0.16,
                                       width: ry * 2, height: ry * 0.32))
        let yy2 = cy + r * sin(Double(k) * 0.42)
        s.ctx.strokeEllipse(in: CGRect(x: cx - ry, y: yy2 - ry * 0.16,
                                       width: ry * 2, height: ry * 0.32))
        s.ctx.restoreGState()
    }
    for k in 0..<6 {
        let rx = r * cos(Double(k) * 0.52)
        s.ctx.saveGState()
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(0.28)))
        s.ctx.setLineWidth(1.2)
        s.ctx.strokeEllipse(in: CGRect(x: cx - rx, y: cy - r, width: rx * 2, height: r * 2))
        s.ctx.restoreGState()
    }

    let gp = pnt(cx + r * 0.28, cy - r * 0.30)
    s.disc(Double(gp.x), Double(gp.y), 11, Chart.oxblood)
    s.ctx.saveGState()
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.9)))
    s.ctx.setLineWidth(3.2)
    s.ctx.strokeEllipse(in: CGRect(x: Double(gp.x) - r * 0.56, y: Double(gp.y) - r * 0.22,
                                   width: r * 1.12, height: r * 0.44))
    s.ctx.restoreGState()

    let star = pnt(cx + r * 0.70, cy - r * 1.20)
    punchStar(s, Double(star.x), Double(star.y), radius: 14, rays: 6, tone: Chart.brass)
    dashLine(s, star, gp, Chart.brass.dk(0.2), width: 2.0)

    label(s, "GEOGRAPHICAL POSITION", at: Double(gp.x) + 26, Double(gp.y) + 34, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .left, tracking: 1.8)
    label(s, "CIRCLE OF EQUAL ALTITUDE", at: cx, cy + r * 0.44, size: 22,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 2.0)
    label(s, "One sight does not give a position. It gives a circle,",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "every point of which would see the body at that same height.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagIntercept(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    for c in 1..<6 {
        let x = W * 0.10 + (W * 0.80) * Double(c) / 6.0
        dashLine(s, pnt(x, H * 0.12), pnt(x, H * 0.76), Chart.inkSoft.al(0.24),
                 width: 1.1, pattern: [3, 8])
    }
    for r in 1..<5 {
        let y = H * 0.12 + (H * 0.64) * Double(r) / 5.0
        dashLine(s, pnt(W * 0.10, y), pnt(W * 0.90, y), Chart.inkSoft.al(0.24),
                 width: 1.1, pattern: [3, 8])
    }

    let ap = pnt(W * 0.36, H * 0.56)
    let az = -0.62
    let toward = pnt(Double(ap.x) + cos(az) * W * 0.34, Double(ap.y) + sin(az) * W * 0.34)
    penStroke(s, [ap, toward], weight: 2.4, colour: Chart.inkSoft, wobble: 0.4,
              taper: false, seed: seed &+ 3)
    for k in 0..<3 {
        let t = 0.86 - Double(k) * 0.05
        let px = Double(ap.x) + cos(az) * W * 0.34 * t
        let py = Double(ap.y) + sin(az) * W * 0.34 * t
        penStroke(s, [pnt(px, py), pnt(px + cos(az + 2.6) * 20, py + sin(az + 2.6) * 20)],
                  weight: 2.0, colour: Chart.inkSoft, wobble: 0.3, taper: true,
                  seed: seed &+ UInt64(10 + k))
    }

    let ip = pnt(Double(ap.x) + cos(az) * W * 0.20, Double(ap.y) + sin(az) * W * 0.20)
    penStroke(s, [ap, ip], weight: 5.0, colour: Chart.oxblood, wobble: 0.4,
              taper: false, seed: seed &+ 17)
    s.disc(Double(ap.x), Double(ap.y), 10, Chart.ink)
    s.disc(Double(ip.x), Double(ip.y), 8, Chart.oxblood)

    let perp = az + 1.5708
    penStroke(s, [pnt(Double(ip.x) - cos(perp) * W * 0.26, Double(ip.y) - sin(perp) * W * 0.26),
                  pnt(Double(ip.x) + cos(perp) * W * 0.26, Double(ip.y) + sin(perp) * W * 0.26)],
              weight: 3.6, colour: Chart.ink, wobble: 0.5, taper: false, seed: seed &+ 23)

    label(s, "AP", at: Double(ap.x) - 22, Double(ap.y) + 34, size: 26,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre)
    label(s, "INTERCEPT", at: (Double(ap.x) + Double(ip.x)) / 2 - 10,
          (Double(ap.y) + Double(ip.y)) / 2 + 40, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .centre, tracking: 1.8)
    label(s, "AZIMUTH  Zn", at: Double(toward.x) - 6, Double(toward.y) - 18, size: 21,
          colour: Chart.inkSoft, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "LINE OF POSITION", at: Double(ip.x) + cos(perp) * W * 0.28,
          Double(ip.y) + sin(perp) * W * 0.28 + 26, size: 21,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 1.8)

    label(s, "Ho greater than Hc: step toward the body. Less: step away.",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "One minute of arc is one nautical mile. Then rule the line square across.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagNoon(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    seaLine(s, y: H * 0.66, from: W * 0.06, to: W * 0.96, seed: seed)
    observerFigure(s, at: pnt(W * 0.50, H * 0.66), height: H * 0.20, seed: seed &+ 3)

    var arcPts: [CGPoint] = []
    for k in 0...50 {
        let t = Double(k) / 50.0
        let x = W * 0.10 + t * W * 0.80
        let y = H * 0.66 - sin(t * .pi) * H * 0.40
        arcPts.append(pnt(x, y))
    }
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [7, 9])
    s.ctx.setStrokeColor(cgt(Chart.brass.dk(0.15).al(0.8)))
    s.ctx.setLineWidth(2.2)
    s.ctx.addPath(polyPath(arcPts, close: false))
    s.ctx.strokePath()
    s.ctx.restoreGState()

    for (k, t) in [0.18, 0.5, 0.82].enumerated() {
        let idx = Int(t * 50)
        let p = arcPts[idx]
        let big = k == 1
        punchStar(s, Double(p.x), Double(p.y), radius: big ? 20 : 12,
                  rays: big ? 8 : 0, tone: Chart.brass)
        if big { s.ring(Double(p.x), Double(p.y), 32, 2.2, Chart.brass.dk(0.25)) }
    }

    let top = arcPts[25]
    dashLine(s, pnt(W * 0.50, H * 0.62), pnt(W * 0.94, H * 0.62), Chart.inkSoft.al(0.7))
    penStroke(s, [pnt(W * 0.50, H * 0.62), top], weight: 3.0, colour: Chart.ink,
              wobble: 0.4, taper: false, seed: seed &+ 11)
    angleArc(s, at: pnt(W * 0.50, H * 0.62), radius: W * 0.22, from: 0.02,
             to: atan2(Double(top.y) - H * 0.62, Double(top.x) - W * 0.50),
             text: "Ho", seed: seed &+ 13)

    label(s, "MERIDIAN PASSAGE", at: Double(top.x), Double(top.y) - 50, size: 22,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 2.4)
    label(s, "At the moment the Sun stops rising, it bears due north or south.",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "Latitude falls out of that one altitude, with no clock at all.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagLongitude(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let cx = W * 0.50, cy = H * 0.42
    let r = H * 0.28
    let globe = ellipsePoints(cx: cx, cy: cy, rx: r, ry: r, steps: 64)
    wash(s, globe, Chart.sea, strength: 0.26, bleed: 4, seed: seed)
    penContour(s, globe, weight: 3.0, colour: Chart.ink, seed: seed &+ 3)
    for k in 0..<7 {
        let rx = r * cos(Double(k) * 0.44)
        s.ctx.saveGState()
        s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(k == 0 ? 0.60 : 0.26)))
        s.ctx.setLineWidth(k == 0 ? 2.2 : 1.2)
        s.ctx.strokeEllipse(in: CGRect(x: cx - rx, y: cy - r, width: rx * 2, height: r * 2))
        s.ctx.restoreGState()
    }
    for k in 0..<4 {
        let a = Double(k) * .pi / 2 + 0.3
        penStroke(s, [pnt(cx + cos(a) * r * 1.06, cy + sin(a) * r * 1.06),
                      pnt(cx + cos(a) * r * 1.20, cy + sin(a) * r * 1.20)],
                  weight: 2.4, colour: Chart.oxblood, wobble: 0.3, taper: true,
                  seed: seed &+ UInt64(20 + k))
    }

    dialFace(s, cx: W * 0.16, cy: H * 0.34, radius: H * 0.13, seed: seed &+ 31)
    dialFace(s, cx: W * 0.84, cy: H * 0.34, radius: H * 0.13, seed: seed &+ 37)
    label(s, "GREENWICH", at: W * 0.16, H * 0.53, size: 22, colour: Chart.ink,
          face: "Georgia-Bold", align: .centre, tracking: 2.4)
    label(s, "SHIP", at: W * 0.84, H * 0.53, size: 22, colour: Chart.ink,
          face: "Georgia-Bold", align: .centre, tracking: 2.4)

    let box = [pnt(W * 0.16, H * 0.68), pnt(W * 0.84, H * 0.68),
               pnt(W * 0.84, H * 0.79), pnt(W * 0.16, H * 0.79)]
    wash(s, box, Chart.paperWarm, strength: 0.80, bleed: 3, seed: seed &+ 41)
    penContour(s, box, weight: 2.2, colour: Chart.ink, seed: seed &+ 43)
    label(s, "ONE HOUR OF TIME  =  FIFTEEN DEGREES OF LONGITUDE",
          at: W / 2, H * 0.745, size: 24, colour: Chart.ink,
          face: "Georgia-Bold", align: .centre, tracking: 1.8)
    label(s, "Four seconds of chronometer error is a mile of ocean at the equator.",
          at: W / 2, H * 0.88, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagStarFind(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    let field = CGRect(x: W * 0.08, y: H * 0.10, width: W * 0.84, height: H * 0.62)
    let fieldPath = CGPath(rect: field, transform: nil)
    wash(s, [pnt(Double(field.minX), Double(field.minY)), pnt(Double(field.maxX), Double(field.minY)),
             pnt(Double(field.maxX), Double(field.maxY)), pnt(Double(field.minX), Double(field.maxY))],
         Chart.seaDeep, strength: 0.32, bleed: 6, seed: seed)
    hatch(s, fieldPath, angle: 0.6, spacing: 7.0, weight: 1.4,
          colour: Chart.ink.al(0.58), coverage: 0.95, seed: seed &+ 5)
    hatch(s, fieldPath, angle: -0.7, spacing: 7.8, weight: 1.3,
          colour: Chart.ink.al(0.46), coverage: 0.88, seed: seed &+ 11)

    let dipper: [CGPoint] = [pnt(W * 0.18, H * 0.44), pnt(W * 0.24, H * 0.52),
                             pnt(W * 0.33, H * 0.53), pnt(W * 0.36, H * 0.44),
                             pnt(W * 0.30, H * 0.38), pnt(W * 0.21, H * 0.37)]
    for k in 0..<dipper.count - 1 {
        s.ctx.saveGState()
        s.ctx.setLineDash(phase: 0, lengths: [8, 7])
        s.ctx.setStrokeColor(cgt(Chart.paperCool.al(0.42)))
        s.ctx.setLineWidth(1.8)
        s.ctx.beginPath(); s.ctx.move(to: dipper[k]); s.ctx.addLine(to: dipper[k + 1])
        s.ctx.strokePath()
        s.ctx.restoreGState()
    }
    for p in dipper { punchStar(s, Double(p.x), Double(p.y), radius: 9, rays: 4, tone: Chart.paperCool) }

    let pole = pnt(W * 0.66, H * 0.22)
    punchStar(s, Double(pole.x), Double(pole.y), radius: 13, rays: 6, tone: Chart.paperCool)
    s.ring(Double(pole.x), Double(pole.y), 28, 2.4, Chart.oxblood.al(0.85))
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [14, 10])
    s.ctx.setStrokeColor(cgt(Chart.oxblood.al(0.8)))
    s.ctx.setLineWidth(2.6)
    s.ctx.beginPath()
    s.ctx.move(to: dipper[4]); s.ctx.addLine(to: pole)
    s.ctx.strokePath()
    s.ctx.restoreGState()

    for _ in 0..<120 {
        var rng = Spin(seed &+ 97)
        _ = rng.d()
    }
    var rng = Spin(seed &+ 131)
    for _ in 0..<130 {
        let x = Double(field.minX) + rng.d() * Double(field.width)
        let y = Double(field.minY) + rng.d() * Double(field.height)
        punchStar(s, x, y, radius: rng.r(1.6, 3.2), rays: 0, tone: Chart.paperCool)
    }

    label(s, "THE POINTERS", at: W * 0.27, H * 0.60, size: 22,
          colour: Chart.paperCool, face: "Georgia-Bold", align: .centre, tracking: 2.4)
    label(s, "POLARIS", at: Double(pole.x) + 44, Double(pole.y) + 8, size: 24,
          colour: Chart.paperCool, face: "Georgia-Bold", align: .left, tracking: 2.4)
    label(s, "Every star you can name is a star you can shoot in the ten minutes",
          at: W / 2, H * 0.85, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "of twilight when both the star and the horizon are visible at once.",
          at: W / 2, H * 0.89, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagCockedHat(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    for c in 1..<6 {
        let x = W * 0.12 + (W * 0.76) * Double(c) / 6.0
        dashLine(s, pnt(x, H * 0.10), pnt(x, H * 0.76), Chart.inkSoft.al(0.22),
                 width: 1.1, pattern: [3, 8])
    }
    for r in 1..<5 {
        let y = H * 0.10 + (H * 0.66) * Double(r) / 5.0
        dashLine(s, pnt(W * 0.12, y), pnt(W * 0.88, y), Chart.inkSoft.al(0.22),
                 width: 1.1, pattern: [3, 8])
    }

    let lines: [(CGPoint, CGPoint, String)] = [
        (pnt(W * 0.16, H * 0.30), pnt(W * 0.84, H * 0.52), "ARCTURUS"),
        (pnt(W * 0.22, H * 0.70), pnt(W * 0.80, H * 0.20), "VEGA"),
        (pnt(W * 0.14, H * 0.56), pnt(W * 0.86, H * 0.34), "ALTAIR"),
    ]
    for (k, l) in lines.enumerated() {
        penStroke(s, [l.0, l.1], weight: 3.4, colour: k == 1 ? Chart.oxblood : Chart.ink,
                  wobble: 0.5, taper: false, seed: seed &+ UInt64(10 + k))
        label(s, l.2, at: Double(l.1.x) + 10, Double(l.1.y) + 8, size: 21,
              colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.8)
    }

    let tri = [pnt(W * 0.505, H * 0.404), pnt(W * 0.545, H * 0.436), pnt(W * 0.487, H * 0.452)]
    wash(s, tri, Chart.oxblood, strength: 0.30, bleed: 2.4, seed: seed &+ 31)
    penContour(s, tri, weight: 2.2, colour: Chart.oxblood, seed: seed &+ 37)
    s.disc(W * 0.512, H * 0.430, 9, Chart.ink)
    s.ring(W * 0.512, H * 0.430, 20, 2.4, Chart.ink)

    label(s, "THE FIX", at: W * 0.512, H * 0.372, size: 24,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 2.6)
    label(s, "Three lines never meet in a point, and a navigator who says they did",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "is a navigator who moved one. The size of the hat is your honesty.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func diagRunningFix(_ s: Sheet, seed: UInt64) {
    let W = s.w, H = s.h
    for c in 1..<6 {
        let x = W * 0.12 + (W * 0.76) * Double(c) / 6.0
        dashLine(s, pnt(x, H * 0.10), pnt(x, H * 0.76), Chart.inkSoft.al(0.22),
                 width: 1.1, pattern: [3, 8])
    }
    let a0 = pnt(W * 0.18, H * 0.24)
    let a1 = pnt(W * 0.62, H * 0.30)
    penStroke(s, [a0, a1], weight: 3.2, colour: Chart.inkSoft, wobble: 0.5,
              taper: false, seed: seed &+ 3)
    let b0 = pnt(W * 0.30, H * 0.52)
    let b1 = pnt(W * 0.74, H * 0.58)
    s.ctx.saveGState()
    s.ctx.setLineDash(phase: 0, lengths: [12, 9])
    s.ctx.setStrokeColor(cgt(Chart.inkSoft.al(0.85)))
    s.ctx.setLineWidth(3.0)
    s.ctx.beginPath(); s.ctx.move(to: b0); s.ctx.addLine(to: b1); s.ctx.strokePath()
    s.ctx.restoreGState()

    for (p, q) in [(a0, b0), (a1, b1)] {
        penStroke(s, [p, q], weight: 2.0, colour: Chart.sea, wobble: 0.4,
                  taper: false, seed: seed &+ 11)
    }
    let cLine0 = pnt(W * 0.44, H * 0.76)
    let cLine1 = pnt(W * 0.78, H * 0.22)
    penStroke(s, [cLine0, cLine1], weight: 3.4, colour: Chart.oxblood, wobble: 0.5,
              taper: false, seed: seed &+ 17)

    s.disc(W * 0.632, H * 0.522, 10, Chart.ink)
    s.ring(W * 0.632, H * 0.522, 22, 2.4, Chart.ink)

    label(s, "MORNING SIGHT", at: Double(a0.x) - 8, Double(a0.y) - 16, size: 21,
          colour: Chart.inkSoft, face: "Georgia", align: .left, tracking: 1.8)
    label(s, "ADVANCED BY THE RUN", at: Double(b1.x) + 12, Double(b1.y) + 8, size: 21,
          colour: Chart.inkSoft, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "NOON SIGHT", at: Double(cLine1.x) + 10, Double(cLine1.y) - 10, size: 21,
          colour: Chart.oxblood, face: "Georgia", align: .right, tracking: 1.8)
    label(s, "RUNNING FIX", at: W * 0.632, H * 0.470, size: 24,
          colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 2.4)

    label(s, "A line taken at dawn is still worth something at noon —",
          at: W / 2, H * 0.86, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
    label(s, "provided you walk it forward exactly as far as the ship has run.",
          at: W / 2, H * 0.90, size: 25, colour: Chart.ink, face: "Georgia", align: .centre)
}

func drawDiagramPlate(_ dg: Diagram, dir: String) {
    let sheet = Sheet(1800, 1350)
    let seed = seedOf("diag-" + dg.slug)
    layPaper(sheet, seed: seed, tone: Chart.paper)
    sheet.flipToTopDown()
    sheet.light = 2.35
    plateBorder(sheet, inset: sheet.w * 0.040, seed: seed &+ 3)

    label(sheet, dg.title.uppercased(), at: sheet.w / 2, sheet.h * 0.085,
          size: 32, colour: Chart.ink, face: "Georgia-Bold", align: .centre, tracking: 4.4)
    penStroke(sheet, [pnt(sheet.w * 0.26, sheet.h * 0.105), pnt(sheet.w * 0.74, sheet.h * 0.105)],
              weight: 2.2, colour: Chart.ink, wobble: 0.6, taper: true, seed: seed &+ 5)

    dg.draw(sheet, seed &+ 101)
    sheet.write(dir, "diag_" + dg.slug)
}

struct SkyScene {
    let slug: String
    let paper: Tint
    let skyWash: Tint
    let skyStrength: Double
    let stars: Int
    let moon: Bool
    let cloud: Double
    let haze: Double
    let hatchSky: Bool
}

let skyScenes: [SkyScene] = [
    SkyScene(slug: "dawn", paper: Chart.paperWarm, skyWash: Chart.oxblood,
             skyStrength: 0.20, stars: 30, moon: false, cloud: 0.30, haze: 0.10, hatchSky: false),
    SkyScene(slug: "dusk", paper: Chart.paperWarm, skyWash: Chart.brass,
             skyStrength: 0.22, stars: 60, moon: false, cloud: 0.24, haze: 0.08, hatchSky: false),
    SkyScene(slug: "nightclear", paper: Chart.paperCool, skyWash: Chart.seaDeep,
             skyStrength: 0.34, stars: 210, moon: false, cloud: 0.06, haze: 0.0, hatchSky: true),
    SkyScene(slug: "moonlit", paper: Chart.paperCool, skyWash: Chart.seaDeep,
             skyStrength: 0.30, stars: 120, moon: true, cloud: 0.16, haze: 0.04, hatchSky: true),
    SkyScene(slug: "hazy", paper: Chart.paperWarm, skyWash: Chart.sky,
             skyStrength: 0.26, stars: 20, moon: false, cloud: 0.20, haze: 0.42, hatchSky: false),
    SkyScene(slug: "overcast", paper: Chart.paperCool, skyWash: Chart.inkSoft,
             skyStrength: 0.28, stars: 0, moon: false, cloud: 0.78, haze: 0.30, hatchSky: false),
]

func drawSkyScene(_ sc: SkyScene, dir: String) {
    let sheet = Sheet(1500, 2000)
    let seed = seedOf("sky-" + sc.slug)
    layPaper(sheet, seed: seed, tone: sc.paper)
    sheet.flipToTopDown()
    sheet.light = 2.1

    let W = sheet.w, H = sheet.h
    let horizon = H * 0.66

    washBand(sheet, from: 0, to: horizon, sc.skyWash, strength: sc.skyStrength, seed: seed &+ 3)

    if sc.hatchSky {
        let skyRect = CGPath(rect: CGRect(x: 0, y: 0, width: W, height: horizon), transform: nil)
        hatch(sheet, skyRect, angle: 0.58, spacing: 7.4, weight: 1.4,
              colour: Chart.ink.al(0.50), coverage: 0.94, seed: seed &+ 11)
        hatch(sheet, skyRect, angle: -0.66, spacing: 8.2, weight: 1.3,
              colour: Chart.ink.al(0.40), coverage: 0.86, seed: seed &+ 17)
    }

    var rng = Spin(seed &+ 41)
    for _ in 0..<sc.stars {
        let x = rng.d() * W
        let y = rng.d() * (horizon * 0.92)
        punchStar(sheet, x, y, radius: rng.r(1.8, 4.4),
                  rays: rng.chance(0.14) ? 4 : 0, tone: sc.paper)
    }

    if sc.moon {
        let mx = W * 0.72, my = horizon * 0.30
        sheet.disc(mx, my, 78, sc.paper.al(0.30))
        sheet.disc(mx, my, 62, sc.paper.al(0.92))
        let crescent = ellipsePoints(cx: mx + 26, cy: my - 8, rx: 58, ry: 58, steps: 40)
        wash(sheet, crescent, Chart.seaDeep, strength: 0.42, bleed: 3, seed: seed &+ 47)
    }

    if sc.cloud > 0.01 {
        let bands = Int(3 + sc.cloud * 9)
        for k in 0..<bands {
            let cy = horizon * rng.r(0.10, 0.86)
            let cw = W * rng.r(0.24, 0.68)
            let cx = rng.d() * W
            let cloud = blob(cx: cx, cy: cy, rx: cw * 0.5, ry: cw * rng.r(0.06, 0.13),
                             rough: 0.26, steps: 22, seed: seed &+ UInt64(60 + k))
            wash(sheet, cloud, Chart.inkSoft, strength: 0.16 + sc.cloud * 0.20,
                 bleed: 6, seed: seed &+ UInt64(70 + k))
            penBroken(sheet, cloud, weight: 1.6, colour: Chart.inkSoft.al(0.42),
                      pieces: 4, gap: 0.16, wobble: 1.2, seed: seed &+ UInt64(80 + k))
        }
    }

    if sc.haze > 0.01 {
        let band = [pnt(-20, horizon - H * 0.16), pnt(W + 20, horizon - H * 0.16),
                    pnt(W + 20, horizon + H * 0.02), pnt(-20, horizon + H * 0.02)]
        wash(sheet, band, sc.paper.lt(0.30), strength: sc.haze * 0.72, bleed: 14, seed: seed &+ 91)
    }

    washBand(sheet, from: horizon, to: H, Chart.sea, strength: 0.30, seed: seed &+ 97)
    seaLine(sheet, y: horizon, from: -20, to: W + 20, seed: seed &+ 101)

    var wr = Spin(seed &+ 131)
    var y = horizon + 40
    while y < H {
        var x = -30.0
        while x < W + 30 {
            let len = wr.r(26, 78) * (1.0 + (y - horizon) / H)
            penStroke(sheet, [pnt(x, y), pnt(x + len * 0.5, y - wr.r(3, 11)), pnt(x + len, y)],
                      weight: 1.6 + (y - horizon) / H * 2.2,
                      colour: Chart.ink.al(wr.r(0.22, 0.52)),
                      wobble: 0.6, taper: true, seed: seed &+ u64(Int(x + y * 3)))
            x += len + wr.r(20, 60)
        }
        y += wr.r(18, 34)
    }

    sheet.write(dir, "sky_" + sc.slug, quality: 0.92)
}

struct Vignette {
    let slug: String
    let rig: Int
    let mood: Tint
    let ice: Bool
}

let vignettes: [Vignette] = [
    Vignette(slug: "trades", rig: 0, mood: Chart.brass, ice: false),
    Vignette(slug: "horn", rig: 1, mood: Chart.seaDeep, ice: false),
    Vignette(slug: "iceedge", rig: 2, mood: Chart.paperCool, ice: true),
    Vignette(slug: "monsoon", rig: 3, mood: Chart.sky, ice: false),
    Vignette(slug: "greatcircle", rig: 0, mood: Chart.sea, ice: false),
    Vignette(slug: "bight", rig: 1, mood: Chart.land, ice: false),
    Vignette(slug: "doldrums", rig: 3, mood: Chart.brass, ice: false),
    Vignette(slug: "baltic", rig: 2, mood: Chart.inkSoft, ice: true),
]

func drawShip(_ s: Sheet, cx: Double, cy: Double, scale: Double, rig: Int, seed: UInt64) {
    let u = 100.0 * scale
    let hull = [pnt(cx - u * 0.72, cy - u * 0.10), pnt(cx + u * 0.78, cy - u * 0.12),
                pnt(cx + u * 0.60, cy + u * 0.20), pnt(cx - u * 0.54, cy + u * 0.18)]
    wash(s, hull, Chart.ink.lt(0.20), strength: 0.50, bleed: 2.4, seed: seed)
    formShade(s, hull, inset: 9, depth: 2, spacing: 4.4, colour: Chart.ink.al(0.7), seed: seed &+ 5)
    penContour(s, hull, weight: 3.0, colour: Chart.ink, seed: seed &+ 11)

    let mastCount = rig == 3 ? 1 : (rig == 2 ? 2 : 3)
    for m in 0..<mastCount {
        let mx = cx - u * 0.40 + Double(m) * u * (mastCount > 1 ? 0.52 : 0.30)
        let height = u * (1.30 - Double(abs(m - 1)) * 0.14)
        penStroke(s, [pnt(mx, cy - u * 0.10), pnt(mx, cy - height)],
                  weight: 4.0, colour: Chart.ink, wobble: 0.4, taper: false,
                  seed: seed &+ UInt64(20 + m))
        let sails = rig == 3 ? 1 : 3
        for k in 0..<sails {
            let sy = cy - u * 0.26 - Double(k) * height * 0.30
            let halfW = u * (0.34 - Double(k) * 0.05)
            let sail = [pnt(mx - halfW, sy), pnt(mx + halfW, sy),
                        pnt(mx + halfW * 0.86, sy - height * 0.24),
                        pnt(mx - halfW * 0.86, sy - height * 0.24)]
            wash(s, sail, Chart.paperWarm, strength: 0.62, bleed: 2.0,
                 seed: seed &+ UInt64(30 + m * 5 + k))
            hatch(s, polyPath(sail), angle: 1.5, spacing: 7.0, weight: 1.0,
                  colour: Chart.inkSoft.al(0.34), coverage: 0.5,
                  bound: polyPath(sail), seed: seed &+ UInt64(40 + m * 5 + k))
            penContour(s, sail, weight: 2.0, colour: Chart.ink, seed: seed &+ UInt64(50 + m * 5 + k))
        }
        for k in 0..<4 {
            let a = -1.1 + Double(k) * 0.24
            penStroke(s, [pnt(mx, cy - height * 0.92),
                          pnt(mx + cos(a) * u * 0.62, cy - u * 0.10)],
                      weight: 1.1, colour: Chart.ink.al(0.55), wobble: 0.5,
                      taper: false, seed: seed &+ UInt64(60 + m * 7 + k))
        }
    }
    penStroke(s, [pnt(cx + u * 0.72, cy - u * 0.14), pnt(cx + u * 1.10, cy - u * 0.32)],
              weight: 3.0, colour: Chart.ink, wobble: 0.4, taper: true, seed: seed &+ 91)
}

func drawVignette(_ v: Vignette, dir: String) {
    let sheet = Sheet(1700, 1150)
    let seed = seedOf("vig-" + v.slug)
    layPaper(sheet, seed: seed, tone: Chart.paper)
    sheet.flipToTopDown()
    sheet.light = 2.2

    let W = sheet.w, H = sheet.h
    let horizon = H * 0.58
    washBand(sheet, from: 0, to: horizon, v.mood, strength: 0.22, seed: seed &+ 3)
    washBand(sheet, from: horizon, to: H, Chart.sea, strength: 0.30, seed: seed &+ 7)

    var rng = Spin(seed &+ 11)
    for k in 0..<5 {
        let cy = horizon * rng.r(0.14, 0.72)
        let cw = W * rng.r(0.22, 0.56)
        let cloud = blob(cx: rng.d() * W, cy: cy, rx: cw * 0.5, ry: cw * rng.r(0.06, 0.12),
                         rough: 0.26, steps: 20, seed: seed &+ UInt64(20 + k))
        wash(sheet, cloud, Chart.inkSoft, strength: 0.14, bleed: 6, seed: seed &+ UInt64(30 + k))
        penBroken(sheet, cloud, weight: 1.5, colour: Chart.inkSoft.al(0.38),
                  pieces: 4, gap: 0.18, wobble: 1.2, seed: seed &+ UInt64(40 + k))
    }

    if v.ice {
        for k in 0..<6 {
            let x = rng.d() * W
            let y = horizon + rng.r(10, H * 0.22)
            let floe = blob(cx: x, cy: y, rx: rng.r(40, 110), ry: rng.r(12, 30),
                            rough: 0.30, steps: 16, seed: seed &+ UInt64(50 + k))
            wash(sheet, floe, Chart.paperCool.lt(0.42), strength: 0.55, bleed: 3,
                 seed: seed &+ UInt64(60 + k))
            penContour(sheet, floe, weight: 1.8, colour: Chart.inkSoft, seed: seed &+ UInt64(70 + k))
        }
    }

    seaLine(sheet, y: horizon, from: -20, to: W + 20, seed: seed &+ 81)
    drawShip(sheet, cx: W * 0.54, cy: horizon + H * 0.05, scale: 2.10, rig: v.rig, seed: seed &+ 151)

    var wr = Spin(seed &+ 191)
    var y = horizon + 46
    while y < H {
        var x = -30.0
        while x < W + 30 {
            let len = wr.r(24, 70) * (1.0 + (y - horizon) / H)
            penStroke(sheet, [pnt(x, y), pnt(x + len * 0.5, y - wr.r(3, 10)), pnt(x + len, y)],
                      weight: 1.5 + (y - horizon) / H * 2.0,
                      colour: Chart.ink.al(wr.r(0.20, 0.50)),
                      wobble: 0.6, taper: true, seed: seed &+ u64(Int(x + y * 3)))
            x += len + wr.r(18, 56)
        }
        y += wr.r(17, 32)
    }

    sheet.write(dir, "vig_" + v.slug)
}
