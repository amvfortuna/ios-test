import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                Text(article.title)
            }
        }
        .onAppear() {
            viewModel.loadArticles()
        }
    }
}

#Preview {
    HomeView()
}
