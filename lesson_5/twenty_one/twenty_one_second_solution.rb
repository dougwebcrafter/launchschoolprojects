SUITS = ['H', 'D', 'S', 'C'].freeze
VALUES = ['2', '3', '4', '5', '6', '7',
          '8', '9', '10', 'J', 'Q', 'K', 'A'].freeze
MAX_TOTAL_VALUE = 21
MAX_DEALER_HITS = 17

def prompt(msg)
  puts "=> #{msg}"
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def total(cards)
  # cards = [['H', '3'], ['S', 'Q'], ... ]
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    sum += if value == "A"
             11
           elsif value.to_i.zero? # J, Q, K
             10
           else
             value.to_i
           end
  end

  # correct for Aces
  values.select { |value| value == "A" }.count.times do
    sum -= 10 if sum > MAX_TOTAL_VALUE
  end

  sum
end

def busted?(cards)
  total(cards) > MAX_TOTAL_VALUE
end

def detect_result(dealer_cards, player_cards)
  player_total = total(player_cards)
  dealer_total = total(dealer_cards)

  if player_total > MAX_TOTAL_VALUE
    :player_busted
  elsif dealer_total > MAX_TOTAL_VALUE
    :dealer_busted
  elsif dealer_total < player_total
    :player
  elsif dealer_total > player_total
    :dealer
  else
    :tie
  end
end

def display_result(result)
  case result
  when :player_busted
    prompt "You busted! Dealer wins!"
  when :dealer_busted
    prompt "Dealer busted! You win!"
  when :player
    prompt "You win!"
  when :dealer
    prompt "Dealer wins!"
  when :tie
    prompt "It's a tie!"
  end
end

def display_initial_situation(player_cards, dealer_cards)
  player_total = total(player_cards)
  first_card = player_cards.first
  second_card = player_cards[1]
  prompt "Dealer has #{dealer_cards[0]} and ?"
  prompt "You have: #{first_card} and #{second_card}. Total: #{player_total}."
end

def deal_initial_cards(deck, player_cards, dealer_cards)
  2.times do
    player_cards << deck.pop
    dealer_cards << deck.pop
  end
end

def choose_option
  player_turn = nil
  loop do
    prompt "Would you like to (h)it or (s)tay?"
    player_turn = gets.chomp.downcase
    break if ['h', 's'].include?(player_turn)
    prompt "Sorry, must enter 'h' or 's'."
  end
  player_turn
end

def hit(deck, player_cards)
  player_cards << deck.pop
  player_total = total(player_cards)
  prompt "You chose to hit!"
  prompt "Your cards are now: #{player_cards}"
  prompt "Your total is now: #{player_total}"
end

def player_turn(deck, player_cards)
  loop do
    player_turn = choose_option
    if player_turn == 'h'
      hit(deck, player_cards)
    end
    break if player_turn == 's' || busted?(player_cards)
  end
  if !busted?(player_cards)
    prompt "Player stayed at #{total(player_cards)}"
  end
end

def dealer_turn(deck, dealer_cards)
  prompt "Dealer turn..."
  dealer_total = 0
  loop do
    break if busted?(dealer_cards) || dealer_total >= MAX_DEALER_HITS
    prompt "Dealer hits!"
    dealer_cards << deck.pop
    prompt "Dealer's cards are now: #{dealer_cards}"
    dealer_total = total(dealer_cards)
  end
  prompt "Dealer stayed at #{dealer_total}" if !busted?(dealer_cards)
end

def play_again?
  puts "-------------"
  prompt "Do you want to play again? (y or n)"
  answer = nil
  loop do
    answer = gets.chomp
    break if %w(y n).include?(answer.downcase)
    prompt "Invalid choice! Try again."
  end
  answer.downcase.casecmp('y').zero?
end

loop do
  prompt "Welcome to Twenty-One!"
  player_score = 0
  dealer_score = 0

  loop do
    deck = initialize_deck
    player_cards = []
    dealer_cards = []

    deal_initial_cards(deck, player_cards, dealer_cards)
    display_initial_situation(player_cards, dealer_cards)

    player_turn(deck, player_cards)
    dealer_turn(deck, dealer_cards) unless busted?(player_cards)

    puts "=============="
    prompt "Dealer has #{dealer_cards}, for a total of: #{total(dealer_cards)}"
    prompt "Player has #{player_cards}, for a total of: #{total(player_cards)}"
    puts "=============="
    result = detect_result(dealer_cards, player_cards)
    display_result(result)

    case result
    when :player_busted, :dealer
      dealer_score += 1
    when :dealer_busted, :player
      player_score += 1
    end

    prompt "Player #{player_score} x #{dealer_score} Dealer"
    prompt "Press enter to continue..."
    gets

    break if player_score == 5 || dealer_score == 5
  end
  if player_score == 5
    prompt "Congratulations! You scored 5! You won!"
  else
    prompt "Sorry, dealer scored 5. Dealer won."
  end
  break unless play_again?
end

prompt "Thank you for playing Twenty-One! Good bye!"
