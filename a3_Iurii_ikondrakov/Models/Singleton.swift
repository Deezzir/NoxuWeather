//
//  Singleton.swift
//  a3_Iurii_ikondrakov
//
//  Created by Iurii Kondrakov on 2022-03-11.
//

class Singleton {
    private static var obj:Singleton? = nil
    private static var history:[Weather]? = nil
    
    private init() {}
    
    static func getInstance() -> Singleton {
        if(self.obj == nil) {
            self.obj = Singleton()
            self.history = [Weather]()
        }
        return self.obj!
    }
    
    func insertItem(item:Weather) {
        Singleton.history?.append(item)
    }
    
    func getHistory() -> [Weather] {
        return Singleton.history!
    }
}
