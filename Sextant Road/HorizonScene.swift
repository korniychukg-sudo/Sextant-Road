import SwiftUI

struct Hue {
    let r: Double
    let g: Double
    let b: Double

    var colour: Color { Color(red: r, green: g, blue: b) }

    func at(_ alpha: Double) -> Color {
        Color(red: r, green: g, blue: b).opacity(max(0, min(1, alpha)))
    }

    func to(_ o: Hue, _ t: Double) -> Hue {
        let f = max(0, min(1, t))
        return Hue(r: r + (o.r - r) * f, g: g + (o.g - g) * f, b: b + (o.b - b) * f)
    }
}

struct SkyKey {
    let hour: Double
    let zenith: Hue
    let rim: Hue
    let sea: Hue
    let seaDeep: Hue
    let body: Hue
    let stars: Double
    let sunLike: Bool
    let caption: String
}

let skyKeys: [SkyKey] = [
    SkyKey(hour: 0,
           zenith: Hue(r: 0.031, g: 0.047, b: 0.094),
           rim: Hue(r: 0.098, g: 0.133, b: 0.212),
           sea: Hue(r: 0.071, g: 0.098, b: 0.153),
           seaDeep: Hue(r: 0.027, g: 0.043, b: 0.075),
           body: Hue(r: 0.925, g: 0.937, b: 0.973),
           stars: 1.0, sunLike: false, caption: "Middle watch"),
    SkyKey(hour: 5,
           zenith: Hue(r: 0.114, g: 0.145, b: 0.259),
           rim: Hue(r: 0.616, g: 0.435, b: 0.373),
           sea: Hue(r: 0.153, g: 0.180, b: 0.243),
           seaDeep: Hue(r: 0.075, g: 0.094, b: 0.133),
           body: Hue(r: 0.914, g: 0.933, b: 0.961),
           stars: 0.55, sunLike: false, caption: "Morning twilight"),
    SkyKey(hour: 8,
           zenith: Hue(r: 0.373, g: 0.541, b: 0.694),
           rim: Hue(r: 0.878, g: 0.780, b: 0.643),
           sea: Hue(r: 0.290, g: 0.392, b: 0.467),
           seaDeep: Hue(r: 0.157, g: 0.235, b: 0.310),
           body: Hue(r: 0.996, g: 0.906, b: 0.694),
           stars: 0.0, sunLike: true, caption: "Forenoon watch"),
    SkyKey(hour: 13,
           zenith: Hue(r: 0.427, g: 0.596, b: 0.729),
           rim: Hue(r: 0.780, g: 0.827, b: 0.855),
           sea: Hue(r: 0.271, g: 0.400, b: 0.482),
           seaDeep: Hue(r: 0.145, g: 0.235, b: 0.318),
           body: Hue(r: 1.000, g: 0.976, b: 0.878),
           stars: 0.0, sunLike: true, caption: "Afternoon watch"),
    SkyKey(hour: 18,
           zenith: Hue(r: 0.310, g: 0.353, b: 0.502),
           rim: Hue(r: 0.878, g: 0.588, b: 0.353),
           sea: Hue(r: 0.239, g: 0.271, b: 0.353),
           seaDeep: Hue(r: 0.110, g: 0.137, b: 0.196),
           body: Hue(r: 0.988, g: 0.796, b: 0.502),
           stars: 0.10, sunLike: true, caption: "Dog watch"),
    SkyKey(hour: 20,
           zenith: Hue(r: 0.118, g: 0.145, b: 0.259),
           rim: Hue(r: 0.478, g: 0.353, b: 0.353),
           sea: Hue(r: 0.129, g: 0.153, b: 0.216),
           seaDeep: Hue(r: 0.055, g: 0.075, b: 0.114),
           body: Hue(r: 0.937, g: 0.945, b: 0.976),
           stars: 0.70, sunLike: false, caption: "Evening twilight"),
    SkyKey(hour: 24,
           zenith: Hue(r: 0.031, g: 0.047, b: 0.094),
           rim: Hue(r: 0.098, g: 0.133, b: 0.212),
           sea: Hue(r: 0.071, g: 0.098, b: 0.153),
           seaDeep: Hue(r: 0.027, g: 0.043, b: 0.075),
           body: Hue(r: 0.925, g: 0.937, b: 0.973),
           stars: 1.0, sunLike: false, caption: "First watch"),
]

