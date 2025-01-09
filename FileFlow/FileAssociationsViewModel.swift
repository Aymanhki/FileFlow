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
    @Published var isProcessing = false

    private let logger = Logger(subsystem: "com.yourapp.FileFlow", category: "FileAssociations")
    
    func changeDefaultApp(for extensions: [String], to appURL: URL) -> OperationResult {
        isProcessing = true
        defer { isProcessing = false }
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
                // Use both methods to ensure the change takes effect
                try NSWorkspace.shared.setDefaultApplication(at: appURL, toOpen: type)
                
                if let typeIdentifier = type.identifier as String? {
                    // Set handler for all roles
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .all, bundleIdentifier as CFString)
                    
                    // Also set specific roles to be thorough
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .viewer, bundleIdentifier as CFString)
                    LSSetDefaultRoleHandlerForContentType(typeIdentifier as CFString, .editor, bundleIdentifier as CFString)
                    
                    successCount += 1
                    logger.info("Successfully set default app for .\(ext)")
                    
                    // Immediately trigger a Launch Services update for this type
                    LSCopyDefaultHandlerForURLScheme(type.identifier as CFString)
                    
                    
                }
            } catch {
                logger.error("Error setting default app for .\(ext): \(error.localizedDescription)")
                failures.append("Error setting default app for .\(ext): \(error.localizedDescription)")
            }
        }
    
        
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("com.apple.LaunchServices.applicationBindingsChanged"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
        
        DistributedNotificationCenter.default().postNotificationName(
            Notification.Name("com.apple.LaunchServices.ApplicationsChanged"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        
        let message = failures.isEmpty ?
            "Successfully set default application for all \(successCount) file types" :
            "Completed with \(successCount) successes and \(failures.count) failures"
        
        return OperationResult(success: failures.isEmpty, message: message, details: failures)
    }
}
