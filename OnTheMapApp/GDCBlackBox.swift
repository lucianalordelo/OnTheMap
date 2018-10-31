//
//  GDCBlackBox.swift
//  OnTheMapApp
//
//  Created by Luciana Lordelo Nascimento on 04/10/2018.
//  Copyright © 2018 Luciana Lordelo Nascimento. All rights reserved.
//

import Foundation

func performUpdatesOnMain (_ updates: @escaping()->Void) {
    DispatchQueue.main.async {
        updates()
    }
}
