//
//  SearchCityViewController.swift
//  Weather app
//
//
//

import UIKit
import CoreData


final class SearchCityViewController: UIViewController {
    
    weak var delegate: AddCityDelegate?
    
    var cities = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        setupSearchController()
        view.backgroundColor = .white
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }

    @objc func getCities() {
        guard let searchText = searchController.searchBar.text else { return }
        let query = ["callback": "?", "q": searchText]
        
        Service.shared.getData(url: "http://gd.geobytes.com/AutoCompleteCity", query: query) { result in
            switch result {
            case .success(let data):
                if let xdata = String(data: data, encoding: .utf8)?.cleanJson().data(using: .utf8), let result = try? JSONDecoder().decode([String].self, from: xdata) {
                    if result == ["%s"] { return }
                    DispatchQueue.main.async {
                        self.cities = result
                    }
                }
            case .failure(let error):
                print("Error occurred: \(error)")
            }
        }
    }
    
    private func showCityDetail(city: String) {
        var activities = [String]()
        if let cityModel = fetchCity(name: city) {
            activities = Array(cityModel.activities?.allObjects as? [Activity] ?? []).map({$0.desc ?? ""})
        }
        let cityDetailsVC = CityDetailViewController(activities: activities, city: city)
        cityDetailsVC.delegate = self.delegate
        navigationController?.pushViewController(cityDetailsVC, animated: true)
    }
}

// MARK: - Search methods
extension SearchCityViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getCities), object: nil)
        perform(#selector(getCities), with: nil, afterDelay: 0.3)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        self.cities = []
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cities = []
    }
}

// MARK: - Table view
extension SearchCityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCityDetail(city: cities[indexPath.row])
    }
}

extension SearchCityViewController {
    func fetchCity(name: String) -> City? {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            let cities = try context.fetch(fetchRequest)
            return cities.first
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
    }

}

extension String {
    func cleanJson() -> String {
        var cleanedJson = self.replacingOccurrences(of: "?", with: "")
        cleanedJson = cleanedJson.replacingOccurrences(of: "(", with: "")
        cleanedJson = cleanedJson.replacingOccurrences(of: ")", with: "")
        cleanedJson = cleanedJson.replacingOccurrences(of: ";", with: "")
        
        return cleanedJson
    }
}
