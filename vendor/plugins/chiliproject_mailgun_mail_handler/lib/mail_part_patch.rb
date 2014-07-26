module Mail
  class Part < Message

    def size
      decoded.size
    end


  end

end