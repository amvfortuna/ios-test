struct Article: Decodable, Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let content: String
}
