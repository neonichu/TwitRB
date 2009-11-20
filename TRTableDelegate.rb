 # TRTableDelegate.rb
# TwitRB
#
# Created by Boris Bügling on 19.11.09.
# Copyright 2009 Extessy AG. All rights reserved.

class TRTableDelegate
	
	attr_accessor :parent

	def numberOfRowsInTableView(tableView)
		parent.updates.count
	end 
	
	def tableView(tableView, objectValueForTableColumn:column, row:row)
		NSLog "Asked for row: #{row} column: #{column}"
		if row < parent.updates.length
			return parent.updates[row].valueForKey(column.identifier.to_sym)
		end
		nil
	end
	
end