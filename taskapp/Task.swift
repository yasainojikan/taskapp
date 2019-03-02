//
//  Task.swift
//  taskapp
//
//  Created by 今冨友裕 on 2019/03/02.
//  Copyright © 2019年 yasainojikan. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var id = 0
    
    @objc dynamic var title = ""
    
    @objc dynamic var contents = ""
    
    @objc dynamic var date = Date()
        
    override static func primaryKey() -> String? {
        return "id"
    }
}
