require "gds_api/helpers"

class EmailTopicChecker
  include GdsApi::Helpers

  # The govuk-delivery mongo db stores absolute paths for feed_urls in its
  # db.topics collection. This environment variable lets us swap out the feed
  # urls generated by Whitehall to match the origin host.
  ORIGIN = URI.parse(ENV.fetch("ORIGIN", "https://www.gov.uk"))

  def self.check(content_id)
    new(content_id).check
  end

  attr_accessor :document

  def initialize(content_id)
    self.document = Document.find_by!(content_id: content_id)
  end

  def check
    edition = document.published_edition
    raise "No published edition" unless edition

    feed_urls = feed_urls(edition)
    govuk_topics = feed_urls.map { |url| govuk_delivery_topic(url) }.compact.sort
    links_hashes = feed_urls.map { |url| links_hash(url) }
    email_topics = links_hashes.map { |hash| email_alert_api_topic(hash) }.compact.sort

    puts "\ngovuk-delivery topics:"
    puts govuk_topics

    puts "\nemail-alert-api topics:"
    puts email_topics

    additional_govuk = (govuk_topics - email_topics).presence || "None"
    puts "\nadditional govuk-delivery topics:"
    puts additional_govuk

    additional_email = (email_topics - govuk_topics).presence || "None"
    puts "\nadditional email-alert-api topics:"
    puts additional_email
  end

  def govuk_delivery_topic(feed_url)
    feed_uri = URI.parse(feed_url)
    feed_uri.scheme = ORIGIN.scheme
    feed_uri.host = ORIGIN.host

    signup_url = Whitehall.govuk_delivery_client.signup_url(feed_uri.to_s)
    signup_uri = URI.parse(signup_url)
    signup_params = CGI.parse(signup_uri.query)

    signup_params.fetch("topic_id").first
  rescue GdsApi::HTTPNotFound
    nil
  end

  def email_alert_api_topic(links_hash)
    response = email_alert_api.find_subscriber_list(links_hash)
    response["subscriber_list"]["gov_delivery_id"]
  rescue GdsApi::HTTPNotFound
    nil
  end

  def feed_urls(edition)
    generator = Whitehall::GovUkDelivery::SubscriptionUrlGenerator.new(edition)
    generator.subscription_urls
  end

  def links_hash(feed_url)
    UrlToSubscriberListCriteria.new(feed_url).convert
  end
end
