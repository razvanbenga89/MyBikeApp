//
//  AddBikeView.swift
//  
//
//  Created by Razvan Benga on 30.05.2023.
//

import SwiftUI
import Theme
import Localization
import Storage
import Models
import BikesRepo
import Dependencies
import UserDefaultsConfig

public class BikeBaseModel: ObservableObject {
  var screenTitle: String {
    ""
  }
  var submitButtonTitle: String {
    ""
  }
  
  var bikeTypes: [BikeType] = BikeType.allCases
  var bikeColors: [Theme.BikeColor] = Theme.BikeColor.allCases
  var wheelSizes: [WheelSize] = WheelSize.allCases
  
  var onFinish: () -> Void = unimplemented("onFinish")
  
  @Published var selectedBikeColor: Theme.BikeColor
  @Published var selectedWheelSize: WheelSize! = .big
  @Published var bikeName: String = ""
  @Published var isBikeNameFieldValid: Bool = true
  @Published var formattedServiceDue: String = ""
  @Published var serviceDue: String = "" {
    didSet {
      let newServiceDue = serviceDue.removeDuplicateCharacters(input: ".")
      if let _ = Double(newServiceDue) {
        formattedServiceDue = newServiceDue
        isServiceDueFieldValid = true
      } else {
        isServiceDueFieldValid = false
      }
    }
  }
  @Published var isServiceDueFieldValid: Bool = true
  @Published var isDefaultBike: Bool = true
  @Published var selectedDistanceUnit = UserDefaultsConfig.distanceUnit
  @Published var selectedBikeTypeIndex: Int = 0 {
    didSet {
      selectedBikeType = BikeType.allCases[selectedBikeTypeIndex]
    }
  }
  private (set) var selectedBikeType: BikeType = .mtb
  
  public init() {
    self.selectedBikeColor = Theme.BikeColor.allCases.first ?? .bikeWhite
  }
  
  func didTapSubmit() async {}
  
  func didTapCancel() {
    onFinish()
  }
  
  func validateFields() {
    isBikeNameFieldValid = !bikeName.isEmpty
    isServiceDueFieldValid = !formattedServiceDue.isEmpty
  }
  
  func areFieldsValid() -> Bool {
    isBikeNameFieldValid &&
    isServiceDueFieldValid
  }
}

public class AddBikeModel: BikeBaseModel {
  override var screenTitle: String {
    Localization.addBikeTitle
  }
  override var submitButtonTitle: String {
    Localization.addBikeAction
  }
  
  @Dependency(\.bikesRepo) var bikesRepo
  
  @MainActor
  override func didTapSubmit() async {
    do {
      validateFields()
      
      guard areFieldsValid() else {
        throw "Invalid input fields"
      }
      
      let bikeId = UUID()
      let newBike = Bike(
        id: bikeId,
        type: selectedBikeType,
        name: bikeName,
        color: selectedBikeColor.rawValue,
        wheelSize: selectedWheelSize,
        serviceDue: Double(serviceDue) ?? 0,
        isDefault: isDefaultBike
      )
      
      try await bikesRepo.addNewBike(newBike)
      onFinish()
    } catch {
    }
  }
}

public class EditBikeModel: BikeBaseModel {
  private let bike: Bike
  override var screenTitle: String {
    Localization.editBikeTitle
  }
  override var submitButtonTitle: String {
    Localization.saveAction
  }
  
  @Dependency(\.bikesRepo) var bikesRepo
  
  init(bike: Bike) {
    self.bike = bike
    super.init()
    update()
  }
  
  @MainActor
  override func didTapSubmit() async {
    do {
      validateFields()
      
      guard areFieldsValid() else {
        throw "Invalid input fields"
      }
      
      let newBike = Bike(
        id: bike.id,
        type: selectedBikeType,
        name: bikeName,
        color: selectedBikeColor.rawValue,
        wheelSize: selectedWheelSize,
        serviceDue: Double(serviceDue) ?? 0,
        isDefault: isDefaultBike
      )
      
      try await bikesRepo.updateBike(newBike)
      onFinish()
    } catch {
    }
  }
  
  private func update() {
    self.bikeName = bike.name
    self.isDefaultBike = bike.isDefault
    self.serviceDue = String(format: "%.0f", bike.serviceDue)
    self.selectedBikeTypeIndex = bikeTypes.firstIndex(of: bike.type) ?? 0
    self.selectedBikeColor = Theme.BikeColor(rawValue: bike.color) ?? .bikeWhite
    self.selectedWheelSize = bike.wheelSize
  }
}

