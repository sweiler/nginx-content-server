module Helper
  TOKEN_LENGTH = 20

  def self.random_char
    type = rand(3)
    case type
      when 0 then
        ('a'..'z').to_a[rand(26)]
      when 1 then
        ('A'..'Z').to_a[rand(26)]
      else
        ('0'..'9').to_a[rand(10)]
    end
  end

  def self.generate_token
    (0...TOKEN_LENGTH).map {random_char}.join
  end
end