//
//  UIApplication+Extension.swift
//  Mobile Weather App
//
//  Created by Coriolan on 2024-06-26.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
