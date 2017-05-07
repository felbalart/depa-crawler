require 'active_support'
require "active_support/core_ext"
require 'action_mailer'

module DepaCrawler

  class Notifier < ActionMailer::Base
    default from: ENV.fetch('REPORTS_SENDER_EMAIL')


    ERROR_RECIPIENT = ENV.fetch('ERROR_RECIPIENT')
    NEW_IDS_RECIPIENT = ENV.fetch('NEW_IDS_RECIPIENT')
    RESULT_RECIPIENT = ENV.fetch('RESULT_RECIPIENT')
    SUBJECT_BASE = "[PI-Crawler]"

    def send_errors(errors)
      to = ERROR_RECIPIENT
      subject = "#{SUBJECT_BASE} Se reportaron errores #{Date.today}"
      body = %Q(
        <b>Fecha: #{Time.new}<b/>\n\n
        <b>Errores<b/>
        #{errors unless errors.empty?}
        ).gsub("\n", '<br>')

      puts body
      send(to, subject, body)
    end

    def send_new_ids(new_ids)
      to = NEW_IDS_RECIPIENT
      subject = "#{SUBJECT_BASE} Tenemos nuevos departamentos! #{Date.today}"

      urls = new_ids.map { |id| "#{Program::DOMAIN_URL}/#{id}"}

      body = %Q(
        <b>Fecha:</b> #{Time.new}\n
        <b>Se consignaron #{new_ids.count} nuevas entradas:</b>\n
        #{urls.join("\n")}
      ).gsub("\n", '<br>')

      puts body
      send(to, subject, body)
    end

    def send_result(new_ids, errors, last_page)
      to = RESULT_RECIPIENT
      subject = "#{SUBJECT_BASE} Reporte de resultados de crawl #{Date.today}"
      urls = new_ids.map { |id| "#{Program::DOMAIN_URL}/#{id}"}

      body = %Q(
        <b>Fecha:</b> #{Time.new}\n
        <b>Páginas Crawleadas:</b> #{last_page}\n
        <b>#{new_ids.count} Nuevas Entradas</b>\n
        #{urls.join("\n")}\n\n
        <b>#{errors.count} Errores<b/>
        #{errors unless errors.empty?}
      ).gsub("\n", '<br>')

      puts body
      send(to, subject, body)
    end

    def send(to, subject, body)
      mail to: to, subject: subject do |format|
        format.html { render inline: body }
      end
    end

    def self.gmail_setup
      ActionMailer::Base.raise_delivery_errors = true
      ActionMailer::Base.delivery_method = :smtp
      ActionMailer::Base.smtp_settings = {
        address:              'smtp.gmail.com',
        port:                 587,
        domain:               'gmail.com',
        user_name:            ENV.fetch('REPORTS_SENDER_EMAIL'),
        password:             ENV.fetch('REPORTS_SENDER_PASSWORD'),
        authentication:       :plain,
        enable_starttls_auto: true
    }
    end
  end
end
