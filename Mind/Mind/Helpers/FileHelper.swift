import Foundation

struct FileHelper {
    #if DEBUG
    private static let environment = "dev"
    #else
    private static let environment = "release"
    #endif
    
    static func getSavingDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let appPath = path.appendingPathComponent("app_data_\(environment)")
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
                print("Directory created at \(path.path)")
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }

    static func saveImage(data: Data, filename: String) {
        let fileURL = getImagesDirectory().appendingPathComponent(filename)
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
            
            let fileURL = getImagesDirectory().appendingPathComponent(name)
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
            
            let fileURL = getImagesDirectory().appendingPathComponent(name)
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Image deleted \(fileURL.path)")
            } catch {
                print("Image is not deleted: \(error.localizedDescription)")
            }
        }
    }
}
