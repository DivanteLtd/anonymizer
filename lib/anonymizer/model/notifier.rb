# Notifier
class Notifier
  def send(message)
  	notifiers = CONFIG['notifier']

    notifiers.each do |notifier, config|
    	if config['enabled'] == true
	    	notifier = Object.const_get(
	        "Notifier::#{notifier.capitalize}"
	      ).new
	  		notifier.send(message, config)
	  	end
    end
  end
end
