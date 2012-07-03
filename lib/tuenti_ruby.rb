require 'mechanize'
require 'open-uri'

#*****************CONSTANTS*****************

#Base URL
TUENTI_BASE_URL = 'http://m.tuenti.com/'
#Functionalities
LOGIN_F = '?m=login&func=process_login'
LOGOUT_F = '?m=login&func=log_out'
HOME_F = '?m=Home&f=index'
PROFILE_F = '?m=Profile&func=my_profile'
TAGGED_PHOTOS_INDEX_F = '?m=Albums&func=index'
TAGGED_PHOTOS_PAGE_F = '?m=Albums&func=view_album_display'
#URL_params
PHOTO_PAGE_P = '&photos_page='
#Form fields
USERNAME_FIELD = 'tuentiemail'
PASSWORD_FIELD = 'password'
#Helpers
ALBUM_PHOTO_IDENTIFIER = 'MobilePhotoNavigation'
PHOTO_IDENTIFIER = 'Foto'
DOMAIN_IDENTIFIER = 'tuenti.com'
SCREEN_SETTINGS = '1920-1080-1920-971-1-9.69'
DEFAULT_IMAGE_STORAGE_URL = '' #Set here the path to store your images
COOKIE_CONNECTION_IDENTIFIER = 'mid'

#*****************END OF CONSTANTS*****************


class TuentiRuby

  attr_accessor :agent

  def initialize(username, password)
    @agent = Mechanize.new
    @mid = nil
    @agent.get(TUENTI_BASE_URL + LOGIN_F)
    form = @agent.page.forms.first
    form.send(USERNAME_FIELD+"=", username)
    form.send(PASSWORD_FIELD+"=", password)
    form.submit
    unless @agent.page.uri.to_s.match(/failed=true/).nil?
      #TODO
      p "*"*100, "RAISE AN EXCEPTION"
    else
      set_screen_cookie #THIS COOKIE STABLISH A BIG SCREEN SIZE SO PHOTOS ARE VIEWED BIG
      set_mid
    end
  end

  def disconnect
    if connected?
      @agent.get(TUENTI_BASE_URL + LOGOUT_F)
      @mid = nil
    end
  end

  def store_images_from_page page, location
    image_links = get_tagged_photos_page_links page
    image_links.each do |image_link|
      @agent.get(TUENTI_BASE_URL + image_link.href)
      @agent.page.images.map { |image| store_mechanize_image(image,location) if !image.alt.nil? && image.alt.match(/#{Regexp.escape(PHOTO_IDENTIFIER)}/) }
    end
  end

  def store_images number_of_pages = 1, location
    number_of_pages.times do |index|
      store_images_from_page index, location
    end
  end

  def connected?
    !@mid.nil?
  end

  private

  def navigate_home
    @agent.get(TUENTI_BASE_URL + HOME_F) if connected?
  end

  def navigate_profile
    @agent.get(TUENTI_BASE_URL + PROFILE_F) if connected?
  end

  def navigate_tagged_photos_index
    @agent.get(TUENTI_BASE_URL + TAGGED_PHOTOS_INDEX_F) if connected?
  end

  def navigate_tagged_photos_page page
    @agent.get(TUENTI_BASE_URL + TAGGED_PHOTOS_PAGE_F + "#{PHOTO_PAGE_P}#{page}") if connected?
  end

  def get_tagged_photos_page_links page
    if connected?
      navigate_tagged_photos_page page
      @agent.page.links.select { |link| link.href.match(/#{Regexp.escape(ALBUM_PHOTO_IDENTIFIER)}/) }
    end
  end

  def store_mechanize_image mechanize_image, base_url = DEFAULT_IMAGE_STORAGE_URL
    url = mechanize_image.url
    name = mechanize_image.alt
    open("#{base_url}/#{name + '-' + rand(10000).to_s}.jpg", 'wb') do |file|
      file << open(url).read
    end
  end

  def set_screen_cookie
    cookie = Mechanize::Cookie.new('screen', SCREEN_SETTINGS, :domain => DOMAIN_IDENTIFIER, :for_domain => true)
    cookie.path = '/'
    cookie.secure = false
    @agent.cookie_jar.add!(cookie)
  end

  def set_mid
    @mid = nil
    @mid = @agent.cookies.select { |cookie| cookie.name == COOKIE_CONNECTION_IDENTIFIER }
    @mid = @mid[0] unless @mid.nil?
  end

end

