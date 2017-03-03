import scrapy

class TeamSpider(scrapy.Spider):
	name = "team"
	start_urls = [
		'http://www.espn.com/mens-college-basketball/teams',
	]

	def parse(self, response):
		for conf in response.css('ul'):
			for team in conf.css('li'):
				yield {
					'team':team.css('h5 a::text').extract(),
					'id':team.css('h5 a::attr(href)').extract()[0].split('/')[7]
				}