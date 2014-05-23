module Clockability

  class TimeConversor

    def self.extract_hours(chili_hours)
      return chili_hours.to_i
    end

    def self.extract_minutes(chili_hours)
      decimal_part = chili_hours - (chili_hours.to_i)

      if(decimal_part >= 0.7)
        return 45
      end
      if(decimal_part >= 0.5)
        return 30
      end
      if(decimal_part >= 0.2)
        return 15
      end
      if((decimal_part < 0.2) and (extract_hours(chili_hours) == 0))
        return 15
      end
      return 0
    end
  end

end