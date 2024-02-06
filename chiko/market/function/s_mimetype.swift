//
//  s_mimetype.swift
//  market
//
//  Created by Busan Dynamic on 10/24/23.
//

import Foundation

func getFileExtension(from data: Data) -> String {
    
    let bytes: [UInt8] = Array(data.prefix(4))
    let byteTupleMapping: [([UInt8], String)] = [
        ([0x68, 0x65, 0x69, 0x63], ".heic"),
        ([0x68, 0x65, 0x69, 0x66], ".heif"),
        ([0x67, 0x69, 0x66], ".gif"),
        ([0x6a, 0x70, 0x65, 0x67], ".jpeg"),
        ([0x6a, 0x70, 0x67], ".jpg"),
        ([0x70, 0x6e, 0x67], ".png"),
        ([0x74, 0x69, 0x66], ".tif"),
        ([0x74, 0x69, 0x66, 0x66], ".tiff"),
        ([0x77, 0x62, 0x6d, 0x70], ".wbmp"),
        ([0x69, 0x63, 0x6f], ".ico"),
        ([0x6a, 0x6e, 0x67], ".jng"),
        ([0x62, 0x6d, 0x70], ".bmp"),
        ([0x73, 0x76, 0x67], ".svg"),
        ([0x73, 0x76, 0x67, 0x7a], ".svgz"),
        ([0x77, 0x65, 0x62, 0x70], ".webp"),
    ]
    
    return byteTupleMapping.first { bytes.starts(with: $0.0) }?.1 ?? ""
}

internal let default_mime_type = "application/octet-stream"

internal let mimeTypes = [
    "heic": "image/heic",
    "heif": "image/heif",
    "gif": "image/gif",
    "jpeg": "image/jpeg",
    "jpg": "image/jpg",
    "png": "image/png",
    "tif": "image/tiff",
    "tiff": "image/tiff",
    "wbmp": "image/vnd.wap.wbmp",
    "ico": "image/x-icon",
    "jng": "image/x-jng",
    "bmp": "image/x-ms-bmp",
    "svg": "image/svg+xml",
    "svgz": "image/svg+xml",
    "webp": "image/webp",
    "avif": "image/avif",
]

//internal let mimeTypes = [
//    "html": "text/html",
//    "htm": "text/html",
//    "shtml": "text/html",
//    "css": "text/css",
//    "xml": "text/xml",
//    "js": "application/javascript",
//    "atom": "application/atom+xml",
//    "rss": "application/rss+xml",
//    "mml": "text/mathml",
//    "txt": "text/plain",
//    "jad": "text/vnd.sun.j2me.app-descriptor",
//    "wml": "text/vnd.wap.wml",
//    "htc": "text/x-component",
//    "woff": "application/font-woff",
//    "jar": "application/java-archive",
//    "war": "application/java-archive",
//    "ear": "application/java-archive",
//    "json": "application/json",
//    "hqx": "application/mac-binhex40",
//    "doc": "application/msword",
//    "pdf": "application/pdf",
//    "ps": "application/postscript",
//    "eps": "application/postscript",
//    "ai": "application/postscript",
//    "rtf": "application/rtf",
//    "m3u8": "application/vnd.apple.mpegurl",
//    "xls": "application/vnd.ms-excel",
//    "eot": "application/vnd.ms-fontobject",
//    "ppt": "application/vnd.ms-powerpoint",
//    "wmlc": "application/vnd.wap.wmlc",
//    "kml": "application/vnd.google-earth.kml+xml",
//    "kmz": "application/vnd.google-earth.kmz",
//    "7z": "application/x-7z-compressed",
//    "cco": "application/x-cocoa",
//    "jardiff": "application/x-java-archive-diff",
//    "jnlp": "application/x-java-jnlp-file",
//    "run": "application/x-makeself",
//    "pl": "application/x-perl",
//    "pm": "application/x-perl",
//    "prc": "application/x-pilot",
//    "pdb": "application/x-pilot",
//    "rar": "application/x-rar-compressed",
//    "rpm": "application/x-redhat-package-manager",
//    "sea": "application/x-sea",
//    "swf": "application/x-shockwave-flash",
//    "sit": "application/x-stuffit",
//    "tcl": "application/x-tcl",
//    "tk": "application/x-tcl",
//    "der": "application/x-x509-ca-cert",
//    "pem": "application/x-x509-ca-cert",
//    "crt": "application/x-x509-ca-cert",
//    "xpi": "application/x-xpinstall",
//    "xhtml": "application/xhtml+xml",
//    "xspf": "application/xspf+xml",
//    "zip": "application/zip",
//    "epub": "application/epub+zip",
//    "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
//    "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
//    "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
//    "mid": "audio/midi",
//    "midi": "audio/midi",
//    "kar": "audio/midi",
//    "mp3": "audio/mpeg",
//    "ogg": "audio/ogg",
//    "m4a": "audio/x-m4a",
//    "ra": "audio/x-realaudio",
//    "3gpp": "video/3gpp",
//    "3gp": "video/3gpp",
//    "ts": "video/mp2t",
//    "mp4": "video/mp4",
//    "mpeg": "video/mpeg",
//    "mpg": "video/mpeg",
//    "mov": "video/quicktime",
//    "webm": "video/webm",
//    "flv": "video/x-flv",
//    "m4v": "video/x-m4v",
//    "mng": "video/x-mng",
//    "asx": "video/x-ms-asf",
//    "asf": "video/x-ms-asf",
//    "wmv": "video/x-ms-wmv",
//    "avi": "video/x-msvideo"
//]

internal func MimeType(ext: String) -> String {
    return mimeTypes[ext.lowercased()] ?? default_mime_type
}

extension String {
    public func mimeType() -> String {
        return MimeType(ext: (self as NSString).pathExtension)
    }
}
