import SwiftUI
import SwiftData

struct BoardView: View {
    @Query() private var nodes: [NodeData]
    @Environment(\.modelContext) private var context

    @Environment(\.managedObjectContext) private var viewContext
  /*  @FetchRequest(
        entity: NodeEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NodeEntity.title, ascending: true)]
    ) private var nodes: FetchedResults<NodeEntity>
   */
   static var boardSize: CGFloat = 10000

    var rootNodes: [NodeData] {
        return nodes.filter { $0.parent == nil }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Button(action: {
                        var positionX = geometry.size.width / 2
                        var positionY = geometry.size.height / 2 - 200
                        addNode(positionX: positionX, positionY: positionY)
                    }) {
                        Label("Add Node", systemImage: "plus.circle")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle)

                    Button(action: {
                        //clearBoard()
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
                
                ForEach(nodes, id: \.id) { node in
                    NodeContainerView(node: node)
                }
                
                /*
                ForEach(rootNodes) { rootNode in
                    NodeContainerView(node: rootNode)
                }*/
            }
            .padding()
        }
    }
    
    private func addNode(positionX: CGFloat, positionY: CGFloat) {
        withAnimation {
        }
        let newNode = NodeData(title: "Title", positionX: positionX, positionY: positionY, imageName: "")
        context.insert(newNode)
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
/*
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
 */
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
