//
//  BasicListViewController.swift
//  AdvancedCompositionalLayout
//
//  Created by Ahmed Tarık Bozyak on 30.04.2023.
//

import Foundation
import UIKit
import Combine

protocol BasicListDelegate: AnyObject {
    func data() -> [AnyHashable]
    func pagination()
    func refresh()
}

class BasicListViewController: UIViewController {
    
    lazy var collectionView = BasicList()
    
    private lazy var viewModel = BasicListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        indicator.frame = CGRect(x: (view.frame.size.width / 2) - 10 , y: view.frame.height - 80, width: 20, height: 20)
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Basic List"
        configureCollectionView()
        configureBindings()
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.edgesToSuperview()
        collectionView.listDelegate = self
    }
    
    private func configureBindings() {
        viewModel.$personList
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] personList in
                self?.collectionView.performUpdates()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    if self.viewModel.personList.isEmpty {
                        self.collectionView.setLoading()
                    }
                    else {
                        self.collectionView.contentInset.bottom = 50
                        self.view.addSubview(self.loadingView)
                    }
                }
                
                else {
                    self.collectionView.refreshControl?.endRefreshing()
                    self.collectionView.clear()
                    self.collectionView.contentInset.bottom = 0
                    self.loadingView.removeFromSuperview()
                }
            }
            .store(in: &cancellables)
        
        viewModel.isSuccessfullyLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSuccess in
                guard let self = self else {return}
                self.viewModel.isLoading = false
                
                if self.viewModel.personList.isEmpty && !isSuccess {
                    let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.tryReload))
                    self.collectionView.setErrorMessage(nil, recognizer: recognizer)
                }

            }
            .store(in: &cancellables)
    }
    
    @objc func tryReload(){
        guard !viewModel.isLoading else {return}
        collectionView.clear()
        viewModel.loadData()
    }
}

extension BasicListViewController: BasicListDelegate {
    func data() -> [AnyHashable] {
        return viewModel.personList
    }
    
    func pagination() {
        guard viewModel.nextData != nil else {return}
        viewModel.loadData()
    }
    
    func refresh() {
        viewModel.loadData()
    }
}
