import SwiftUI

struct SextantGlyph: View {
    var size: CGFloat = 24
    var colour: Color = Sea.ink

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            let apex = CGPoint(x: w * 0.50, y: h * 0.14)
            let r = h * 0.74
            var arc = Path()
            arc.addArc(center: apex, radius: r, startAngle: .radians(0.90),
                       endAngle: .radians(2.24), clockwise: false)
            ctx.stroke(arc, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.11,
                                                                    lineCap: .round))
            var frame = Path()
            frame.move(to: CGPoint(x: apex.x + cos(0.94) * r, y: apex.y + sin(0.94) * r))
            frame.addLine(to: apex)
            frame.addLine(to: CGPoint(x: apex.x + cos(2.20) * r, y: apex.y + sin(2.20) * r))
            ctx.stroke(frame, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.085,
                                                                      lineCap: .round,
                                                                      lineJoin: .round))
            var arm = Path()
            arm.move(to: apex)
            arm.addLine(to: CGPoint(x: apex.x + cos(1.36) * r, y: apex.y + sin(1.36) * r))
            ctx.stroke(arm, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                     lineCap: .round))
            let drum = CGRect(x: apex.x + cos(1.36) * r - w * 0.09,
                              y: apex.y + sin(1.36) * r - w * 0.09,
                              width: w * 0.18, height: w * 0.18)
            ctx.fill(Path(ellipseIn: drum), with: .color(colour))
        }
        .frame(width: size, height: size)
    }
}

struct ShipGlyph: View {
    var size: CGFloat = 24
    var colour: Color = Sea.ink

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var hull = Path()
            hull.move(to: CGPoint(x: w * 0.08, y: h * 0.68))
            hull.addLine(to: CGPoint(x: w * 0.92, y: h * 0.68))
            hull.addLine(to: CGPoint(x: w * 0.76, y: h * 0.86))
            hull.addLine(to: CGPoint(x: w * 0.22, y: h * 0.86))
            hull.closeSubpath()
            ctx.fill(hull, with: .color(colour))

            var mast = Path()
            mast.move(to: CGPoint(x: w * 0.50, y: h * 0.66))
            mast.addLine(to: CGPoint(x: w * 0.50, y: h * 0.10))
            ctx.stroke(mast, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                      lineCap: .round))
            var sailA = Path()
            sailA.move(to: CGPoint(x: w * 0.52, y: h * 0.16))
            sailA.addLine(to: CGPoint(x: w * 0.86, y: h * 0.42))
            sailA.addLine(to: CGPoint(x: w * 0.52, y: h * 0.42))
            sailA.closeSubpath()
            ctx.fill(sailA, with: .color(colour.opacity(0.78)))
            var sailB = Path()
            sailB.move(to: CGPoint(x: w * 0.48, y: h * 0.20))
            sailB.addLine(to: CGPoint(x: w * 0.16, y: h * 0.46))
            sailB.addLine(to: CGPoint(x: w * 0.48, y: h * 0.46))
            sailB.closeSubpath()
            ctx.fill(sailB, with: .color(colour.opacity(0.55)))
        }
        .frame(width: size, height: size)
    }
}

