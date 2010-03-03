require 'open-uri'
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

    # Use the secret .pibb format
    code = open("http://gist.github.com/#{@gist_id}.pibb").read

    # Remove the <pre> tag
    #
    # Tumblr wrap lines at of HTML at times and having the additional 
    # whitespace in a <pre> is very undesirable.
    h = Hpricot(code)

    h.search('pre').each do |pre|
      pre.swap(pre.inner_html) if pre.inner_html.length > 0
    end

    @gist_code = h.to_html
  end

  private
  def post_to_tumblr(email, password, title, body)
    post_private = post_private ? 1 : 0

    Net::HTTP.start("www.tumblr.com") do |http|
      req = Net::HTTP::Post.new("/api/write")
      req.set_form_data :email => email, :password => password,
        :title => title, :body => body, :format => 'html',
        :private => post_private

      http.request(req)
    end
  end
end
