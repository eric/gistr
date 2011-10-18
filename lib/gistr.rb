require 'open-uri'

class Gistr
  def initialize(gist_id, options = {})
    @gist_id = gist_id
    @post_private = options[:private] || 1
  end

  def post(email, password, title, blog)
    post_to_tumblr(email, password, title, blog, gist_code)
  end

  def gist_code
    return @gist_code if @gist_code

    # Use the secret .pibb format
    code = open("https://gist.github.com/#{@gist_id}.pibb").read

    @gist_code = code
  end

  private
  def post_to_tumblr(email, password, title, blog, body)
    Net::HTTP.start("www.tumblr.com") do |http|
      req = Net::HTTP::Post.new("/api/write")
      req.set_form_data :email => email, :password => password,
        :title => title, :body => body, :format => 'html',
        :private => @post_private, :group => blog

      http.request(req)
    end
  end
end
