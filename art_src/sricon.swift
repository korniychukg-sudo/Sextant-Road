import Foundation
import CoreGraphics

func renderIcon(_ dir: String) {
    let s = Sheet(1024, 1024)
    let seed = seedOf("sextant-road-icon")
    s.fillAll(Tint(r: 0.086, g: 0.125, b: 0.184))

    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(Tint(r: 0.180, g: 0.243, b: 0.318)),
                                   cgt(Tint(r: 0.055, g: 0.086, b: 0.133))] as CFArray,
                          locations: [0, 1]) {
        s.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 512, y: 620), startRadius: 20,
                                 endCenter: CGPoint(x: 512, y: 560), endRadius: 760,
                                 options: [.drawsAfterEndLocation])
    }

    s.flipToTopDown()
    s.light = 2.25

    var rng = Spin(seed)
    for _ in 0..<130 {
        let x = rng.d() * 1024
        let y = rng.d() * 800
        s.disc(x, y, rng.r(1.4, 3.6), Tint(r: 0.94, g: 0.92, b: 0.84, a: rng.r(0.18, 0.62)))
    }

    let horizon = 902.0
    let seaRegion = [pnt(-40, horizon), pnt(1064, horizon), pnt(1064, 1064), pnt(-40, 1064)]
    wash(s, seaRegion, Tint(r: 0.129, g: 0.212, b: 0.290), strength: 0.86, bleed: 8, seed: seed &+ 3)
    var wr = Spin(seed &+ 11)
    var y = horizon + 22
    while y < 1030 {
        var x = -40.0
        while x < 1064 {
            let len = wr.r(40, 110)
            penStroke(s, [pnt(x, y), pnt(x + len * 0.5, y - wr.r(4, 12)), pnt(x + len, y)],
                      weight: 2.6, colour: Tint(r: 0.62, g: 0.70, b: 0.74, a: wr.r(0.18, 0.42)),
                      wobble: 0.7, taper: true, seed: seed &+ u64(Int(x + y)))
            x += len + wr.r(26, 80)
        }
        y += wr.r(26, 44)
    }
    penStroke(s, [pnt(-30, horizon), pnt(1054, horizon)], weight: 4.0,
              colour: Tint(r: 0.72, g: 0.78, b: 0.80, a: 0.72),
              wobble: 1.4, taper: false, seed: seed &+ 17)

    sextantFigure(s, cx: 504, cy: 566, radius: 548, tilt: -0.13,
                  sextantIconPalette, seed: seed &+ 401)

    let starX = 852.0, starY = 162.0
    s.disc(starX, starY, 62, Tint(r: 0.98, g: 0.94, b: 0.82, a: 0.16))
    s.disc(starX, starY, 30, Tint(r: 0.99, g: 0.97, b: 0.90, a: 0.55))
    s.disc(starX, starY, 17, Tint(r: 1.0, g: 0.99, b: 0.95, a: 0.98))
    for k in 0..<4 {
        let a = Double(k) * .pi / 2 + 0.20
        penStroke(s, [pnt(starX, starY), pnt(starX + cos(a) * 96, starY + sin(a) * 96)],
                  weight: 8.0, colour: Tint(r: 0.99, g: 0.97, b: 0.90, a: 0.66),
                  wobble: 0.4, taper: true, seed: seed &+ UInt64(190 + k))
    }

    if let g = CGGradient(colorsSpace: chartSpace,
                          colors: [cgt(Tint(r: 0, g: 0, b: 0, a: 0)),
                                   cgt(Tint(r: 0, g: 0, b: 0, a: 0.42))] as CFArray,
                          locations: [0.58, 1]) {
        s.ctx.drawRadialGradient(g, startCenter: CGPoint(x: 512, y: 512), startRadius: 0,
                                 endCenter: CGPoint(x: 512, y: 512), endRadius: 760,
                                 options: [.drawsAfterEndLocation])
    }

    s.writePNG(dir, "AppIcon-1024")
}