struct SkyMood {
    let zenith: Hue
    let rim: Hue
    let sea: Hue
    let seaDeep: Hue
    let body: Hue
    let stars: Double
    let sunLike: Bool
    let caption: String
    let bodyRise: Double
    let bodyAcross: Double
}

func moodFor(hour: Double) -> SkyMood {
    let h = max(0, min(23.999, hour))
    var lo = skyKeys[0]
    var hi = skyKeys[skyKeys.count - 1]
    for i in 0..<(skyKeys.count - 1) where h >= skyKeys[i].hour && h <= skyKeys[i + 1].hour {
        lo = skyKeys[i]
        hi = skyKeys[i + 1]
    }
    let span = max(0.001, hi.hour - lo.hour)
    let t = (h - lo.hour) / span
    let anchor = t < 0.5 ? lo : hi

    let dayArc = sin(max(0, min(1, (h - 5.6) / 12.6)) * .pi)
    let nightPhase = h < 5.6 ? (h + 5.0) / 11.0 : (h - 18.2) / 11.0
    let nightArc = sin(max(0, min(1, nightPhase)) * .pi)
    let rise = anchor.sunLike ? 0.08 + dayArc * 0.74 : 0.10 + nightArc * 0.66
    let across = anchor.sunLike
        ? 0.14 + max(0, min(1, (h - 5.6) / 12.6)) * 0.72
        : 0.80 - max(0, min(1, nightPhase)) * 0.62

    return SkyMood(zenith: lo.zenith.to(hi.zenith, t),
                   rim: lo.rim.to(hi.rim, t),
                   sea: lo.sea.to(hi.sea, t),
                   seaDeep: lo.seaDeep.to(hi.seaDeep, t),
                   body: lo.body.to(hi.body, t),
                   stars: lo.stars + (hi.stars - lo.stars) * t,
                   sunLike: anchor.sunLike,
                   caption: anchor.caption,
                   bodyRise: rise,
                   bodyAcross: across)
}

struct HorizonScene: View {
    var hour: Double
    var swell: Double
    var seed: Int

    private func starField(_ count: Int) -> [(CGFloat, CGFloat, CGFloat, Double)] {
        var rng = SeaSpin(seed &* 13 &+ 7)
        var out: [(CGFloat, CGFloat, CGFloat, Double)] = []
        for _ in 0..<count {
            out.append((CGFloat(rng.unit()), CGFloat(rng.unit()),
                        CGFloat(rng.range(0.8, 2.3)), rng.range(0.25, 1.0)))
        }
        return out
    }

