import SwiftUI

struct SextantField: View {
    let brief: SightBrief
    let setting: Double
    let tilt: Double
    let swellPhase: Double
    var showHint: Bool

    private var tiltRadians: Double { tilt * 0.14 }

    private var swellOffsetDegrees: Double {
        sin(swellPhase) * brief.swellMinutes / 60.0
    }

    private var effectiveAltitude: Double {
        brief.perfectHs / max(0.2, cos(tiltRadians)) + swellOffsetDegrees
    }

    private var gapDegrees: Double { effectiveAltitude - setting }

    private func compress(_ g: Double) -> CGFloat {
        let sign: Double = g < 0 ? -1 : 1
        return CGFloat(sign * pow(min(abs(g), 40), 0.55) * 250)
    }

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                if let img = PlateStore.image("sky_" + brief.skySlug) {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: side, height: side)
                        .clipped()
                } else {
                    Sea.deep
                }

                Canvas { ctx, size in
                    draw(ctx: ctx, rect: CGRect(origin: .zero, size: size))
                }
                .frame(width: side, height: side)
            }
            .frame(width: side, height: side)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Sea.ink.opacity(0.85), lineWidth: 6)
            )
            .overlay(
                Circle().stroke(Sea.brass.opacity(0.55), lineWidth: 2)
                    .padding(5)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func draw(ctx: GraphicsContext, rect: CGRect) {
        let w = rect.width, h = rect.height
        let horizonY = h * 0.56
        let swellPixels = CGFloat(sin(swellPhase)) * CGFloat(min(10, brief.swellMinutes * 2.4))
        let seaY = horizonY + swellPixels

        var seaPath = Path()
        seaPath.move(to: CGPoint(x: 0, y: seaY))
        var x: CGFloat = 0
        while x <= w {
            let ripple = sin(Double(x) * 0.09 + swellPhase * 1.7) * 1.4
            seaPath.addLine(to: CGPoint(x: x, y: seaY + CGFloat(ripple)))
            x += 6
        }
        seaPath.addLine(to: CGPoint(x: w, y: h))
        seaPath.addLine(to: CGPoint(x: 0, y: h))
        seaPath.closeSubpath()
        ctx.fill(seaPath, with: .color(Sea.deep.opacity(0.55)))

        var rim = Path()
        rim.move(to: CGPoint(x: 0, y: seaY))
        x = 0
        while x <= w {
            let ripple = sin(Double(x) * 0.09 + swellPhase * 1.7) * 1.4
            rim.addLine(to: CGPoint(x: x, y: seaY + CGFloat(ripple)))
            x += 6
        }
        ctx.stroke(rim, with: .color(Color.white.opacity(brief.haze > 0.45 ? 0.42 : 0.85)),
                   style: StrokeStyle(lineWidth: 2.2))

        if brief.haze > 0.05 {
            let band = Path(CGRect(x: 0, y: seaY - 26, width: w, height: 52))
            ctx.fill(band, with: .color(Color.white.opacity(brief.haze * 0.32)))
        }

        for k in 0..<7 {
            var wave = Path()
            let y = seaY + 14 + CGFloat(k) * 13
            guard y < h else { break }
            var wx: CGFloat = CGFloat((k % 3)) * 22 - 20
            while wx < w {
                wave.move(to: CGPoint(x: wx, y: y))
                wave.addQuadCurve(to: CGPoint(x: wx + 26, y: y),
                                  control: CGPoint(x: wx + 13, y: y - 5))
                wx += 52
            }
            ctx.stroke(wave, with: .color(Color.white.opacity(0.20)),
                       style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
        }

        let mirrorRect = CGRect(x: 0, y: 0, width: w * 0.5, height: h)
        ctx.fill(Path(mirrorRect), with: .color(Sea.deep.opacity(0.16)))

        var divider = Path()
        divider.move(to: CGPoint(x: w * 0.5, y: 0))
        divider.addLine(to: CGPoint(x: w * 0.5, y: h))
        ctx.stroke(divider, with: .color(Color.white.opacity(0.30)),
                   style: StrokeStyle(lineWidth: 1.6, dash: [5, 6]))

        let bodyY = seaY - compress(gapDegrees)
        let bodyX = w * 0.30
        if bodyY > -60 && bodyY < h + 60 {
            var clipped = ctx
            clipped.clip(to: Path(mirrorRect))
            drawBody(clipped, at: CGPoint(x: bodyX, y: bodyY), scale: w)
        }

        var cross = Path()
        cross.move(to: CGPoint(x: w * 0.5 - 16, y: seaY))
        cross.addLine(to: CGPoint(x: w * 0.5 + 16, y: seaY))
        ctx.stroke(cross, with: .color(Sea.brass.opacity(0.9)),
                   style: StrokeStyle(lineWidth: 1.6))

        if abs(gapDegrees) > 0.30 || (showHint && abs(gapDegrees) > 0.02) {
            let up = gapDegrees < 0
            var arrow = Path()
            let ax = w * 0.82
            let ay = h * 0.5
            let dir: CGFloat = up ? -1 : 1
            arrow.move(to: CGPoint(x: ax, y: ay + dir * 26))
            arrow.addLine(to: CGPoint(x: ax, y: ay - dir * 26))
            arrow.move(to: CGPoint(x: ax - 9, y: ay - dir * 14))
            arrow.addLine(to: CGPoint(x: ax, y: ay - dir * 26))
            arrow.addLine(to: CGPoint(x: ax + 9, y: ay - dir * 14))
            ctx.stroke(arrow, with: .color(Sea.brass.opacity(0.75)),
                       style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
    }

    private func drawBody(_ ctx: GraphicsContext, at p: CGPoint, scale: CGFloat) {
        switch brief.kind {
        case .star, .planet:
            let r = scale * 0.020
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r * 4, y: p.y - r * 4,
                                            width: r * 8, height: r * 8)),
                     with: .color(Color.white.opacity(0.18)))
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r,
                                            width: r * 2, height: r * 2)),
                     with: .color(Color.white))
            var rays = Path()
            for k in 0..<4 {
                let a = Double(k) * .pi / 2 + 0.25
                rays.move(to: p)
                rays.addLine(to: CGPoint(x: p.x + CGFloat(cos(a)) * r * 5,
                                         y: p.y + CGFloat(sin(a)) * r * 5))
            }
            ctx.stroke(rays, with: .color(Color.white.opacity(0.65)),
                       style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
        case .sun, .moon:
            let r = scale * 0.075
            let tone = brief.kind == .sun ? Sea.brassLight : Color.white
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r * 1.5, y: p.y - r * 1.5,
                                            width: r * 3, height: r * 3)),
                     with: .color(tone.opacity(0.16)))
            ctx.fill(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r,
                                            width: r * 2, height: r * 2)),
                     with: .color(tone.opacity(0.95)))
            ctx.stroke(Path(ellipseIn: CGRect(x: p.x - r, y: p.y - r,
                                              width: r * 2, height: r * 2)),
                       with: .color(Sea.ink.opacity(0.45)),
                       style: StrokeStyle(lineWidth: 1.4))
            var limbMark = Path()
            let ly = brief.limb == .lower ? p.y + r : p.y - r
            limbMark.move(to: CGPoint(x: p.x - r * 0.7, y: ly))
            limbMark.addLine(to: CGPoint(x: p.x + r * 0.7, y: ly))
            ctx.stroke(limbMark, with: .color(Sea.oxblood.opacity(0.9)),
                       style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        }
    }
}