public struct AddBikeView: View {
  enum Field: Int, CaseIterable {
    case bikeName
    case bikeService
  }
  
  enum Ids {
    static let colorSelectionViewId = "colorSelectionViewId"
    static let bikeNameViewId = "bikeNameViewId"
    static let bikeServiceViewId = "bikeServiceViewId"
  }
  
  @ObservedObject var model: BikeBaseModel
  @FocusState private var focusedField: Field?
  
  public init(model: BikeBaseModel) {
    self.model = model
  }
  
  public var body: some View {
    NavigationView {
      ScrollViewReader { proxy in
        ScrollView(showsIndicators: false) {
          VStack {
            ColorSelectionView(
              bikeColors: self.model.bikeColors,
              selectedBikeColor: self.$model.selectedBikeColor
            )
            .id(Ids.colorSelectionViewId)
            
            BikeSelectionView(
              bikeTypes: self.model.bikeTypes,
              selectedBikeTypeIndex: self.$model.selectedBikeTypeIndex,
              selectedWheelSize: self.$model.selectedWheelSize,
              selectedBikeColor: self.$model.selectedBikeColor
            )
            
            VStack(spacing: 20) {
              CustomTextField(
                text: self.$model.bikeName,
                isTextValid: self.$model.isBikeNameFieldValid,
                placeholder: Localization.bikeNamePlaceholder,
                errorText: Localization.requiredFieldMessage
              )
              .focused(self.$focusedField, equals: .bikeName)
              .submitLabel(.done)
              .id(Ids.bikeNameViewId)
              
              SelectionView(
                selectedValue: self.$model.selectedWheelSize,
                values: .constant(self.model.wheelSizes),
                isRequired: true,
                placeholder: Localization.wheelSizePlaceholder,
                contentBuilder: { selectedValue, $isSelectionViewShown in
                  Button {
                    isSelectionViewShown = false
                    self.model.selectedWheelSize = selectedValue
                  } label: {
                    Text(selectedValue.description)
                      .foregroundColor(.white)
                  }
                  .frame(width: 100, height: 40)
                },
                onTapGesture: {
                  self.focusedField = nil
                }
              )
              
              CustomTextField(
                text: self.$model.formattedServiceDue,
                isTextValid: self.$model.isServiceDueFieldValid,
                onChangeText: {
                  self.model.serviceDue = $0
                },
                placeholder: Localization.serviceInPlaceholder,
                errorText: Localization.requiredFieldMessage,
                description: self.model.selectedDistanceUnit.description
              )
              .focused(self.$focusedField, equals: .bikeService)
              .keyboardType(.decimalPad)
              .id(Ids.bikeServiceViewId)
              
              Toggle(Localization.defaultBikePlaceholder, isOn: self.$model.isDefaultBike)
                .toggleStyle(SwitchToggleStyle(tint: Theme.AppColor.appLightBlue.value))
                .foregroundColor(.white)
                .font(.textFieldFont)
              
              Button(self.model.submitButtonTitle) {
                Task {
                  await self.model.didTapSubmit()
                }
              }
              .buttonStyle(PrimaryButtonStyle())
            }
          }
          .padding(.horizontal)
          
          Spacer()
        }
        .onChange(of: focusedField) { newValue in
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation {
              if let newValue = newValue {
                switch newValue {
                case .bikeName:
                  proxy.scrollTo(Ids.bikeNameViewId, anchor: .bottom)
                case .bikeService:
                  proxy.scrollTo(Ids.bikeServiceViewId, anchor: .top)
                }
              } else {
                proxy.scrollTo(Ids.colorSelectionViewId, anchor: .top)
              }
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
        
        if focusedField == .bikeService {
          ToolbarItem(placement: .keyboard) {
            Button(Localization.doneAction) {
              focusedField = nil
            }
          }
        }
      }
      .background(
        ZStack(alignment: .top) {
          Color.defaultBackgroundColor
          WaveShape()
            .fill(Theme.AppColor.appDarkBlue.value)
        }
        .ignoresSafeArea()
      )
    }
  }
}

struct AddBikeView_Previews: PreviewProvider {
  static var previews: some View {
    AddBikeView(model: AddBikeModel())
  }
}
