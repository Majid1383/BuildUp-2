//
//  ObjectModel.swift
//  BuildUp
//
//  Created by IIC on 02/09/24.
//
import SwiftUI

enum BoxSize{
    
    case square(CGFloat)
    case rectangle(CGFloat, CGFloat)
    
    var size: CGSize {
        switch self {
        case .square(let side):
            return CGSize(width: side, height: side)
            
        case .rectangle(let width, let height):
            return CGSize(width: width, height: height)
        }
    }
}


