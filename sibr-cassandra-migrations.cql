CREATE KEYSPACE IF NOT EXISTS blaseball WITH replication = { 'class': 'SimpleStrategy', 'replication_factor': 1 };

CREATE TABLE IF NOT EXISTS blaseball.leagues(
  id uuid PRIMARY KEY,
  name text,
  subleague_ids set<uuid>
);

CREATE TABLE IF NOT EXISTS blaseball.subleagues(
  id uuid PRIMARY KEY,
  name text,
);

CREATE TABLE IF NOT EXISTS blaseball.players(
  id uuid,
  name text,
  anticapitalism decimal,
  baseThirst decimal,
  buoyancy decimal,
  chasiness decimal,
  coldness decimal,
  continuation decimal,
  divinity decimal,
  groundFriction decimal,
  indulgence decimal,
  laserlikeness decimal,
  martyrdom decimal,
  moxie decimal,
  musclitude decimal,
  omniscience decimal,
  overpowerment decimal,
  patheticism decimal,
  ruthlessness decimal,
  shakespearianism decimal,
  suppression decimal,
  tenaciousness decimal,
  thwackability decimal,
  tragicness decimal,
  unthwackability decimal,
  watchfulness decimal,
  pressurization decimal,
  totalFingers smallInt,
  soul smallInt,
  deceased boolean,
  started_career_at timestamp,
  ended_career_at timestamp,
  active boolean,
  perceived_at timestamp,
  PRIMARY KEY (id, perceived_at)
);

CREATE TABLE IF NOT EXISTS blaseball.teams(
  id uuid,
  division_id uuid,
  fullName text,
  location text,
  mainColor text,
  nickname text,
  secondaryColor text,
  shorthand text,
  emoji text,
  slogan text,
  shameRuns smallInt,
  totalShames smallInt,
  totalShamings smallInt,
  seasonShames smallInt,
  seasonShamings smallInt,
  championships smallInt,
  active boolean,
  perceived_at timestamp,
  PRIMARY KEY (id, perceived_at)
);

CREATE TABLE IF NOT EXISTS blaseball.team_members(
  id uuid PRIMARY KEY,
  team_id uuid, 
  player_id uuid,
  started_at timestamp,
  ended_at timestamp,
);

CREATE TABLE IF NOT EXISTS blaseball.games(
  id uuid PRIMARY KEY,
  terminology_id uuid, # The ID of the terminology record (as provided in the raw message)
  rules_id uuid, # The ID of the rules record (as provided in the raw message)
  statsheet_id uuid, # The ID of the statsheet record (as provided in the raw message)
  away_score decimal, # The number of runs scored by the away team.
  home_score decimal, # The number of run scored by the home team.
  away_team_id uuid, # The ID of the away team record.
  home_team_id uuid, # The ID of the home team record.
  away_team_odds decimal, # The odds for the away team.
  home_team_odds decimal, # The odds for the home team.
  season smallInt, # The current season (1-indexed).
  is_postseason boolean, # Is this game in the postseason?
  day smallInt, # The day of the season (1-indexed).
  phase smallInt, # The phase of the season.
  innings smallInt, # The number of innings in the game.
  series_index smallInt, # What game in the series this is (1-indexed).
  series_length smallInt, # The number of games in the series.
  shame boolean, # Did this game end in shame?
  weather varchar(64), # The weather for this game.
  perceived_started_at timestamp, # The first time this game was seen by the client.
  perceived_ended_at timestamp # The time this game ended as seen by the client.
);

CREATE TYPE blaseball.event_base_runner(
  runner_id uuid, # The ID of the player that is on base.
  responsible_pitcher_id uuid, # The ID of the pitcher that is responsible for the runner.
  base_before_play tinyInt, # The base of the runner at the start of the play (see game_events). 0 - not on base at the start of the play.
  base_after_play tinyInt, # The base of the runner at the end of the play (see game_events). 0 - Not on base at the end of the play.
  was_base_stolen boolean, # Was the base successfully stolen?
  was_caught_stealing boolean, # Was the runner caught stealing?
  was_picked_off boolean, # Was the runner picked off
);

