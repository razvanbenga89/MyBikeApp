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

public class SettingsModel: ObservableObject {
  @Published var serviceReminder: String = ""
  @Published var isServiceReminderOn: Bool
  
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
  }
  
  @MainActor
  func load() async {
    for await bikes in bikesRepo.getBikes() {
      self.bikes = bikes
      self.selectedBike = bikes.first(where: { $0.isDefault })
    }
  }
}

public struct SettingsView: View {
  enum Field: Int, CaseIterable {
    case serviceReminder
  }
  
  @ObservedObject var model: SettingsModel
  @FocusState private var focusedField: Field?
  
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
          placeholder: "Distance Units",
          contentBuilder: { selectedValue, $isSelectionViewShown in
            Button {
              isSelectionViewShown = false
              self.model.selectedDistanceUnit = selectedValue
            } label: {
              Text(selectedValue.description)
                .foregroundColor(.white)
            }
            .frame(width: 100, height: 40)
          }
        )
        
        VStack(alignment: .leading) {
          Text("Service Reminder")
            .font(.textFieldPlaceholderFont)
            .foregroundColor(Theme.AppColor.appGrey.value)
          
          HStack(alignment: .center) {
            CustomTextField(
              text: self.$model.serviceReminder,
              isRequired: false,
              description: self.model.selectedDistanceUnit.description
            )
            .keyboardType(.decimalPad)
            .focused(self.$focusedField, equals: .serviceReminder)
            
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
          placeholder: "Default Bike",
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
          Text("Settings")
            .font(.navBarTitleFont)
            .foregroundColor(.white)
        }
        
        ToolbarItem(placement: .keyboard) {
          Button("Done") {
            focusedField = nil
          }
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
