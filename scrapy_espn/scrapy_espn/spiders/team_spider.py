import scrapy

class TeamSpider(scrapy.Spider):
	name = "team"
	start_urls = [
		'http://www.espn.com/mens-college-basketball/teams',
	]

	def parse(self, response):
		for col in response.css('div.span-2'):
			for conf in col.css('div.mod-container'):
				conference = conf.css('h4::text').extract()[0]
				for team in conf.css('li'):
					yield {
						'id':team.css('h5 a::attr(href)').extract()[0].split('/')[7],
						'school':team.css('h5 a::text').extract()[0].replace(" ", "_").lower(),
						'url_name':team.css('h5 a::attr(href)').extract()[0].split('/')[8],
						'conf':conference.replace(" ", "_").lower()
					}
