import SwiftUI
import CoreData

struct BoardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: NodeEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NodeEntity.title, ascending: true)]
    ) private var nodes: FetchedResults<NodeEntity>
    static var boardSize: CGFloat = 10000

    var rootNodes: [NodeEntity] {
        return nodes.filter { $0.parent == nil }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Button(action: {
                        addNode(posX: geometry.size.width / 2, posY: geometry.size.height / 2 - 200)
                    }) {
                        Label("Add Node", systemImage: "plus.circle")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)

                    Button(action: {
                        clearBoard()
                    }) {
                        Label("Clear Board", systemImage: "trash")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                }
                .frame(width: 150)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                ForEach(rootNodes) { rootNode in
                    NodeContainerView(node: rootNode)
                }
            }
            .padding()
        }
    }
    
    private func addNode(posX: CGFloat, posY: CGFloat) {
        withAnimation {
            let newNode = NodeEntity(context: viewContext)
            newNode.id = UUID()
            newNode.title = "New Node"
            newNode.positionX = posX
            newNode.positionY = posY
            newNode.imageName = ""

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func clearBoard() {
        for node in nodes {
            viewContext.delete(node)
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
