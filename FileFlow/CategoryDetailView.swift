import SwiftUI
import UniformTypeIdentifiers

struct CategoryDetailView: View {
    let category: Category
    @ObservedObject var viewModel: FileAssociationsViewModel
    // @StateObject private var viewModel = FileAssociationsViewModel()
    @State private var selectedApp: URL? = nil
    @State private var excludedExtensions: Set<String> = []
    @State private var showingAppIcon: NSImage? = nil
    @State private var showingResult: Bool = false
    @State private var operationResult: OperationResult? = nil

    init(category: Category, viewModel: FileAssociationsViewModel) {
        self.category = category
        self.viewModel = viewModel
        let nonDefaultExtensions = Set(category.extensions).subtracting(category.defaultExtensions)
        _excludedExtensions = State(initialValue: nonDefaultExtensions)
    }
    
    

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Selection Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Default Application")
                        .font(.headline)

                    if let app = selectedApp {
                        HStack(spacing: 16) {
                            if let icon = showingAppIcon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 64, height: 64)
                            }

                            VStack(alignment: .leading) {
                                Text(app.lastPathComponent)
                                    .font(.title2)
                                Button("Change Application") {
                                    selectApp()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        Button(action: selectApp) {
                            HStack {
                                Image(systemName: "plus.app")
                                Text("Select Application")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // Extensions Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("File Extensions")
                            .font(.headline)
                        Spacer()
                        HStack(spacing: 8) {
                            Button("Select All") {
                                excludedExtensions.removeAll()
                            }
                            Button("Deselect All") {
                                excludedExtensions = Set(category.extensions)
                            }
                            Button("Select Default") {
                                excludedExtensions = Set(category.extensions).subtracting(category.defaultExtensions)
                            }
                        }
                    }

                    ScrollView(.vertical) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(category.extensions, id: \.self) { ext in
                                Toggle(".\(ext)", isOn: Binding(
                                    get: { !excludedExtensions.contains(ext) },
                                    set: { isIncluded in
                                        if isIncluded {
                                            excludedExtensions.remove(ext)
                                        } else {
                                            excludedExtensions.insert(ext)
                                        }
                                    }
                                ))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

                // Apply Button
                Button("Apply Changes") {
                    applyChanges()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedApp == nil)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .alert("Operation Result", isPresented: $showingResult) {
            Button("OK") { }
        } message: {
            if let result = operationResult {
                Text(result.message)
            }
        }
        .onChange(of: category) { newCategory in
            resetForNewCategory(newCategory)
        }
    }

    private func resetForNewCategory(_ newCategory: Category) {
        selectedApp = nil
        showingAppIcon = nil
        excludedExtensions = Set(newCategory.extensions).subtracting(newCategory.defaultExtensions)
    }

    private func selectApp() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")

        if panel.runModal() == .OK, let url = panel.url {
            selectedApp = url
            showingAppIcon = NSWorkspace.shared.icon(forFile: url.path)
        }
    }

    private func applyChanges() {
        guard let appURL = selectedApp else { return }
        let extensionsToChange = category.extensions.filter { !excludedExtensions.contains($0) }
        let result = viewModel.changeDefaultApp(for: extensionsToChange, to: appURL)
        operationResult = result
        showingResult = true
    }
}
