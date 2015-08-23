# -*- coding: utf-8 -*-
require "mechanize"

class Place < ActiveRecord::Base

  validates :name, presence: true

  geocoded_by :address
  after_validation :geocode# , if: ->(obj){ obj.address.present? and obj.address_changed? }

  scope :search_with_keyword, ->(keyword) { where(["name LIKE ? OR address LIKE ?", "%#{keyword}%", "%#{keyword}%"]) }
  scope :search_with_category, ->(category) { where(["category = ?", category]) }

  paginates_per 100

  def self.search(domain = "http://www.p-shouhinken.com/", path = "fukuoka/shop/", prefecture = "福岡県福岡市")
    agent = Mechanize.new

    begin
      p domain + path

      page = agent.get(domain + path)
      table = page.search("table.list")
      table.search("tr").each do |tr|
        place = Place.new
        tds = tr.search("td")
        tds.each_with_index do |td, i|
          unless td.text.blank?
            case i
            when 0
              place.name = td.text
            when 1
              place.category = td.text
            when 2
              place.address = prefecture + td.text.sub(/〒[0-9]{3}-[0-9]{4} /, "")
            when 3
              place.tel = td.text
            when 4
              place.url = td.at("a").attr("href")
            end
          end
        end

        p place.name

        unless Place.where(["name = ? AND address = ? AND tel = ?", place.name, place.address, place.tel]).first
          place.save

          p "SAVED"
        end
      end

      if next_page = page.search("span.next").first
        path = next_page.at("a").attr("href")
        Place.search(domain, path)
      end
    rescue TimeoutError
      warn "TimeoutError"
    rescue Mechanize::ResponseCodeError => ex
      case ex.response_code
      when "404" then
        warn "404: #{ex.page.uri} does not exist"
      when "503" then
        # follows RFC2616
        if @retryuri != "#{domain}#{path}" && sec = ex.page.header["Retry-After"]
          warn "503: will retry #{ex.page.uri} in #{sec}seconds"
          @retryuri = ex.page.uri
          sleep sec.to_i
          retry
        end
      when /\A5/ then
        warn "#{ex.response_code}: internal error"
      else
        warn ex.message
      end
    end
  end
end
