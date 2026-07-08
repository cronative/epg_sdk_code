////
////  ConfigurationParameters.swift
////  FrameWork-V2
////
////  Created by eand ePayment on 09/11/24.
////
//
//enum ConfigParametersError: Error {
//    case invalidInput(String)
//    case duplicateParameter(String)
//}
//
//public class ConfigurationParameters {
//    // Dictionary to hold configuration parameters, grouped by group name
//    private var parameters: [String: [String: String]] = [:]
//
//    // Default group name
//    private let defaultGroup = "default"
//
//    // Computed property to check if parameters are empty
//    public var isEmpty: Bool {
//        return parameters.isEmpty || parameters.values.allSatisfy { $0.isEmpty }
//    }
//
//    // Adds a configuration parameter either to the specified group or to the default group
//    public func addParam(group: String? = nil, paramName: String, paramValue: String) throws {
//        guard !paramName.isEmpty else {
//            throw ConfigParametersError.invalidInput("Parameter name cannot be empty.")
//        }
//        
//        // Use default group if group is not specified
//        let groupName = group ?? defaultGroup
//
//        // Initialize the group if it doesn't exist
//        if parameters[groupName] == nil {
//            parameters[groupName] = [:]
//        }
//
//        // Check for duplicate parameter names in the specified group
//        if parameters[groupName]!.keys.contains(paramName.lowercased()) {
//            throw ConfigParametersError.duplicateParameter("Duplicate parameter name: \(paramName)")
//        }
//
//        // Add the parameter
//        parameters[groupName]![paramName.lowercased()] = paramValue
//    }
//
//    // Returns a configuration parameter's value from the specified group or the default group
//    public func getParamValue(group: String? = nil, paramName: String) throws -> String? {
//        guard !paramName.isEmpty else {
//            throw ConfigParametersError.invalidInput("Parameter name cannot be empty.")
//        }
//
//        let groupName = group ?? defaultGroup
//        return parameters[groupName]?[paramName.lowercased()]
//    }
//
//    // Removes a configuration parameter from the specified group or the default group
//    public func removeParam(group: String? = nil, paramName: String) throws -> String? {
//        guard !paramName.isEmpty else {
//            throw ConfigParametersError.invalidInput("Parameter name cannot be empty.")
//        }
//
//        let groupName = group ?? defaultGroup
//
//        // Check if the group exists and if the parameter exists within the group
//        guard var groupParameters = parameters[groupName],
//              groupParameters.keys.contains(paramName.lowercased()) else {
//            return nil // Parameter not found
//        }
//
//        // Remove the parameter and return its value
//        let removedValue = groupParameters.removeValue(forKey: paramName.lowercased())
//        parameters[groupName] = groupParameters
//
//        return removedValue
//    }
//}
