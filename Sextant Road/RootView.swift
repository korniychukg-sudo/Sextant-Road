import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: SeaStore
    @State private var tab: Int = 0
    @State private var lastTab: Int = 0

    var body: some View {
        ZStack {
            Sea.paper.ignoresSafeArea()
            VStack(spacing: 0) {
                Group {
                    switch tab {
                    case 0: TodayView()
                    case 1: SightTabView()
                    case 2: PassageListView()
                    case 3: AlmanacView()
                    default: LogView()
                    }
                }
                .id(tab)
                .transition(.asymmetric(
                    insertion: .move(edge: tab >= lastTab ? .trailing : .leading)
                        .combined(with: .opacity),
                    removal: .opacity))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()

                tabBar
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { !store.onboarded },
            set: { if !$0 { store.finishOnboarding() } })) {
            OnboardingView { store.finishOnboarding() }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Today", AnyView(WatchGlyph(size: 24, colour: tint(0))))
            tabButton(1, "Sight", AnyView(SextantGlyph(size: 24, colour: tint(1))))
            tabButton(2, "Passages", AnyView(ShipGlyph(size: 24, colour: tint(2))))
            tabButton(3, "Almanac", AnyView(AlmanacGlyph(size: 24, colour: tint(3))))
            tabButton(4, "Log", AnyView(LogbookGlyph(size: 24, colour: tint(4))))
        }
        .padding(.top, 9)
        .padding(.bottom, 3)
        .background(
            Sea.card
                .overlay(Rectangle().fill(Sea.ink.opacity(0.14)).frame(height: 1),
                         alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tint(_ index: Int) -> Color {
        tab == index ? Sea.ink : Sea.ink.opacity(0.34)
    }

    private func tabButton(_ index: Int, _ label: String, _ icon: AnyView) -> some View {
        Button(action: {
            guard tab != index else { return }
            SeaFeel.tap()
            lastTab = tab
            withAnimation(.easeOut(duration: 0.26)) { tab = index }
        }) {
            VStack(spacing: 4) {
                icon
                Text(label.uppercased())
                    .font(SeaFont.title(9))
                    .tracking(0.9)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .foregroundColor(tint(index))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OnboardingView: View {
    let onDone: () -> Void
    @State private var page: Int = 0

    private let pages: [(String, String, String)] = [
        ("The one angle",
         "Celestial navigation rests on a single measurement: the angle between the horizon and a body in the sky. A sextant exists to take that angle from a moving deck.",
         "inst_sextant"),
        ("Bring it down",
         "Drag the glass to bring the body down to the sea. Rock left and right to swing the arc — the true altitude is the lowest reading of the swing. Then turn the drum for the last few minutes.",
         "sky_dusk"),
        ("Work it honestly",
         "The reading is not the truth. Take off the index error, the dip for your height of eye, the refraction of the air, and the half-diameter of a disc. What is left is worth plotting.",
         "diag_dip"),
        ("Step off the intercept",
         "Compare your altitude with the one computed for an assumed position. One minute of difference is one nautical mile. Step it toward the body or away, rule the line square across, and you have a line of position.",
         "diag_intercept"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if page > 0 {
                    Button(action: { withAnimation { page -= 1 } }) {
                        HStack(spacing: 5) {
                            ChevronMark(size: 13, colour: Sea.inkSoft, pointsLeft: true)
                            Text("Back".uppercased())
                                .font(SeaFont.title(11)).tracking(1.6)
                                .foregroundColor(Sea.inkSoft)
                        }
                        .padding(.vertical, 7).padding(.horizontal, 12)
                        .background(Capsule().fill(Sea.cardSunk))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
                Button(action: onDone) {
                    Text("Skip".uppercased())
                        .font(SeaFont.title(11)).tracking(1.6)
                        .foregroundColor(Sea.inkPale)
                        .padding(.vertical, 7).padding(.horizontal, 12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.top, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Plate(name: pages[page].2)
                        .frame(height: SeaMetrics.isPad ? 340 : 230)
                    Text(pages[page].0)
                        .font(SeaFont.title(28))
                        .foregroundColor(Sea.ink)
                    Text(pages[page].1)
                        .font(SeaFont.body(17))
                        .foregroundColor(Sea.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, SeaMetrics.gutter)
                .padding(.top, 14)
                .padding(.bottom, 20)
            }

            HStack(spacing: 7) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Circle()
                        .fill(i == page ? Sea.ink : Sea.ink.opacity(0.20))
                        .frame(width: 7, height: 7)
                }
            }
            .padding(.bottom, 14)

            SeaButton(title: page + 1 >= pages.count ? "Take the first sight" : "Next") {
                if page + 1 >= pages.count { onDone() }
                else { withAnimation { page += 1 } }
            }
            .padding(.horizontal, SeaMetrics.gutter)
            .padding(.bottom, 22)
        }
        .seaPage()
        .centreColumn()
    }
}

struct OpeningScreen: View {
    @State private var glow: Bool = false

    var body: some View {
        ZStack {
            Sea.deep.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                SextantGlyph(size: 110, colour: Sea.brassLight)
                    .opacity(glow ? 1.0 : 0.55)
                Text("SEXTANT ROAD")
                    .font(SeaFont.title(25))
                    .tracking(6)
                    .foregroundColor(Sea.paper)
                Text("Bring a body down to the sea")
                    .font(SeaFont.italic(15))
                    .foregroundColor(Sea.paper.opacity(0.65))
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                glow = true
            }
        }
    }
}
