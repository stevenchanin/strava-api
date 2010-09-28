require 'httparty'
require 'strava/exceptions'

#classes used to hold results from Strava
require 'strava/hash_based_store'
require 'strava/club'
require 'strava/member'
require 'strava/bike'
require 'strava/ride'
require 'strava/segment'
require 'strava/effort'

module Strava
  #everything now in independent class files
end

#classes to perform network access to Strava
require 'strava/clubs'
require 'strava/rides'
require 'strava/segments'
require 'strava/efforts'
require 'strava/base'
