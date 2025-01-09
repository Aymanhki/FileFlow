import Foundation

enum Category: String, CaseIterable, Identifiable {
    case video
    case audio
    case images
    case code
    case documents
    case archives
    case development
    case design
    
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .video: return "Video"
        case .audio: return "Audio"
        case .images: return "Image"
        case .code: return "Code"
        case .documents: return "Documents"
        case .archives: return "Archives"
        case .development: return "Development"
        case .design: return "Design"
        }
    }
    
    var icon: String {
        switch self {
        case .video: return "play.circle"
        case .audio: return "music.note"
        case .images: return "photo"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .documents: return "doc"
        case .archives: return "archivebox"
        case .development: return "hammer"
        case .design: return "paintbrush"
        }
    }
    
    var extensions: [String] {
        switch self {
        case .video: return [
            "mp4", "mov", "avi", "mkv", "wmv", "flv", "webm", "m4v",
            "mpeg", "mpg", "3gp", "3g2", "mts", "m2ts", "ts", "qt"
        ]
        case .audio: return [
            "mp3", "wav", "aac", "m4a", "flac", "ogg", "wma", "aiff",
            "alac", "mid", "midi", "ape", "opus"
        ]
        case .images: return [
            "jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "svg",
            "raw", "cr2", "nef", "arw", "heic", "ico", "psd"
        ]
        case .code: return [
            "swift", "java", "py", "js", "html", "css", "cpp", "c",
            "h", "hpp", "cs", "php", "rb", "go", "rs", "tsx", "jsx",
            "json", "xml", "yaml", "sql", "sh", "bash", "zsh"
        ]
        case .documents: return [
            "pdf", "doc", "docx", "txt", "rtf", "odt", "pages",
            "md", "tex", "epub", "mobi", "azw", "azw3"
        ]
        case .archives: return [
            "zip", "rar", "7z", "tar", "gz", "bz2", "xz", "iso",
            "dmg", "pkg"
        ]
        case .development: return [
            "xcodeproj", "pbxproj", "gradle", "pom", "sln", "csproj",
            "vcxproj", "workspace", "project", "iml"
        ]
        case .design: return [
            "ai", "eps", "sketch", "fig", "xd", "ae", "prproj",
            "aep", "psb", "indd", "idml"
        ]
        }
    }
    
    var defaultExtensions: [String] {
        switch self {
        case .video: return ["mp4", "mov", "mkv", "avi"]
        case .audio: return ["mp3", "wav", "m4a", "flac"]
        case .images: return ["jpg", "jpeg", "png", "gif"]
        case .code: return ["swift", "java", "py", "js", "html", "css"]
        case .documents: return ["pdf", "doc", "docx", "txt"]
        case .archives: return ["zip", "rar", "7z"]
        case .development: return ["xcodeproj", "workspace", "project"]
        case .design: return ["sketch", "fig", "psd"]
        }
    }
}
