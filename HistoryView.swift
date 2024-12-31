import SwiftUI

struct HistoryView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedUnit = "kg"
    @State private var selectedImage: UIImage? = nil
    @State private var showingFullscreenImage: Bool = false
    
    @State private var selectedEntry: WeightEntry?
    @State private var isEditing = false
    
    init(selectedUnit: String) {
        _selectedUnit = State(initialValue: selectedUnit)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Stored Records")
                    .font(.headline)
                HeaderRow(selectedUnit: selectedUnit)
                List {
                    Section(){
                        ForEach(dataManager.entries.sorted(by: { $0.date > $1.date }), id: \.id) { entry in
                            HistoryRow(entry: entry, selectedUnit: selectedUnit, selectedImage: $selectedImage, showingFullscreenImage: $showingFullscreenImage, isEditing: $isEditing, selectedEntry: $selectedEntry)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
                .listStyle(.plain)
            }
            .sheet(isPresented: $showingFullscreenImage) {
                if let image = selectedImage {
                    FullscreenImageView(image: image)
                        .presentationDetents([.large])
                }
            }
            .sheet(isPresented: Binding(
                get: { isEditing && selectedEntry != nil},
                set: { newValue in
                    if !newValue {
                        selectedEntry = nil
                    }
                    isEditing = newValue
                })) {
                    if let selectedEntry {
                        EditEntryView(entry: selectedEntry, selectedUnit: selectedUnit, onUpdate: { updatedEntry in
                            if let index = dataManager.entries.firstIndex(where: {$0.id == selectedEntry.id} )
                            {
                                dataManager.entries[index] = updatedEntry
                            }
                            isEditing = false
                        })
                    }
                    
                }
            .task(id: showingFullscreenImage) {
                if showingFullscreenImage, let entry = dataManager.entries.first(where: {$0.imageData != nil && $0.imageData == selectedImage?.jpegData(compressionQuality: 1.0)} ), let image = entry.getImage() {
                    selectedImage = image
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let idsToDelete = offsets.map { dataManager.entries[$0].id }
            dataManager.entries.removeAll { idsToDelete.contains($0.id) }
        }
    }
    
    
     private func displayWeight(entry: WeightEntry, unit:String) -> String {
        let weightForDisplay: Double
           if unit == "kg" {
             weightForDisplay = entry.weight
         } else if unit == "lbs"{
               weightForDisplay = kgToLbs(kg: entry.weight)
         } else {
             weightForDisplay = kgToStone(kg:entry.weight)
        }
          return String ( format:"%.1f", weightForDisplay)
     }
    private func kgToLbs(kg: Double) -> Double {
        return kg * 2.20462
    }
    
    private func kgToStone(kg:Double) -> Double {
        return kg / 6.35029
    }
}

struct HistoryRow: View {
    var entry: WeightEntry
    var selectedUnit: String
    @Binding var selectedImage: UIImage?
    @Binding var showingFullscreenImage: Bool
    @Binding var isEditing: Bool
    @Binding var selectedEntry: WeightEntry?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(entry.date, formatter: itemDateFormatter)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("\(entry.date, formatter: itemTimeFormatter)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
             Text("\(displayWeight(entry: entry, unit: selectedUnit))")
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("\(entry.muscleMass.formatted(.number.precision(.fractionLength(1))))")
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("\(entry.bodyFat.formatted(.number.precision(.fractionLength(1))))")
                .frame(maxWidth: .infinity, alignment: .center)
            Text("\(entry.visceralFat.formatted(.number.precision(.fractionLength(0))))")
                .frame(maxWidth: .infinity, alignment: .center)
            if let image = entry.getImage() {
                Button {
                    selectedImage = image
                    showingFullscreenImage = true
                } label: {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 30, maxHeight: 30, alignment: .center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .buttonStyle(PlainButtonStyle())
            } else {
                Text("-")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
         .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button("Edit") {
                isEditing = true
                selectedEntry = entry
            }
            .tint(.blue)
        }
    }
    
      private func displayWeight(entry: WeightEntry, unit:String) -> String {
        let weightForDisplay: Double
           if unit == "kg" {
             weightForDisplay = entry.weight
         } else if unit == "lbs"{
               weightForDisplay = kgToLbs(kg: entry.weight)
         } else {
             weightForDisplay = kgToStone(kg:entry.weight)
        }
          return String ( format:"%.1f", weightForDisplay)
     }
    private func kgToLbs(kg: Double) -> Double {
        return kg * 2.20462
    }
    
    private func kgToStone(kg:Double) -> Double {
        return kg / 6.35029
    }
}


struct HeaderRow: View {
    
    var selectedUnit:String
    var body: some View {
        HStack{
            Text("Date")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Weight \n (\(selectedUnit))")
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Muscle %")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Body Fat %")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Visc. Fat")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Pic")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical,5)
    }
}


private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy HH:mm"
    return formatter
}()
private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy"
    return formatter
}()

private let itemTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()
