# TwitRbDelegate.rb
# TwitRB
#
# Created by Boris Bügling on 17.11.09.
# Copyright 2009 Extessy AG. All rights reserved.

class TwitRbDelegate

	attr_accessor :credentials_window, :main_window
	attr_accessor :username_field, :password_field
	attr_accessor :username, :password, :updates
	attr_accessor :table_view, :status_label

	def applicationDidFinishLaunching(notification)
		NSApp.beginSheet(credentials_window, 
				modalForWindow:main_window,
				modalDelegate:nil,
				didEndSelector:nil,
				contextInfo:nil)
	end
	
	def initialize
		@updates = []
	end
	
	def submitCredentials(sender)
		self.username = username_field.stringValue
		self.password = password_field.stringValue
		NSApp.endSheet(credentials_window)
		credentials_window.orderOut(sender)
		NSLog "I have #{username} as username"
		NSLog "I have #{password} as password"
		
		url = NSURL.URLWithString("http://twitter.com/statuses/friends_timeline.xml")
		request = NSURLRequest.requestWithURL(url)
		@connection = NSURLConnection.connectionWithRequest(request, delegate:self)
	end
	
	def hideCredentials(sender)
		NSLog "Cancelled twitter credentials"
		NSApp.endSheet(credentials_window)
		credentials_window.orderOut(sender)
	end
	
	def connection(connection, didReceiveResponse:response)
		NSLog "Got a response #{response.statusCode}"
	end
	
	def connection(connection, didReceiveData:data)
		@receivedData ||= NSMutableData.new
		@receivedData.appendData(data)
	end
	
	def connectionDidFinishLoading(connection)
		doc = NSXMLDocument.alloc.initWithData(@receivedData,
						options:NSXMLDocumentValidate, error:nil)
		statuses = doc.rootElement.nodesForXPath('status', error:nil)
		NSLog "Received #{statuses.count} updates from Twitter"
		self.updates = statuses.map do |s|
			{
				:user => s.nodesForXPath('user/name', error:nil).first.stringValue,
				:tweet => s.nodesForXPath('text', error:nil).first.stringValue
			}
		end
		table_view.reloadData
		self.status_label.stringValue = "Updated"
	end
	
	def connection(connection, didReceiveAuthenticationChallenge:challenge)
		if challenge.previousFailureCount == 0 && !challenge.proposedCredential
			creds = NSURLCredential.credentialWithUser(username, password:password, persistence:NSURLCredentialPersistence)
			challenge.sender.userCredential(creds, forAuthenticationChallenge:challenge)
		else
			NSLog "Credentials failed. :-("
		end
	end
	
end