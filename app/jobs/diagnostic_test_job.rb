class DiagnosticTestJob < ActiveJob::Base
  include SuckerPunch::Job

  def perform(answers, program, user, ruta)

  	puts "Aquí empiezan las respuestas"
  	quanswers = []
  	answers.each do |answer| 
  		quanswers << {question: Question.find(answer.question_id).question_text, answer: answer.answer_text}
  	end

  	quanswers.each do |hash|
  		case hash[:question]
  		when /Cómo definirías la situación actual de tu proyecto/
  			hash[:score] = 0
  		when /selecciona el que define más el mercado al que está dirigida tu idea de negocio/
  			##### Set points #####
   			case hash[:answer]
  			when /Grupos de personas o empresas que tienen la misma necesidad/
  				hash[:score] = "Excelente"
  			when /Un grupo de personas o empresas muy especializado/
  				hash[:score] = "Excelente"
  			when /Público en general/
				hash[:score] = "Excelente"
  			when /Grupos de personas o empresas con características diferentes/
				hash[:score] = "Excelente"
  			when /Todas las anteriores/
				hash[:score] = "Bueno"
  			when /Ninguna de las anteriores/
				hash[:score] = "Regular"
  			when /Aún no lo sé/
  				hash[:score] = "Malo"	
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "¡Excelente! identificaste el mercado al que está dirigido  tu idea de negocio. Determinar las características de tu cliente resultará más fácil. Aún así, siempre se puede saber más de nuestro posible cliente...Hablamos de investigar más allá: ¿Cómo se comporta? ¿En dónde vive? ¿A qué se dedica? ¿Quieres saber más? ¡Te ayudamos!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Conocer los diferentes tipos de mercado que existen ayuda a que sea menos complicado elegir al que se dirige tu idea de negocio. ¡No te preocupes! ¡Nosotros te ayudaremos a mejorarlo!"
  			else
  				hash[:message] = "Conocer y saber identificar el tipo de mercado al que va dirigido tu proyecto es de los aspectos principales a tomar en cuenta cuando vas iniciando. Es algo complicado, si, pero para eso estamos. Te ayudaremos a identificar el mercado de tus posibles clientes. "
  			end
  		when /Qué datos ya conoces de tu principal cliente/
  			##### Set points #####
  			hash[:score] = 0
			if hash[:answer].include?("Hábitos")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Comportamiento")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Personalidad")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("ingresos")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("socioeconómico")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("estudios")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Ubicación geográfica")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Género")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Edad")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Ocupación")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("ventas anuales")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Tamaño")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("Giro o sector")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("iniciativa a la que pertence")
				hash[:score] = hash[:score] + 1
			end
			if hash[:answer].include?("ninguno de los aspectos")
				hash[:score] = hash[:score] + 0
			end
			if hash[:score] >= 7
				hash[:score] = "Excelente"
			elsif (hash[:score] < 7 && hash[:score] >= 3)
				hash[:score] = "Bueno"
			elsif (hash[:score] < 3 && hash[:score] >= 1)
				hash[:score] = "Regular"
			else	
				hash[:score] = "Malo"
			end
			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "Al parecer ya conoces algunos datos que describen a tu posible cliente, con ello podrás facilitar la búsqueda de información para ir construyendo tu proyecto. Aún así, nosotros podemos ayudarte a que conozcas más datos...¡A mayor presición, mayor efectividad!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Entendemos que no es sencillo identificar perfectamente al cliente, pero no te preocupes, puedes ampliar estos y otros aspectos para reforzar el perfil de tu cliente ideal."
  			else
  				hash[:message] = "Conocer a tu cliente ideal te permite enfocar tus estrategias correctamente en ellos, por lo que saberlo identificar resultará un gran reto, ¿estás listo? ¡Resolvámoslo juntos!. "
  			end
  		when /Cómo incluyes innovación a tu proyecto/
  			##### Set points #####
   			case hash[:answer]
  			when /No lo he pensado pero quiero saber cómo innovar/
  				hash[:score] = 6
  			when /No tiene innovación/
  				hash[:score] = 1
  			when /Tendrá maneras innovadoras de vender el producto/
				hash[:score] = "Excelente"
  			when /Será innovadora en la organización/
				hash[:score] = 6
  			when /El proceso y la forma en que produciré será diferente e innovador/
				hash[:score] = "Excelente"
  			when /tiene características innovadoras a las que actualmente/
				hash[:score] = "Excelente"
  			when /Innovará en la forma de/
  				hash[:score] =	9
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "¡Bien hecho! identificar específicamente en dónde será innovadora tu empresa, pone un paso al frente a tu proyecto.  Recuerda que ser competitivo es fundamental para lograr que tus clientes te elijan frente a la competencia. ¡Juntos podremos construir esta idea!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Es normal que la palabra innovación venga acompañada de incertidumbre, pero al conocer las formas en las que puedes inyectar innovación a tu negocio te dará una ventaja en el mercado, ¡no pierdas la oportunidad!"
  			else
  				hash[:message] = "¿Que oportunidades en el mercado podrías dejar pasar si tu idea no es innovadora? No importa que tipo de proyecto tengas en mente, conoce como puedes diferenciarte e innovar. ¡Encontremos juntos más respuestas!"
  			end
  		when /Conoces el sector en el que incursionarías con tu idea de negocio/
  			##### Set points #####
   			case hash[:answer]
  			when /incluso estoy al tanto de los retos/
  				hash[:score] = 13
  			when /pero no estoy al tanto de los retos/
  				hash[:score] = 9
  			when /no lo considero necesario/
				hash[:score] = 5
  			else
				hash[:score] = 5
  			end
  			##### Set message #####
  			when hash[:score] == "Excelente"
  				hash[:message] = "Tener una idea de negocio en mente implica conocer el sector económico y la actividad en el que te desarrollarás. Aún así, podrías reforzar lo que ya conoces y darle aún más estructura a tu proyecto... ¿Quieres saber más? ¡Deja que nuestro equipo de expertos te asesore!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Tu idea de negocio indiscutiblemente se verá impactada por las situaciones que ocurran en el sector económico o actividad a la que te dedicarás. Identifica oportunidades y retos del mismo y prepárate para salir al mercado. ¡El mundo necesita tu idea!"
  			else
  				hash[:message] = "Si aún no has considerado conocer la situación del sector en donde se desarrollará tu proyecto no esperes más, comienza a investigar sobre los retos y oportunidades que enfrenta el sector en el que se desarrollará tu proyecto​."
  			end
  		when /Existe actualmente un producto o servicio similar que pudiera sustituir al tuyo/
  			##### Set points #####
   			case hash[:answer]
  			when /conozco ya varias empresas/
  				hash[:score] = 12
  			when /estoy seguro de que no tengo competencia/
  				hash[:score] = 9
  			when /No lo sé con certeza/
				hash[:score] = 5
  			when /No me parece relevante/
				hash[:score] = 5
  			end
  			##### Set message #####
  			when hash[:score] == "Excelente"
  				hash[:message] = ""
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = ""
  			else
  				hash[:message] = ""
  			end
  		when /Sabes cuánto costaría iniciar con tu negocio/
  			##### Set points #####
   			case hash[:answer]
  			when /tengo identificados todos los costos/
  				hash[:score] = 12
  			when /poco claros los costos y gastos/
  				hash[:score] = 9
  			when /desconozco el monto total/
				hash[:score] = 5
  			end
  			##### Set message #####
  			when hash[:score] == "Excelente"
  				hash[:message] = ""
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = ""
  			else
  				hash[:message] = ""
  			end
  		when /Tienes identificados a los posibles proveedores de los insumos/
  			##### Set points #####
   			case hash[:answer]
  			when /Conozco los posibles proveedores y los costos/
  				hash[:score] = 12
  			when /Conozco los posibles proveedores pero no/
  				hash[:score] = 9
  			when /Conozco los costos pero no los posibles/
				hash[:score] = 9
  			when /No tengo identificados los costos ni/
				hash[:score] = 5
  			end
  			##### Set message #####
  			when hash[:score] == "Excelente"
  				hash[:message] = ""
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = ""
  			else
  				hash[:message] = ""
  			end
  		when /Tienes identificados los atributos y características/
  			##### Set points #####
   			case hash[:answer]
  			when /sé muy bien cómo me diferenciaré/
  				hash[:score] = 15
  			when /Tengo medianamente claro/
  				hash[:score] = 9
  			when /no será diferente/
				hash[:score] = 5
  			when /No lo sé/
				hash[:score] = 5
  			end
  			##### Set message #####
  		end
  	end

  	puts quanswers

  	#user.group.users.each do |mentor|
    #  mentor.mentor_program_notifications.create(program: program, user: user, notification_type: 'key_question')
    #  if mentor.panel_notifications.complete_mentor.first.nil? || mentor.panel_notifications.complete_mentor.first.status
    #  	Programs.key_question(program, mentor, user, ruta)
    #  end  
    #end
  end
end  	