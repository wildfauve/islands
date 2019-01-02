class FileWriter

  def initialize(name)
    @file = File.open(name, "w")
  end

  def puts(line)
    @file.puts line
  end

end
