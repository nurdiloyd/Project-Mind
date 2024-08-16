import SwiftUI
import Foundation
import AppKit

struct FileHelper {
    #if DEBUG
    private static let environment = "dev"
    #else
    private static let environment = "release"
    #endif
    
    private static let dataPath = "app_data_\(environment)"
    
    static func getSavingDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appPath = path.appendingPathComponent(dataPath)
        createDirectoryIfNeeded(at: appPath)
        
        return appPath
    }
    
    static func getImagesDirectory() -> URL {
        let path = getSavingDirectory().appendingPathComponent("images")
        createDirectoryIfNeeded(at: path)
        
        return path
    }
        
    private static func createDirectoryIfNeeded(at path: URL) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path.path) {
            do {
                try fileManager.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Directory can not be created: \(error.localizedDescription)")
            }
        }
    }

    static func saveImage(data: Data, filename: String) {
        let fileURL = getImagesDirectory().appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
        } catch {
            print("Image can not be saved: \(error.localizedDescription)")
        }
    }

    static func loadImage(filename: String?) -> Data? {
        if let name = filename {
            if name.isEmptyOrWithWhiteSpace {
                return nil
            }
            
            let fileURL = getImagesDirectory().appendingPathComponent(name)
            do {
                let data = try Data(contentsOf: fileURL)
                return data
            } catch {
                print("Image can not be loaded: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }

    static func deleteImage(filename: String?) {
        if let name = filename {
            if name.isEmptyOrWithWhiteSpace {
               return
            }
            
            let fileURL = getImagesDirectory().appendingPathComponent(name)
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Image can not be deleted: \(error.localizedDescription)")
            }
        }
    }
    
    static func exportSavingDirectory() {
          let savePanel = NSSavePanel()
          savePanel.title = "Export Saving Directory"
          savePanel.message = "Choose a location to save your app data"
          savePanel.canCreateDirectories = true
          savePanel.nameFieldStringValue = dataPath

          savePanel.begin { response in
              guard response == .OK, let exportURL = savePanel.url else {
                  print("Export was canceled or failed.")
                  return
              }

              let savingDirectory = getSavingDirectory()

              do {
                  try copyDirectoryContents(from: savingDirectory, to: exportURL)
                  print("Directory exported successfully to \(exportURL.path)")
              } catch {
                  print("Failed to export directory: \(error.localizedDescription)")
              }
          }
      }

      private static func copyDirectoryContents(from sourceURL: URL, to destinationURL: URL) throws {
          let fileManager = FileManager.default
          
          if !fileManager.fileExists(atPath: destinationURL.path) {
              try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
          }

          let items = try fileManager.contentsOfDirectory(atPath: sourceURL.path)

          for item in items {
              let sourceItemURL = sourceURL.appendingPathComponent(item)
              let destinationItemURL = destinationURL.appendingPathComponent(item)

              if fileManager.fileExists(atPath: destinationItemURL.path) {
                  try fileManager.removeItem(at: destinationItemURL)
              }

              try fileManager.copyItem(at: sourceItemURL, to: destinationItemURL)
          }
      }
}
