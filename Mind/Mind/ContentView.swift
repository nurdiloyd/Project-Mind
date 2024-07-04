//
//  ContentView.swift
//  Project-Mind
//
//  Created by Nurdogan Karaman on 3.07.2024.
//
/*
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
*/

import SwiftUI

extension Comparable
{
    func clamped(to limits: ClosedRange<Self>) -> Self
    {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

struct ContentView: View
{
    @State var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var boxSize: CGFloat = 300
    
    private func getScale(for geometrySize: CGSize, value: CGFloat) -> CGFloat
    {
        let minEdgeLength = min(geometrySize.width, geometrySize.height)
        let minScale: CGFloat = minEdgeLength / BoardView.boardSize
        let maxScale: CGFloat = minEdgeLength / self.boxSize
        let newScale = value.clamped(to: minScale...maxScale)
        return newScale
    }

    var body: some View
    {
        GeometryReader
        { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true)
            {
                ZStack
                {
                    ZStack
                    {
                        BoardView()
                    }
                    .frame(width: BoardView.boardSize, height: BoardView.boardSize)
                    .scaleEffect(self.scale)
                }
                .frame(width: BoardView.boardSize * self.scale, height: BoardView.boardSize * self.scale)
                .background(Color(NSColor.windowBackgroundColor))
                .onAppear
                {
                    let minEdgeLength = min(geometry.size.width, geometry.size.height)
                    //self.scale = minEdgeLength / self.size
                    //self.lastScaleValue = self.scale
                }
                .onChange(of: geometry.size)
                { _, newSize in
                    self.scale = self.getScale(for: newSize, value: self.scale)
                    self.lastScaleValue = self.scale
                }
            }
            .defaultScrollAnchor(.center)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .gesture(
                MagnificationGesture()
                    .onChanged
                    { value in
                        self.scale = self.getScale(for: geometry.size, value: self.lastScaleValue * value)
                    }
                    .onEnded
                    { value in
                        self.lastScaleValue = self.scale
                    }
            )
        }
    }
}

struct HelloWorldView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}

