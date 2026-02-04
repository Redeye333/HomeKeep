import Foundation

struct PreloadedTaskTemplate: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let frequencyType: FrequencyType
    let frequencyValue: Int
    let notes: String?

    func toMaintenanceTask() -> MaintenanceTask {
        MaintenanceTask(
            name: name,
            icon: icon,
            notes: notes,
            frequencyType: frequencyType,
            frequencyValue: frequencyValue,
            isPreloaded: true
        )
    }
}

struct PreloadedTaskLibrary {
    static let tasks: [PreloadedTaskTemplate] = [
        PreloadedTaskTemplate(
            name: "HVAC Filter Replacement",
            icon: "wind",
            frequencyType: .months,
            frequencyValue: 3,
            notes: "Replace or clean your HVAC air filter. Check monthly if you have pets."
        ),
        PreloadedTaskTemplate(
            name: "Gutter Cleaning",
            icon: "drop.triangle",
            frequencyType: .months,
            frequencyValue: 6,
            notes: "Remove debris from gutters and check downspouts for blockages."
        ),
        PreloadedTaskTemplate(
            name: "Water Heater Flush",
            icon: "flame",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Drain and flush the water heater to remove sediment buildup."
        ),
        PreloadedTaskTemplate(
            name: "Smoke Detector Batteries",
            icon: "sensor",
            frequencyType: .months,
            frequencyValue: 6,
            notes: "Replace batteries and test all smoke and carbon monoxide detectors."
        ),
        PreloadedTaskTemplate(
            name: "Dryer Vent Cleaning",
            icon: "wind",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Clean the dryer vent duct to prevent fire hazards and improve efficiency."
        ),
        PreloadedTaskTemplate(
            name: "Refrigerator Coil Cleaning",
            icon: "refrigerator",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Vacuum the condenser coils on the back or bottom of your refrigerator."
        ),
        PreloadedTaskTemplate(
            name: "Garbage Disposal Cleaning",
            icon: "arrow.3.trianglepath",
            frequencyType: .months,
            frequencyValue: 1,
            notes: "Clean with ice cubes and citrus peels. Check for odors and clogs."
        ),
        PreloadedTaskTemplate(
            name: "Dishwasher Filter Cleaning",
            icon: "dishwasher",
            frequencyType: .months,
            frequencyValue: 1,
            notes: "Remove and rinse the filter. Run a cleaning cycle with vinegar."
        ),
        PreloadedTaskTemplate(
            name: "Washing Machine Clean Cycle",
            icon: "washer",
            frequencyType: .months,
            frequencyValue: 1,
            notes: "Run an empty hot cycle with washing machine cleaner or vinegar."
        ),
        PreloadedTaskTemplate(
            name: "Range Hood Filter",
            icon: "oven",
            frequencyType: .months,
            frequencyValue: 3,
            notes: "Soak the metal filter in hot soapy water or run through dishwasher."
        ),
        PreloadedTaskTemplate(
            name: "Test Garage Auto-Reverse",
            icon: "door.garage.closed",
            frequencyType: .months,
            frequencyValue: 6,
            notes: "Place an object under the door and test the auto-reverse safety feature."
        ),
        PreloadedTaskTemplate(
            name: "Recaulk Bathrooms",
            icon: "drop",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Inspect and replace worn caulk around tubs, showers, and sinks."
        ),
        PreloadedTaskTemplate(
            name: "Check Fire Extinguisher",
            icon: "flame.circle",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Verify pressure gauge is in the green zone. Check for damage or corrosion."
        ),
        PreloadedTaskTemplate(
            name: "Winterize Spigots",
            icon: "snowflake",
            frequencyType: .seasonal,
            frequencyValue: 1,
            notes: "Disconnect hoses, drain outdoor faucets, and install insulated covers before winter."
        ),
        PreloadedTaskTemplate(
            name: "AC Service",
            icon: "air.conditioner.horizontal",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Schedule professional maintenance. Clean outdoor unit, check refrigerant levels."
        ),
        PreloadedTaskTemplate(
            name: "Pest Control",
            icon: "ant",
            frequencyType: .months,
            frequencyValue: 3,
            notes: "Inspect for signs of pests. Apply preventive treatments around the perimeter."
        ),
        PreloadedTaskTemplate(
            name: "Pressure Wash Exterior",
            icon: "house",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Pressure wash siding, driveway, patio, and walkways."
        ),
        PreloadedTaskTemplate(
            name: "Septic Pump",
            icon: "arrow.down.to.line",
            frequencyType: .years,
            frequencyValue: 4,
            notes: "Schedule professional septic tank pumping. Inspect baffles and drain field."
        ),
        PreloadedTaskTemplate(
            name: "Roof Inspection",
            icon: "house.lodge",
            frequencyType: .months,
            frequencyValue: 12,
            notes: "Check for missing or damaged shingles, flashing, and signs of leaks."
        ),
        PreloadedTaskTemplate(
            name: "Deep Clean Carpets",
            icon: "rectangle.split.3x3",
            frequencyType: .months,
            frequencyValue: 6,
            notes: "Steam clean or shampoo carpets. Consider professional cleaning annually."
        ),
    ]
}
