//
//  CommandPrivilege.swift
//  FireAlarm
//
//  Created by NobodyNada on 11/20/16.
//  Copyright © 2016 NobodyNada. All rights reserved.
//

import Foundation

open class CommandPrivilege: Command {
	override open class func usage() -> [String] {
		return ["privilege * *"]
	}
	
	override open class func privileges() -> ChatUser.Privileges {
		return .owner
	}
	
	private func usage() {
		reply("Usage: privilege <user> <privilege>")
	}
	
	override open func run() throws {
		if arguments.count != 2 {
			return usage()
		}
		
		let user = arguments.first!
		let privilegeName = arguments.last!
		
		var privilege: ChatUser.Privileges?
		
		for (priv, name) in ChatUser.Privileges.privilegeNames {
			if name.lowercased() == privilegeName.lowercased()  {
				privilege = ChatUser.Privileges(rawValue: priv)
				break
			}
		}
		
		guard let priv = privilege else {
			reply("\(privilegeName) is not a valid privilege")
			return
		}
		
		var targetUser: ChatUser?
		let idFromURL: Int?
		if let url = URL(string: user), let id = postIDFromURL(url, isUser: true) {
			idFromURL = id
		} else {
			idFromURL = nil
		}
		
		//search for the user in the user database
		for chatUser in message.room.userDB {
			let cleanedName = chatUser.name.replacingOccurrences(of: " ", with: "").lowercased()
			if chatUser.id == Int(user) ||
				cleanedName == user.lowercased() ||
				(user.hasPrefix("@") && cleanedName == String(user.lowercased().dropFirst())) || 
				chatUser.id == idFromURL {
				
				targetUser = chatUser
				break
			}
		}
		
		guard let u = targetUser else {
			reply("I don't know that user.")
			return
		}
		
		guard !u.privileges.contains(priv) else {
			reply("That user already has that privilege.")
			return
		}
		
		u.privileges.update(with: priv)
		reply("Given \(ChatUser.Privileges.name(of: priv)) privileges to [\(u.name)](//stackoverflow.com/u/\(u.id)).")
	}
}
