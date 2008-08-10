
require 'open-uri'
require 'activesupport'
require 'hpricot'

class Gistr
  def initialize(gist_id)
    @gist_id = gist_id
  end

  def post(email, password, title)
    post_to_tumblr(email, password, title, gist_code)
  end

  def gist_code
    return @gist_code if @gist_code

    js = open("http://gist.github.com/#{@gist_id}.js").read
    code = js.scan(/document.write\('([^']*)'/).flatten.last.gsub("\\\n", "\n")

    h = Hpricot(code)

    h.search('pre').each do |pre|
      pre.swap(pre.inner_html)
    end

    @gist_code = h.to_html
  end

  private
  def post_to_tumblr(email, password, title, body)
    Net::HTTP.start("www.tumblr.com") do |http|
      req = Net::HTTP::Post.new "/api/write"
      req.set_form_data :email => email, :password => password,
	:title => title, :body => body,
	:private => 1

      http.request req
    end
  end
end
