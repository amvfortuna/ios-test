struct Article: Decodable, Identifiable, Equatable {
    let id: Int
    let title: String
    let subtitle: String
    let content: String
}
