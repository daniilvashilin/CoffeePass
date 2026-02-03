import SwiftUI

struct HomeView: View {
    private let container: AppContainer
    @State private var vm: HomeViewModel
    
    init(container: AppContainer) {
        self.container = container
        _vm = State(initialValue: HomeViewModel(
            authService: container.authService,
            firestore: container.firestoreService
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backGround.ignoresSafeArea()
                VStack(spacing: 16) {
                    HomeHeaderView(destination: UserSettingsView(container: container))
                    
                    Text("⭐️ \(vm.points)")
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}


struct HomeHeaderView<Destination: View>: View {
    let destination: Destination
    var body: some View {
        HStack {
            Text("\(timeOfTheDayGreeting())")
                .font(.title)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .textScale(.default)
                .fontWeight(.medium)
            Spacer()
            NavigationLink {
                destination
            } label: {
                ZStack {
                    Circle()
                        .fill(.accent.opacity(0.2))
                        .frame(width: 45, height: 45)
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .tint(.primary)
                }
            }
            
        }
        .padding()
    }
    private func timeOfTheDayGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return TimeOfTheDayGreeting.morning.rawValue
        case 12..<17:
            return TimeOfTheDayGreeting.afternoon.rawValue
        default:
            return TimeOfTheDayGreeting.evening.rawValue
        }
    }
}


enum TimeOfTheDayGreeting: String, CaseIterable {
    case morning = "Good morning"
    case afternoon = "Good afternoon"
    case evening = "Good evening"
}
