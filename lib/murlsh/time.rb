require 'time'

class Time

  # Return a string of the approximate amount of time that has passed since
  # this time.
  def fuzzy
     days_ago = (Time.now.to_i - to_i) / 86400

     case days_ago
       when 0 then 'today'
       when 1 then 'yesterday'
       when (2..4) then "#{days_ago} days ago"
       when (5..7) then strftime('%a %e %b')
       when (8..180) then strftime('%e %b').strip
       else strftime('%e %b %Y').strip
    end
  end

end
