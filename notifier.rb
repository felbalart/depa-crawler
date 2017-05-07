require 'active_support'
require "active_support/core_ext"
require 'action_mailer'

module DepaCrawler

  class Notifier < ActionMailer::Base
    default from: ENV.fetch('REPORTS_SENDER_EMAIL')


    ERROR_RECIPIENT = ENV.fetch('ERROR_RECIPIENT')
    NEW_IDS_RECIPIENT = ENV.fetch('NEW_IDS_RECIPIENT')
    RESULT_RECIPIENT = ENV.fetch('RESULT_RECIPIENT')
    SUBJECT_BASE = "[DepaCrawler_v2]"
    GP_LINK_PATH = ENV.fetch('GP_LINK_PATH')
    GITHUB_MULTITAB_URL = ENV.fetch('GITHUB_MULTITAB_URL')

    def send_errors(errors)
      to = ERROR_RECIPIENT
      subject = "#{SUBJECT_BASE} Se reportaron errores #{Time.new.strftime('%b%e - %p')}"
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
      subject = "#{SUBJECT_BASE} Novedades #{Time.new.strftime('%b%e - %p')}"

      urls = new_ids.map { |id| build_url id }
      multitab_url = build_multitab_url(new_ids)

      body = %Q(
        <b>Fecha:</b> #{Time.new.strftime('%b %e %p')}
        <h4>Se consignaron #{new_ids.count} nuevas entradas</h4>
        #{"<a href=\"" + multitab_url + "\">Link Multitab</a> *Requiere deshabilitar bloqueo popups" if new_ids.count > 1}\n
        Links Individuales:
        #{urls.join("\n")}
      ).gsub("\n", '<br>')

      puts body
      send(to, subject, body)
    end

    def send_result(new_ids, errors, last_page)
      to = RESULT_RECIPIENT
      subject = "#{SUBJECT_BASE} Reporte de resultados de crawl #{Time.new.strftime('%b%e - %p')}"
      urls = new_ids.map { |id| build_url id }

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

    def build_url(id)
      site = id[0..1]
      n_id = id[2..-1]
      if site == 'PI'
        "#{PiCrawler::PI_HOST}/#{n_id}"
      elsif site == 'GP'
        "#{GpCrawler::GP_HOST}#{GP_LINK_PATH}/#{n_id}"
      end
    end

    def build_multitab_url(ids)
      grouped_ids = ids.group_by{ |w| w[0..1] }
      params = grouped_ids.map do |site, ids|
        site.downcase + '=' + ids.map { |sids| sids[2..-1] }.join(',')
      end.join('&')
      GITHUB_MULTITAB_URL + '?' + params
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
