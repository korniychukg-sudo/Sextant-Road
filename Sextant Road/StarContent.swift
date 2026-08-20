import Foundation

struct NavStar: Identifiable {
    let slug: String
    let name: String
    let constellation: String
    let magnitude: String
    let declination: String
    let hemisphere: String
    let howToFind: String
    let story: String

    var id: String { slug }
}

let navStars: [NavStar] = navStarsA + navStarsB + navStarsC

let navStarsA: [NavStar] = [
    NavStar(slug: "polaris", name: "Polaris", constellation: "Ursa Minor",
            magnitude: "2.0", declination: "N 89° 21'", hemisphere: "North",
            howToFind: "Run a line through the two stars at the outer edge of the Plough's bowl and carry it five times their spacing.",
            story: "The one star that barely moves. Stand anywhere north of the equator, measure its height above the horizon, apply a small correction and you have your latitude — no tables, no clock, no arithmetic worth the name. Every other star in the sky is a calculation. Polaris is a reading."),
    NavStar(slug: "sirius", name: "Sirius", constellation: "Canis Major",
            magnitude: "−1.5", declination: "S 16° 44'", hemisphere: "Both",
            howToFind: "Follow the three stars of Orion's belt down and to the left. Sirius is the brightest thing in that quarter of the sky and flashes colours low down.",
            story: "The brightest star there is, and the easiest sight in the book — bright enough to hold in the mirror when the twilight is nearly gone. It flickers red and green near the horizon because you are looking through the thickest air, which is also why a low Sirius is a sight to distrust."),
    NavStar(slug: "canopus", name: "Canopus", constellation: "Carina",
            magnitude: "−0.7", declination: "S 52° 42'", hemisphere: "South",
            howToFind: "South and west of Sirius, about the width of two outstretched hands. Nothing else down there is so bright.",
            story: "The second brightest star, and for the southern navigator the great standby. It never rises for most of Europe, which is why the old northern almanacs barely mention it and why the first ships to cross the line found the southern sky an unlearned language."),
    NavStar(slug: "arcturus", name: "Arcturus", constellation: "Bootes",
            magnitude: "−0.1", declination: "N 19° 05'", hemisphere: "Both",
            howToFind: "Follow the curve of the Plough's handle away from the bowl. Arc to Arcturus, as every apprentice is taught.",
            story: "A red-orange star high in the northern summer sky and one of the three that make the classic evening triangle with Vega and Altair. Take those three in ten minutes of twilight and the crossing lines will put you inside a mile."),
    NavStar(slug: "vega", name: "Vega", constellation: "Lyra",
            magnitude: "0.0", declination: "N 38° 47'", hemisphere: "North",
            howToFind: "Nearly overhead on northern summer evenings, the brightest of the three corners of the Summer Triangle.",
            story: "Bright, blue-white and unmistakable — and high enough in summer that refraction hardly touches it, which makes it one of the most honest sights in the sky. A body near the zenith is a body whose light has come to you through the least possible air."),
    NavStar(slug: "capella", name: "Capella", constellation: "Auriga",
            magnitude: "0.1", declination: "N 46° 00'", hemisphere: "North",
            howToFind: "North of Orion, high in the winter sky. Follow the line from Rigel through Betelgeuse and keep going.",
            story: "A winter star that never sets for much of northern Europe, which makes it a friend on long nights when the sky is more cloud than star. Its yellow is the same yellow as the Sun, which is no accident: it is two Sun-like giants too close together for any eye to split."),
    NavStar(slug: "rigel", name: "Rigel", constellation: "Orion",
            magnitude: "0.2", declination: "S 08° 12'", hemisphere: "Both",
            howToFind: "The bright blue-white foot of Orion, diagonally opposite Betelgeuse across the belt.",
            story: "Sits almost on the celestial equator, which is a gift: it is visible from very nearly everywhere on Earth and rises and sets close to due east and west. A body on the equator gives a line of position that runs almost north and south — exactly what you want for longitude."),
    NavStar(slug: "procyon", name: "Procyon", constellation: "Canis Minor",
            magnitude: "0.4", declination: "N 05° 11'", hemisphere: "Both",
            howToFind: "East of Orion, forming a wide triangle with Sirius and Betelgeuse.",
            story: "The name means before the dog — it rises ahead of Sirius and announces it. In a crowded winter sky a navigator wants stars that can be told apart at a glance in poor light, and Procyon's place in that triangle makes it one of the few that never gets mistaken."),
]

