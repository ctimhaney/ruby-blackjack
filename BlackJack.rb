class Deck
	attr_accessor :cards
	
	def initialize (fn = "std_deck.csv")
		@cards = []
		if File.exist? fn and File.extname(fn).eql?(".csv")
			File.foreach(fn) { |l|
				a = l.split ","
				@cards.push(Card.new(a[0],a[1].to_i,a[2],a[3]))
			}
		end
	end
	
	def shuffle
		for i in 0...@cards.length
			j = rand @cards.length
			temp = @cards[i]
			@cards[i] = @cards[j]
			@cards[j] = temp
		end
	end
	
	def print
		@cards.each do |c|
			puts "#{c.pval}"
		end
	end
	
	def draw
		@cards.pop
	end
	
	def isEmpty
		@cards.length == 0
	end
end

class Card
	attr_accessor :id
	attr_accessor :value
	attr_accessor :desc
	attr_accessor :suit
	attr_accessor :sval
	
	def initialize (i = "A ", v = 11, d = "ace", s = "spade")
		@id = i
		@value = v
		@desc = d
		@suit = s
		@sval = @suit[0]
	end
	
	def pval
		"#{@desc} of #{@suit}"
	end
	
	def img
		lines = [" ________ ", "|#{@id}      |"]
		if @sval == 's'
			lines[2] = "|\u2660  _    |"
			lines[3] = "|  / \\   |"
			lines[4] = "| /   \\  |"
			lines[5] = "| \\_ _/  |"
			lines[6] = "|  / \\  \u2660|"
		elsif @sval == 'h'
			lines[2] = "|\u2665 _  _  |"
			lines[3] = "| / \\/ \\ |"
			lines[4] = "| \\    / |"
			lines[5] = "|  \\  /  |"
			lines[6] = "|   \\/  \u2665|"
		elsif @sval == 'd'
			lines[2] = "|\u2666  _    |"
			lines[3] = "|  / \\   |"
			lines[4] = "| /   \\  |"
			lines[5] = "| \\   /  |"
			lines[6] = "|  \\_/  \u2666|"
		elsif @sval == 'c'
			lines[2] = "|\u2663       |"
			lines[3] = "|   ()   |"
			lines[4] = "|  ()()  |"
			lines[5] = "|   /\\   |"
			lines[6] = "|       \u2663|"
		else
			lines[2] = "|   __   |"
			lines[3] = "|  (  )  |"
			lines[4] = "|    (   |"
			lines[5] = "|        |"
			lines[6] = "|    *   |"
		end
		if @id.eql? "10"
			lines[7] = "|      #{@id}|"
		else
			lines[7] = "|       #{@id[0]}|"
		end
		lines[8] = " -------- "
		lines
	end
end

class Hand
	attr_accessor :cards
	attr_accessor :aceCount
	attr_accessor :sum
	
	def initialize
		@cards = []
		@aceCount = 0
		@sum = 0
	end

	def addCard(cd)
		@cards.push(cd)
		@sum = @sum + cd.value
		if (cd.id.eql? "A ")
			@aceCount = @aceCount + 1
		end
	end
	
	def pval
		a = ""
		@cards.each do |c|
			a = a + "*#{c.desc} of #{c.suit}"
		end
		a
	end
	
	def spendAce
		@aceCount = @aceCount - 1
		@sum = @sum - 10
	end
	
	def img
		temp = ["","","","","","","","",""]
		@cards.each do |c|
			cdIm = c.img
			for i in 0...temp.length
				temp[i] = temp[i] << " " << cdIm[i]
			end
		end
		temp.join "\n"
	end
	
end

class BGame
	
	attr_accessor :roundOver
	attr_accessor :funds
	attr_accessor :win
	
	def initialize
		newGame
		@funds = 50
	end
	
	def newGame
	
		@dealHand = Hand.new
		@myHand = Hand.new
		@ddek = Deck.new
		@roundOver = false
		@win = false
		
		10.times do 
			@ddek.shuffle
		end
		
		@myHand.addCard @ddek.draw
		@myHand.addCard @ddek.draw
		
		@dealHand.addCard @ddek.draw
		@dealHand.addCard @ddek.draw
	end
	
	def step
		if @myHand.sum > 21 and @myHand.aceCount > 0
			@myHand.spendAce
		elsif @myHand.sum > 21 and @myHand.aceCount == 0
			puts "\nYou bust. Dealer wins."
			@roundOver = true
		else
			puts "\n--Your hand-- \n#{@myHand.img}"
			puts "\n--Dealer shows-- \n#{@dealHand.cards[1].img().join("\n")}"
			print "\n(h)it or (s)tay: "
			arg = gets.chomp
			
			case arg
			when "h"
				if !@ddek.isEmpty
					nc = @ddek.draw
					puts "\n>>#{nc.pval()}"
					@myHand.addCard nc
				else
					puts "\nDeck Empty\n\n"
				end
			when "s"
				puts "\n***FINAL HAND*** \n#{@myHand.img}\n\n"
				if @dealHand.sum > 21 and @dealHand.aceCount > 0
					@dealHand.spendAce
				end
				while @dealHand.sum < 16
					nnc = @ddek.draw
					puts ">>Dealer draws #{nnc.pval}"
					@dealHand.addCard nnc
					if @dealHand.sum > 21 and @dealHand.aceCount > 0
						@dealHand.spendAce
					end
				end
				
				puts ">>Dealer reveals #{@dealHand.cards[0].pval}"
				puts "\n***DEALER HAND*** \n#{@dealHand.img}\n\n"
				
				if @dealHand.sum > 21
					puts "Dealer bust. You win!"
					@win = true
				elsif @dealHand.sum < @myHand.sum
					puts "You win!"
					@win = true
				elsif @dealHand.sum >= @myHand.sum
					puts "Dealer wins."
				end
				@roundOver = true
			else
				puts "Invalid option." 
			end
		end
	end
end

nn = BGame.new

while nn.funds > 0
	puts "\nCurrent funds: #{nn.funds}"
	print "Place your bet: "
	betAmt = gets.chomp.to_i
	
	if betAmt <= nn.funds
		while !nn.roundOver
			nn.step
		end
		
		if nn.win
			nn.funds = nn.funds + betAmt
		else
			nn.funds = nn.funds - betAmt
		end
		
		nn.newGame
	else
		puts "You don't have enough money."
	end
end

