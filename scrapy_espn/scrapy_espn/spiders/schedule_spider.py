import datetime
import scrapy

class ESPNSpider(scrapy.Spider):
	name = "espn"

	def __init__(self, team='', year='', *args, **kwargs):
		super(ESPNSpider, self).__init__(*args, **kwargs)
		self.start_urls = ['http://www.espn.com/mens-college-basketball/team/schedule/_/id/%(team)s/year/%(year)s' % {'team': team, 'year': year}]


	def parse(self, response):
		for team in response.css('table.tablehead tr'):
			if team.css('::attr(class)').extract()[0] not in ['colhead', 'stathead', 'evenrow', 'oddrow']:
		 		if len(team.css('td::text').extract()) == 2:
		 			result = team.css('td ul span::text').extract()[0].lower()
		 			if result == "w":
		 				record = str(int(team.css('td::text').extract()[1].split()[0].split('-')[0]) - 1) + "-" + team.css('td::text').extract()[1].split()[0].split('-')[1]
		 			else:
		 				record = team.css('td::text').extract()[1].split()[0].split('-')[0] + "-" + str(int(team.css('td::text').extract()[1].split()[0].split('-')[1]) - 1)
					yield {
						'record': record,
						'game_id': team.css('td ul a::attr(href)').extract()[2].split('/')[7],
						'day': datetime.datetime.strptime(team.css('td::text').extract()[0], '%a, %b %d').strftime('%A').lower(),
						'date': self.start_urls[0].split('/')[10] + "-" + datetime.datetime.strptime(team.css('td::text').extract()[0], '%a, %b %d').strftime('%m-%d'),
						'home_id': self.start_urls[0].split('/')[8],
						'opp_id': team.css('td ul a::attr(href)').extract()[0].split('/')[7],
						'score': team.css('td ul a::text').extract()[1].split(' ')[0],
						'result': team.css('td ul span::text').extract()[0].lower(),
						# 'post_conf_record': team.css('td::text').extract()[1].split()[1]
						}