//
//  AddRideView.swift
//  
//
//  Created by Razvan Benga on 06.06.2023.
//

import SwiftUI
import Dependencies
import Models
import Theme
import Localization
import BikesRepo
import RidesRepo
import UserDefaultsConfig

public class RideBaseModel: ObservableObject {
  var screenTitle: String {
    ""
  }
  var submitButtonTitle: String {
    ""
  }
  
  public var onFinish: () -> Void = unimplemented("onFinish")
  
  @Published var selectedDistanceUnit = UserDefaultsConfig.distanceUnit
  @Published var rideName: String = ""
  @Published var isRideNameFieldValid: Bool = true
  
  @Published var formattedDistance: String = ""
  @Published var distance: String = "" {
    didSet {
      if let _ = Double(distance) {
        formattedDistance = String(distance.prefix(5))
        isDistanceFieldValid = true
      } else {
        isDistanceFieldValid = false
      }
    }
  }
  @Published var isDistanceFieldValid: Bool = true
  
  @Published var duration: String = ""
  @Published var isDurationFieldValid: Bool = true
  @Published var selectedHours: Int = 0 {
    didSet {
      updateDuration()
    }
  }
  @Published var selectedMinutes: Int = 0 {
    didSet {
      updateDuration()
    }
  }
  
  @Published var formattedDate: String = ""
  @Published var selectedDate: Date = Date() {
    didSet {
      formattedDate = DateFormatter.rideDateFormatter.string(from: selectedDate)
    }
  }
  @Published var isDateFieldValid: Bool = true
  
  @Published var selectedBike: Bike? = nil {
    didSet {
      isBikeSelectionFieldValid = selectedBike != nil
    }
  }
  @Published var isBikeSelectionFieldValid: Bool = false
  @Published var bikes: [Bike] = []
  
  @Dependency(\.bikesRepo) var bikesRepo
  @Dependency(\.ridesRepo) var ridesRepo
  
  public init() {}
  
  @MainActor
  func load() async {
    for await bikes in bikesRepo.getBikes() {
      self.bikes = bikes
      self.selectedBike = bikes.first(where: { $0.isDefault })
    }
  }
  
  func didTapSubmit() async {}
  
  func didTapCancel() {
    onFinish()
  }
  
  func validateFields() {
    if selectedHours == 0 && selectedMinutes == 0 {
      isDurationFieldValid = false
    }
    
    isDateFieldValid = !formattedDate.isEmpty
    isRideNameFieldValid = !rideName.isEmpty
    isDistanceFieldValid = !distance.isEmpty
  }
  
  func areFieldsValid() -> Bool {
    isRideNameFieldValid &&
    isDateFieldValid &&
    isDistanceFieldValid &&
    isBikeSelectionFieldValid &&
    isDurationFieldValid
  }
  
  func updateDuration() {
    switch (selectedHours, selectedMinutes) {
    case (0, 0):
      duration = ""
    case (_, 0):
      duration = "\(selectedHours)h"
    case (0, _):
      duration = "\(selectedMinutes)min"
    default:
      duration = "\(selectedHours)h, \(selectedMinutes)min"
    }
  }
}

public class AddRideModel: RideBaseModel {
  override var screenTitle: String {
    "Add Ride"
  }
  
  override var submitButtonTitle: String {
    "Add Ride"
  }
  
  @MainActor
  override func didTapSubmit() async {
    do {
      validateFields()
      
      guard let selectedBike = selectedBike, areFieldsValid() else {
        throw "Invalid input fields"
      }
      
      let rideId = UUID()
      let newRide = Ride(
        id: rideId,
        name: rideName,
        distance: Double(distance) ?? 0,
        duration: (selectedHours * 60) + selectedMinutes,
        date: selectedDate,
        bikeId: selectedBike.id,
        bikeName: selectedBike.name
      )
      
      try await ridesRepo.addNewRide(newRide)
      onFinish()
    } catch {
    }
  }
}

public class EditRideModel: RideBaseModel {
  private let ride: Ride
  
  override var screenTitle: String {
    "Edit Ride"
  }
  
  override var submitButtonTitle: String {
    "Save"
  }
  