struct AlmanacGlyph: View {
    var size: CGFloat = 24
    var colour: Color = Sea.ink

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var left = Path()
            left.move(to: CGPoint(x: w * 0.50, y: h * 0.24))
            left.addCurve(to: CGPoint(x: w * 0.08, y: h * 0.20),
                          control1: CGPoint(x: w * 0.34, y: h * 0.14),
                          control2: CGPoint(x: w * 0.18, y: h * 0.14))
            left.addLine(to: CGPoint(x: w * 0.08, y: h * 0.78))
            left.addCurve(to: CGPoint(x: w * 0.50, y: h * 0.82),
                          control1: CGPoint(x: w * 0.20, y: h * 0.74),
                          control2: CGPoint(x: w * 0.34, y: h * 0.74))
            left.closeSubpath()
            ctx.stroke(left, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                      lineJoin: .round))
            var right = Path()
            right.move(to: CGPoint(x: w * 0.50, y: h * 0.24))
            right.addCurve(to: CGPoint(x: w * 0.92, y: h * 0.20),
                           control1: CGPoint(x: w * 0.66, y: h * 0.14),
                           control2: CGPoint(x: w * 0.82, y: h * 0.14))
            right.addLine(to: CGPoint(x: w * 0.92, y: h * 0.78))
            right.addCurve(to: CGPoint(x: w * 0.50, y: h * 0.82),
                           control1: CGPoint(x: w * 0.80, y: h * 0.74),
                           control2: CGPoint(x: w * 0.66, y: h * 0.74))
            right.closeSubpath()
            ctx.stroke(right, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                       lineJoin: .round))
            let star = CGPoint(x: w * 0.71, y: h * 0.46)
            for k in 0..<4 {
                let a = Double(k) * .pi / 2 + 0.32
                var ray = Path()
                ray.move(to: star)
                ray.addLine(to: CGPoint(x: star.x + CGFloat(cos(a)) * w * 0.13,
                                        y: star.y + CGFloat(sin(a)) * w * 0.13))
                ctx.stroke(ray, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.05,
                                                                         lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

struct LogbookGlyph: View {
    var size: CGFloat = 24
    var colour: Color = Sea.ink

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            let page = Path(roundedRect: CGRect(x: w * 0.16, y: h * 0.10,
                                                width: w * 0.62, height: h * 0.80),
                            cornerRadius: w * 0.06)
            ctx.stroke(page, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075))
            for k in 0..<4 {
                var line = Path()
                let y = h * (0.28 + Double(k) * 0.16)
                line.move(to: CGPoint(x: w * 0.27, y: y))
                line.addLine(to: CGPoint(x: w * (k == 3 ? 0.52 : 0.67), y: y))
                ctx.stroke(line, with: .color(colour.opacity(0.72)),
                           style: StrokeStyle(lineWidth: w * 0.055, lineCap: .round))
            }
            var quill = Path()
            quill.move(to: CGPoint(x: w * 0.62, y: h * 0.82))
            quill.addLine(to: CGPoint(x: w * 0.94, y: h * 0.22))
            ctx.stroke(quill, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                        lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

struct StarMark: View {
    var size: CGFloat = 18
    var colour: Color = Sea.brass
    var filled: Bool = true

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var p = Path()
            let cx = w / 2, cy = h / 2
            for k in 0..<10 {
                let a = Double(k) * .pi / 5 - .pi / 2
                let r = k % 2 == 0 ? Double(w) * 0.48 : Double(w) * 0.20
                let pt = CGPoint(x: cx + CGFloat(cos(a) * r), y: cy + CGFloat(sin(a) * r))
                if k == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()
            if filled {
                ctx.fill(p, with: .color(colour))
            } else {
                ctx.stroke(p, with: .color(colour.opacity(0.55)),
                           style: StrokeStyle(lineWidth: w * 0.08, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

struct ChevronMark: View {
    var size: CGFloat = 14
    var colour: Color = Sea.inkPale
    var pointsLeft: Bool = false

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var p = Path()
            if pointsLeft {
                p.move(to: CGPoint(x: w * 0.68, y: h * 0.16))
                p.addLine(to: CGPoint(x: w * 0.30, y: h * 0.50))
                p.addLine(to: CGPoint(x: w * 0.68, y: h * 0.84))
            } else {
                p.move(to: CGPoint(x: w * 0.34, y: h * 0.16))
                p.addLine(to: CGPoint(x: w * 0.72, y: h * 0.50))
                p.addLine(to: CGPoint(x: w * 0.34, y: h * 0.84))
            }
            ctx.stroke(p, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.16,
                                                                    lineCap: .round,
                                                                    lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct CloseMark: View {
    var size: CGFloat = 18
    var colour: Color = Sea.inkSoft

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var p = Path()
            p.move(to: CGPoint(x: w * 0.22, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.78, y: h * 0.78))
            p.move(to: CGPoint(x: w * 0.78, y: h * 0.22))
            p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.78))
            ctx.stroke(p, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.13,
                                                                    lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}

struct TickMark: View {
    var size: CGFloat = 16
    var colour: Color = Sea.moss

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            var p = Path()
            p.move(to: CGPoint(x: w * 0.18, y: h * 0.52))
            p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.76))
            p.addLine(to: CGPoint(x: w * 0.84, y: h * 0.24))
            ctx.stroke(p, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.15,
                                                                    lineCap: .round,
                                                                    lineJoin: .round))
        }
        .frame(width: size, height: size)
    }
}

struct AnchorGlyph: View {
    var size: CGFloat = 22
    var colour: Color = Sea.brass

    var body: some View {
        Canvas { ctx, rect in
            let w = rect.width, h = rect.height
            ctx.stroke(Path(ellipseIn: CGRect(x: w * 0.40, y: h * 0.08,
                                              width: w * 0.20, height: h * 0.20)),
                       with: .color(colour), style: StrokeStyle(lineWidth: w * 0.08))
            var shank = Path()
            shank.move(to: CGPoint(x: w * 0.50, y: h * 0.26))
            shank.addLine(to: CGPoint(x: w * 0.50, y: h * 0.80))
            ctx.stroke(shank, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.08,
                                                                       lineCap: .round))
            var stock = Path()
            stock.move(to: CGPoint(x: w * 0.26, y: h * 0.36))
            stock.addLine(to: CGPoint(x: w * 0.74, y: h * 0.36))
            ctx.stroke(stock, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.075,
                                                                       lineCap: .round))
            var arms = Path()
            arms.move(to: CGPoint(x: w * 0.16, y: h * 0.58))
            arms.addCurve(to: CGPoint(x: w * 0.84, y: h * 0.58),
                          control1: CGPoint(x: w * 0.22, y: h * 0.94),
                          control2: CGPoint(x: w * 0.78, y: h * 0.94))
            ctx.stroke(arms, with: .color(colour), style: StrokeStyle(lineWidth: w * 0.08,
                                                                       lineCap: .round))
        }
        .frame(width: size, height: size)
    }
}
