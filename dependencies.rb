$:.unshift File.expand_path(File.dirname(__FILE__), "helpers/")
# we need the environment variables set before requiring files
# that reference them at a file level
require "helpers/dotenv_loader"
DotenvLoader.new.load

require "helpers/constants"
require "helpers/app_configuration"
require "helpers/database_access.rb"
require "helpers/path_provider"
require "helpers/client"
require "helpers/error_presenter"
require "helpers/nb_app_install"
require "helpers/request_oauth_access_token"
require "helpers/handle_oauth_callback"
require "helpers/handle_event_creation"
require "helpers/handle_contact_request_creation"
require "helpers/match_nb_person"
require "helpers/create_survey_response"

$:.unshift File.expand_path(File.dirname(__FILE__), "models/")
require "models/account"
require "models/event"
require "models/contact_request"
