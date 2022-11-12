//
//  UCIDecodable.swift
//  ChessFrontend
//
//  Created by Vincent Kwok on 10/11/22.
//

import Foundation

/// A protocol that allows decoding of data within various structures by ``UCIDecoder``s
///
/// `struct`s, `enum`s and `class`es can all conform to this protocol to allow decoding
/// of data from UCI strings for populating properties.
protocol UCIDecodable {
    /// The enum that the UCI data is keyed by
    associatedtype Key: UCIKey

    /// Populates fields from an ``UCIDecoder``
    init(_ decoder: any UCIDecoder) throws
}

/// An enum which UCI values are keyed by, allowing decoding
typealias UCIKey = RawRepresentable & CaseIterable
