require 'mail'

# Notifier
class Notifier
  # Send email notification
  class Mail
    def send(message, config)
	    ::Mail.defaults do
	      delivery_method :smtp,
	      	address: config['address'],
	      	port: config['port'],
	      	user_name: config['user_name'],
	      	password: config['password'],
	      	enable_starttls_auto: config['enable_starttls_auto']
	    end

	    mail = ::Mail.new do
	    	to config['to']
	      from config['from']
	      subject 'Anonymization Problem'
	      body message
	    end

	    mail.deliver!
    end
  end
end