# Player event types:
# INCINERATION - The player was incinerated
# PEANUT_GOOD - The player had a yummy reaction!
# PEANUT_BAD - The player had an allergic reaction!

CREATE TYPE blaseball.player_event(
  player_id uuid, # The player that was affected by the event.
  event_type varchar(32), # The type of the event.
);

# Game event types:
# UNKNOWN - An event not currently tracked.
# NONE - No event occurred (should not use usually).
# OUT - A generic out.
# STRIKEOUT - The player struck out.
# STOLEN_BASE - A player stole a base.
# CAUGHT_STEALING - A player was caught stealing.
# PICKOFF - A player was picked off.
# WILD_PITCH - A wild pitch occurred.
# BALK - The pitcher balked (umps please add balks to blaseball).
# OTHER_ADVANCE - Some base advancement not otherwise covered here.
# WALK - The batter was walked.
# INTENTIONAL_WALK - The batter was intentionally walked.
# HIT_BY_PITCH - The batter was hit by pitch.
# FIELDERS_CHOICE - The play advanced on fielders choice.
# SINGLE - The batter hit a single.
# DOUBLE - The batter hit a double.
# TRIPLE - The batter hit a triple.
# HOME_RUN - The batter hit a home run.


# CHANGES BY no space BELOW THIS LINE

# Game Events from datause.txt - these would be for event_type. I'd recommend keeping the same numbers even if we don't use all of them, just for easy transfer between Retrosheet and Retroshleet data if wanted
# 0    Unknown event
# 1    No event
# 2    Generic out - If batter grounds or flies out, use this
# 3    Strikeout
# 4    Stolen base - would need to mark current play as complete, then start a new play line with the updated at-bat state and append a '.' to pitch_list, then proceed with the rest of the at-bat. See lines 13 & 14 on MIA201904210.csv where the player on 1st stole second
# 5    Defensive indifference - In reference to a "stolen" base (the base would not count as stolen in the player's stats), not implemented in blaseball
# 6    Caught stealing - same process as Stolen Base
# 7    Pickoff error - Probably not implemented
# 8    Pickoff - Probably not implemented
# 9    Wild pitch - Probably not implemented
# 10   Passed ball - Probably not implemented
# 11   Balk - Probably not implemented
# 12   Other advance - Only possible use I can see is if we have a data error and don't know how a player advanced bases
# 13   Foul error - Probably not implemented
# 14   Walk
# 15   Intentional walk - Probably not implemented
# 16   Hit by pitch - Probably not implemented
# 17   Interference - Probably not implemented
# 18   Error - Probably not implemented
# 19   Fielder's choice
# 20   Single
# 21   Double
# 22   Triple
# 23   Home run
# 24   Missing play - Used if we have missing data
		  
# Weather Events?
# Possible to-do, list of weather events if they interfere in some way play? Not sure if weather does anything, haven't followed the research

# Play Events for event_text. Have cut down to only what is relevant to blaseball, since fielding and trajectory isn't tracked. This might get a bit weird...
# Batter Events
# O - Ball fielded for an out. Not used in Retrosheet, but used here because we don't have fielding data. Will be followed by one of the '/' results below for more details.
# /G - Ground ball (currently will only know on an out)
# /F - Fly ball (currently will only know on an out)
# /SF - Sacrifice Fly
# /GDP## - Grounded into double play, #'s represent which baserunners are out (eg if runners on 1st and 2nd are out but batter reaches base, GDP12. If runner on 1st and batter are out, GDP1B, or we could use GDP10 if preferred)
# /GTP - Grounded into triple play (not sure if implemented, hasn't been observed yet)
# /FDP#B (or FDP#0) - Fly into double play, # would be baserunner aside from batter who is out (not sure if implemented)
# /FTP - Fly into triple play (double not sure if implemented)
# /FC# - Fielder's Choice, # is the baserunner who was put out. Batter advancement is implied. DOES NOT COUNT AS A HIT.
# S - Single
# D - Double
# T - Triple
# H - Homerun
# DGR - Ground rule double (don't think this is implemented? But might be)
# HP - hit by pitch (Probably not implemented)
# K - Strikeout. Technically more events can follow, but I don't think that's implemented
# W - Walk. Technically more events can follow, but I don't think that's implemented
# Baserunner advancement - in addition to the above codes, any baserunner advancement on the play is signified by '.' followed by a breakdown of the advancement. eg O/G.1-2;3-H represents a ground out during which the runner on 1st advances to 2nd, and the one on 3rd reaches home. Batter advancement (hopefully) doesn't need to be specifically stated
#
# Baserunner Events
# BK - Balk, probably not implemented
# CS% - Baserunner caught stealing % base, 2 3 or H
# PB - Passed Ball leading to advancement, don't think it's implemented
# WP - Wild Pitch, similar to PB but pitcher error rather than catcher, also not implemented
# PO% - Baserunner picked off where % is the base they started on, probably not implemented
# SB% - Stolen base, % is base stolen, 2 3 or H

