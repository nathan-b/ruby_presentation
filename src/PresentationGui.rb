require './PresentationParser.rb'
require 'tk'

#Tk is the enemy of all mankind.
class PresentationGui

	def initialize(file)
		@currentSlide = 0
		#Fonts
		@titleFont = TkFont.new('times')
		@titleFont.configure('size'=>36)
		@contentFont = TkFont.new('times')
		@contentFont.configure('size'=>22)
		@codeFont = TkFont.new('courier')
		@codeFont.configure('size'=>16)

		pp = PresentationParser.new
		@slides = pp.readPresentation(file)
	end

	def main
		#This stuff is hardcoded, which is bad, but that's the way we swing here.
		@root = TkRoot.new() { }
		@root.geometry('1024x768+0+0')
		@root.overrideredirect(true)
		@root.bind("Escape"){ exit }

		#The navigation bar (at the bottom, containing Back, Fwd, and Page#)
		navBar = TkFrame.new(@root)
		navBar.configure('relief'=>'flat','borderwidth'=>2,'bg'=>'white')
		navBar.pack('side'=>'bottom', 'fill'=>'x')

		#The back button (to replace image, just overwrite back.gif).
        backButton = TkPhotoImage.new('file'=>'../resources/back.gif')
		bLabel = TkLabel.new(navBar) { image backButton }
		bLabel.bind('ButtonRelease-1'){ prevSlide }
		bLabel.pack('side'=>'left','anchor'=>'w')

		#Forward button (ditto)
        forwardButton = TkPhotoImage.new('file'=>'../resources/forward.gif')
		fLabel = TkLabel.new(navBar) { image forwardButton }
		fLabel.bind('ButtonRelease-1'){ nextSlide }
		fLabel.pack('side'=>'right','anchor'=>'e')
		
		#Slide number
		@slideNumber = TkLabel.new(navBar)
		@slideNumber.configure(	'font'=>@contentFont, 
										'justify'=>'center',
										'bg'=>'white')

		#The main frame, which contains everything not in the nav bar
		@contentFrame = TkFrame.new
		@contentFrame.pack('fill'=>'both')

		#The title. Since this never gets unpacked, we can leave it here and 
		#Tk won't move it off to Azerbaijan or anything like that (which it
		#very much loves to do).
		@title = TkLabel.new(@contentFrame)
		@title.configure('font'=>@titleFont)
		@title.pack

		#The place where the text/bullet points go.
		@content = TkLabel.new(@contentFrame)
		@content.configure('font'=>@contentFont, 'justify'=>'left')

		#The place where the code goes.
		@codeListing = TkText.new(@contentFrame)
		@codeListing.configure('font'=>@codeFont, 'width'=>40)

		#The results of the code execution go here. Note that this is
		#just the return value; print/puts statements still go to console.
		@codeResult = TkText.new(@contentFrame)
		@codeResult.configure('font'=>@codeFont)

		#The proc keyword allows you to assign a closure to a variable (or at
		#least, I think that's what it does).
		cmd = proc {evaluateCode}
		@evalBtn = TkButton.new(@contentFrame) {
			text 'Evaluate'
			command cmd
		}

		displaySlide

		Tk.mainloop()
	end
	
	def evaluateCode
		@codeResult.insert('end', '> ' + 
			eval(@codeListing.get('0.0','end')).to_s + "\n")
	end

	#Move to the next slide
	def nextSlide
		if @currentSlide < @slides.length - 1
			@currentSlide+=1
			displaySlide
		end

	end

	#Move to the previous slide, if we do indeed have one of those.
	def prevSlide
		if @currentSlide != 0
			@currentSlide -= 1
			displaySlide
		end

	end

	def displaySlide

		curr = @slides[@currentSlide]
		@codeListing.unpack
		@evalBtn.unpack
		@codeResult.unpack

		@codeListing.delete('0.0','end')
		@codeResult.delete('0.0','end')
		#Ruby allows us to completely ignore the benefits of polymorphism by
		#taking certain actions when a variable is of a certain type. This is
		#quick 'n' easy via the multi-way select contstruct. Mom isn't exactly
		#going to put this code on the refridgerator, but it works.
		case curr
		when CodeTextCompositeSlide
			#So that we're not flying all over the place when editing code
			unbindKeys 
				
			@title.configure('text'=>curr.title)
			@content.configure('text'=>curr.getContent)
			@codeListing.insert('end',curr.code)
	
			#Getting Tk's packing algorithm to display all these widgets
			#in approximately the right place took a bit of tinkering.
			#Change the order of this code at your peril. 
			@content.pack('side'=>'top')
			@codeListing.pack('side'=>'left', 'padx'=>5, 'pady'=>10)
			@evalBtn.pack('side'=>'left')
			@codeResult.pack('side'=>'right', 'padx'=>5, 'pady'=>10)
			
		when BulletPointsSlide
			bindKeys
		
			@title.configure('text'=>curr.title)
			@content.configure('text'=>curr.getContent)

			@content.pack('side'=>'left', 'pady'=>50)
		when TextSlide
			bindKeys
		
			@title.configure('text'=>curr.title)
			@content.configure('text'=>curr.getContent)

			@content.pack('side'=>'left', 'pady'=>50)
		when CodeSlide
			unbindKeys
		
			@title.configure('text'=>curr.title)
			@content.unpack

			@codeListing.insert('end',curr.getContent)

			@codeListing.pack('side'=>'left', 'padx'=>5, 'pady'=>10)
			@evalBtn.pack('side'=>'left') 
			@codeResult.pack('side'=>'right', 'padx'=>5, 'pady'=>10)
		when Slide
			bindKeys
		
			@title.configure('text'=>curr.title)
		end
		
		@slideNumber.configure('text'=>@currentSlide+1).pack;

	end
	
		def bindKeys
		@root.bind("Key-Return"){  nextSlide(); }
		@root.bind("Key-space"){  nextSlide(); }
		@root.bind("Key-Right"){  nextSlide(); }
		@root.bind("Key-BackSpace"){ prevSlide(); }
		@root.bind("Key-Left"){ prevSlide(); }
	end
	
	def unbindKeys
		@root.bind("Key-Return"){}
		@root.bind("Key-space"){}
		@root.bind("Key-Right"){}
		@root.bind("Key-BackSpace"){}
		@root.bind("Key-Left"){}
	end

end

