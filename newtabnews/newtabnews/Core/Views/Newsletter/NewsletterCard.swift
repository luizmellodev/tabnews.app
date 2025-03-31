import SwiftUI

struct NewsletterCard: View {
    let newsletter: PostRequest
    let isNew: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink {
            NewsletterDetailsView(nw: newsletter)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Title or Date
                    Text(isNew ? (newsletter.title ?? "Sem título") : formatDate(newsletter.createdAt))
                        .font(.headline)
                        .foregroundStyle(isNew ? .blue : .primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // New badge if created today
                    if isNew {
                        Text("NOVO")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(.blue)
                            )
                    }
                }
                
                if isNew {
                    Text("Publicado hoje")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CardColor"))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString,
              let date = ISO8601DateFormatter().date(from: dateString) else {
            return "Data indisponível"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}