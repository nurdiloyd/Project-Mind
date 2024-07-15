import Foundation

struct FileHelper {
    static func saveImage(data: Data, filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        createDocumentsDirectoryIfNeeded()  // Ensure the directory exists
        do {
            try data.write(to: fileURL)
            print("Image saved \(filename)")
        } catch {
            print("Image is not saved: \(error.localizedDescription)")
        }
    }

    static func loadImage(filename: String?) -> Data? {
        if let name = filename {
            if name.isEmptyOrWithWhiteSpace {
                return nil
            }
            
            let fileURL = getDocumentsDirectory().appendingPathComponent(name)
            do {
                let data = try Data(contentsOf: fileURL)
                print("Image loaded \(name)")
                return data
            } catch {
                print("Image is not loaded: \(error.localizedDescription)")
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
            
            let fileURL = getDocumentsDirectory().appendingPathComponent(name)
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image deleted \(fileURL.path)")
            } catch {
                print("Image is not deleted: \(error.localizedDescription)")
            }
        }
    }

    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private static func createDocumentsDirectoryIfNeeded() {
        let fileManager = FileManager.default
        let documentsDirectory = getDocumentsDirectory()
        if !fileManager.fileExists(atPath: documentsDirectory.path) {
            do {
                try fileManager.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Documents directory created at \(documentsDirectory.path)")
            } catch {
                print("Error creating documents directory: \(error.localizedDescription)")
            }
        }
    }
}
