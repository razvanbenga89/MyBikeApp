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
      let newDistance = distance.removeDuplicateCharacters(input: ".")
      if let _ = Double(newDistance) {
        formattedDistance = newDistance
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
  @Published var selectedDate: Date? {
    didSet {
      if let selectedDate = selectedDate {
        formattedDate = DateFormatter.rideDateFormatter.string(from: selectedDate)
      }
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
      self.selectedBike = bikes.first(where: { $0.isDefault }) ?? bikes.first
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
  
  func scheduleNotification(with updatedDistance: Double) {
    guard UserDefaultsConfig.isServiceReminderOn,
          let bike = self.selectedBike else {
      return
    }
    
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(
        withIdentifiers: [bike.id.uuidString]
      )
    
    let ridesTotalDistance = bike.ridesTotalDistanceAfterLatestService + updatedDistance
    
    if ridesTotalDistance >= bike.serviceDue - Double(UserDefaultsConfig.serviceReminderDistance) {
      let content = UNMutableNotificationContent()
      content.title = bike.name
      
      let serviceDue = bike.serviceDue - ridesTotalDistance
      if let formattedServiceDue = NumberFormatter.distanceNumberFormatter.string(from: NSNumber(value: serviceDue)) {
        content.subtitle = serviceDue > 0 ? "\(Localization.notificationServiceIn)\(formattedServiceDue)\(UserDefaultsConfig.distanceUnit.description.lowercased())" : Localization.notificationServiceOverdue
      }
      
      content.sound = UNNotificationSound.default
      content.userInfo = ["bikeColor" : bike.color]
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
      let request = UNNotificationRequest(identifier: bike.id.uuidString, content: content, trigger: trigger)
      
      UNUserNotificationCenter.current().add(request)
    }
  }
}

public class AddRideModel: RideBaseModel {
  override var screenTitle: String {
    Localization.addRideTitle
  }
  
  override var submitButtonTitle: String {
    Localization.addRideAction
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
        date: selectedDate ?? Date(),
        bikeId: selectedBike.id,
        bikeName: selectedBike.name
      )
      
      try await ridesRepo.addNewRide(newRide)
      scheduleNotification(with: newRide.distance)
      onFinish()
    } catch {
    }
  }
}

public class EditRideModel: RideBaseModel {
  private let ride: Ride
  
  override var screenTitle: String {
    Localization.editRideTitle
  }
  
  override var submitButtonTitle: String {
    Localization.saveAction
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
        date: selectedDate ?? Date(),
        bikeId: selectedBike.id,
        bikeName: selectedBike.name
      )
      
      try await ridesRepo.updateRide(newRide)
      scheduleNotification(with: newRide.distance - ride.distance)
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
  private let rideNameTextFieldId = "rideNameTextFieldId"
  
  public init(model: RideBaseModel) {
    self.model = model
  }
  
  public var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          VStack(spacing: 20) {
            CustomTextField(
              text: self.$model.rideName,
              isTextValid: self.$model.isRideNameFieldValid,
              placeholder: Localization.rideTitlePlaceholder,
              errorText: Localization.requiredFieldMessage
            )
            .focused(self.$focusedField, equals: .rideName)
            .submitLabel(.done)
            .id(rideNameTextFieldId)
            
            SelectionView(
              selectedValue: self.$model.selectedBike,
              values: self.$model.bikes,
              isRequired: true,
              placeholder: Localization.bikePlaceholder,
              isTextValid: self.$model.isBikeSelectionFieldValid,
              errorText: Localization.requiredFieldMessage,
              contentBuilder: { selectedValue, $isSelectionViewShown in
                Button {
                  isSelectionViewShown = false
                  self.model.selectedBike = selectedValue
                } label: {
                  Text(selectedValue.name)
                    .foregroundColor(.white)
                }
                .padding()
              },
              onTapGesture: {
                self.focusedField = nil
              }
            )
            
            CustomTextField(
              text: self.$model.formattedDistance,
              isTextValid: self.$model.isDistanceFieldValid,
              onChangeText: {
                self.model.distance = $0
              },
              placeholder: Localization.distancePlaceholder,
              errorText: Localization.requiredFieldMessage,
              description: self.model.selectedDistanceUnit.description
            )
            .focused(self.$focusedField, equals: .distance)
            .keyboardType(.decimalPad)
            
            RideDurationPickerView(
              duration: self.$model.duration,
              selectedHours: self.$model.selectedHours,
              selectedMinutes: self.$model.selectedMinutes,
              isFieldValid: self.$model.isDurationFieldValid,
              onTapGesture: {
                self.focusedField = nil
              }
            )
            
            RideDatePickerView(
              formattedDate: self.$model.formattedDate,
              selectedDate: self.$model.selectedDate,
              isFieldValid: self.$model.isDateFieldValid,
              onTapGesture: {
                self.focusedField = nil
              }
            )
            
            Button(self.model.submitButtonTitle) {
              self.focusedField = nil
              Task {
                await self.model.didTapSubmit()
              }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top)
            
            Spacer()
          }
          .padding(.horizontal)
        }
        .onChange(of: focusedField) { newValue in
          if newValue == nil {
            withAnimation {
              proxy.scrollTo(rideNameTextFieldId, anchor: .top)
            }
          }
        }
      }
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
        if focusedField == .distance {
          ToolbarItem(placement: .keyboard) {
            Button(Localization.doneAction) {
              focusedField = nil
            }
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
