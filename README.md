# Travel To-Do List App

The Travel To-Do List App helps users organize their travel plans, check the weather for different cities, and add notes about places and activities they want to visit.

## Why This App?

Many people travel or plan to travel, so they need an app to organize their favorite places to visit. This app allows users to:
- Organize their favorite cities to visit.
- Check the weather for each city.
- Add notes about the places in each city they want to go to and the activities they want to do.

## Features

- **Add Favorite Cities:** Search and add cities to your favorite list.
- **Check Weather:** Get real-time weather updates for your favorite cities.
- **Add Activities:** Add and manage activities for each city.

## Code Overview

### Protocols

Defines a delegate method to notify when a city is added.

```swift
protocol AddCityDelegate: AnyObject {
    func didAddCity()
}
```

### View Controllers

#### `CityDetailViewController`
Manages details of a selected city, allowing users to add activities and save them to CoreData.

```swift
final class CityDetailViewController: UIViewController {
    @objc func saveButtonTapped() {
        // Save city and activities
    }

    @objc private func addButtonTapped() {
        // Add new activity to the list
    }
}

extension CityDetailViewController: UITableViewDataSource {
    // Table view data source methods
}
```

#### `FavoriteCitiesViewController`
Manages the list of favorite cities and their weather data.

```swift
class FavoriteCitiesViewController: UIViewController {
    @objc func addCityDidTap() {
        // Present search city view controller
    }

    func loadWeatherData() {
        // Load weather data for all cities
    }
}

extension FavoriteCitiesViewController: AddCityDelegate {
    func didAddCity() {
        // Reload weather data
    }
}
```

#### `SearchCityViewController`
Allows users to search for cities and add them to their favorite list.

```swift
final class SearchCityViewController: UIViewController {
    @objc func getCities() {
        // Fetch city suggestions based on search text
    }
}

extension SearchCityViewController: UISearchResultsUpdating {
    // Search results updating methods
}
```

### Services

Handles fetching weather data from an API.

```swift
class Service {
    static var shared = Service()
    
    func getData(url: String, query: [String:String]?, completion: @escaping (Result<Data, Error>) -> Void ) {
        // Network request logic
    }

    func fetchWeather(city: String, completion: @escaping (String, Double) -> Void) {
        // Fetch weather data for a city
    }
}
```

### Models

Defines the model for weather data.

```swift
struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: Main
}

struct Weather: Decodable {
    let icon: String
}

struct Main: Decodable {
    let temp: Double
}
```

## Learning Objective

The primary goal of this project is to understand how to fetch and use weather data within an iOS application. The `Service` class demonstrates how to make network requests to the OpenWeatherMap API to retrieve weather information, which is then used to display current weather conditions for the user's favorite cities.

## Setup

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd travel-to-do-list-app
   ```

2. **Install Dependencies**
   Ensure you have CocoaPods installed, then run:
   ```bash
   pod install
   ```

3. **Open the Project**
   Open the `.xcworkspace` file in Xcode:
   ```bash
   open TravelToDoListApp.xcworkspace
   ```

4. **Run the App**
   Select a simulator or a connected device and hit the run button in Xcode.

## Dependencies

- **UIKit:** For building the user interface.
- **CoreData:** For persisting favorite cities and activities.
- **OpenWeatherMap API:** For fetching weather data.

## Acknowledgements

- [OpenWeatherMap](https://openweathermap.org/) for the weather API.
- [GeoBytes](http://www.geobytes.com/) for city autocomplete suggestions.

---

This README provides a comprehensive guide to understanding and running the Travel To-Do List App, including a detailed explanation of the code and the learning objective.
