//
//  SearchVC.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit

///Search state consisting of four cases:
///- noSearchEntry: User has yet to input in searchBar.
///- zeroResults: No results found.
///- noInternet: User has no internet so search not available.
///- resultsFound: Search results received and populated.
enum SearchState {
    case noSearchEntry, zeroResults, noInternet, resultsFound, performingSearch
}

class SearchVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: VIEWMODEL
    var viewModel: SearchViewModel = SearchViewModel()
    
    // MARK: DETAILEDBOOKVIEW PRESENTER
    ///Used to present a DetailedBookView whenever cell is selected.
    var detailedBookViewPresenter: DetailedBookViewPresenter!
    
    // MARK: VIEWS
    ///Table view showing wishlist books.
    private let bookTableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    //Background image presented on tableView in different situations.
    private let backgroundImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "startSearch")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let searchBar: SearchBar
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Search Open Library"
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    
    private let searchSettingsButton: UIButton = {
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "settings"), for: .normal)
        button.addTarget(self, action: #selector(toggleSettingsView), for: .touchUpInside)
        return button
    }()
    
    private let bookCoverToggleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Only show books with covers"
        label.font = UIFont.systemFont(ofSize: 18)
        label.alpha = 0 //start at 0 to animate in
        return label
    }()
    
    private let bookCoverToggle: UISwitch = {
        let toggle: UISwitch = UISwitch()
        toggle.onTintColor = .rgb(74, green: 144, blue: 226)
        toggle.alpha = 0 //start at 0 to animate in
        toggle.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        return toggle
    }()
    
    ///Contains titleLabel, searchSettingsButton, bookCoverToggleLabel, and bookCoverToggle
    private let headerView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = backgroundGray
        view.clipsToBounds = true
        return view
    }()
    
    private let searchCancelButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    ///Loading indicator for searches.
    private let loader: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    // MARK: VIEW PROPERTIES
    ///Defines initial headerView margin from top of view.
    private let titleInitialTopMargin: CGFloat = 10
    
    //Defines initial headerView Height
    private let headerInitialHeight: CGFloat = 42 //32+10
    
    //Defines expanded header height
    private let headerExpandedHeight: CGFloat = 106 //32*3+10
    
    ///Height of search bar.
    private let searchBarHeight: CGFloat = 40
    
    ///Top constraint for headerView.
    private var titleTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    ///Height constraint for headerView.
    private var headerBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    ///Top constraint for searchBar.
    private var searchBarTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    ///Width constraint for searchBar.
    private var searchBarWidthConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    ///Used to cancel search when tapping on screen.
    private var tapGesture: UITapGestureRecognizer!
    
    ///Search state consisting of four cases:
    ///- noSearchEntry: User has yet to input in searchBar.
    ///- zeroResults: No results found.
    ///- noInternet: User has no internet so search not available.
    ///- resultsFound: Search results received and populated.
    var searchState: SearchState = .noSearchEntry {
        didSet {
            switch searchState {
                
            case .noSearchEntry:
                loader.stopAnimating()
                backgroundImageView.image = UIImage(named: "startSearch")
                tapGesture.isEnabled = true
                bookTableView.reloadData()
                
            case .zeroResults:
                loader.stopAnimating()
                backgroundImageView.image = UIImage(named: "zeroResults")
                tapGesture.isEnabled = true
                bookTableView.reloadData()
                
            case .noInternet:
                loader.stopAnimating()
                closeSearch()
                backgroundImageView.image = UIImage(named: "noInternet")
                tapGesture.isEnabled = true
                bookTableView.reloadData()
                
            case .resultsFound:
                loader.stopAnimating()
                backgroundImageView.image = nil
                tapGesture.isEnabled = false
                bookTableView.reloadData()

            case .performingSearch:
                backgroundImageView.image = nil
                loader.startAnimating()
                bookTableView.reloadData()
            }
        }
    }
    
    // MARK: - INIT
    init() {
        let placeholderString: NSAttributedString = NSAttributedString(string: "Title, author, keywords", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
        searchBar = SearchBar(placeholderText: placeholderString, height: searchBarHeight)
        super.init(nibName: nil, bundle: nil)
        
        configureSearchBar()
        detailedBookViewPresenter = DetailedBookViewPresenter(bookTableView: bookTableView, searchVC: self)
    }
    
    // MARK: VIEW FUNCTIONS
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = backgroundGray
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reinstantiate search result BookObjects to avoid Realm: 'Object has been deleted or invalidated' error if deleted an objected in Wishlist tab that was added from the bookTableView in existing search. See link for details: https://stackoverflow.com/questions/32308842/realm-can-i-save-a-object-after-delete-the-object
        viewModel.reinstantiateBookObjects(searchState: { (searchState) in
            self.searchState = searchState
        })
    }
    
    ///Add subviews, update properties, and configure auto-constraints.
    private func setupViews() {
        //turn on autolayout
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        searchSettingsButton.translatesAutoresizingMaskIntoConstraints = false
        bookCoverToggleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookCoverToggle.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchCancelButton.translatesAutoresizingMaskIntoConstraints = false
        bookTableView.translatesAutoresizingMaskIntoConstraints = false
        loader.translatesAutoresizingMaskIntoConstraints = false
        
        //add views
        self.view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(searchSettingsButton)
        headerView.addSubview(bookCoverToggleLabel)
        headerView.addSubview(bookCoverToggle)
        
        self.view.addSubview(searchBar)
        self.view.addSubview(searchCancelButton)
        self.view.addSubview(bookTableView)
        self.bookTableView.addSubview(loader)
        
        //x,y,w,h
        let xMargin: CGFloat = self.view.frame.width*0.05
        
        headerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        headerBottomConstraint = headerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: headerInitialHeight)
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        
        headerBottomConstraint.isActive = true
        
        titleLabel.sizeToFit()
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: xMargin).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.searchSettingsButton.leftAnchor).isActive = true
        titleTopConstraint = titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: titleInitialTopMargin)
        titleTopConstraint.isActive = true
        
        searchSettingsButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -xMargin).isActive = true
        searchSettingsButton.topAnchor.constraint(equalTo: titleLabel.topAnchor).isActive = true
        searchSettingsButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        searchSettingsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bookCoverToggleLabel.sizeToFit()
        bookCoverToggleLabel.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: xMargin).isActive = true
        bookCoverToggleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        bookCoverToggleLabel.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        bookCoverToggle.leftAnchor.constraint(equalTo: bookCoverToggleLabel.rightAnchor, constant: xMargin).isActive = true
        bookCoverToggle.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -xMargin).isActive = true
        bookCoverToggle.centerYAnchor.constraint(equalTo: bookCoverToggleLabel.centerYAnchor).isActive = true
        
        searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.9)
        searchBarWidthConstraint.isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: searchBarHeight).isActive = true
        searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: xMargin).isActive = true
        
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20)
        searchBarTopConstraint.isActive = true
        
        searchCancelButton.widthAnchor.constraint(equalToConstant: self.view.frame.width*0.2).isActive = true
        searchCancelButton.heightAnchor.constraint(equalToConstant: searchBarHeight).isActive = true
        searchCancelButton.leftAnchor.constraint(equalTo: searchBar.rightAnchor).isActive = true
        searchCancelButton.topAnchor.constraint(equalTo: searchBar.topAnchor).isActive = true
        
        bookTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bookTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bookTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bookTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20).isActive = true
        
        loader.centerXAnchor.constraint(equalTo: bookTableView.centerXAnchor).isActive = true
        loader.centerYAnchor.constraint(equalTo: bookTableView.topAnchor, constant: 40).isActive = true
        loader.widthAnchor.constraint(equalTo: bookTableView.widthAnchor, multiplier: 0.4).isActive = true
        loader.heightAnchor.constraint(equalTo: bookTableView.widthAnchor).isActive = true
        
        setupTableView()
    }
    
    ///Configures searchBar delegate and any targets.
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    ///Configures bookTableView properties
    private func setupTableView(){
        bookTableView.register(BookListingCell.self, forCellReuseIdentifier: "book")
        bookTableView.delegate = self
        bookTableView.dataSource = self
        bookTableView.tableFooterView = UIView()
        bookTableView.backgroundColor = backgroundGray
        bookTableView.backgroundView = backgroundImageView
        bookTableView.backgroundView?.contentMode = .scaleAspectFit
        bookTableView.keyboardDismissMode = .onDrag
        bookTableView.separatorStyle = .none
        
        bookTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelSearch))
        bookTableView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: USER INPUT ACTIONS
    ///Closes search action and resets search state.
    @objc private func cancelSearch() {
        closeSearch()
        searchState = .noSearchEntry
    }
    
    @objc private func toggleSettingsView() {
        if headerBottomConstraint.constant == headerInitialHeight {
            headerBottomConstraint.constant = headerExpandedHeight
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.headerView.backgroundColor = UIColor.white
                self.bookCoverToggleLabel.alpha = 1
                self.bookCoverToggle.alpha = 1
            })
        } else {
            headerBottomConstraint.constant = headerInitialHeight
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.headerView.backgroundColor = backgroundGray
                self.bookCoverToggleLabel.alpha = 1
                self.bookCoverToggle.alpha = 1
            })
        }
    }
    
    @objc private func switchValueDidChange() {
        viewModel.isBookCoverFilterOn.toggle()
    }
    
    //Closes search action.
    private func closeSearch() {
        viewModel.cancelSearchTask()
        
        if searchBar.text != "" {
            searchBar.text = ""
            searchCancelButton.setTitleColor(.gray, for: .normal)
            searchBar.endEditing(true)
            searchBar.toggleSearch(didBeganEditing: false)
            updateViewsWithSearchToggle()
        }
        else if searchBar.isEditing == true {
            searchBar.endEditing(true)
            searchBar.toggleSearch(didBeganEditing: false)
            updateViewsWithSearchToggle()
        }
    }
    
    ///Updates views whenever search bar is toggled.
    private func updateViewsWithSearchToggle() {
        //If title is at starting location
        if titleTopConstraint.constant == titleInitialTopMargin {
            //If header is expanded, reset header and subview properties
            if headerBottomConstraint.constant == headerExpandedHeight {
                UIView.animate(withDuration: 0.25, animations: {
                    self.headerView.backgroundColor = backgroundGray
                    self.bookCoverToggleLabel.alpha = 0
                    self.bookCoverToggle.alpha = 0
                })
            }
            titleTopConstraint.constant = -headerInitialHeight
            headerBottomConstraint.constant = titleInitialTopMargin
            
            searchBarTopConstraint.constant = 10
            searchBarWidthConstraint.constant = self.view.frame.width*0.7
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.headerView.alpha = 0
                self.searchCancelButton.alpha = 1
            })
        }
        else {
            if searchBar.text!.isEmpty {
                titleTopConstraint.constant = titleInitialTopMargin
                headerBottomConstraint.constant = headerInitialHeight
                searchBarTopConstraint.constant = 20
                searchBarWidthConstraint.constant = self.view.frame.width*0.9
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                    self.headerView.alpha = 1
                    self.searchCancelButton.alpha = 0
                })
            }
        }
    }
    
    // MARK: TEXTFIELD DELEGATE
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchBar.toggleSearch(didBeganEditing: true)
        updateViewsWithSearchToggle()
    }
    
    ///Called whenever the text in the search bar changes.
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.performSearch(searchText: textField.text, searchState: { (searchState) in
            self.searchState = searchState
        })
        
        searchState = .performingSearch
    }
    
    // MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book", for: indexPath) as! BookListingCell
        
        let book: BookObject = viewModel.books[indexPath.row]
        cell.book = book
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.endEditing(true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell: BookListingCell = self.bookTableView.cellForRow(at: indexPath) as! BookListingCell
        
        detailedBookViewPresenter.openDetailedViewFor(selectedBook: viewModel.books[indexPath.row], selectedImageView: cell.coverImageView, selectedImageShadow: cell.imageShadow, selectedBookIndex: indexPath)
    }
    
    // MARK: MISC
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
