import Foundation

struct InstrumentEntry: Identifiable {
    let slug: String
    let title: String
    let era: String
    let measures: String
    let howUsed: String
    let story: String

    var id: String { slug }
}

let instrumentEntries: [InstrumentEntry] = instrumentsSetA + instrumentsSetB + instrumentsSetC

let instrumentsSetA: [InstrumentEntry] = [
    InstrumentEntry(slug: "sextant", title: "The Sextant", era: "from 1757",
                    measures: "Angles up to 120°, to a tenth of a minute",
                    howUsed: "Look through the telescope at the horizon. Move the index arm until the reflected body appears to sit on the sea line, rock the instrument to find the lowest reading, then read the arc and the drum together.",
                    story: "The whole trick is double reflection: two mirrors mean the arc need only be a sixth of a circle to measure a third of one, and — far more importantly — the body and the horizon arrive at your eye together, so a rolling deck moves both at once. That is why a sextant works at sea and a fixed instrument does not."),
    InstrumentEntry(slug: "octant", title: "The Octant", era: "from 1731",
                    measures: "Angles up to 90°",
                    howUsed: "As a sextant, but read with a plain vernier and without a micrometer drum. Ebony frame, ivory scale, brass fittings.",
                    story: "Invented twice in the same year on two sides of the Atlantic, by John Hadley in London and Thomas Godfrey in Philadelphia, neither knowing of the other. It made the backstaff obsolete inside a generation. Cheap enough that a mate could own one, which mattered more than any refinement."),
    InstrumentEntry(slug: "backstaff", title: "The Backstaff", era: "from 1594",
                    measures: "The Sun's altitude, up to 90°",
                    howUsed: "Stand with your back to the Sun. Slide the shadow vane until its shadow falls on the horizon vane, then look through the sight vane at the horizon and read the two arcs together.",
                    story: "John Davis put the observer's back to the Sun and saved a great many eyes. Before it, taking a noon sight meant staring straight at the thing you were measuring. Sailors called it the Davis quadrant, and used it for a hundred and fifty years."),
    InstrumentEntry(slug: "astrolabe", title: "The Mariner's Astrolabe", era: "from 1481",
                    measures: "Altitude of the Sun or a star, in whole degrees",
                    howUsed: "Hang it from your thumb so it swings true, turn the alidade until the Sun's light passes through both sight holes, and read the degree mark against the pointer.",
                    story: "A heavy brass ring with most of its metal cut away — not for elegance but so the wind could pass through without swinging it. Even so, taking a sight from a pitching deck meant three men: one to hold, one to turn the alidade, one to read. Accurate to perhaps a degree, which is sixty miles."),
    InstrumentEntry(slug: "crossstaff", title: "The Cross-Staff", era: "from 1342",
                    measures: "The angle between two objects, up to about 60°",
                    howUsed: "Put the end of the staff to your eye and slide the transom until one end touches the horizon and the other the body. The graduation on the staff gives the angle.",
                    story: "The simplest instrument that ever gave a latitude: a stick and a sliding crosspiece. Its faults are famous — you must look at two things at once with one eye, and the Sun will blind you doing it. But it was cheap, it was wooden, and it could be replaced at any port in Europe."),
]

