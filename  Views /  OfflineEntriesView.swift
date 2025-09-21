import SwiftUI
import Combine

struct OfflineEntriesView: View {
    @StateObject private var viewModel = OfflineEntriesViewModel()
    @State private var showAlert = false

     var searchText: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Patient Info")) {
                    TextField("Full Name", text: $viewModel.name)
                    TextField("Phone Number", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    TextField("Age", text: $viewModel.age)
                        .keyboardType(.numberPad)
                    Picker("Gender", selection: $viewModel.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Symptoms")) {
                    TextField("Enter symptoms, separated by comma", text: $viewModel.symptoms)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section {
                    Button(action: {
                        viewModel.submitEntry()
                        showAlert = true
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(viewModel.isHealthy ? "Good News 🎉" : "Attention 🚨"),
                            message: Text(viewModel.diagnosisMessage + "\nEntries will be synced automatically when online."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }

                Section(header: Text("History")) {
                    ForEach(viewModel.entries.filter {
                        searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased())
                    }) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Name: \(entry.name)")
                                Spacer()
                                if entry.isSynced {
                                    Label("Synced", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                } else {
                                    Label("Pending", systemImage: "clock.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                }
                            }
                            Text("Phone: \(entry.phone)")
                            Text("Age: \(entry.age)")
                            Text("Gender: \(entry.gender)")
                            Text("Symptoms: \(entry.symptoms)")
                            Text("Result: \(entry.result)")
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { offsets in
                        viewModel.deleteEntry(at: offsets)
                    }
                }

                if viewModel.hasPendingEntries {
                    Section {
                        HStack {
                            Spacer()
                            Button("Sync Now") {
                                viewModel.syncEntries()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Offline Entries")
            .onAppear {
                viewModel.startAutoSync()
            }
        }
    }
}

struct OfflineEntriesView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineEntriesView(searchText: "john")
    }
}

