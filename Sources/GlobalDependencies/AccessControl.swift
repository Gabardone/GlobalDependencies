//
//  AccessControl.swift
//
//
//  Created by Óscar Morales Vivó on 11/28/23.
//

import Foundation

/**
 Enumerates Swift access control options as to use as a parameter for a code generating macro.
 */
public enum AccessControl {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
}
