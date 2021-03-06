#!/usr/bin/env ruby
require_relative 'crinkle_butt'
require_relative 'language'

# A caretaker bot extension
module CareTaker
  include Language

  # Gets a hash of all babs this CareTaker is watching, associated to
  # their CrinkleButt objects
  def babs
    @babs = {} if @babs.nil?
    @babs
  end

  # Babysits a user, a bot-exposed function that creates a CrinkleButt
  # object for the user this is supposed to babysit
  def bot_babysit(event, user)
    user_id = user[/\d+/].to_i

    if babs.key? user_id
      event.respond "#{bab_aww.capitalize}, this #{bab_name} wants " \
                    "#{bab_attention}"
    else
      babs[user_id] = create_bab(event, user_id)
      event.respond "#{bab_ok.capitalize} lets get you all cleaned up"
    end
  end

  # Creates a CrinkleButt object for the passed in user and event that
  # called #bab_check in this module
  def create_bab(event, user_id)
    CrinkleButt.new(event, user_id) do |bab|
      bab_check(bab)
    end
  end

  # Checks the bab passed in, and notices if their diaper needs attention
  def bab_check(bab)
    return if bab.user.idle? || bab.diaper < 10

    bab.message bab_notice.capitalize if rand(2).zero?
    sleep rand(3..5)
    bab_request_change(bab)
  end

  # Requests that this bab be changed
  # TODO: Lock out all other bab change requests
  def bab_request_change(bab)
    bab.ping_message bab_diaper_full
    sleep rand(8..15)
    bab.message "#{bab_ok.capitalize}, time to #{bab_diaper_change}!"
    bab.ping_message(bab_come.capitalize)

    bab.lock(&method(:bab_change))

    bab.diaper = 0
    bab_approval(bab)
  end

  # The things that happen during a diaper change
  def bab_change(bab)
    bab.delay_message(
      8..15,
      "\\*#{bab_remove_tapes(bab.ping)}\\*",
      "\\*#{bab_cleaning(bab.ping)}\\*",
      "\\*#{bab_diaper_underneath(bab.ping)}\\*",
      "\\*#{bab_tape_up(bab.ping)}\\*"
    )
  end

  # The post-change admirement
  def bab_approval(bab)
    bab.message "\\*pats #{bab.ping}'s #{bab_butt}\\*" if rand(3).zero?
    bab.message "#{bab_there_we_go.capitalize}! #{bab_clean_diaper.capitalize}"
  end
end
