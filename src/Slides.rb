#The base class for presentation slides.
#Contains a title and a number, but no content
class Slide
	#attr_reader is the fast way to define read-only field accessors. 
	#attr_accessor is for read/write, and attr_writer is for write-only.
	attr_reader :title, :number

	#This is the constructor
	def initialize(title, number)
		#Class variables start with an @
		@title=title
		@number=number
	end 
  
	def getContent
		return ''
	end

	def to_s #to_s is like .ToString() in Java or C#
		#Variables can be referenced inside double-quoted strings
		#using the #{} construct.
		return "\n#{@title}\n\nSlide ##{@number}"
	end
  
end

#A slide containing text content
class TextSlide < Slide
  attr_reader :content
  
  def initialize(title, number, text)
    super(title, number) #Call the parent class' constructor.
    @content=text
  end
  
  #Overrides the parent class' getContent
  def getContent
	maxLineLen = 64 #sort of a soft limit
	ctr=maxLineLen
	content = "\t"+@content
	#Split the lines up, wrapping at whitespace
	while(ctr<content.length)
		val = (content[ctr,1]=~/\s/)!=0
		if (content[ctr,1]=~/\s/)!=0
			ctr+=1
		else
			content[ctr]="\n\t"
			ctr+=maxLineLen
		end		
	end
	return content
  end
  
  def to_s
    return "\n#{@title}\n\t#{@content}\nSlide ##{@number}"
  end
end

#A class containing bullet points or text.
#Text is denoted by bullet points with an indent level of 0.
class BulletPointsSlide < Slide
  attr_reader :content
  
  def initialize(title, number, bullets)
    super(title, number)
    @content=bullets
  end
  
  def getContent
	ret = ""
	@content.each{|x| 
		ret << "\t"
		#The fact that you can do this sort of thing is why
		#Ruby is totally awesome.
		x[0].times{ ret << "   "}
		if x[0]>0 
			ret << "*" #Only add a bullet if we're indented
		end
		ret << " #{x[1]}\n"
	}
	ret
  end
  
  def to_s
    str = "\n#{@title}\n"
    content.each{|x| str+="\t* #{x}\n"}
    return str += "\nSlide##{@number}"
  end
end

#A slide that contains just code (no text content).
class CodeSlide < Slide
	attr_reader :content
	
	def initialize(title, number, code)
		super(title, number)
		@content=code
	end
	
	def getContent
		#We don't preformat the code any.
		@content
	end
	
	def to_s
		return "\n#{@title}\n\t#{@content}\nSlide ##{@number}"
	end
end

#A slide that contains both text and code.
class CodeTextCompositeSlide < TextSlide
	attr_reader :code
 
	def initialize(title, number, content, code)
		super(title, number, content)
		@code=code
	end
	
	#Note that getContent is inherited from TextSlide and it still works
	#just fine, so we don't need to override it here.
	
	def getCode
		@code
	end
 
  def to_s
    return "\n#{@title}\n\t#{@content}\n\t#{@code}\nSlide ##{@number}"
  end
 end