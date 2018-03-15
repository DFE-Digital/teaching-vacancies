module VacancyScraper::NorthEastSchools
  class ListManager
    SEARCH_PATH = "#{ROOT_URL}//search-results/?schooltype&" \
                  'jobrole=8%2012%209%2088%2013%2010%2021%2011&subject&area'.freeze

    def initialize(root = SEARCH_PATH)
      @root = root
      @page = Nokogiri::HTML(open(root))
    end

    def search_results
      search_box.xpath('//div[contains(@class, "media")]')
                .xpath('//a[contains(@class,"media-content")]').map do |result|
        result.attr('href')
      end
    end

    def next_page
      paginate_next = pagination.xpath('//a[i[contains(@class, "icon-angle-right")]]')
      @next_page = paginate_next.present? ? URI.join(ROOT_URL, paginate_next.attr('href')).to_s : nil
    end

    private

    def search_box
      @search_box = @page.xpath('//div[contains(@class, "featured-vacancies")]')
    end

    def pagination
      @pagination = search_box.xpath('//div[contains(@class, "pagination")]')
    end
  end
end
