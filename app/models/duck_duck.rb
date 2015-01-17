class DuckDuck
  HEADERS = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36"}
  
  def self.js_eval(str)
    cxt = V8::Context.new
    str = "var arr = #{str}"
    cxt.eval(str)
    cxt[:arr]
  end
  
  def self.get(options={})
    raise ArgumentError.new('Need search term - query') unless options[:query]
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
    end
  end
end