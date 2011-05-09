require 'httparty'
require 'strava-api/exceptions'

#classes used to hold results from Strava
require 'strava-api/hash_based_store'
require 'strava-api/club'
require 'strava-api/member'
require 'strava-api/bike'
require 'strava-api/ride'
require 'strava-api/segment'
require 'strava-api/effort'
require 'strava-api/settings'
require 'strava-api/user'
require 'strava-api/streams'

module StravaApi
  #everything now in independent class files
end

#classes to perform network access to Strava
require 'strava-api/authentication'
require 'strava-api/clubs'
require 'strava-api/rides'
require 'strava-api/segments'
require 'strava-api/efforts'
require 'strava-api/base'
