//
//  HKPaginationManager.swift
//  HesseKit
//
//  Created by Hesse Huang on 16/11/2018.
//  Copyright © 2018 HesseKit. All rights reserved.
//

#if canImport(Alamofire)
import Alamofire

import UIKit

protocol HKPaginationIndicator {
    /// The amount of this set of data
    var count: Int { get }
    /// The total amount of data
    var total:  Int { get }
}

class HKPaginationManager: NSObject {
    
    private(set) var offset: Int = 0
    private(set) var total:  Int?
    private(set) var isFetching: Bool = false
    
    /// Set the `fetchAction` when view did load, and then call `fetchIfNeeded`.
    ///
    ///     paginationManager.fetchAction = { [weak self] manager in
    ///         return NetworkManager.shared.sendxxxRequest()
    ///             .onError { error in  }
    ///             .onSuccess { json in  }
    ///     }
    ///
    var fetchAction: ((HKPaginationManager) -> Alamofire.DataRequest?)?
    
    /// Indicates whether we can fetch more data now.
    var canFetch: Bool {
        return !isFetching && (total == nil ? true : offset < total!)
    }
    
    /// Reset all the properties. Call this method in the refresh controll block.
    ///
    ///     tableView.refreshControl = HKRefreshControl() { [weak self] refreshControl in
    ///         self?.paginationManager.reset()
    ///         self?.paginationManager.fetchIfNeeded()?.finally {
    ///             refreshControl.endRefreshing()
    ///         }
    ///     }
    ///
    func reset() {
        offset = 0
        total  = nil
        isFetching = false
    }

    /// Commit fetch request.
    func fetchIfNeeded() -> DataRequest? {
        if canFetch {
            isFetching = true
            return fetchAction?(self)?
                .onSuccess { [weak self] json in
                    self?.offset += json.count
                    self?.total = json.total
                }
                .finally { [weak self] in
                    self?.isFetching = false
            }
        }
        return nil
    }
    
    /// Commit fetch request. You should call this method in the scroll view delegate method `scrollViewWillEndDragging(_:)`
    func fetchIfNeeded(by scrollView: UIScrollView, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let exceedsBottomBound = scrollView.bounds.height + targetContentOffset.pointee.y >= floor(scrollView.contentSize.height) && targetContentOffset.pointee.y > scrollView.bounds.height
        if exceedsBottomBound {
            _ = fetchIfNeeded()
        }
    }

}

extension HKPaginationManager {
    fileprivate static var runtimePropertyKey = "HKPaginationManagerRuntimePropertyKey"
}

protocol HKPaginating {
    var paginationManager: HKPaginationManager { get }
}

extension HKPaginating {
    /// You can directly access this property to get the pagination manager to use.
    var paginationManager: HKPaginationManager {
        get {
            if let manager = objc_getAssociatedObject(self, &HKPaginationManager.runtimePropertyKey) as? HKPaginationManager {
                return manager
            } else {
                let manager = HKPaginationManager()
                objc_setAssociatedObject(self, &HKPaginationManager.runtimePropertyKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return manager
            }
        }
    }
}

extension UIViewController: HKPaginating { }

#if canImport(MJRefresh)

// MARK: Supporting Auto Load More Data
protocol RefreshHeaderManaging: class {
    var refreshHeaderEmbeddedScrollView: UIScrollView? { get }
    func startRefreshingData()
}

extension RefreshHeaderManaging where Self: UIViewController {
    
    func startRefreshingData() {
        refreshHeaderEmbeddedScrollView?.mj_header?.beginRefreshing()
    }
    
    func setupRefreshHeader(with action: @escaping () -> DataRequest?) {
        setupRefreshHeader(with: { _ in action() })
    }
    
    /// Add a refresh header (MJRefresh) onto the table view with the given action. In the action, you should: a) update your models, b) handle HUDs. You should not: modify the state of the refresh header.
    ///
    /// - Parameter action: The refresh control action.
    func setupRefreshHeader(with action: @escaping (_ offset: Int) -> DataRequest?) {
        guard let scrollView = refreshHeaderEmbeddedScrollView else { return }
        paginationManager.fetchAction = {
            return action($0.offset)
        }
        scrollView.mj_header = HKRefreshHeader { [weak self] in
            self?.paginationManager.reset()
            self?.paginationManager.fetchIfNeeded()?.finally { [weak scrollView] in
                scrollView?.mj_header?.endRefreshing()
            }
        }
        scrollView.mj_header?.beginRefreshing()
    }
    
    /// Indicating whether you should remove all fetched models.
    var shouldRemoveAllModels: Bool {
        return refreshHeaderEmbeddedScrollView?.mj_header?.isRefreshing ?? false
    }
    
}

extension UITableViewController: RefreshHeaderManaging {
    var refreshHeaderEmbeddedScrollView: UIScrollView? {
        return tableView
    }
}

extension UICollectionViewController: RefreshHeaderManaging {
    var refreshHeaderEmbeddedScrollView: UIScrollView? {
        return collectionView
    }
}


#endif


#if canImport(SwiftyJSON)
import SwiftyJSON

extension JSON: HKPaginationIndicator {
    var count: Int {
        return self["data"].arrayObject?.count ?? 0
    }
    var total: Int {
        return self["total"].intValue
    }
    var offset: Int {
        return self["offset"].intValue
    }
}

//extension RefreshHeaderManaging where Self: UIViewController {
//    func paginate<T: JSONWrapperModel>(into models: inout [T], by json: JSON) {
//        if shouldRemoveAllModels || json.offset == 0 {
//            models = json["data"].array(of: T.self)
//        } else {
//            models += json["data"].array(of: T.self)
//        }
//    }
//    
//}
#endif
#endif
