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

		#tv network if available
		try:
			tv_coverage = response.css('div.game-network::text').extract()[0].split()[1].lower()
		except IndexError:
			tv_coverage = ""

		#attendance if availalbe
		try:
			attendance = response.css('div.game-info-note.capacity::text').extract()[0].split()[1].replace(',','')
		except IndexError:
			attendance = ""

		#capacity if available
		try:
			capacity = response.css('div.game-info-note.capacity::text').extract()[1].split()[1].replace(',','')
		except IndexError:
			capacity = ""

		#home team conference record if available
		try:
			home_conf_record = response.css('div.team-info div.record span.inner-record::text').extract()[1].split()[1]
		except IndexError:
			home_conf_record = "0-0"

		#away team conference record if available
		try:
			away_conf_record = response.css('div.team-info div.record span.inner-record::text').extract()[0].split()[1]
		except IndexError:
			away_conf_record = "0-0"


		yield {
			'game_id': self.start_urls[0].split('/')[4].split('=')[1],
			# 'home_name':response.css('div.team-info a.team-name span.long-name::text').extract()[1].replace(" ", "_").lower(),
			'home_id': response.css('div.team-info a::attr(href)').extract()[1].split('/')[5],
			'home_rank': home_rank,
			'home_record': response.css('div.team-info div.record::text').extract()[1],
			#'home_conf_record': home_conf_record,
			#'away_name':response.css('div.team-info a.team-name span.long-name::text').extract()[0].replace(" ", "_").lower(),
			'away_id': response.css('div.team-info a::attr(href)').extract()[0].split('/')[5],
			'away_rank': away_rank,
			'away_record': response.css('div.team-info div.record::text').extract()[0],
			#'away_conf_record': away_conf_record,
			'date': response.css('div.game-date-time span::attr(data-date)').extract()[0].split('T')[0],
			'time': response.css('div.game-date-time span::attr(data-date)').extract()[0].split('T')[1][:-1],
			# 'arena': arena,
			'tv_coverage': tv_coverage,
			'line': line,
			'attendance': attendance,
			'capacity': capacity
			#'refs': response.css('div.game-info-note span::text').extract()
		}