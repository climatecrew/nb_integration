# frozen_string_literal: true

require 'roda'
require 'json'

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'dependencies'

class Server < Roda
  include AppConfiguration

  plugin :json
  plugin :json_parser
  plugin :all_verbs
  plugin :render
  plugin :public, gzip: true, default_mime: 'text/html'
  plugin :halt

  def logger
    env['rack.logger']
  end

  route do |r|
    # GET / request
    r.root do
      render('home', locals: { flash: {} })
    end

    # for testing serve client-app as a static HTML page from the public directory
    # conversely when installed in a nation we expect the admin to
    # embed a JavaScript snippet to pull the app into the page of their choice
    r.public

    # enable an administrator to install this app in their nation
    r.on 'install' do
      r.is do
        r.get do
          flash = r.params['flash'] || {}
          render('home', locals: { flash: flash })
        end

        r.post do
          slug = r.params['slug']
          if slug.nil? || slug.empty?
            r.redirect('/install?flash[error]=slug+is+missing')
          else
            nb_install_url = NBAppInstall.new(slug: slug).url
            r.redirect(nb_install_url)
          end
        end
      end
    end

    # process OAuth callbacks from NationBuilder, primarily to store access tokens
    r.on 'oauth' do
      r.is 'callback' do
        result = HandleOAuthCallback.new(r).call
        if result.errors.any?
          logger.warn("Request to /oauth/callback failed: Params: #{r.params}. Errors: #{result.message}")
        end
        r.redirect("/install?flash[#{result.flash_type}]=#{CGI.escape(result.message)}")
      end
    end

    r.on 'app' do
      render('app', locals: { populate_nb_values: r.params['logged_in'] == 'true' })
    end

    # load JavaScript app for embed on nation web page
    r.on 'embed' do
      slug = r.params['slug']
      callback = r.params['callback']

      response['Content-Type'] = 'application/javascript'
      render('contact_me', locals: { slug: slug, callback: callback })
    end

    # JSON interface to this app's functionality
    r.on 'api' do
      response['Allow'] = 'GET, HEAD, POST, PUT'
      response['Access-Control-Allow-Origin'] = '*'
      response['Access-Control-Allow-Headers'] = 'Accept, Accept-Language, Content-Language, Content-Type'

      r.options do
        {}
      end

      r.is 'health' do
        if r.params['raise_error'] == 'true'
          raise 'Health check endpoint: raise test error'
        else
          {
            data: {
              id: 1,
              type: 'health_check',
              attributes: { status: 'OK' }
            }
          }
        end
      end

      r.is 'contact_requests' do
        slug = r.params['slug']
        if slug.nil?
          r.halt(422, ErrorPresenter.new({ title: 'missing slug parameter' }).to_h)
        else
          account = Account.first(nb_slug: slug)
          r.halt(422, ErrorPresenter.new({ title: "nation slug '#{slug}' not recognized" }).to_h) if account.nil?
        end

        r.post do
          logger.info("Attempting to create contact_request for nation #{slug}")
          payload = r.params['data']
          code, body = HandleContactRequestCreation.new(logger, account, payload).call
          response.status = code
          body
        end
      end
    rescue StandardError => error
      logger.warn(error)
      response.status = 500
      ErrorPresenter.new({ title: 'An unexpected error has occurred.' }).to_h
    end
  end
end
