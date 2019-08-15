//
//  WishlistVC.swift
//  Library
//
//  Created by Ever Uribe on 8/14/19.
//  Copyright © 2019 Ever Uribe. All rights reserved.
//

import UIKit
import RealmSwift

class WishlistVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: VIEWMODEL
    var viewModel: WishlistViewModel = WishlistViewModel()
    
    // MARK: DETAILEDBOOKVIEW PRESENTER
    ///Used to present a DetailedBookView whenever cell is selected.
    var detailedBookViewPresenter: DetailedBookViewPresenter!

    // MARK: SUBVIEWS
    ///Label for title of view controller.
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "Wishlist"
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    
    ///Table view showing wishlist books.
    private let bookTableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    //Background image presented on tableView in custom situations.
    private let backgroundImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.image = UIImage(named: "emptyWishlist")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: OTHER PROPERTIES
    ///Top constraint for titleLabel.
    private var titleLabelTopConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    // MARK: VIEW SETUP
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = backgroundGray
        backgroundImageView.image = viewModel.setBackgroundImage()
        setupViews()
        detailedBookViewPresenter = DetailedBookViewPresenter(bookTableView: bookTableView, searchVC: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reload in case book was added in search tab
        bookTableView.reloadData()
        backgroundImageView.image = viewModel.setBackgroundImage()
    }

    ///Sets up the view and its subviews.
    private func setupViews() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(titleLabel)
        self.view.addSubview(bookTableView)
        
        titleLabel.sizeToFit()
        titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: self.view.frame.width*0.05).isActive = true
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
        titleLabelTopConstraint.isActive = true
        
        bookTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        bookTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        bookTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        bookTableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        
        setupTableView()
    }
    
    ///Sets up bookTableView properties
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
        bookTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0) //to scroll higher than tab bar
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
        let cell: BookListingCell = self.bookTableView.cellForRow(at: indexPath) as! BookListingCell
        tableView.deselectRow(at: indexPath, animated: true)
        detailedBookViewPresenter.openDetailedViewFor(selectedBook: cell.book!, selectedImageView: cell.coverImageView, selectedImageShadow: cell.imageShadow, selectedBookIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            self.viewModel.deleteBookAt(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return [delete]
    }
    
    //Reset image for reused cells
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        backgroundImageView.image = viewModel.setBackgroundImage()
    }
}
