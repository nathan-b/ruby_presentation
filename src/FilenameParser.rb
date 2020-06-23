class FilenameParser
	#Variables decorated with @@ are class (static) variables
	@@AllowEscapedSpaces = false
	
	#Class (static) methods are decorated with the class name and a .
	def FilenameParser.AllowEscapedSpaces(allow)
		@@AllowEscapedSpaces = allow
	end
	
	#Takes an array of strings, returns the filename
	def FilenameParser.Parse(str, idx = 0)
		retStr = ""
		if str[idx][0,1]=='"' #Read in double-quoted string
			retStr << str[idx]
			while retStr[-1,1]!='"' && idx < str.length-1
				retStr << " " << str[idx+=1]
			end
		else
			retStr = str[idx]
			if(@@AllowEscapedSpaces) #Read in UNIX-style escaped spaces
				while retStr[-1,1]=='/' && idx < str.length-1
					retStr << " " << str[idx+=1]
				end
			end
		end	
		return retStr
	end
	
end

#Tests
#exp1 = 'Test.txt'
#exp2 = '"Test file name"'
#exp3 = '"Test file name"'
#exp4 = 'Test/ file/ name'

#res1 = FilenameParser.Parse(['Test.txt', 'other', 'worthless', 'crap'])
#res2 = FilenameParser.Parse(['"Test', 'file', 'name"', 'other', 'worthless', 'crap'])
#res3 = FilenameParser.Parse(['other', 'worthless', '"Test', 'file', 'name"', 'crap'], 2)
#FilenameParser.AllowEscapedSpaces(true)
#res4 = FilenameParser.Parse(['Test/', 'file/', 'name', 'other', 'worthless', 'crap'])
#if res1 == exp1
#	puts "Pass"
#else
#	puts "Fail test 1: Expected '#{exp1}' but got '#{res1}'"
#end
#if res2 == exp2
#	puts "Pass"
#else
#	puts "Fail test 2: Expected '#{exp2}' but got '#{res2}'"
#end
#if res3 == exp3
#	puts "Pass"
#else
#	puts "Fail test 3: Expected '#{exp3}' but got '#{res3}'"
#end
#if res4 == exp4
#	puts "Pass"
#else
#	puts "Fail test 4: Expected '#{exp4}' but got '#{res4}'"
#end