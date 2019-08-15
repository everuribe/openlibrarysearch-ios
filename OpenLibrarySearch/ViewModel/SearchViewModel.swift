//
//  SearchViewModel.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import Foundation

/// Handles search view functions and references data. 
class SearchViewModel {
    
    ///View model array of BookObject
    var books: [BookObject] = []
    
    ///Model array of JSON data transfer objects. 
    var searchResultDTOs: [BookDTO] = []
    
    ///Dispatch work item to handle search. Used to cancel as necessary whenever new input is received at search bar.
    private var searchTask: DispatchWorkItem!
    
    var isBookCoverFilterOn: Bool = false
    
    ///Recreates BookObjects based off of decoded JSON in BookDocumentDTOs. Sends search state in completion handler.
    func reinstantiateBookObjects(searchState: @escaping (SearchState) -> Void) {
        var state: SearchState
        
        if !searchResultDTOs.isEmpty {
            if !self.isBookCoverFilterOn {
                books = JSONDataTransferToObject(bookDTOs: searchResultDTOs)
            } else {
                books = JSONDataTransferToObject(bookDTOs: searchResultDTOs).filter { $0.cover_i != nil }
            }
            
            if self.books.isEmpty {
                state = .noSearchEntry
            }
            else {
                state = .resultsFound
            }
        } else {state = .noSearchEntry}
        
        DispatchQueue.main.async {
            searchState(state)
        }
    }
    
    ///Cancels previous search task, performs new search, and updates models accordingly. Allows completion handler with searchState so that view can update accordingly.
    func performSearch(searchText: String?, searchState: @escaping (SearchState) -> Void) {
        cancelSearchTask()
        
        if let validSearchText: String = searchText {
            if !validSearchText.isEmpty {
                
                searchTask = DispatchWorkItem {
                    let baseUrl: String = "https://openlibrary.org/search.json?q="
                    let searchUrlString: String = baseUrl + validSearchText.replacingOccurrences(of: " ", with: "+")
                    
                    self.downloadJSON(searchUrl: searchUrlString, results: { results in
                        if !self.isBookCoverFilterOn {
                            self.books = self.JSONDataTransferToObject(bookDTOs: results)
                        } else {
                            self.books = self.JSONDataTransferToObject(bookDTOs: results).filter { $0.cover_i != nil }
                        }
                        if self.books.isEmpty {
                            DispatchQueue.main.async {searchState(.zeroResults)}
                        }
                        else {
                            DispatchQueue.main.async {searchState(.resultsFound)}
                        }
                        self.searchResultDTOs = results
                    }, internetStatus: { (internetStatus) in
                        if !internetStatus {
                            DispatchQueue.main.async {searchState(.noInternet)}
                        }
                    })
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300), execute: searchTask)
            } else {
                books = []
                searchResultDTOs = []
                DispatchQueue.main.async {searchState(.noSearchEntry)}
            }
        } else { DispatchQueue.main.async {searchState(.noSearchEntry)}}
    }
    
    ///Performs JSON retrieval. Allows completion handler with internetStatus output so that view can update accordingly.
    func downloadJSON(searchUrl: String, results: @escaping ([BookDTO]) -> Void, internetStatus: @escaping (Bool) -> Void) {
        guard let jsonUrl: URL = URL(string: searchUrl) else {return}
        
        URLSession.shared.dataTask(with: jsonUrl, completionHandler: { (data, urlResponse, error) in
            guard let data = data else {
                internetStatus(urlResponse != nil)
                return
            }
            do {
                let searchObject = try JSONDecoder().decode(SearchObject.self, from: data)
                
                DispatchQueue.main.async {
                    results(searchObject.docs)
                }
            } catch {
                print(error)
            }
        }).resume()
    }
    
    ///Converts JSON DTOs to BookObjects
    func JSONDataTransferToObject(bookDTOs: [BookDTO]) -> [BookObject] {
        var objects: [BookObject] = []
        
        for dto in bookDTOs {
            let object: BookObject = BookObject(bookDTO: dto)
            objects.append(object)
        }
        return objects
    }
    
    ///Cancels searchTask and resets model and viewModel arrays
    func cancelSearchTask() {
        if let search = searchTask {
            search.cancel()
            searchTask = nil
        }
        books = []
        searchResultDTOs = []
    }
    
    // Implement below in the case where settings is toggled while search results are displayed.
    //    func filterSearch(searchState: @escaping (SearchState) -> Void) {
    //        imageFilterOn.toggle()
    //
    //        if imageFilterOn {
    //            if !books.isEmpty {
    //                books = books.filter { $0.cover_i != nil }
    //                searchState(.resultsFound)
    //            } else {
    //                searchState(.noSearchEntry)
    //            }
    //        } else {
    //            if !books.isEmpty {
    //                books = JSONDataTransferToObject(bookDTOs: searchResultDTOs)
    //                searchState(.resultsFound)
    //            } else {
    //                searchState(.noSearchEntry)
    //            }
    //        }
    //    }
}
