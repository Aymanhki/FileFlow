// FileAssociationsViewModel.swift
import Foundation
import AppKit
import CoreServices
import UniformTypeIdentifiers
import os.log

struct OperationResult {
    let success: Bool
    let message: String
    let details: [String]
}

class FileAssociationsViewModel: ObservableObject {
    private let logger = Logger(subsystem: "com.yourapp.FileFlow", category: "FileAssociations")
    
    func changeDefaultApp(for extensions: [String], to appURL: URL) -> OperationResult {
        guard let bundle = Bundle(url: appURL),
              let bundleIdentifier = bundle.bundleIdentifier else {
            logger.error("Failed to get bundle identifier for app: \(appURL.path)")
            return OperationResult(
                success: false,
                message: "Could not get bundle identifier for the selected application",
                details: []
            )
        }
        
        var successCount = 0
        var failures: [String] = []
        
        for ext in extensions {
            guard let type = UTType(filenameExtension: ext) else {
                logger.error("Failed to create UTType for extension: \(ext)")
                failures.append("Could not create UTType for .\(ext)")
                continue
            }
            
            do {
                try NSWorkspace.shared.setDefaultApplication(at: appURL, toOpen: type)
                
                if let typeIdentifier = type.identifier as String? {
                    // Set both viewer and editor roles
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .viewer, bundleIdentifier as CFString)
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .editor, bundleIdentifier as CFString)
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .all, bundleIdentifier as CFString)
                    successCount += 1
                    logger.info("Successfully set default app for .\(ext)")
                }
            } catch {
                logger.error("Error setting default app for .\(ext): \(error.localizedDescription)")
                failures.append("Error setting default app for .\(ext): \(error.localizedDescription)")
            }
        }
        
        // Refresh Finder and system services
        refreshSystemServices()
        
        let message = failures.isEmpty ?
            "Successfully set default application for all \(successCount) file types" :
            "Completed with \(successCount) successes and \(failures.count) failures"
        
        return OperationResult(success: failures.isEmpty, message: message, details: failures)
    }
    
    private func refreshSystemServices() {
        // Reset Launch Services database
        let task = Process()
        task.launchPath = "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
        task.arguments = ["-kill", "-r", "-domain", "local", "-domain", "system", "-domain", "user"]
        try? task.run()
        
        // Restart Finder
        let task2 = Process()
        task2.launchPath = "/usr/bin/killall"
        task2.arguments = ["Finder"]
        try? task2.run()
        
        // Clear system cache
        try? FileManager.default.removeItem(atPath: "~/Library/Caches/com.apple.finder" as String)
        
        // Reset Launch Services
        let task3 = Process()
        task3.launchPath = "/usr/bin/defaults"
        task3.arguments = ["read", "com.apple.LaunchServices", "LSHandlers"]
        try? task3.run()
    }
}
