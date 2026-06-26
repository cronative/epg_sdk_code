//
//  Internet.swift
//  EPG
//
//  Created by Mohd Arsad on 14/10/22.
//

import Foundation
import UIKit
import SystemConfiguration

internal class Internet {
    
    static let shared = Internet()
    
    class var isAvailable: Bool {
        return Internet.shared.checkInternet()
    }
    
    private func checkInternet() -> Bool {
        if !(self.hasInternetConnectivity()) {
            return false
        }
        return true
    }
    
    private func hasInternetConnectivity() -> Bool {
        
      var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
      zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
      zeroAddress.sin_family = sa_family_t(AF_INET)
      let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
          SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
      }
      var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
      if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
      }
      /* Only Working for WIFI
       let isReachable = flags == .reachable
       let needsConnection = flags == .connectionRequired
       return isReachable && !needsConnection
       */
      // Working for Cellular and WIFI
      let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
      let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
      let ret = (isReachable && !needsConnection)
      return ret
    }
    
    func getIPAddress() -> String {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                guard let interface = ptr?.pointee else { return "" }
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                    // wifi = ["en0"]
                    // wired = ["en2", "en3", "en4"]
                    // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

                    let name: String = String(cString: (interface.ifa_name))
                    if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address ?? ""
    }
}
