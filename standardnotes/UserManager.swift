//
//  UserManager.swift
//  standardnotes
//
//  Created by Mo Bitar on 12/23/16.
//  Copyright © 2016 Standard Notes. All rights reserved.
//

import Foundation

struct Keys {
    var mk: String?
    var encryptionKey: String
    var authKey: String
}

class UserManager {
    
    static let LogoutNotification = "LogoutNotification"
    
    static let sharedInstance : UserManager = {
        return UserManager()
    }()

    init() {
        email = UserDefaults.standard.object(forKey: "email") as! String?
        server = UserDefaults.standard.object(forKey: "server") as! String?
        jwt = UserDefaults.standard.object(forKey: "jwt") as! String?
        mk = UserDefaults.standard.object(forKey: "mk") as! String?
        
        if server == nil {
            server = "https://sync.standardnotes.org"
        }
    }
    
    var email: String!
    var server: String!
    var mk: String!
    var jwt: String!
    

    var _keys: Keys!
    var keys: Keys {
        get {
            if(_keys == nil) {
                _keys = Crypto.sharedInstance.generateKeysFromMasterKey(masterKey: mk)
            }
            return _keys
        }
    }
    
    //#MARK TouchID modifies User default
    var touchIDEnabled: Bool {
        get{
            return UserDefaults.standard.bool(forKey: "touchIDEnabled")
        }
        set{
            UserDefaults.standard.set(newValue, forKey: "touchIDEnabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    public func toggleTouchID(){
        touchIDEnabled = !touchIDEnabled
    }
    
    private var _authParams: [String : Any]?
    var authParams: [String : Any]? {
        get {
            if _authParams == nil {
                return UserDefaults.standard.object(forKey: "authParams") as! [String : Any]?
            }
            
            return _authParams
        }
        
        set {
            _authParams = newValue
            UserDefaults.standard.setValue(newValue, forKey: "authParams")
        }
    }
    
    func save() {
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set(server, forKey: "server")
        UserDefaults.standard.set(jwt, forKey: "jwt")
        UserDefaults.standard.set(mk, forKey: "mk")
        
        persist()
    }
    
    func persist() {
        UserDefaults.standard.synchronize()
    }
    
    var signedIn : Bool {
        return self.jwt != nil
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "jwt")
        UserDefaults.standard.removeObject(forKey: "mk")
        UserDefaults.standard.removeObject(forKey: "touchIDEnabled")
        
        self.email = nil
        self.mk = nil
        self.jwt = nil
        
        persist()
    }
}
