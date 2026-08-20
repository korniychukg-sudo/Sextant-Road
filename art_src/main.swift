import Foundation

let args = CommandLine.arguments
let outDir = args.count > 1 ? args[1] : "./out"
let mode = args.count > 2 ? args[2] : "all"

try? FileManager.default.createDirectory(atPath: outDir,
                                         withIntermediateDirectories: true)

func stamp(_ what: String) {
    FileHandle.standardError.write(("  " + what + "\n").data(using: .utf8)!)
}

if mode == "icon" || mode == "all" {
    stamp("icon")
    renderIcon(outDir)
}

if mode == "stars" || mode == "all" {
    for f in figures {
        stamp("star " + f.slug)
        drawStarPlate(f, dir: outDir)
    }
}

if mode == "instruments" || mode == "all" {
    for i in instruments {
        stamp("instrument " + i.slug)
        drawInstrumentPlate(i, dir: outDir)
    }
}

if mode == "diagrams" || mode == "all" {
    for dg in diagrams {
        stamp("diagram " + dg.slug)
        drawDiagramPlate(dg, dir: outDir)
    }
}

if mode == "charts" || mode == "all" {
    for c in voyageCharts {
        stamp("chart " + c.slug)
        drawVoyageChart(c, dir: outDir)
    }
}

if mode == "skies" || mode == "all" {
    for sc in skyScenes {
        stamp("sky " + sc.slug)
        drawSkyScene(sc, dir: outDir)
    }
}

if mode == "vignettes" || mode == "all" {
    for v in vignettes {
        stamp("vignette " + v.slug)
        drawVignette(v, dir: outDir)
    }
}

stamp("done")
