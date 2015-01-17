class DuckDuck
  HEADERS = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"}
  
  def self.js_eval(str)
    cxt = V8::Context.new
    str = "var arr = #{str}"
    cxt.eval(str)
    cxt[:arr]
  end
  
  def self.search(options={})
    raise ArgumentError.new('Need search term - query') unless options[:query]
    if options[:type] == 'web' || options[:type].blank?
      web(options)
    elsif options[:type] == 'topic'
      topics(options)
    end
  end
  
  def self.web(options)
    page = options[:page].to_i
    limit = (page * 50) - 20
    limit = 0 if limit < 0
    hash = {q: options[:query], s: limit, t: "D", l: 'us-en', p: 1}
    resp = HTTParty.get("https://duckduckgo.com/d.js", query: hash, headers: HEADERS)

    if resp.ok?
      str = resp.body.scan(/if \(nrn\) nrn\('d',(.*)?\)\;/).flatten.first
      results = (js_eval(str) || []) rescue []
      results.collect do |result|
        {url: result.u, title: result.t, snippet: result.a} unless result.respond_to?(:n)
      end.compact
    else
      []
    end
  end
  
  def self.topics(options)
    resp = HTTParty.get("http://api.duckduckgo.com/?q=#{options[:query]}&format=json")
    if resp.ok?
      data = JSON.parse(resp.body)
      data['RelatedTopics'].collect{|hash| topic_data_from_result(hash)}.flatten.compact
    else
      []
    end
  end
  
  
  def self.topic_data_from_result(hash)
    if hash['Topics'].present?
      hash['Topics'].collect{|hash| topic_data_from_result(hash)}
    elsif hash['Result']
      {url: hash['FirstURL'], title: hash['FirstURL'], snippet: hash['Text']}
    else
      nil
    end
  end
end