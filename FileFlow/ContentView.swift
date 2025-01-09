import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FileAssociationsViewModel()
    @State private var selectedCategory: Category? = nil
    
    var body: some View {
        NavigationSplitView {
            List(Category.allCases, selection: $selectedCategory) { category in
                NavigationLink(value: category) {
                    Label(category.name, systemImage: category.icon)
                }
            }
            .navigationTitle("Categories")
        } detail: {
            if let category = selectedCategory {
                CategoryDetailView(category: category)
            } else {
                ContentUnavailableView(
                    "Select a Category",
                    systemImage: "square.grid.2x2",
                    description: Text("Choose a category from the sidebar to manage file associations.")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .navigationSplitViewColumnWidth(ideal: 300, max: 400)
        .frame(minWidth: 800, minHeight: 600)
    }
}
