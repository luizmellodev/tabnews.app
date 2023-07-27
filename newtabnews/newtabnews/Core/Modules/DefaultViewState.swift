//
//  DefaultViewState.swift
//  newtabnews
//
//  Created by Luiz Mello on 27/07/23.
//

import Foundation

public enum DefaultViewState {
    case loading
    case started
    case dataChanged
    case requestFailed
    case requestSucceeded
    case noConnection
    case paginatedLoading
    case emptyResult
}
