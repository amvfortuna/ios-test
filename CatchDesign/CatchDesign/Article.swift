struct Article: Decodable, Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let content: String
}
