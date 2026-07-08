//
//  UiCustomization.swift
//  EPG-Demo
//
//  Created by eand ePayment on 05/10/24.


import Foundation
import UIKit
// Enum for button types
public enum ButtonType {
    case submit, continueButton, next, cancel, resend
}

// Error type for invalid input
enum InvalidInputError: Error {
    case invalidInput(String)
}

// Customization data classes
public struct ButtonCustomization {
    var backgroundColor: String
    var textColor: String
    var fontSize: Int
    var title : String
    var color :UIColor
    var fontStyle: UIFont
    
    init(backgroundColor: String, textColor: String, fontSize: Int, title : String, color :UIColor, fontStyle : UIFont) throws {
        guard !backgroundColor.isEmpty, !textColor.isEmpty, fontSize > 0 else {
            throw InvalidInputError.invalidInput("Invalid ButtonCustomization parameters.")
        }
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.fontSize = fontSize
        self.title = title
        self.color = color
        self.fontStyle = fontStyle
    }
}

public struct ToolbarCustomization {
    var backgroundColor: String
    var textColor: String
    var titleFontSize: Int
    
    init(backgroundColor: String, textColor: String, titleFontSize: Int) throws {
        guard !backgroundColor.isEmpty, !textColor.isEmpty, titleFontSize > 0 else {
            throw InvalidInputError.invalidInput("Invalid ToolbarCustomization parameters.")
        }
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.titleFontSize = titleFontSize
    }
}

public struct LabelCustomization {
    var textColor: String
    var fontSize: Int
    
    init(textColor: String, fontSize: Int) throws {
        guard !textColor.isEmpty, fontSize > 0 else {
            throw InvalidInputError.invalidInput("Invalid LabelCustomization parameters.")
        }
        self.textColor = textColor
        self.fontSize = fontSize
    }
}

public struct TextBoxCustomization {
    var borderColor: String
    var textColor: String
    var fontSize: Int
    var borderWidth: Int
    var borderRadius: Int
    
    init(borderColor: String, textColor: String, fontSize: Int, borderWidth: Int, borderRadius: Int) throws {
        guard !borderColor.isEmpty, !textColor.isEmpty, fontSize > 0 else {
            throw InvalidInputError.invalidInput("Invalid TextBoxCustomization parameters.")
        }
        self.borderColor = borderColor
        self.textColor = textColor
        self.fontSize = fontSize
        self.borderWidth = borderWidth
        self.borderRadius = borderRadius
    }
}

// Main UiCustomization class
public class UiCustomization {
    private var buttonCustomizations: [ButtonType: ButtonCustomization]
    private var toolbarCustomization: ToolbarCustomization?
    private var labelCustomization: LabelCustomization?
    private var textBoxCustomization: TextBoxCustomization?
    
    private init(buttonCustomizations: [ButtonType: ButtonCustomization],
                 toolbarCustomization: ToolbarCustomization?,
                 labelCustomization: LabelCustomization?,
                 textBoxCustomization: TextBoxCustomization?) {
        self.buttonCustomizations = buttonCustomizations
        self.toolbarCustomization = toolbarCustomization
        self.labelCustomization = labelCustomization
        self.textBoxCustomization = textBoxCustomization
    }
    
    // Factory method to create a UiCustomization instance
    public static func create(buttonCustomizations: [ButtonType: ButtonCustomization] = [:],
                              toolbarCustomization: ToolbarCustomization? = nil,
                              labelCustomization: LabelCustomization? = nil,
                              textBoxCustomization: TextBoxCustomization? = nil) throws -> UiCustomization {
        
        let customization = UiCustomization(
            buttonCustomizations: buttonCustomizations,
            toolbarCustomization: toolbarCustomization,
            labelCustomization: labelCustomization,
            textBoxCustomization: textBoxCustomization
        )
        
        if buttonCustomizations.isEmpty {
            customization.applyDefault()
        }
        
        try validateParameters(customization: customization)
        
        return customization
    }
    
    // Validation function
    private static func validateParameters(customization: UiCustomization) throws {
        if customization.buttonCustomizations.isEmpty {
            throw InvalidInputError.invalidInput("Button customizations cannot be empty.")
        }
        // Additional validations as needed
    }
    
    // Apply default values
    public func applyDefault() -> UiCustomization {
        if buttonCustomizations.isEmpty {
            buttonCustomizations = [
                .submit: try! ButtonCustomization(
                    backgroundColor: "#FF00FF",
                    textColor: "#FFFFFF",
                    fontSize: 16,
                    title: "Submit",
                    color: .magenta,
                    fontStyle: .systemFont(ofSize: 16)
                ),
                .continueButton: try! ButtonCustomization(
                    backgroundColor: "#008000",
                    textColor: "#FFFFFF",
                    fontSize: 16,
                    title: "Continue",
                    color: .green,
                    fontStyle: .systemFont(ofSize: 16)
                ),
                .next: try! ButtonCustomization(
                    backgroundColor: "#FFA500",
                    textColor: "#FFFFFF",
                    fontSize: 16,
                    title: "Next",
                    color: .orange,
                    fontStyle: .systemFont(ofSize: 16)
                ),
                .cancel: try! ButtonCustomization(
                    backgroundColor: "#FF0000",
                    textColor: "#FFFFFF",
                    fontSize: 16,
                    title: "Cancel",
                    color: .red,
                    fontStyle: .systemFont(ofSize: 16)
                ),
                .resend: try! ButtonCustomization(
                    backgroundColor: "#FFFF00",
                    textColor: "#000000",
                    fontSize: 16,
                    title: "Resend",
                    color: .yellow,
                    fontStyle: .systemFont(ofSize: 16)
                )
            ]
        }
        
        if toolbarCustomization == nil {
            toolbarCustomization = try! ToolbarCustomization(backgroundColor: "#0000FF", textColor: "#FFFFFF", titleFontSize: 18)
        }
        
        if labelCustomization == nil {
            labelCustomization = try! LabelCustomization(textColor: "#000000", fontSize: 14)
        }
        
        if textBoxCustomization == nil {
            textBoxCustomization = try! TextBoxCustomization(borderColor: "#D3D3D3", textColor: "#000000", fontSize: 14, borderWidth: 1, borderRadius: 5)
        }
        
        return self
    }
    
    // Accessors for customizations
    public func getButtonCustomization(for buttonType: ButtonType) throws -> ButtonCustomization {
        guard let customization = buttonCustomizations[buttonType] else {
            throw InvalidInputError.invalidInput("Invalid button type: \(buttonType)")
        }
        return customization
    }
    
    public func getToolbarCustomization() throws -> ToolbarCustomization {
        guard let customization = toolbarCustomization else {
            throw InvalidInputError.invalidInput("Toolbar customization is not set.")
        }
        return customization
    }
    
    public func getLabelCustomization() throws -> LabelCustomization {
        guard let customization = labelCustomization else {
            throw InvalidInputError.invalidInput("Label customization is not set.")
        }
        return customization
    }
    
    public func getTextBoxCustomization() throws -> TextBoxCustomization {
        guard let customization = textBoxCustomization else {
            throw InvalidInputError.invalidInput("TextBox customization is not set.")
        }
        return customization
    }
}