  public init(ride: Ride) {
    self.ride = ride
    super.init()
    update()
  }
  
  @MainActor
  override func load() async {
    for await bikes in bikesRepo.getBikes() {
      self.bikes = bikes
      self.selectedBike = bikes.first(where: {
        $0.id == ride.bikeId
      })
    }
  }
  
  private func update() {
    self.rideName = ride.name
    self.selectedDate = ride.date
    self.distance = String(format: "%.1f", ride.distance)
    self.selectedHours = ride.duration / 60
    self.selectedMinutes = ride.duration % 60
    updateDuration()
  }
  
  @MainActor
  override func didTapSubmit() async {
    do {
      validateFields()
      
      guard let selectedBike = selectedBike, areFieldsValid() else {
        throw "Invalid input fields"
      }
      
      let newRide = Ride(
        id: ride.id,
        name: rideName,
        distance: Double(distance) ?? 0,
        duration: (selectedHours * 60) + selectedMinutes,
        date: selectedDate,
        bikeId: selectedBike.id,
        bikeName: selectedBike.name
      )
      
      try await ridesRepo.updateRide(newRide)
      onFinish()
    } catch {
    }
  }
}

public struct AddRideView: View {
  enum Field: Int, CaseIterable {
    case rideName
    case distance
  }
  
  @ObservedObject var model: RideBaseModel
  @FocusState private var focusedField: Field?
  
  public init(model: RideBaseModel) {
    self.model = model
  }
  
  public var body: some View {
    NavigationView {
      VStack {
        VStack(spacing: 20) {
          CustomTextField(
            text: self.$model.rideName,
            isTextValid: self.$model.isRideNameFieldValid,
            placeholder: "Ride Title",
            errorText: "Required Field"
          )
          .focused(self.$focusedField, equals: .rideName)
          .submitLabel(.done)
          
          SelectionView(
            selectedValue: self.$model.selectedBike,
            values: self.$model.bikes,
            isRequired: true,
            placeholder: "Bike",
            isTextValid: self.$model.isBikeSelectionFieldValid,
            errorText: "Required Field",
            contentBuilder: { selectedValue, $isSelectionViewShown in
              Button {
                isSelectionViewShown = false
                self.model.selectedBike = selectedValue
              } label: {
                Text(selectedValue.name)
                  .foregroundColor(.white)
              }
              .frame(width: 100, height: 40)
            }
          )
          
          CustomTextField(
            text: self.$model.formattedDistance,
            isTextValid: self.$model.isDistanceFieldValid,
            onChangeText: {
              self.model.distance = $0
            },
            placeholder: "Distance",
            errorText: "Required Field",
            description: self.model.selectedDistanceUnit.description
          )
          .focused(self.$focusedField, equals: .distance)
          .keyboardType(.decimalPad)
          
          RideDurationPickerView(
            duration: self.$model.duration,
            selectedHours: self.$model.selectedHours,
            selectedMinutes: self.$model.selectedMinutes,
            isFieldValid: self.$model.isDurationFieldValid
          )
          
          RideDatePickerView(
            formattedDate: self.$model.formattedDate,
            selectedDate: self.$model.selectedDate,
            isFieldValid: self.$model.isDateFieldValid
          )

          Button(self.model.submitButtonTitle) {
            Task {
              await self.model.didTapSubmit()
            }
          }
          .buttonStyle(PrimaryButtonStyle())
          .padding(.top)
          
          Spacer()
        }
        .padding()
      }
      .frame(maxHeight: .infinity)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(self.model.screenTitle)
            .font(.navBarTitleFont)
            .foregroundColor(.white)
        }
        ToolbarItem {
          Button(Localization.cancelAction) {
            self.model.didTapCancel()
          }
          .font(.navBarItemFont)
        }
        ToolbarItem(placement: .keyboard) {
          Button("Done") {
            focusedField = nil
          }
        }
      }
      .background(
        Theme.AppColor.appDarkBlue.value
      )
    }
    .task {
      await self.model.load()
    }
  }
}

struct AddRideView_Previews: PreviewProvider {
  static var previews: some View {
    AddRideView(model: AddRideModel())
  }
}
