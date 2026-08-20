import Foundation

struct Lesson: Identifiable {
    let slug: String
    let title: String
    let standfirst: String
    let paragraphs: [String]

    var id: String { slug }
}

let lessons: [Lesson] = lessonsA + lessonsB + lessonsC

let lessonsA: [Lesson] = [
    Lesson(slug: "altitude", title: "What an Altitude Is",
           standfirst: "Everything in celestial navigation begins with one angle.",
           paragraphs: [
            "An altitude is the angle at your eye between the horizon and a body in the sky. Nothing more. A sextant exists to measure that one angle and to do it from a moving deck, which is the whole of its difficulty.",
            "The number the instrument gives you is called the sextant altitude, Hs. It is not yet the truth. Your instrument has a small error of its own, your eye is above the sea, and the air between you and the body has bent its light. Each of those is a correction, applied in a fixed order, and what comes out at the end is the observed altitude, Ho.",
            "Ho is the honest angle: what a perfect observer at sea level with a perfect instrument in a vacuum would have measured. Only Ho is worth taking to the chart.",
            "The habit to build is this — never write down a sextant reading without also writing down the height of eye you took it from, the index error of the instrument, and the time. A reading without those three is not a sight. It is a number."])
    ,
    Lesson(slug: "horizon", title: "The Visible Horizon",
           standfirst: "The line you measure from is not where you think it is.",
           paragraphs: [
            "The horizon you can see is the tangent from your eye to the curve of the sea. Raise your eye and that tangent point runs further away and further down. Both facts matter, and the second matters more.",
            "From a small boat, with your eye two metres up, the horizon is about three miles off. From the bridge of a ship, twelve metres up, it is seven miles. From the crosstrees it is ten. That is why the lookout goes aloft.",
            "But as the horizon runs away it also drops below the true level plane through your eye. That drop is called dip, and it is the reason your sight will read too large unless you take it off.",
            "A poor horizon spoils a sight faster than a poor instrument. Haze, a rain squall, mist lying on the water, the false line where fog meets sea — each will cost you minutes of arc. When the horizon is bad, the honest thing is to write in the log that the horizon was bad."])
    ,
    Lesson(slug: "dip", title: "The Dip of the Horizon",
           standfirst: "The first correction, and the one you control.",
           paragraphs: [
            "Dip in minutes of arc is 1.76 times the square root of your height of eye in metres. Three metres gives three minutes. Twelve metres gives six. Twenty-six metres gives nine.",
            "It is always subtracted. The visible horizon is below the true horizontal, so every angle you measure up from it is larger than the angle you wanted.",
            "Notice how the square root works against extravagance. Climbing from three metres to twelve — four times the height — only doubles the dip. The correction grows slowly, which is a mercy, because nobody measures their height of eye precisely.",
            "The mistake that costs real distance is not getting the number slightly wrong. It is taking a sight from the bridge wing and applying the dip for the main deck, or the reverse. Three minutes of error is three miles, and three miles is the difference between clearing a headland and not."])
    ,
    Lesson(slug: "refraction", title: "How the Air Bends the Light",
           standfirst: "Every body sits higher than it really is.",
           paragraphs: [
            "Light entering the atmosphere at an angle is bent downward, so a body appears higher than it truly stands. The correction — refraction — is always subtracted, and it is not a constant.",
            "High up, near the zenith, the light comes almost straight down through the least air and refraction is nearly nothing. Low down it passes through a long slant of thick air and the effect grows fast: at thirty degrees it is under two minutes, at ten degrees it is five, at five degrees it is over eight.",
            "Below about fifteen degrees the correction also becomes unreliable, because it depends on temperature and pressure in ways no standard table can know. A cold night over warm water can bend light in ways that will make a fool of you.",
            "The rule that follows is simple and worth obeying: take your sights high when you can. If you must shoot low, shoot several and expect the answer to be soft."])
]

