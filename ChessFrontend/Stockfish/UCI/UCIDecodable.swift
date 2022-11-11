//
//  UCIDecodable.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 10/11/22.
//

import Foundation

protocol UCIDecodable {
    associatedtype Key: UCIKey

    init(_ decoder: any UCIDecoder) throws
}

typealias UCIKey = RawRepresentable & CaseIterable
