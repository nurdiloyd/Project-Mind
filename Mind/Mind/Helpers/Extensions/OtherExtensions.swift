import Foundation
import PhotosUI

extension String {
    var isEmptyOrWithWhiteSpace: Bool {
        self.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

extension NSImage {
    func cropToSquare() -> NSImage {
        let originalSize = self.size
        let sideLength = min(originalSize.width, originalSize.height)
        
        let x = (originalSize.width - sideLength) / 2
        let y = (originalSize.height - sideLength) / 2
        let cropRect = NSRect(x: x, y: y, width: sideLength, height: sideLength)
        
        let croppedImage = NSImage(size: cropRect.size)
        croppedImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: cropRect.size), from: cropRect, operation: .copy, fraction: 1.0)
        croppedImage.unlockFocus()
        
        return croppedImage
    }
}

extension NSImage {
    func resize(to dimension: CGFloat) -> NSImage {
        let originalSize = self.size
        
        let resizedImage = NSImage(size: NSSize(width: dimension / 2, height: dimension / 2))
        resizedImage.lockFocus()
        self.draw(in: NSRect(x: 0, y: 0, width: dimension / 2, height: dimension / 2), from: NSRect(origin: .zero, size: originalSize), operation: .copy, fraction: 1.0)
        resizedImage.unlockFocus()
        
        return resizedImage
    }
}

extension NSImage {
    func compressToJPEG(to factor: CGFloat = 0.5)  -> Data? {
        if let tiffData = self.tiffRepresentation,
           let bitmapImageRep = NSBitmapImageRep(data: tiffData) {
            let jpegData = bitmapImageRep.representation(using: .jpeg, properties: [.compressionFactor: factor])
            if let data = jpegData {
                return data
            }
        }
        
        return nil
    }
}

extension CGFloat {
    func sign() -> CGFloat {
        return (self < Self(0) ? -1 : 1)
    }
}

extension Double {
    func sign() -> Double {
        return (self < Self(0) ? -1 : 1)
    }
}
