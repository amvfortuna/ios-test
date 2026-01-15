import SwiftUI

struct ListView: View {
    
    var sample: [Article] = [
        .init(id: 1, title: "Article 1", subtitle: "Subtitle", content: "Lorem ipsum"),
        .init(id: 2, title: "Article 2", subtitle: "Subtitle", content: "Lorem ipsum"),
        .init(id: 3, title: "Article 3", subtitle: "Subtitle", content: "Lorem ipsum"),
        .init(id: 4, title: "Article 4", subtitle: "Subtitle", content: "Lorem ipsum"),
        .init(id: 5, title: "Article 5", subtitle: "Subtitle", content: "Lorem ipsum")
    ]
    
    var body: some View {
        NavigationStack {
            List(sample) { article in
                HStack {
                    Text(article.title)
                    NavigationLink(destination: Text("Detail"), label: { EmptyView() })
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
        }
    }
}

#Preview {
    ListView()
}
