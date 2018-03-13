module VacancyScraper::NorthEastSchools

  class ListManager
    ALTTEACHER = BASE_URL +
      '/search-results/?schooltype=82+96+87+84+80+74+81+73+85+76+72+75+91+83&jobrole=11&subject=&area='

    def initialize(root = ALTTEACHER)
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
      @next_page = paginate_next.present? ? URI.join(BASE_URL, paginate_next.attr('href')).to_s : nil
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