let instrumentsSetB: [InstrumentEntry] = [
    InstrumentEntry(slug: "kamal", title: "The Kamal", era: "from the 9th century",
                    measures: "The altitude of a known star, in fixed steps",
                    howUsed: "Hold the knotted cord in your teeth and the wooden card at arm's length. Choose the knot at which the card exactly fills the gap between the horizon and the star.",
                    story: "A rectangle of wood, a knotted string, and a body of memorised knowledge about which knot belongs to which port. Arab navigators crossed the Indian Ocean with it for six hundred years. Each knot is a latitude, and a latitude is a landfall."),
    InstrumentEntry(slug: "chronometer", title: "The Marine Chronometer", era: "from 1761",
                    measures: "Greenwich time, to a second a week",
                    howUsed: "Never move it, never wind it out of its hour, never let it stop. Compare it against a known signal in port and keep a written record of its rate.",
                    story: "Longitude is time, and time was the thing no ship could keep. John Harrison spent forty years proving a clock could go to sea. The board that had promised the prize spent nearly as long refusing to pay it. Within fifty years every deep-water ship carried three of them, and disagreement between them was how you knew one had gone wrong."),
    InstrumentEntry(slug: "chiplog", title: "The Chip Log", era: "from 1574",
                    measures: "Speed through the water, in knots",
                    howUsed: "Throw the weighted chip astern, let the line run free and count the knots that pass through your fingers while the sand glass empties.",
                    story: "The reason speed at sea is measured in knots is that it was once measured in actual knots — spaced along a line at the same ratio to a nautical mile as the glass bore to an hour. Everything about dead reckoning rests on this: your course, your speed, your time, and the honesty of the man counting."),
    InstrumentEntry(slug: "leadline", title: "The Lead Line", era: "from antiquity",
                    measures: "Depth in fathoms, and the nature of the bottom",
                    howUsed: "Swing the lead forward, let it touch bottom under the bow, and read the mark at the water as the ship comes over it. Arm the hollow with tallow to bring up sand or shell.",
                    story: "The oldest instrument on this list and the last one you will ever give up. It answers a question no star can: not where you are, but whether there is water under you. The leather, bunting and knots at each mark can be read in the dark by feel alone, which is when you most need them."),
    InstrumentEntry(slug: "azimuthcompass", title: "The Azimuth Compass", era: "from 1680",
                    measures: "The bearing of a body, and therefore compass error",
                    howUsed: "Sight the Sun or a star across the vanes as it rises or sets and read the bearing off the card. Compare it with the true bearing from the tables.",
                    story: "A compass tells you where its needle points, which is not the same as north. The difference is variation, deviation and iron in the hull, and the only way to catch it is to sight something whose true bearing you already know. The sky, in other words, checks the compass."),
]

let instrumentsSetC: [InstrumentEntry] = [
    InstrumentEntry(slug: "traverseboard", title: "The Traverse Board", era: "from 1400",
                    measures: "Course and speed through a watch, by memory of pegs",
                    howUsed: "Every half hour, put a peg in the hole for the course steered. On the lower grid, peg the speed logged. At the end of the watch, work the whole traverse into one course and distance.",
                    story: "Made for a crew who could not write. Eight rings of holes, one for each half hour of the watch, and thirty-two points of the compass radiating out. At the end of four hours the board holds the entire watch's steering, and the mate turns it into a single line on the chart."),
    InstrumentEntry(slug: "nocturnal", title: "The Nocturnal", era: "from 1520",
                    measures: "The hour of the night, from the pole stars",
                    howUsed: "Set the outer disc to the date, sight Polaris through the central hole, and swing the arm until it lies along the two Guards of the Little Bear. Read the hour off the teeth by touch.",
                    story: "A clock with one hand and no works, driven by the turning of the sky. The teeth around the rim are cut at different lengths so the hour can be counted with a fingertip in complete darkness — the most quietly brilliant detail on any instrument here."),
    InstrumentEntry(slug: "stationpointer", title: "The Station Pointer", era: "from 1774",
                    measures: "A position from two horizontal angles between three marks",
                    howUsed: "Set the two outer arms to the angles measured between three charted objects, then slide the whole instrument over the chart until each arm lies on its mark. The centre is your ship.",
                    story: "Coastal navigation's neatest trick and the only fix on this list that needs no sky at all. Two angles between three known points, taken with a sextant held sideways, and the answer falls out of the geometry. Accurate to yards, which no star sight has ever been."),
    InstrumentEntry(slug: "pelorus", title: "The Pelorus", era: "from 1854",
                    measures: "Relative and true bearings from the ship's head",
                    howUsed: "Set the card to the course being steered, sight the object across the vanes, and read the bearing directly. Or set the card to zero and read the angle off the bow.",
                    story: "A dumb compass — no needle, no magnetism, nothing to be pulled about by the iron in the ship. It only knows what you tell it. That is precisely why it is trusted: an instrument with no opinion of its own cannot be wrong about north, only about what you set."),
]
