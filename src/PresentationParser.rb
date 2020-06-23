require './Slides.rb'

class PresentationParser
  
	#These are the possible states for the parser.
	#Note that anything starting with a capital letter is either a constant
	#or a class name.
	Start 		= 0	#The starting (base) state
	HasTitle		= 1	#We have read in a title
	Bullets 		= 2	#We are reading in bullets
	Text 			= 3	#We are reading in text
	Code 			= 4	#We are reading in code
	Composite 	= 5	#We have both text and code for this slide
  
	#function readPresentation. Uses very simple I/O commands to read and parse
	#the presentation file
	def readPresentation(file)
		inf = File.open(file,'r')
		slides = parse(inf.read)
		inf.close
		return slides	#the return statement is not strictly necessary
	end
  
	private	#This works just like it does in C++
  
	def parse(str)
		#Matches something like <text><number>:<anything goes here>
		re = /\s*(\D*?)(\d*):(\s*)(.*)/
		#All these variables need to be declared up here. If they are
		#instantiated in the block below, they will only be in that block's
		#scope and will not be visible once the block exits (annoying).
		slides = Array.new
		num = 0
		state = Start
		currTitle = ""
		content = ""
		code = ""

		#The each method splits the string up at newlines by default, but it
		#takes a parameter and can split by anything.
		str.each_line { |line|	
			if line =~ re
				case $1
				when "Title" #Start of a new slide
					#Insert our working slide into the array
					case state
					when HasTitle
						slides << Slide.new(currTitle, num)
					when Bullets
						slides << BulletPointsSlide.new(currTitle, num, content)
					when Text
						slides << TextSlide.new(currTitle, num, content)
					when Code
						slides << CodeSlide.new(currTitle, num, code)
					when Composite
						slides << CodeTextCompositeSlide.new(currTitle, num, content, code)
					end
					 
					num+=1          
					currTitle = $4
					content = code = ""
					state=HasTitle
					 
				when "B" #Bullet point
					if state != Bullets
						content = Array.new
					end
					bpArray = [$2.to_i,$4]	#to_i converts string > integer				
					content << bpArray
					state = Bullets
					 
				when "Text"
					if state != Text
						content = ""
					end
					content += $4 + "\n"
					if(state == Code)
						state = Composite
					else
						state = Text
					end
					
				when ""
					code += $3 + $4 + "\n"
					if(state == Text)
						state = Composite
					else
						state = Code
					end
					
				end
			elsif
				#.strip removes leading and trailing whitespace
				if line.strip != ''
					puts "Found bogus line '#{line}'"
				end
			end   
		}
		#insert final slide
		case state
		when HasTitle
			slides << Slide.new(currTitle, num)
		when Bullets
			slides << BulletPointsSlide.new(currTitle, num, content)
		when Text
			slides << TextSlide.new(currTitle, num, content)
		when Code
			slides << CodeSlide.new(currTitle, num, code)
		when Composite
			slides << CodeTextCompositeSlide.new(currTitle, num, content, code)
		end
		
		return slides
	end #end function parse
end

#tests
#puts "Reading testpres.txt"
#pp = PresentationParser.new
#myslides = pp.readPresentation("testpres.txt")
#myslides.each{|x| puts x}