struct LevelBubble: View {
    let tilt: Double

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                Capsule().fill(Sea.cardSunk)
                Capsule().stroke(Sea.ink.opacity(0.28), lineWidth: 1)
                Capsule()
                    .stroke(Sea.brass.opacity(0.55), lineWidth: 1)
                    .frame(width: 26, height: geo.size.height - 4)
                Circle()
                    .fill(abs(tilt) < 0.06 ? Sea.moss : Sea.oxblood)
                    .frame(width: geo.size.height - 8, height: geo.size.height - 8)
                    .offset(x: CGFloat(max(-1, min(1, tilt))) * (w / 2 - 14))
            }
        }
        .frame(height: 26)
    }
}

struct SwellTrace: View {
    let phase: Double
    let amplitude: Double

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Canvas { ctx, _ in
                var p = Path()
                var x: CGFloat = 0
                while x <= w {
                    let y = h / 2 - CGFloat(sin(Double(x) / Double(w) * 6.28 * 2)) * (h / 2 - 4)
                    if x == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
                    x += 3
                }
                ctx.stroke(p, with: .color(Sea.wave.opacity(0.55)),
                           style: StrokeStyle(lineWidth: 1.6))
                var mid = Path()
                mid.move(to: CGPoint(x: 0, y: h / 2))
                mid.addLine(to: CGPoint(x: w, y: h / 2))
                ctx.stroke(mid, with: .color(Sea.ink.opacity(0.20)),
                           style: StrokeStyle(lineWidth: 1, dash: [3, 4]))

                var t = phase.truncatingRemainder(dividingBy: 6.28318) / 6.28318
                if t < 0 { t += 1 }
                let mx = CGFloat(t) * w / 2
                let my = h / 2 - CGFloat(sin(phase)) * (h / 2 - 4)
                ctx.fill(Path(ellipseIn: CGRect(x: mx - 4, y: my - 4, width: 8, height: 8)),
                         with: .color(abs(sin(phase)) < 0.14 ? Sea.moss : Sea.oxblood))
            }
        }
        .frame(height: 30)
        .opacity(amplitude > 0.1 ? 1 : 0.4)
    }
}
