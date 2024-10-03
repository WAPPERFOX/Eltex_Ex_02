import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        enum CargoType {
            case fragile
            case perishable (temperatureRequirement: Int)
            case bulk
        }
        struct Cargo {
            let description: String
            let weight: Int
            let type: CargoType
            init?(description: String, weight: Int, type: CargoType) {
                guard weight >= 0 else { return nil }
                self.description = description
                self.weight = weight
                self.type = type
            }
        }
        class Vehicle {
            let make: String
            let model: String
            let year: Int
            let capacity: Int
            let types: [CargoType]?
            var currentLoad: Int? = 0
            var fuelCapacity: Double
            var fuelConsumption: Double
            init(make: String, model: String, year: Int, capacity: Int, types: [CargoType]? = nil, fuelCapacity: Double, fuelConsumption: Double) {
                self.make = make
                self.model = model
                self.year = year
                self.capacity = capacity
                self.types = types
                self.fuelCapacity = fuelCapacity
                self.fuelConsumption = fuelConsumption
            }
            func loadCargo(cargo: Cargo) {
                guard let currentLoad = currentLoad else { return }
                //if let types = types, types.contains(where: cargo.type) {
                    //print("Этот груз не поддееживается этой машиной.")
                    //return
                //}
                if currentLoad + cargo.weight > capacity {
                    print("Превышена грузоподъёмность!")
                    return
                }
                self.currentLoad = currentLoad + cargo.weight
                print("Груз загружен: \(cargo.description). Текущая загрузка: \(self.currentLoad ?? 0) кг.")
            }
            func unloadCargo() {
                self.currentLoad = 0
                print("Выполнена разгрузка. Текущая загрузка: 0 кг.")
            }
            func canGo(cargo: [Cargo], path: Int) -> Bool {
                let totalWeight = cargo.reduce(0) { $0 + $1.weight }
                guard totalWeight <= capacity else { return false }
                let fuelNeeded = (Double(path) / 100) * fuelConsumption * 2
                return fuelNeeded <= fuelCapacity / 2
                    }
            }
        class Truck: Vehicle {
            var trailerAttached: Bool
            var trailerCapacity: Int?
            var trailerTypes: [CargoType]?
            init(make: String, model: String, year: Int, capacity: Int, trailerAttached: Bool, trailerCapacity: Int? = nil, trailerTypes: [CargoType]? = nil, fuelCapacity: Double, fuelConsumption: Double) {
                self.trailerAttached = trailerAttached
                self.trailerCapacity = trailerCapacity
                self.trailerTypes = trailerTypes
                super.init(make: make, model: model, year: year, capacity: capacity, fuelCapacity: fuelCapacity, fuelConsumption: fuelConsumption)
            }
            override func loadCargo(cargo: Cargo) {
                guard let currentLoad = currentLoad else { return }
                //if let types = types, !types.contains(cargo.type) {
                    //print("Этот груз не поддееживается этой машиной.")
                    //return
                //}
                if currentLoad + cargo.weight > capacity {
                    if trailerAttached, let trailerCapacity = trailerCapacity {
                        let trailerCurrentLoad = (self.currentLoad ?? 0) - capacity
                        if trailerCurrentLoad + cargo.weight > trailerCapacity {
                            print("Превышена грузоподъёмность прицепа!")
                            return
                        } else {
                            self.currentLoad = (self.currentLoad ?? 0) + cargo.weight
                            print("Груз загружен в прицеп: \(cargo.description). Текущая загрузка: \(self.currentLoad ?? 0) кг.")
                        }
                    } else {
                        print("Превышена грузоподъёмность!")
                        return
                    }
                } else {
                    self.currentLoad = currentLoad + cargo.weight
                    print("Груз загружен: \(cargo.description). Текущая загрузка: \(self.currentLoad ?? 0) кг.")
                }
            }
        }
        class Fleet {
            var vehicles: [Vehicle] = []

            func addVehicle(_ vehicle: Vehicle) {
                vehicles.append(vehicle)
            }
            func totalCapacity() -> Int {
                return vehicles.reduce(0) { $0 + $1.capacity }
            }
            func totalCurrentLoad() -> Int {
                return vehicles.compactMap { $0.currentLoad }.reduce(0, +)
            }
            func info() {
                print("Информация по автопарку. Общая грузоподъемность: \(totalCapacity()) кг. Общая загрузка на текущий момент: \(totalCurrentLoad()) кг")
            }
        }

        let fleet = Fleet()
        let fordRaptor = Vehicle(make: "Ford", model: "Raptor", year: 2024, capacity: 455, fuelCapacity: 100.0, fuelConsumption: 20.3)
        let scaniaG500 = Truck(make: "Scania", model: "G500", year: 2024, capacity: 35000, trailerAttached: true, trailerCapacity: 15000, fuelCapacity: 600.0, fuelConsumption: 30.3)
        let ladaLargus = Vehicle(make: "Lada", model: "Largus", year: 2024, capacity: 200, fuelCapacity: 65.0, fuelConsumption: 10.1)
        
        let sand = Cargo(description: "Песок", weight: 35000, type: .bulk)!
        let glass = Cargo(description: "Стекло", weight: 355, type: .fragile)!
        let milk = Cargo(description: "Молоко", weight: 190, type: .perishable(temperatureRequirement: -5))!

        fleet.addVehicle(fordRaptor)
        fleet.addVehicle(scaniaG500)
        fleet.addVehicle(ladaLargus)
        
        fleet.info()

        scaniaG500.loadCargo(cargo: sand)
        fordRaptor.loadCargo(cargo: glass)
        ladaLargus.loadCargo(cargo: milk)
        
        fleet.info()
    }
}
