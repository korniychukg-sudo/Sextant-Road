import Foundation

struct Award: Identifiable {
    let slug: String
    let name: String
    let requirement: String
    let test: (SeaStore) -> Bool
    var id: String { slug }
}

let allAwards: [Award] = awardsA + awardsB + awardsC

let awardsA: [Award] = [
    Award(slug: "first-sight", name: "First Light",
          requirement: "Take and work your first sight",
          test: { $0.totalSights >= 1 }),
    Award(slug: "ten-sights", name: "Ten on the Arc",
          requirement: "Take ten sights",
          test: { $0.totalSights >= 10 }),
    Award(slug: "fifty-sights", name: "Fifty on the Arc",
          requirement: "Take fifty sights",
          test: { $0.totalSights >= 50 }),
    Award(slug: "inside-one", name: "Inside a Mile",
          requirement: "Bring a sight within one minute of arc",
          test: { ($0.bestErrorMinutes ?? 99) <= 1.0 }),
    Award(slug: "inside-half", name: "Half a Minute",
          requirement: "Bring a sight within half a minute of arc",
          test: { ($0.bestErrorMinutes ?? 99) <= 0.5 }),
    Award(slug: "five-clean", name: "A Steady Hand",
          requirement: "Take five three-star sights",
          test: { $0.perfectSights >= 5 }),
]

let awardsB: [Award] = [
    Award(slug: "clean-work", name: "Worked Clean",
          requirement: "Reduce ten sights without a wrong correction",
          test: { $0.cleanReductions >= 10 }),
    Award(slug: "steady-average", name: "The Steady Average",
          requirement: "Hold an average error under two minutes over twenty sights",
          test: { $0.totalSights >= 20 && ($0.averageErrorMinutes ?? 99) < 2.0 }),
    Award(slug: "sun-and-moon", name: "Sun and Moon",
          requirement: "Shoot both the Sun and the Moon",
          test: { $0.bodiesShot().contains("The Sun") && $0.bodiesShot().contains("The Moon") }),
    Award(slug: "ten-bodies", name: "Ten Named Bodies",
          requirement: "Shoot ten different bodies",
          test: { $0.bodiesShot().count >= 10 }),
    Award(slug: "twenty-bodies", name: "The Whole Almanac",
          requirement: "Shoot twenty different bodies",
          test: { $0.bodiesShot().count >= 20 }),
    Award(slug: "first-fix", name: "The First Fix",
          requirement: "Complete a day's fix on a passage",
          test: { $0.totalFixes >= 1 }),
]

let awardsC: [Award] = [
    Award(slug: "first-passage", name: "Landfall",
          requirement: "Finish a passage",
          test: { $0.voyagesFinished >= 1 }),
    Award(slug: "four-passages", name: "Four Oceans",
          requirement: "Finish four passages",
          test: { $0.voyagesFinished >= 4 }),
    Award(slug: "all-passages", name: "Every Road",
          requirement: "Finish all eight passages",
          test: { $0.voyagesFinished >= 8 }),
    Award(slug: "read-all", name: "The Whole Instruction",
          requirement: "Read all twelve lessons",
          test: { $0.readLessons.count >= lessons.count }),
    Award(slug: "star-catalogue", name: "The Star Catalogue",
          requirement: "Open all twenty-four star plates",
          test: { $0.metStars.count >= navStars.count }),
    Award(slug: "quiz-master", name: "Examined",
          requirement: "Score at least fourteen of sixteen on the examination",
          test: { $0.quizBest >= 14 }),
]
