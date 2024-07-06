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
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var nodes: [NodeData]

    private var rootNodes: [NodeData] {
        nodes.filter { $0.parent == nil }
    }

    @State private var lastScaleValue: CGFloat = 1.0
    @State private var scale: CGFloat = 1.0
    @State private var boxSize: CGFloat = 300
    @State private var currentSize: CGSize = .zero
    static let boardSize: CGFloat = 10000

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            ZStack {
                ZStack {
                    ForEach(rootNodes, id: \.id) { node in
                        NodeContainerView(node: node)
                    }
                }
                .frame(width: ContentView.boardSize, height: ContentView.boardSize)
                .scaleEffect(self.scale)
            }
            .frame(width: ContentView.boardSize * self.scale, height: ContentView.boardSize * self.scale)
            .background(Color(NSColor.windowBackgroundColor))
        }
        .defaultScrollAnchor(.center)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .toolbar {
            ToolbarItem {
                Button {
                    let positionX = currentSize.width / 2
                    let positionY = currentSize.height / 2 - 200
                    addNode(positionX: positionX, positionY: positionY)
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            ToolbarItem {
                Button {
                    clearBoard()
                } label: {
                    Image(systemName: "trash").foregroundStyle(.red)
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    self.scale = self.getScale(for: currentSize, value: self.lastScaleValue * value)
                }
                .onEnded { value in
                    self.lastScaleValue = self.scale
                }
        )
        .readSize { size in
            currentSize = size
            self.scale = self.getScale(for: currentSize, value: self.scale)
            self.lastScaleValue = self.scale
        }
    }

    private func getScale(for geometrySize: CGSize, value: CGFloat) -> CGFloat {
        let minEdgeLength = min(geometrySize.width, geometrySize.height)
        let minScale: CGFloat = minEdgeLength / ContentView.boardSize
        let maxScale: CGFloat = minEdgeLength / self.boxSize
        let newScale = value.clamped(to: minScale...maxScale)
        return newScale
    }

    private func addNode(positionX: CGFloat, positionY: CGFloat) {
        withAnimation {
            let newNode = NodeData(title: "Title", 
                                   positionX: Double(positionX),
                                   positionY: Double(positionY),
                                   imageName: "")
            
            context.insert(newNode)
            
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func clearBoard() {
        for node in nodes {
            context.delete(node)
        }
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [NodeData.self])
}