let navStarsB: [NavStar] = [
    NavStar(slug: "betelgeuse", name: "Betelgeuse", constellation: "Orion",
            magnitude: "0.5", declination: "N 07° 24'", hemisphere: "Both",
            howToFind: "The red shoulder of Orion, up and to the left of the belt.",
            story: "Red enough to name by colour alone, and variable enough that its brightness in the almanac is a rough promise rather than a fact. For the navigator it hardly matters — you are measuring where it is, not how bright. But it is the star that teaches beginners that the sky is not fixed."),
    NavStar(slug: "achernar", name: "Achernar", constellation: "Eridanus",
            magnitude: "0.5", declination: "S 57° 08'", hemisphere: "South",
            howToFind: "At the far southern end of the long winding river of Eridanus, well away from anything else bright.",
            story: "The end of the river. Deep in the southern sky with empty darkness around it, which makes it unmistakable and also makes it lonely — there is nothing near enough to check yourself against. Learn its place among the Magellanic Clouds and you will never lose it."),
    NavStar(slug: "altair", name: "Altair", constellation: "Aquila",
            magnitude: "0.8", declination: "N 08° 55'", hemisphere: "Both",
            howToFind: "The southern corner of the Summer Triangle, flanked closely by a fainter star on either side.",
            story: "The flanking pair are the giveaway — no other bright star in that part of the sky wears two smaller ones so neatly. Altair spins so fast it is visibly flattened, though no sextant will ever tell you so. What matters at sea is that it is bright, low-declination and easy."),
    NavStar(slug: "aldebaran", name: "Aldebaran", constellation: "Taurus",
            magnitude: "0.9", declination: "N 16° 33'", hemisphere: "Both",
            howToFind: "Follow Orion's belt up and to the right. The first bright orange star you meet is Aldebaran.",
            story: "The eye of the bull, glaring back at Orion across the winter sky. It sits in front of the V of the Hyades but is not one of them — a chance alignment, forty light years in front of a cluster a hundred and fifty behind. Navigation cares nothing for this, and yet."),
    NavStar(slug: "antares", name: "Antares", constellation: "Scorpius",
            magnitude: "1.1", declination: "S 26° 28'", hemisphere: "Both",
            howToFind: "The red heart of the Scorpion, low in the southern summer sky, with two fainter stars flanking it in a short row.",
            story: "The rival of Mars, and in a bad year you can be caught out by the resemblance. A planet does not twinkle and a star does; that is the test that has settled the argument on a hundred bridge wings. Take a sight of Mars believing it Antares and your fix will be nowhere near your ship."),
    NavStar(slug: "spica", name: "Spica", constellation: "Virgo",
            magnitude: "1.0", declination: "S 11° 15'", hemisphere: "Both",
            howToFind: "Carry the arc of the Plough's handle past Arcturus and drive a spike to Spica.",
            story: "Blue-white and alone in a quiet stretch of sky, which is exactly what a navigator wants. Arc to Arcturus, spike to Spica — one sweep of the arm from the Plough and you have two of the best stars in the book, roughly at right angles to each other. Two lines that cross cleanly."),
    NavStar(slug: "pollux", name: "Pollux", constellation: "Gemini",
            magnitude: "1.1", declination: "N 28° 00'", hemisphere: "North",
            howToFind: "The brighter of the twin heads, north-east of Orion. Castor stands beside it, whiter and fainter.",
            story: "Two heads side by side, and the almanac lists only one of them. Pollux is the orange one and the brighter, and if you shoot Castor by mistake you will be some miles adrift and never know why. Learn which twin is which before you need to know it in the dark."),
    NavStar(slug: "fomalhaut", name: "Fomalhaut", constellation: "Piscis Austrinus",
            magnitude: "1.2", declination: "S 29° 33'", hemisphere: "Both",
            howToFind: "Low in the autumn sky south of the Square of Pegasus, quite alone.",
            story: "The lonely one of the autumn evening, with nothing bright within a hand's span. That isolation is its virtue and its trap: you cannot mistake it for anything, but neither can you use a neighbour to confirm it. Drop the Square of Pegasus straight down and it is where you land."),
]