    var body: some View {
        let mood = moodFor(hour: hour)
        Canvas { ctx, size in
            let w = size.width, h = size.height
            let skyBottom = h * 0.70

            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: skyBottom)),
                     with: .linearGradient(
                        Gradient(colors: [mood.zenith.colour, mood.rim.colour]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: skyBottom)))

            if mood.stars > 0.02 {
                for s in starField(90) {
                    let x = s.0 * w
                    let y = s.1 * skyBottom * 0.92
                    let r = s.2
                    ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r,
                                                    width: r * 2, height: r * 2)),
                             with: .color(Color.white.opacity(s.3 * mood.stars * 0.9)))
                }
            }

            let bx = w * mood.bodyAcross
            let by = skyBottom - skyBottom * mood.bodyRise * 0.88
            let br: CGFloat = mood.sunLike ? 15 : 9
            for k in stride(from: 5, through: 1, by: -1) {
                let rr = br * CGFloat(k) * 1.7
                ctx.fill(Path(ellipseIn: CGRect(x: bx - rr, y: by - rr,
                                                width: rr * 2, height: rr * 2)),
                         with: .color(mood.body.at(0.055)))
            }
            ctx.fill(Path(ellipseIn: CGRect(x: bx - br, y: by - br,
                                            width: br * 2, height: br * 2)),
                     with: .color(mood.body.at(0.96)))
            if !mood.sunLike {
                for k in 0..<4 {
                    let a = Double(k) * .pi / 2 + 0.28
                    var ray = Path()
                    ray.move(to: CGPoint(x: bx, y: by))
                    ray.addLine(to: CGPoint(x: bx + CGFloat(cos(a)) * br * 3.4,
                                            y: by + CGFloat(sin(a)) * br * 3.4))
                    ctx.stroke(ray, with: .color(mood.body.at(0.42)),
                               style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
                }
            }

            var glow = Path()
            glow.move(to: CGPoint(x: bx - w * 0.10, y: skyBottom))
            glow.addLine(to: CGPoint(x: bx + w * 0.10, y: skyBottom))
            glow.addLine(to: CGPoint(x: bx + w * 0.04, y: h))
            glow.addLine(to: CGPoint(x: bx - w * 0.04, y: h))
            glow.closeSubpath()
            ctx.fill(glow, with: .linearGradient(
                Gradient(colors: [mood.body.at(0.30), mood.body.at(0.0)]),
                startPoint: CGPoint(x: 0, y: skyBottom),
                endPoint: CGPoint(x: 0, y: h)))

            ctx.fill(Path(CGRect(x: 0, y: skyBottom, width: w, height: h - skyBottom)),
                     with: .linearGradient(
                        Gradient(colors: [mood.sea.colour, mood.seaDeep.colour]),
                        startPoint: CGPoint(x: 0, y: skyBottom),
                        endPoint: CGPoint(x: 0, y: h)))

            var rim = Path()
            rim.move(to: CGPoint(x: 0, y: skyBottom))
            rim.addLine(to: CGPoint(x: w, y: skyBottom))
            ctx.stroke(rim, with: .color(Color.white.opacity(0.34)),
                       style: StrokeStyle(lineWidth: 1.4))

            var rng = SeaSpin(seed &* 29 &+ 11)
            var y = skyBottom + 7
            while y < h {
                let depth = (y - skyBottom) / max(1, h - skyBottom)
                var x = CGFloat(-30)
                while x < w + 30 {
                    let len = CGFloat(rng.range(16, 54)) * (0.5 + depth)
                    let lift = CGFloat(rng.range(1.2, 3.4)) * CGFloat(1 + swell * 0.6)
                    var wave = Path()
                    wave.move(to: CGPoint(x: x, y: y))
                    wave.addQuadCurve(to: CGPoint(x: x + len, y: y),
                                      control: CGPoint(x: x + len * 0.5, y: y - lift))
                    ctx.stroke(wave, with: .color(Color.white.opacity(0.05 + depth * 0.13)),
                               style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                    x += len + CGFloat(rng.range(14, 46))
                }
                y += CGFloat(rng.range(9, 17))
            }

            let shipX = w * 0.76
            let deck = skyBottom - 1
            var hull = Path()
            hull.move(to: CGPoint(x: shipX - 22, y: deck))
            hull.addLine(to: CGPoint(x: shipX + 22, y: deck))
            hull.addLine(to: CGPoint(x: shipX + 15, y: deck + 6))
            hull.addLine(to: CGPoint(x: shipX - 15, y: deck + 6))
            hull.closeSubpath()
            ctx.fill(hull, with: .color(Color.black.opacity(0.66)))
            for m in [-9.0, 1.0, 11.0] {
                var mast = Path()
                mast.move(to: CGPoint(x: shipX + CGFloat(m), y: deck))
                mast.addLine(to: CGPoint(x: shipX + CGFloat(m), y: deck - 17))
                ctx.stroke(mast, with: .color(Color.black.opacity(0.60)),
                           style: StrokeStyle(lineWidth: 1.6))
            }
        }
        .drawingGroup()
    }
}
