//
//  CityDetailViewController.swift
//  Weather app

//

import Foundation
import UIKit
import CoreData

final class CityDetailViewController: UIViewController {
    
    var activities: [String]
    let city: String
    
    let tableView = UITableView()
    let stackView = UIStackView()
    let inputTextField = UITextField()
    let addButton = UIButton(type: .system)
    
    weak var delegate: AddCityDelegate?
    
    init(activities: [String], city: String) {
        self.activities = activities
        self.city = city
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.title = city
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped))
        setupStackView()
        setupTableView()
        view.backgroundColor = .white
    }
    
    @objc func saveButtonTapped() {
        guard let cityName = self.title, !cityName.isEmpty else {
            print("No city to save")
            return
        }
        saveCity(withName: cityName, activities: activities)
        delegate?.didAddCity()
//        self.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    func saveCity(withName cityName: String, activities: [String]) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let existingCity = fetchCity(withName: cityName, context: context)
        
        if let city = existingCity {
            // Update existing city
            // Here, you can decide whether to remove all old activities and add new, or just add new
            city.removeFromActivities(city.activities!) // If you want to replace all activities
            for activityDesc in activities {
                let activity = Activity(context: context)
                activity.desc = activityDesc
                city.addToActivities(activity)
            }
        } else {
            // Create a new City object since it doesn't exist
            let newCity = City(context: context)
            newCity.name = cityName
            
            for activityDesc in activities {
                let activity = Activity(context: context)
                activity.desc = activityDesc
                newCity.addToActivities(activity)
            }
        }
        
        // Save to CoreData
        do {
            try context.save()
            print("Saved successfully!")
        } catch {
            print("Failed to save city: \(error)")
        }
    }

    
    func fetchCity(withName name: String, context: NSManagedObjectContext) -> City? {
        let fetchRequest: NSFetchRequest<City> = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error as NSError {
            print("Error fetching city: \(error), \(error.userInfo)")
            return nil
        }
    }

    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(inputTextField)
        stackView.addArrangedSubview(addButton)
        
        inputTextField.placeholder = "Enter activity"
        inputTextField.borderStyle = .roundedRect
        
        addButton.setTitle("Add", for: .normal)
        addButton.configuration = .filled()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc private func addButtonTapped() {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        activities.append(text)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        inputTextField.text = nil  // Clear the text field after adding
    }
    
}

extension CityDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = activities[indexPath.row]
        
        cell.contentConfiguration = contentConfig
        cell.selectionStyle = .none
        return cell
    }
    
    
}
