//
//  SettingsView.swift
//  
//
//  Created by Razvan Benga on 09.06.2023.
//

import SwiftUI
import Theme
import Models
import BikesRepo
import Storage
import Dependencies
import UserDefaultsConfig
import Popovers
import Localization

public class SettingsModel: ObservableObject {
  @Published var selectedServiceReminder: String
  @Published var isServiceReminderOn: Bool {
    didSet {
      UserDefaultsConfig.isServiceReminderOn = isServiceReminderOn
    }
  }
  
  @Published var selectedBike: Bike? = nil
  @Published var bikes: [Bike] = []
  
  @Published var selectedDistanceUnit: DistanceUnit! {
    didSet {
      UserDefaultsConfig.distanceUnit = selectedDistanceUnit
    }
  }
  @Published var distanceUnits = DistanceUnit.allCases
  
  @Dependency(\.bikesRepo) var bikesRepo
  
  public init() {
    self.selectedDistanceUnit = UserDefaultsConfig.distanceUnit
    self.isServiceReminderOn = UserDefaultsConfig.isServiceReminderOn
    self.selectedServiceReminder = "\(UserDefaultsConfig.serviceReminderDistance)"
  }
  
  @MainActor
  func load() async {
    for await bikes in bikesRepo.getBikes() {
      self.bikes = bikes
      self.selectedBike = bikes.first(where: { $0.isDefault })
    }
  }
  
  func didSelectServiceReminder(_ value: Int) {
    self.selectedServiceReminder = "\(value)"
    UserDefaultsConfig.serviceReminderDistance = value
  }
  
  @MainActor
  func didSelectDefaultBike(_ bike: Bike) async {
    do {
      try await bikesRepo.updateBikeToDefault(bike.id)
      self.selectedBike = bike
    } catch {
      
    }
  }
}

public struct SettingsView: View {
  enum Field: Int, CaseIterable {
    case serviceReminder
  }
  
  @ObservedObject var model: SettingsModel
  @FocusState private var focusedField: Field?
  @State private var isShowingPopover: Bool = false
  
  public init(model: SettingsModel) {
    self.model = model
  }
  
  public var body: some View {
    NavigationView {
      VStack(spacing: 20) {
        SelectionView(
          selectedValue: self.$model.selectedDistanceUnit,
          values: self.$model.distanceUnits,
          isRequired: false,
          placeholder: Localization.distanceUnitsPlaceholder,
          contentBuilder: { selectedValue, $isSelectionViewShown in
            Button {
              isSelectionViewShown = false
              self.model.selectedDistanceUnit = selectedValue
            } label: {
              Text(selectedValue.description)
                .foregroundColor(.white)
            }
            .padding()
          },
          onTapGesture: {}
        )
        
        VStack(alignment: .leading) {
          Text(Localization.serviceReminderPlaceholder)
            .font(.textFieldPlaceholderFont)
            .foregroundColor(Theme.AppColor.appGrey.value)
          
          HStack(alignment: .center) {
            ServiceReminderPickerView(
              selectedServiceReminder: self.$model.selectedServiceReminder,
              description: self.model.selectedDistanceUnit.description,
              didTapSave: {
                self.model.didSelectServiceReminder($0)
              })
            
            Toggle("", isOn: self.$model.isServiceReminderOn)
              .labelsHidden()
              .toggleStyle(
                SwitchToggleStyle(tint: Theme.AppColor.appLightBlue.value)
              )
          }
        }
        
        SelectionView(
          selectedValue: self.$model.selectedBike,
          values: self.$model.bikes,
          isRequired: false,
          placeholder: Localization.defaultBikePlaceholder,
          contentBuilder: { selectedValue, $isSelectionViewShown in
            Button {
              isSelectionViewShown = false
              Task {
                await self.model.didSelectDefaultBike(selectedValue)
              }
            } label: {
              Text(selectedValue.name)
                .foregroundColor(.white)
            }
            .padding()
          },
          onTapGesture: {}
        )
        
        Spacer()
      }
      .padding()
      .frame(maxHeight: .infinity)
      .navigationBarTitleDisplayMode(.inline)
      .background(
        Theme.AppColor.appDarkBlue.value
      )
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(Localization.settingsTitle)
            .font(.navBarTitleFont)
            .foregroundColor(.white)
        }
      }
    }
    .viewDidLoadTask {
      await self.model.load()
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(model: SettingsModel())
  }
}
