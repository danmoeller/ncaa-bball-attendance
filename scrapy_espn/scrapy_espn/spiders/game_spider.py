import scrapy
from __future__ import division

class GameSpider(scrapy.Spider):
	name = "game"

	def __init__(self, game='', *args, **kwargs):
		super(GameSpider, self).__init__(*args, **kwargs)
		self.start_urls = ['http://www.espn.com/mens-college-basketball/game?gameId=%(game)s' % {'game': game}]

	def parse(self, response):

		# home & away score
		home_score = response.css('div.score::text').extract()[1]
		away_score = response.css('div.score::text').extract()[0]

		# record of home & away after game
		home_wins = int(response.css('div.team-info div.record::text').extract()[1].split("-")[0])
		home_losses = int(response.css('div.team-info div.record::text').extract()[1].split("-")[1])
		away_wins = int(response.css('div.team-info div.record::text').extract()[0].split("-")[0])
		away_losses = int(response.css('div.team-info div.record::text').extract()[0].split("-")[1])

		# convert to record before game for home & away
		if home_score > away_score:
			home_wins -= 1
			away_losses -= 1
		else:
			home_losses -= 1
			away_wins -= 1

		# win percentage of home team
		if home_wins == 0:
			home_win_pct = 0
		else:
			if home_losses == 0:
				home_win_pct = 1
			else:
				home_win_pct = home_wins / home_losses

		# win percentage of home team
		if away_wins == 0:
			away_win_pct = 0
		else:
			if away_losses == 0:
				away_win_pct = 1
			else:
				away_win_pct = away_wins / away_losses

		# home opener check
		if home_wins + home_losses == 0:
			first_game = "true"
		else:
			first_game = "false"


		# home AP rank else 0
		try:
			home_rank = response.css('div.team-info span.rank::text').extract()[1]
		except IndexError:
			home_rank = 0
		
		# away AP rank else 0
		try:
			away_rank = response.css('div.team-info span.rank::text').extract()[0]
		except IndexError:
			away_rank = 0

		# home team conference record
		# try:
		# 	home_conf_record = response.css('div.team-info div.record span.inner-record::text').extract()[1].split()[1]
		# except IndexError:
		# 	home_conf_record = "0-0"

		# away team conference record
		# try:
		# 	away_conf_record = response.css('div.team-info div.record span.inner-record::text').extract()[0].split()[1]
		# except IndexError:
		# 	away_conf_record = "0-0"

		# arena name 
		# try:
		# 	arena = response.css('figcaption div::text').extract()[0].strip().replace(" ", "_").lower()
		# except IndexError:
		# 	try:
		# 		arena = response.css('div.location-details span::text').extract()[0].replace(" ", "_").lower()
		# 	except IndexError:
		# 		arena = ""

		#tv network showing game
		try:
			tv_coverage = response.css('div.game-network::text').extract()[0].split()[1].lower()
		except IndexError:
			tv_coverage = ""

		# betting line in terms of home team
		try:
			line = response.css('div.odds-details ul li::text').extract()[0].split()[2][1:]
			if response.css('div.team-info a.team-name span.abbrev::text').extract()[1] == response.css('div.odds-details ul li::text').extract()[0].split()[1]:
				line = -float(line)
			else:
				line = line
		except IndexError:
			line = 0

		#attendance
		try:
			attendance = response.css('div.game-info-note.capacity::text').extract()[0].split()[1].replace(',','')
		except IndexError:
			attendance = ""

		#capacity of arena
		try:
			capacity = response.css('div.game-info-note.capacity::text').extract()[1].split()[1].replace(',','')
		except IndexError:
			capacity = ""
		
		yield {
			'game_id': self.start_urls[0].split('/')[4].split('=')[1],
			# 'home_name':response.css('div.team-info a.team-name span.long-name::text').extract()[1].replace(" ", "_").lower(),
			'home_id': response.css('div.team-info a::attr(href)').extract()[1].split('/')[5],
			'home_rank': home_rank,
			'home_wins': home_wins,
			'home_losses': home_losses,
			'home_win_pct': home_win_pct,
			'home_score': home_score,
			'first_game': first_game,
			# 'home_record': response.css('div.team-info div.record::text').extract()[1],
			#'home_conf_record': home_conf_record,
			#'away_name':response.css('div.team-info a.team-name span.long-name::text').extract()[0].replace(" ", "_").lower(),
			'away_id': response.css('div.team-info a::attr(href)').extract()[0].split('/')[5],
			'away_rank': away_rank,
			'away_wins': away_wins,
			'away_losses': away_losses,
			'away_win_pct': away_win_pct,
			'away_score': away_score,
			# 'away_record': response.css('div.team-info div.record::text').extract()[0],
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