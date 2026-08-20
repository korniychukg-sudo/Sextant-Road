import Foundation

struct GlossaryTerm: Identifiable {
    let term: String
    let meaning: String
    var id: String { term }
}

let glossary: [GlossaryTerm] = glossaryA + glossaryB + glossaryC + glossaryD + glossaryE

let glossaryA: [GlossaryTerm] = [
    GlossaryTerm(term: "Altitude", meaning: "The angle between the horizon and a body, measured at the observer's eye."),
    GlossaryTerm(term: "Hs", meaning: "Sextant altitude — the raw reading straight off the arc and drum, before any correction."),
    GlossaryTerm(term: "Ha", meaning: "Apparent altitude — Hs after index error and dip have been applied."),
    GlossaryTerm(term: "Ho", meaning: "Observed altitude — the corrected, honest angle. The only one worth plotting."),
    GlossaryTerm(term: "Hc", meaning: "Computed altitude — what the body's altitude would be from your assumed position."),
    GlossaryTerm(term: "Index error", meaning: "The angle a sextant reads when it should read zero. On the arc means it reads too much."),
    GlossaryTerm(term: "Dip", meaning: "The angle by which the visible sea horizon falls below the true horizontal, because your eye is above the water."),
    GlossaryTerm(term: "Refraction", meaning: "The bending of light in the atmosphere, which makes every body appear higher than it is."),
    GlossaryTerm(term: "Semi-diameter", meaning: "Half the apparent width of the Sun or Moon, about sixteen minutes of arc."),
]

let glossaryB: [GlossaryTerm] = [
    GlossaryTerm(term: "Limb", meaning: "The upper or lower edge of a disc. What you actually bring down to the horizon."),
    GlossaryTerm(term: "Intercept", meaning: "The difference between Ho and Hc, in minutes of arc, which is also its distance in nautical miles."),
    GlossaryTerm(term: "Azimuth", meaning: "The true bearing of a body from the observer, measured clockwise from north."),
    GlossaryTerm(term: "Zn", meaning: "The symbol for true azimuth, used in every sight reduction form ever printed."),
    GlossaryTerm(term: "Line of position", meaning: "A line on the chart somewhere along which the ship must lie. Abbreviated LOP."),
    GlossaryTerm(term: "Assumed position", meaning: "A convenient guessed position, chosen near the ship, from which the calculation is worked."),
    GlossaryTerm(term: "Circle of position", meaning: "The true shape of a single sight's answer: a circle drawn round the body's geographical position."),
    GlossaryTerm(term: "Geographical position", meaning: "The point on the Earth's surface directly beneath a body at a given instant."),
    GlossaryTerm(term: "Cocked hat", meaning: "The small triangle formed where three lines of position fail to meet at a point."),
]

let glossaryC: [GlossaryTerm] = [
    GlossaryTerm(term: "Fix", meaning: "A position derived from two or more crossing lines of position."),
    GlossaryTerm(term: "Running fix", meaning: "A fix made from two sights taken at different times, with the ship's run laid off between them."),
    GlossaryTerm(term: "Dead reckoning", meaning: "Position worked forward from a known point using course, speed and time alone."),
    GlossaryTerm(term: "Declination", meaning: "A body's angular distance north or south of the celestial equator. The sky's latitude."),
    GlossaryTerm(term: "SHA", meaning: "Sidereal hour angle — a star's position measured westward from the First Point of Aries."),
    GlossaryTerm(term: "GHA", meaning: "Greenwich hour angle — how far west of Greenwich a body's geographical position lies at a given moment."),
    GlossaryTerm(term: "Meridian passage", meaning: "The moment a body crosses your meridian, standing due north or due south, at its greatest altitude."),
    GlossaryTerm(term: "Noon sight", meaning: "An altitude taken at meridian passage, which gives latitude without needing the time."),
    GlossaryTerm(term: "Nautical mile", meaning: "One minute of arc on a great circle: 1,852 metres. The reason a minute of altitude is a mile of distance."),
]

let glossaryD: [GlossaryTerm] = [
    GlossaryTerm(term: "Knot", meaning: "One nautical mile in one hour. Named for the knots in a chip log's line."),
    GlossaryTerm(term: "Swinging the arc", meaning: "Rocking the sextant gently about the line of sight so the body swings in an arc. The true altitude is at the bottom of the swing."),
    GlossaryTerm(term: "Marking", meaning: "Calling the instant of the sight, so a second person can note the time exactly."),
    GlossaryTerm(term: "Height of eye", meaning: "How far your eye stands above the sea. It fixes the dip and must be honest."),
    GlossaryTerm(term: "Twilight", meaning: "The window in which both stars and the horizon can be seen. All star sights live in it."),
    GlossaryTerm(term: "Civil twilight", meaning: "The period when the Sun is up to six degrees below the horizon. The best stars appear at its end."),
    GlossaryTerm(term: "Horizon glass", meaning: "The half-silvered mirror through which you see the real horizon and the reflected body at once."),
    GlossaryTerm(term: "Index mirror", meaning: "The mirror on the moving arm, which catches the body and throws it down to the horizon glass."),
    GlossaryTerm(term: "Shades", meaning: "Coloured glass filters that swing across the light path, without which a Sun sight would cost you an eye."),
]

let glossaryE: [GlossaryTerm] = [
    GlossaryTerm(term: "Micrometer drum", meaning: "The fine screw at the end of the index arm that reads minutes and tenths."),
    GlossaryTerm(term: "Vernier", meaning: "An older scale that reads fractions of a division by counting which pair of lines coincide."),
    GlossaryTerm(term: "Limb of the sextant", meaning: "The graduated arc itself, on which the whole degrees are read."),
    GlossaryTerm(term: "Chronometer rate", meaning: "The known amount a chronometer gains or loses each day, kept in writing and applied to every sight."),
    GlossaryTerm(term: "Variation", meaning: "The angle between true north and magnetic north at a given place. Printed on the chart."),
    GlossaryTerm(term: "Deviation", meaning: "Compass error caused by the ship's own iron, which changes with the ship's heading."),
    GlossaryTerm(term: "Great circle", meaning: "The shortest track between two points on a sphere. It looks curved on a Mercator chart."),
    GlossaryTerm(term: "Rhumb line", meaning: "A track of constant compass course. Longer than a great circle, and far easier to steer."),
    GlossaryTerm(term: "Amplitude", meaning: "The bearing of the Sun at rising or setting, used to check the compass against the sky."),
]
