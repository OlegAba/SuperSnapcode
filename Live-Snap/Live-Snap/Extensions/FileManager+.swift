//
//  FileManager+.swift
//  Live-Snap
//
//  Created by Oleg Abalonski on 1/13/18.
//  Copyright © 2018 Oleg Abalonski. All rights reserved.
//

import Foundation

extension FileManager {
    
    func clearDocumentsDirectory() {
        guard let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        guard let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) else { return }
        for url in fileURLs {
            try? removeItem(at: url)
        }
    }
}