let lessonsB: [Lesson] = [
    Lesson(slug: "semidiameter", title: "Limb and Centre",
           standfirst: "You cannot bring the middle of the Sun down to the sea.",
           paragraphs: [
            "The Sun and the Moon are discs, not points. Trying to judge where the centre of a bright disc sits against the horizon is guesswork. Trying to lay an edge on the horizon is a thing the eye does extremely well.",
            "So you bring down an edge — a limb — and then correct for the half-diameter to get the centre. The Sun's semi-diameter is about sixteen minutes of arc. The Moon's is about fifteen and a half, and varies more.",
            "Bring the lower limb down and the centre is above it: add. Bring the upper limb down and the centre is below it: subtract. Getting the sign backwards puts thirty-two minutes into your answer, which is thirty-two miles.",
            "Most navigators shoot the lower limb by habit, and change only when the lower limb is lost in haze or cloud. Habit is a defence against sign errors, and sign errors are the ones that put ships on rocks."])
    ,
    Lesson(slug: "circleposition", title: "The Circle of Position",
           standfirst: "A single sight does not give a position. It gives a circle.",
           paragraphs: [
            "At any moment a body stands directly overhead at exactly one point on the Earth. That point is its geographical position, and it moves west at about fifteen degrees an hour.",
            "If you measure the body's altitude and find it fifty degrees above your horizon, then you are forty degrees of arc — two thousand four hundred nautical miles — from that point. Everyone else who measured fifty degrees at the same instant is the same distance away.",
            "All of you together stand on a circle drawn round the geographical position. That circle is your position line. You are somewhere on it and the sight cannot say where.",
            "This is why a fix needs two bodies, or one body twice with the ship's run between. Two circles cross in two places, and the two places are usually thousands of miles apart, so common sense settles which is yours."])
    ,
    Lesson(slug: "intercept", title: "The Intercept Method",
           standfirst: "Marcq St. Hilaire's answer to an impossible drawing.",
           paragraphs: [
            "A circle of position two thousand miles across cannot be drawn on a chart. But over the twenty or thirty miles that matter, an arc that size is indistinguishable from a straight line — and drawing a straight line is easy.",
            "So you guess. You choose an assumed position near where you think you are, and you calculate what altitude a body would have shown from there. That is the computed altitude, Hc.",
            "Compare it with what you actually observed. If your Ho is greater than Hc, you are nearer the body than your assumption, by one nautical mile for every minute of difference. If Ho is less, you are further away.",
            "Step that difference along the bearing of the body — toward if greater, away if less — and rule a line square across at the end of it. That line is a piece of the great circle, and it is your line of position."])
    ,
    Lesson(slug: "noonsight", title: "The Noon Sight",
           standfirst: "The one sight that needs no clock at all.",
           paragraphs: [
            "As the Sun climbs toward noon it rises more and more slowly, hangs, and begins to fall. At the moment it stops rising it is on your meridian — due north or due south of you — and its altitude at that instant gives your latitude directly.",
            "You do not need to know the time. You do not need an assumed position. You need the Sun's declination for the day and one subtraction. For four hundred years that made latitude easy and longitude nearly impossible.",
            "The method is to start observing well before noon and keep marking. The reading climbs, slows, and steadies. Take the greatest altitude you get.",
            "In practice you watch for the moment the figure stops growing. On a rolling ship in poor visibility that moment can be hard to catch, which is why a good navigator starts early and takes more sights than are needed."])
]

let lessonsC: [Lesson] = [
    Lesson(slug: "longitudetime", title: "Longitude Is Time",
           standfirst: "The whole difficulty of navigation, in one sentence.",
           paragraphs: [
            "The Earth turns three hundred and sixty degrees in twenty-four hours: fifteen degrees an hour, one degree in four minutes, one minute of arc in four seconds.",
            "So if you know the time at Greenwich and the local time where you stand, the difference between them is your longitude. Nothing more complicated than that is required — except a clock that keeps Greenwich time on a ship, which took a century of failure to build.",
            "The arithmetic cuts both ways. Four seconds of chronometer error is one mile of position error at the equator. A clock losing two seconds a day is fifteen miles wrong after a month at sea.",
            "That is why ships carried three chronometers. One tells you the time. Two tell you nothing when they disagree. Three let you find the liar."])
    ,
    Lesson(slug: "staridentify", title: "Finding the Star",
           standfirst: "Twilight is short and the sky is crowded.",
           paragraphs: [
            "Star sights are only possible in twilight, when the stars are out and the horizon is still visible. That window is about twenty minutes in the tropics and can be an hour in high latitudes. Everything must be ready before it opens.",
            "Choose your stars in advance. Three is the standard, and they should be spread widely round the compass — ideally about a hundred and twenty degrees apart, so their position lines cross at good angles.",
            "Bright is better than well placed. A star you cannot find in ten seconds is a star you should not have chosen. The classic pointers exist for exactly this: the Plough to Polaris, the Plough's handle to Arcturus and on to Spica, Orion's belt to Sirius and to Aldebaran.",
            "Set your sextant to roughly the altitude you expect before you look. Then the star is already near the horizon in the mirror and you only have to find it, not hunt for it."])
    ,
    Lesson(slug: "cockedhat", title: "The Cocked Hat",
           standfirst: "Three lines that never quite meet.",
           paragraphs: [
            "Take three sights, work them, and rule three lines of position. They will form a small triangle. They always do. A navigator who reports three lines crossing at a point has moved one of them.",
            "The triangle is called the cocked hat, and its size is an honest statement about the quality of your work. A hat two miles across on a rolling ship in poor twilight is respectable. A hat ten miles across means something went wrong and you should find out what before you trust the fix.",
            "The usual place to put the fix is the centre of the triangle. This is a convention, not a truth. If one of the three sights was taken through haze or at a low altitude, weight the other two.",
            "A very small hat is not proof of a good fix, either. Three sights sharing the same systematic error — a wrong index error, a wrong height of eye — will agree beautifully with each other and be miles from the ship."])
    ,
    Lesson(slug: "runningfix", title: "The Running Fix",
           standfirst: "How a morning sight is still worth something at noon.",
           paragraphs: [
            "Often only one body is available: the Sun on a clear day, one star through a gap in cloud. One line of position is not a fix — but two lines taken hours apart can be made into one, if you account for the ship's movement between them.",
            "Work the first sight and rule its line. Then, from any point on that line, lay off the course steered and the distance run in the interval, and rule a second line parallel to the first through the new point. You have advanced the line.",
            "Where the advanced line crosses the line from the second sight is your running fix.",
            "Its accuracy depends entirely on the dead reckoning in between. Currents you did not know about, leeway, a helmsman who wandered — all of it goes straight into the answer. A running fix over two hours is usually sound. A running fix over twelve hours is a hope with a line drawn through it."])
]
