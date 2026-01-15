import SwiftUI
import PullToRefreshSwiftUI

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel(repository: ConcreteHomeRepository(networkClient: ConcreteNetworkClient(urlSession: URLSession.shared)))
    @State var displayError: Bool = false
    @State var isRefreshing: Bool = false
    @State private var rotationDegrees: CGFloat = 0.0
    
    var body: some View {
        if viewModel.articles.isEmpty {
            emptyState
        } else {
            listView
        }
    }
    
    @ViewBuilder
    var emptyState: some View {
        ZStack {
            Color.primaryBackgroundColor
                .ignoresSafeArea()
            PullToRefreshScrollView(
                pullToRefreshAnimationHeight: 120,
                isRefreshing: $isRefreshing) {
                    Task {
                        await viewModel.loadArticles($displayError)
                        isRefreshing.toggle()
                    }
                } animationViewBuilder: { state in
                    LoadingView(circularBackgroundColor: .primaryBackgroundColor, overlayColor: .secondaryBackgroundColor)
                        .frame(minHeight: 120)
                } contentViewBuilder: { scrollViewSize in
                    ZStack(alignment: .center) {
                        Image("CatchDesignLogo")
                    }
                    .frame(width: scrollViewSize.width, height: scrollViewSize.height)
                    .background(Color.primaryBackgroundColor)
                }
        }
        .alert("An error occurred while fetching content.", isPresented: $displayError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text("Please try again later.")
        })
    }
    
    @ViewBuilder
    var listView: some View {
        NavigationStack {
            PullToRefreshScrollView(
                pullToRefreshAnimationHeight: 120,
                isRefreshing: $isRefreshing) {
                    Task {
                        await viewModel.loadArticles($displayError)
                        isRefreshing.toggle()
                    }
                } animationViewBuilder: { state in
                    LoadingView(circularBackgroundColor: .primaryBackgroundColor, overlayColor: .secondaryBackgroundColor)
                        .frame(minHeight: 120)
                } contentViewBuilder: { scrollViewSize in
                    List(viewModel.articles) { article in
                        HStack {
                            Text(article.title)
                            NavigationLink(value: article, label: { EmptyView() })
                                .opacity(0)
                            Spacer()
                            Text(article.subtitle)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.primary)
                                .padding(.leading, 5)
                        }
                        .frame(height: 44)
                    }
                    .listStyle(.plain)
                    .frame(width: scrollViewSize.width, height: scrollViewSize.height)
                    .navigationDestination(for: Article.self) { article in
                        viewModel.navigateToDetailsView(article: article)
                    }
                }
        }
    }
}

#Preview {
    HomeView()
}
