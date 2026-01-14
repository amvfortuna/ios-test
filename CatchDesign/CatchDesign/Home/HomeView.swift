import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel(repository: ConcreteHomeRepository())
    @State var displayError: Bool = false
    
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                Text(article.title)
            }
        }
        .onAppear() {
            Task {
                await viewModel.loadArticles($displayError)
            }
        }
    }
}

#Preview {
    HomeView()
}