#Changed order to match Retrosheet, and first number in comment if present is the related BEVENT field number in Retrosheet, both for easy of reference back to https://www.retrosheet.org/datause.txt if needed
CREATE TABLE IF NOT EXISTS blaseball.game_events(
  perceived_at timestamp, # The time at which the first message that is included in this event was observed by the client.
  game_id uuid, # 0 The ID of the game record. Might be good to have a non-UUID id as well, for ease of reference? Following Retrosheet style, could be HOM###$$$ (HOM = abbreviated home team, ### = season, $$$ = game number, WIN)
  away_team_id uuid, # 1 The ID of the away team record. Technically duplicated information from games table, we could probably leave out. Main argument for keeping is ease of reference with the Home Team name in Retrosheet field 0. Could even combine HOMVIS###$$$
  inning tinyInt, # 2 The inning in which the event took place (1-indexed).
  top_of_inning boolean, # Did this event take place in the top or the bottom of the inning?
  batter_team_id uuid, # 3 The ID of the batter's team record.
  home_strike_count smallInt, # The number of strikes required to strike out a batter on the home team.
  away_strike_count smallInt, # The number of strikes required to strike out a batter on the away team.
  outs_before_play tinyInt, # 4 The number of outs before this event took place.
  total_balls smallInt, # 5 The total number of balls that occurred in the play.
  total_strikes smallInt, # 6 The total number of strikes that occurred in the play.
  total_fouls smallInt, # The total number of foul balls that occurred in the play (not currently trackable).
  pitches list<varchar(1)>, # 7 The pitches in this play. See Retrosheet for symbology.
  away_score decimal, # 8 The score of the away team.
  home_score decimal, # 9 The score of the home team.
  batter_id uuid, # 10 The ID of the batter's player record.
  res_batter_id uuid, # 12 The ID of the reserve/replacement batter's player record, if the original batter is incinerated during the play
  pitcher_id uuid, # 14 The ID of the pitcher's player record.
  pitcher_team_id uuid, # The ID of the pitcher's team record.
  res_pitcher_id uuid, # 16 The ID of the reserve/replacement pitcher's player record, if the original batter is incinerated during the play
  base_runners list<FROZEN<blaseball.event_base_runner>>, # 26-28 The base runners at the start and end of the play (see event_base_runner).
  event_text text, # 29 Different from event_type, provides additional info on play. 
  is_leadoff boolean, # 30 Is this batter leading off the inning?
  is_pinch_hit boolean, # 31 Is this batter pinch hitting? (Post-incineration)
  lineup_position smallInt, # 33 not sure if we have access to this - can we keep track of batting order as batters come to the plate, then cycle through once we reach 9?
  event_type text, # 34 The type of event.
  is_last_event_for_plate_appearance boolean, # 35 Is this the last event in the plate appearance? (Almost always true, false if a base is stolen for example. Play will continue on a new line.)
  at_bat_flag boolean # 36 Whether the batter has actually completed the at-bat. (Almost always true, will ONLY be false if a baserunner makes third out as a pickoff or caught stealing in which case it is not charged)
  hit_value tinyInt # 37 Single digit to represent batter's hit performance during the play, from 0 (no hit) to 4 (home run). Fielder's Choice counts as 0
  is_sacrifice_hit boolean, # 38 Was this a sacrifice hit?
  is_sacrifice_fly boolean, # 39 Was this a sacrifice fly?
  outs_on_play tinyInt, # 40 The number of outs that occurred from this play.
  is_double_play boolean, # 41 Is this a double play?
  is_triple_play boolean, # 42 Is this a triple play?
  runs_batted_in tinyInt, # 43 The number of runs batted in.
  is_wild_pitch boolean, # 44 Was this event a wild pitch? (Not implemented)
  is_passed_ball boolean, # 45 Was this event a passed ball? (Not implemented)
  fielded_by_id uuid, # 46 If fielded for an out, who was the player credited?
  batted_ball_type text, # 47 F - fly ball, G - ground ball, L - line drive, P - pop-up. Not sure if we can track this. Only know specifically if F or G on an out, but I'd still like it recorded to see what I can do with it
  is_bunt boolean, # 48 Was this play a bunt? (Not implemented)
  errors_on_play tinyInt, # 51 The number of errors that occurred on the play. (not implemented)
  batter_dest tinyInt, # 58 Batter Destination, ie what base they ended up on at end of play. Technically not a duplicate of hit value, as Fielder's Choice would be non-zero in this case
  runner1_dest tinyInt, # 59 Baserunner on 1st's final base location on the play, 1-4
  runner2_dest tinyInt, # 60 Baserunner on 2nd's final base location on the play, 2-4
  runner3_dest tinyInt, # 61 Baserunner on 3rd's final base location on the play, 3-4
  runner1_sb_flag boolean, # 66 Whether the runner on 1st successfully steals (Play continues on new line)
  runner2_sb_flag boolean, # 67 Whether the runner on 2nd successfully steals (Play continues on new line)
  runner3_sb_flag boolean, # 68 Whether the runner on 3rd successfully steals (Play continues on new line)
  runner1_cs_flag boolean, # 69 Whether the runner on 1st is caught stealing (Play continues on new line)
  runner2_cs_flag boolean, # 70 Whether the runner on 2nd is caught stealing (Play continues on new line)
  runner3_cs_flag boolean, # 71 Whether the runner on 3rd is caught stealing (Play continues on new line)
  pitcher1_id uuid, # 75 Pitcher responsible for runner on 1st (only relevant if starting pitcher incinerated)
  pitcher2_id uuid, # 76 Pitcher responsible for runner on 2nd (only relevant if starting pitcher incinerated)
  pitcher3_id uuid, # 77 Pitcher responsible for runner on 3rd (only relevant if starting pitcher incinerated)
  pinch_runner_1 uuid, # 80 Pinch runner for runner on 1st, if the original runner is incinerated
  pinch_runner_2 uuid, # 81 Pinch runner for runner on 2nd, if the original runner is incinerated
  pinch_runner_3 uuid, # 82 Pinch runner for runner on 3rd, if the original runner is incinerated
  removed_runner_1 uuid, # 83 Runner on 1st replaced (incinerated) by a pinch runner
  removed_runner_2 uuid, # 84 Runner on 2nd replaced (incinerated) by a pinch runner
  removed_runner_3 uuid, # 85 Runner on 3rd replaced (incinerated) by a pinch runner
  event_index int, # 96 The position of this event relative to the other events in the game (0-indexed).
  
  batter_count tinyInt, # The total number of batters to take the plate in this game. Clarification? Is this just a running tally?
  batter_base_after_play tinyInt, # The number of batters on base after the play.
  is_last_game_event boolean, # Is this the last event in the game?
  player_events list<FROZEN<blaseball.player_event>>, # The player events that occurred in the play (incinerations, etc).
  event_text list<text>, # The message text descriptions that contributed to this event.
  additional_context text, # Free space for your own comments.
  PRIMARY KEY (game_id, event_index)
);
