class RelevanceQNA
  def initialize(hostname, username, password)
    @hostname = hostname
    @username = username
    @password = password
    @webreports_uri = URI.parse("http://#{@hostname}/webreports")
  end
  
  def query(expr)
    params = { 'Username' => @username,
               'Password' => @password,
               'page' => 'EvaluateRelevanceOnly',
               'expr' => expr }
    result = Net::HTTP.post_form(@webreports_uri, params)
    doc = REXML::Document.new(result.body)
    doc.root.get_elements('answerlist/answer').map &:text
  end
end
