//
//  FavoriteCitiesViewController.swift
//  Weather app
//
//
//

import UIKit
import CoreData

class FavoriteCitiesViewController: UIViewController {
    
    var citiesWeatherData = [(city: City, weather: String, iconUrl: String)]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var tableView = UITableView()
    var searchController = UISearchController()
    var filteredData = [(city: City, weather: String, iconUrl: String)]()
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupTableView()
        loadWeatherData()
        self.title = "Cities"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCityDidTap))
    }
    
    func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Search Cities"
        navigationItem.searchController = searchController
    }
    
    func setupTableView() {
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeatherCell")
        view.addSubview(tableView)
    }
    
    @objc func addCityDidTap() {
        let vc = SearchCityViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true)
    }
    
    func loadWeatherData() {
        let cities = fetchCities()
        citiesWeatherData = []
        for city in cities {
            if let name = city.name {
                Service.shared.fetchWeather(city: name) { iconUrl, temp in
                    self.citiesWeatherData.append((city: city, weather: "\(temp)", iconUrl: iconUrl))
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func showCityDetail(city: City) {
        var activities = [String]()
        activities = Array(city.activities?.allObjects as? [Activity] ?? []).map({$0.desc ?? ""})
        let cityDetailsVC = CityDetailViewController(activities: activities, city: city.name ?? "")
        cityDetailsVC.delegate = self
        navigationController?.pushViewController(cityDetailsVC, animated: true)
    }
}


extension FavoriteCitiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? filteredData.count : citiesWeatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let data = isSearching ? filteredData[indexPath.row] : citiesWeatherData[indexPath.row]
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = data.city.name
        contentConfig.secondaryText = data.weather
        cell.contentConfiguration = contentConfig
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        let url = URL(string: data.iconUrl)
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                var updatedContentConfig = cell.defaultContentConfiguration()
                updatedContentConfig.text = contentConfig.text
                updatedContentConfig.secondaryText = contentConfig.secondaryText
                updatedContentConfig.image = image
                updatedContentConfig.imageProperties.maximumSize = CGSize(width: 48, height: 48)
                cell.contentConfiguration = updatedContentConfig
            }
        }.resume()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCityDetail(city: citiesWeatherData[indexPath.row].city)
    }
}

extension FavoriteCitiesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
        } else {
            isSearching = true
            filteredData = citiesWeatherData.filter {
                $0.city.name!.lowercased().contains(searchText.lowercased())
            }
            tableView.reloadData()
        }
        
    }
}

// MARK: - CoreData
extension FavoriteCitiesViewController {
    func fetchCities() -> [City] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Could not fetch cities: \(error), \(error.userInfo)")
            return []
        }
    }

}

extension FavoriteCitiesViewController: AddCityDelegate {
    func didAddCity() {
        loadWeatherData()
    }
    
}
