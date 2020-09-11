//
//  FileManager+Util.swift
//  BugSnap
//
//  Created by Héctor García Peña on 7/24/19.
//  Copyright © 2019 Héctor García Peña. All rights reserved.
//
import Foundation

/**
    Extension with some utility methods
*/
public extension FileManager {
    
    
    /**
        Gets the filenames within a directory sorted by its creation date.
        - Parameter path: The directory path within the sandbox for the app
        - Parameter ascending: Whether the sorting order should be ascending ( true, default value) or descending
        - Returns: An array with the directory contents (whether is a directory is validated) with the full path for each of the files, or nil if there's an error.
    */
    @objc func sortedFiles( for path : String, ascending : Bool = true ) -> [String]? {
        
        var isDirectory : ObjCBool = ObjCBool(booleanLiteral: false)
        let pointer = UnsafeMutablePointer<ObjCBool>(&isDirectory)
        let dirPath = path as NSString
        
        // Check whether the file exists
        guard fileExists(atPath: path, isDirectory: pointer) else {
            NSLog("The path \(path) doesn't exist")
            return nil
        }
        isDirectory = pointer.pointee
        if !isDirectory.boolValue {
            NSLog("The path \(path) is not a directory")
            return nil
        }
        
        // Get directory contents
        var files : [String]!
        do {
            files = try contentsOfDirectory(atPath: path)
        }
        catch{
            NSLog("Contents of \(path) failed with \(error)")
            return nil
        }
        
        let filesFiltered = files.filter {
            !($0 == "." || $0 == "..")
        }
        
        // Sort by date
        let sortedFiles = filesFiltered.sorted {
            let path1 = dirPath.appendingPathComponent($0)
            let path2 = dirPath.appendingPathComponent($1)
            
            do {
                let attributes1 = try self.attributesOfItem(atPath: path1 )
                let attributes2 = try self.attributesOfItem(atPath: path2 )
                
                guard let date1 = attributes1[.creationDate] as? Date,
                    let date2 = attributes2[.creationDate] as? Date else {
                        return false
                }
                
                let result = date1.compare(date2)
                
                return (ascending && result == .orderedAscending) || (!ascending && result == .orderedDescending)
            }
            catch {
                NSLog("There was an error while getting the attributes of: \n \(path1) \n or \n \(path2)")
                return false
            }
        }
        
        var array = [String]()
        sortedFiles.forEach {
            array.append(dirPath.appendingPathComponent($0))
        }
        return array
    }
    
    /**
        Returns the last n created files from a directory specified as parameter.
        - Parameter numberOfFiles: The maximum number of files to be returned by this method
        - Parameter directory: The directory to look after the required file names
        - Returns: An array with the last *numberOfFiles* or the files in the directory (if numberOfFiles is greater than the number of files contained within the directory). This method returns nil if there's an error while retrieving the directory contents (such as a non existent directory)
    */
    @objc func last( numberOfFiles : UInt , from directory: String ) -> [String]? {
        
        guard let sortedFiles = FileManager.default.sortedFiles(for: directory, ascending : false),
            sortedFiles.count > 0  else {
                return nil
        }
        
        ///  Get the maximum number of files to load
        let maxFiles = min(Int(numberOfFiles),sortedFiles.count)
        
        // Check the range
        guard maxFiles > 0 else {
            return nil
        }
        
        let toAdd = sortedFiles[0...(maxFiles-1)]
        var files = [String]()
        files.append(contentsOf: toAdd.reversed())
        return files
    }
    
    /**
        Builds a filename with the following format : <BundleName>-<timestamp>. The timestamp uses DateFormatter and it has the pattern '<year><month><day>T<hours><mins><secs>'
        This method assembles a file name with the CFBundleName for the App, a timestamp and a file extension (by default log).
        - Parameter fileExtension: The file extension (defaults to "log")
     */
    @objc static func buildAppFileName(fileExtension : String =  "m4a") -> String {
        let appName = "memo"
        //(Bundle.main.infoDictionary?["CFBundleName"] as? String) ??
        let filteredAppName = appName.filter { $0.isLetter || $0.isNumber }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        return "\(filteredAppName)-\(formatter.string(from: Date())).\(fileExtension)"
    }
}