let navStarsC: [NavStar] = [
    NavStar(slug: "deneb", name: "Deneb", constellation: "Cygnus",
            magnitude: "1.2", declination: "N 45° 21'", hemisphere: "North",
            howToFind: "The tail of the Swan and the third corner of the Summer Triangle, north-east of Vega.",
            story: "The most distant star anyone regularly shoots — its light left before the first sextant was thought of and will be crossing the same ocean long after the last one is in a museum. None of which changes the working: bring it down, note the time, apply the corrections."),
    NavStar(slug: "regulus", name: "Regulus", constellation: "Leo",
            magnitude: "1.4", declination: "N 11° 52'", hemisphere: "Both",
            howToFind: "At the foot of the backwards question mark that forms the Lion's head and mane.",
            story: "Sits within half a degree of the path the Sun walks, which means the Moon and the planets pass close to it and sometimes hide it altogether. For the navigator that nearness is a warning label: look twice before you swear the bright thing beside Regulus is a star."),
    NavStar(slug: "acrux", name: "Acrux", constellation: "Crux",
            magnitude: "0.8", declination: "S 63° 11'", hemisphere: "South",
            howToFind: "The bottom star of the Southern Cross. Extend the long axis of the Cross four and a half times to find the south celestial pole.",
            story: "The south has no pole star. It has this instead: a small hard cross that points at an empty place in the sky, and a navigator willing to measure four and a half lengths in the dark. Generations of southern seamen learned latitude from a hole in the heavens."),
    NavStar(slug: "dubhe", name: "Dubhe", constellation: "Ursa Major",
            magnitude: "1.8", declination: "N 61° 39'", hemisphere: "North",
            howToFind: "The upper pointer of the Plough's bowl, the one further from the handle.",
            story: "One of the two pointers, and therefore the star that has shown more people the way north than any other. It never sets across most of Europe and North America, which makes it a star you can always find and, in high latitudes on a summer night, sometimes the only one you can."),
    NavStar(slug: "alpheratz", name: "Alpheratz", constellation: "Andromeda",
            magnitude: "2.1", declination: "N 29° 12'", hemisphere: "North",
            howToFind: "The north-east corner of the Great Square of Pegasus, where Andromeda's chain of stars begins.",
            story: "Claimed by two constellations for centuries and finally awarded to Andromeda, though it still does the structural work of holding up the corner of the Square. A star with an argument attached is a star you remember, and remembering is nine tenths of star sights."),
    NavStar(slug: "schedar", name: "Schedar", constellation: "Cassiopeia",
            magnitude: "2.2", declination: "N 56° 39'", hemisphere: "North",
            howToFind: "In the W of Cassiopeia, on the opposite side of Polaris from the Plough.",
            story: "When the Plough is low and lost in haze, Cassiopeia is high — the two swap places around the pole through the year, so between them there is always a signpost. Schedar is the brightest of the W and the one to take when you want a northern line and cannot see the Bear."),
    NavStar(slug: "hamal", name: "Hamal", constellation: "Aries",
            magnitude: "2.0", declination: "N 23° 30'", hemisphere: "North",
            howToFind: "A short bent line of three stars between the Square of Pegasus and the Pleiades.",
            story: "A quiet star in a quiet constellation, and yet the whole coordinate system of the sky is named for the point Aries once held. The point has drifted since — precession moves it a degree every seventy-two years — but the name stayed, as names do."),
    NavStar(slug: "markab", name: "Markab", constellation: "Pegasus",
            magnitude: "2.5", declination: "N 15° 18'", hemisphere: "Both",
            howToFind: "The south-west corner of the Great Square of Pegasus.",
            story: "The Square is the autumn navigator's clock face: four corners, wide apart, easy to identify even through thin cloud. Markab is one of them, and the useful thing about a corner star is that you never have to wonder which star it is."),
]
