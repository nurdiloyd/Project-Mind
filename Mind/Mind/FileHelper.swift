import Foundation

struct FileHelper {

    static func saveImageToFile(data: Data, filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        createDocumentsDirectoryIfNeeded()  // Ensure the directory exists
        do {
            try data.write(to: fileURL)
            print("Image saved successfully to \(fileURL.path)")
        } catch {
            print("Error saving image to file: \(error.localizedDescription)")
        }
    }

    static func loadImageFromFile(filename: String) -> Data? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            print("Image loaded successfully from \(fileURL.path)")
            return data
        } catch {
            print("Error loading image from file: \(error.localizedDescription)")
            return nil
        }
    }

    static func deleteSavedImage(filename: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("Image deleted successfully from \(fileURL.path)")
        } catch {
            print("Error deleting image from file: \(error.localizedDescription)")
        }
    }

    static func saveData<T: Codable>(data: T, key: String) {
        let userDefaults = UserDefaults.standard
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: key)
            print("Data saved successfully for key \(key)")
        } catch {
            print("Error saving data for key \(key): \(error.localizedDescription)")
        }
    }

    static func loadData<T: Codable>(key: String) -> T? {
        let userDefaults = UserDefaults.standard
        guard let savedData = userDefaults.data(forKey: key) else {
            print("No data found for key \(key)")
            return nil
        }
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: savedData)
            print("Data loaded successfully for key \(key)")
            return decodedData
        } catch {
            print("Error loading data for key \(key): \(error.localizedDescription)")
            return nil
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
