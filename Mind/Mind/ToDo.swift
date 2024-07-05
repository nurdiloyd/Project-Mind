//
//  ToDoListView.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/21/23.
//

import SwiftUI
import SwiftData

struct ToDoListView: View {

    let todos: [ToDo]
    @Environment(\.modelContext) private var context

    private func deleteTodo(indexSet: IndexSet) {
        indexSet.forEach { index in
            let doto = todos[index]
            context.delete(doto)

            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var body: some View {
        List {
            ForEach(todos, id: \.id) { todo in
                NavigationLink(value: todo) {
                    VStack(alignment: .leading) {
                        Text(todo.name)
                            .font(.title3)
                        Text(todo.note)
                            .font(.caption)
                    }
                }
            }.onDelete(perform: deleteTodo)
        }.navigationDestination(for: ToDo.self) { todo in
            ToDoDetailScreen(todo: todo)
        }
    }
}

struct ToDoDetailScreen: View {
    
    @State private var name: String = ""
    @State private var note: String = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let todo: ToDo

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Note description", text: $note)
            
            Button("Update") {
                todo.name = name
                todo.note = note
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
                
                dismiss()
            }
        }.onAppear {
            name = todo.name
            note = todo.note
        }
    }
}

//
//  ToDo.swift
//  Another ToDo App
//
//  Created by Joash Tubaga on 6/20/23.
//

import Foundation
import SwiftData

@Model
final class ToDo: Identifiable {

    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var note: String
//    var isCompleted: Bool = false

//    init(id: String = UUID().uuidString, name: String, isCompleted: Bool = false) {
//        self.id = id
//        self.name = name
//        self.isCompleted = isCompleted
//    }

    init(id: String = UUID().uuidString, name: String, note: String) {
        self.id = id
        self.name = name
        self.note = note
    }

//    static var sampleData: [ToDo] {
//        [
//            ToDo(name: "Create a sample project on swiftdata"),
//            ToDo(name: "Record the initial setup for Chris to use", isCompleted: true)
//        ]
//    }
}
