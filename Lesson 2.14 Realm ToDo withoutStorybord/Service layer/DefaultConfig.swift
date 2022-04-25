//
//  defaultConfig.swift
//  Lesson 2.14 Realm ToDo
//
//  Created by Константин Андреев on 19.04.2022.
//

import UIKit

class DefaultConfig {
    static let shared = DefaultConfig()
    let backgroundcolor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    let cornerRadius: CGFloat = 8
    let deleteColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
    let myDayColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
    let editColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
    private init() {}
    
    func setDefaults(for navigationController: UINavigationController?) {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let customAppearance = UINavigationBarAppearance()
        
        customAppearance.backgroundColor = backgroundcolor
        customAppearance.titleTextAttributes = [.foregroundColor : UIColor.white]
        customAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = customAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = customAppearance
    }
    
    
}
