import scrapy

class GameSpider(scrapy.Spider):
	name = "game"

	def __init__(self, game='', *args, **kwargs):
		super(GameSpider, self).__init__(*args, **kwargs)
		self.start_urls = ['http://www.espn.com/mens-college-basketball/game?gameId=%(game)s' % {'game': game}]

	def parse(self, response):

		# line is in terms of the home game
		try:
			line = response.css('div.odds-details ul li::text').extract()[0].split()[2][1:]
			if response.css('div.team-info a.team-name span.abbrev::text').extract()[1] == response.css('div.odds-details ul li::text').extract()[0].split()[1]:
				line = -float(line)
			else:
				line = line
		except IndexError:
			line = 0

		try:
			arena = response.css('figcaption div::text').extract()[0].strip().replace(" ", "_").lower()
		except IndexError:
			arena = response.css('div.location-details span::text').extract()[0].replace(" ", "_").lower()

		# AP rank or else 0
		try:
			home_rank = response.css('div.team-info span.rank::text').extract()[1]
		except IndexError:
			home_rank = 0
		
		# AP rank or else 0
		try:
			away_rank = response.css('div.team-info span.rank::text').extract()[0]
		except IndexError:
			away_rank = 0

		try:
			tv_coverage = response.css('div.game-network::text').extract()[0].split()[1].lower()
		except IndexError:
			tv_coverage = ""


		yield {
			'game_id': self.start_urls[0].split('/')[4].split('=')[1],
			# 'home_name':response.css('div.team-info a.team-name span.long-name::text').extract()[1].replace(" ", "_").lower(),
			'home_id': response.css('div.team-info a::attr(href)').extract()[1].split('/')[5],
			'home_rank': home_rank,
			'home_record': response.css('div.team-info div.record::text').extract()[1],
			'home_conf_record': response.css('div.team-info div.record span.inner-record::text').extract()[1].split()[1],
			#'away_name':response.css('div.team-info a.team-name span.long-name::text').extract()[0].replace(" ", "_").lower(),
			'away_id': response.css('div.team-info a::attr(href)').extract()[0].split('/')[5],
			'away_rank': away_rank,
			'away_record': response.css('div.team-info div.record::text').extract()[0],
			'away_conf_record': response.css('div.team-info div.record span.inner-record::text').extract()[0].split()[1],
			'date': response.css('div.game-date-time span::attr(data-date)').extract()[0].split('T')[0],
			'time': response.css('div.game-date-time span::attr(data-date)').extract()[0].split('T')[1][:-1],
			'arena': arena,
			'tv_coverage': tv_coverage,
			'line': line,
			'attendance': response.css('div.game-info-note.capacity::text').extract()[0].split()[1].replace(',',''),
			'capacity': response.css('div.game-info-note.capacity::text').extract()[1].split()[1].replace(',','')
			#'refs': response.css('div.game-info-note span::text').extract()
		}