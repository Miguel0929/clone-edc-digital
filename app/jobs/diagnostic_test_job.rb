class DiagnosticTestJob < ActiveJob::Base
  include SuckerPunch::Job
  include EvaluationHelper

  FROM = "soporte-edcdigital@distritoemprendedor.com"
  NAME = "EDC Digital"

  def perform(answers, chapter, user, first_time)

  	quanswers = []
  	answers.each do |answer| 
  		quanswers << {question: Question.find(answer.question_id).question_text, answer: answer.answer_text}
  	end
    "=================================="
  	evaluations = chapter.evaluations
    program_bienvenido = chapter.program

  	quanswers.each do |hash|
  		case hash[:question]
  		when /selecciona el que define más el mercado al que está dirigida tu idea de negocio/
  			hash[:order] = 1
  			##### Set score #####
   			case hash[:answer]
  			when /Grupos de personas o empresas que tienen la misma necesidad/
  				hash[:score] = "Excelente"
  			when /Un grupo de personas o empresas muy especializado/
  				hash[:score] = "Excelente"
  			when /Público en general/
				hash[:score] = "Regular"
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
  				hash[:message] = "¡Bien! identificaste el mercado al que está dirigido  tu idea de negocio. Determinar las características de tu cliente resultará más fácil. Aún así, siempre se puede saber más de nuestro posible cliente...Hablamos de investigar más allá: ¿Cómo se comporta? ¿En dónde vive? ¿A qué se dedica? ¿Quieres saber más? ¡Te ayudamos!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Conocer los diferentes tipos de mercado que existen ayuda a que sea menos complicado elegir al que se dirige tu idea de negocio. ¡No te preocupes! ¡Nosotros te ayudaremos a mejorarlo!"
  			else
  				hash[:message] = "Conocer y saber identificar el tipo de mercado al que va dirigido tu proyecto es de los aspectos principales a tomar en cuenta cuando vas iniciando. Es algo complicado, si, pero para eso estamos. Te ayudaremos a identificar el mercado de tus posibles clientes. "
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("selecciona el que define más el mercado al que está dirigida tu idea de negocio")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Qué datos ya conoces de tu principal cliente/
  			hash[:order] = 2
  			##### Set score #####
  			counter = 0
			if hash[:answer].include?("Hábitos")
				counter = counter + 1
			end
			if hash[:answer].include?("Comportamiento")
				counter = counter + 1
			end
			if hash[:answer].include?("Personalidad")
				counter = counter + 1
			end
			if hash[:answer].include?("ingresos")
				counter = counter + 1
			end
			if hash[:answer].include?("socioeconómico")
				counter = counter + 1
			end
			if hash[:answer].include?("estudios")
				counter = counter + 1
			end
			if hash[:answer].include?("Ubicación geográfica")
				counter = counter + 1
			end
			if hash[:answer].include?("Género")
				counter = counter + 1
			end
			if hash[:answer].include?("Edad")
				counter = counter + 1
			end
			if hash[:answer].include?("Ocupación")
				counter = counter + 1
			end
			if hash[:answer].include?("ventas anuales")
				counter = counter + 1
			end
			if hash[:answer].include?("Tamaño")
				counter = counter + 1
			end
			if hash[:answer].include?("Giro o sector")
				counter = counter + 1
			end
			if hash[:answer].include?("iniciativa a la que pertence")
				counter = counter + 1
			end
			if hash[:answer].include?("ninguno de los aspectos")
				counter = counter + 0
			end
			if counter >= 7
				hash[:score] = "Excelente"
			elsif (counter < 7 && counter >= 3)
				hash[:score] = "Bueno"
			elsif (counter < 3 && counter >= 1)
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
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Qué datos ya conoces de tu principal cliente")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Cómo incluyes innovación a tu proyecto/
  			hash[:order] = 3
  			##### Set score #####
   			case hash[:answer]
  			when /No lo he pensado pero quiero saber cómo innovar/
  				hash[:score] = "Regular"
  			when /No tiene innovación/
  				hash[:score] = "Malo"
  			when /Tendrá maneras innovadoras de vender el producto/
				hash[:score] = "Excelente"
  			when /Será innovadora en la organización/
				hash[:score] = "Excelente"
  			when /El proceso y la forma en que produciré será diferente e innovador/
				hash[:score] = "Excelente"
  			when /tiene características innovadoras a las que actualmente/
				hash[:score] = "Excelente"
  			when /Innovará en la forma de/
  				hash[:score] =	"Excelente"
  			when /conozco cómo innovar en/
  				hash[:score] = "Bueno"
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
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Cómo incluyes innovación a tu proyecto")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Conoces el sector en el que incursionarías con tu idea de negocio/
  			hash[:order] = 4
  			##### Set score #####
   			case hash[:answer]
  			when /incluso estoy al tanto de los retos/
  				hash[:score] = "Excelente"
  			when /pero no estoy al tanto de los retos/
  				hash[:score] = "Bueno"
  			when /no lo considero necesario/
				hash[:score] = "Regular"
  			else
				hash[:score] = "Malo"
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "Tener una idea de negocio en mente implica conocer el sector económico y la actividad en el que te desarrollarás. Aún así, podrías reforzar lo que ya conoces y darle aún más estructura a tu proyecto... ¿Quieres saber más? ¡Deja que nuestro equipo de expertos te asesore!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Tu idea de negocio indiscutiblemente se verá impactada por las situaciones que ocurran en el sector económico o actividad a la que te dedicarás. Identifica oportunidades y retos del mismo y prepárate para salir al mercado. ¡El mundo necesita tu idea!"
  			else
  				hash[:message] = "Si aún no has considerado conocer la situación del sector en donde se desarrollará tu proyecto no esperes más, comienza a investigar sobre los retos y oportunidades que enfrenta el sector en el que se desarrollará tu proyecto​."
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Conoces el sector en el que incursionarías con tu idea de negocio")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Existe actualmente un producto o servicio similar que pudiera sustituir al tuyo/
  			hash[:order] = 5
  			##### Set score #####
   			case hash[:answer]
  			when /conozco ya varias empresas/
  				hash[:score] = "Excelente"
  			when /estoy seguro de que no tengo competencia/
  				hash[:score] = "Bueno"
  			when /No lo sé con certeza/
				hash[:score] = "Regular"
  			when /No me parece relevante/
				hash[:score] = "Malo"
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "Muy bien, identificar que otros negocios ya realizan lo que tienes en mente, te puede ayudar a detectar áreas de oportunidad y aprovecharlas en pro de tu proyecto. ¿Qué ventajas ofrece tu producto o servicio sobre ellos?"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "¿Sabías que la competencia no solo implica lo que es igual a tu proyecto? si existe un producto o servicio que satisfaga la misma necesidad, sin importar que no sea directamente lo que tu quieres hacer, ya se considera competencia. Para descubrir más de esto, te invitamos a que consideres este aspecto para continuar."
  			else
  				hash[:message] = "Es vital saber que otros negocios ya llevan a cabo lo que tienes en mente, no esperes a que sea tarde para identificarlos, conoce a tu competencia y aprovecha oportunidades que ellos no han visto. Si no lo haces tú, ¡ellos lo harán!"
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Existe actualmente un producto o servicio similar que pudiera sustituir al tuyo")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Sabes cuánto costaría iniciar con tu negocio/
  			hash[:order] = 6
  			##### Set score #####
   			case hash[:answer]
  			when /tengo identificados/
  				hash[:score] = "Excelente"
  			when /tengo noción de los costos y gastos/
  				hash[:score] = "Bueno"
  			when /poco claros los costos y gastos/
  				hash[:score] = "Regular"
  			when /desconozco el monto total/
				hash[:score] = "Malo"
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "Bien, si ya tienes identificados los costos y gastos representativos de tu proyecto, será mucho más fácil para ti y nuestros expertos llevar a cabo el extenso proceso de validación ténico - financiera, y con ello la construcción de tu idea de negocio será más rápida."
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Descubrir los diferentes aspectos que integran la cantidad monetaria que requieres para iniciar es un proceso que lleva tiempo, por ello, detenerte a analizar todos y cada uno de los costos y gastos que representa poner en marcha un proyecto te ayudará a estructurar y definir correctamente tu idea de negocio."
  			else
  				hash[:message] = "Al desarrollar todos los aspectos técnicos de tu idea, lograrás identificar el monto de dinero que requieres, y con ello determinar la mejor fuente de financiamiento. ¡No dejes que siga corriendo el tiempo! ¡Comienza a estructurar tu idea antes de que alguien más lo haga!"
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Sabes cuánto costaría iniciar con tu negocio")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Tienes identificados a los posibles proveedores de los insumos/
  			hash[:order] = 7
  			##### Set score #####
   			case hash[:answer]
  			when /Conozco los posibles proveedores y los costos/
  				hash[:score] = "Excelente"
  			when /Conozco los posibles proveedores pero no/
  				hash[:score] = "Bueno"
  			when /Conozco los costos pero no los posibles/
				hash[:score] = "Regular"
  			when /No tengo identificados los costos ni/
				hash[:score] = "Malo"
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "El hecho de que ya conozcas sobre posibles proveedores te ayuda a identificar mejor los requerimentos y los retos que representará para tu negocio. Pero... ¿Sabías que puedes reforzarlo al adentrarte en investigaciones aún más profundas? ¡Nosotros te ayudamos!"
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "El cruce entre quién te puede proveer lo que necesitas y cuánto dinero necesitarás para ello resultará más facil de identificar si comienzas a hacar un análisis de tus proveedores. ¿Cómo podrías detectarlo? Te ayudamos...contamos con herramientas digitales ideales para ello."
  			else
  				hash[:message] = "Si conoces quien te puede proveer de los insumos para tu negocio, identificarás también los costos que representa, con lo que podrás hacer presupuestos y estarás más cerca de validar técnica y financieramente tu proyecto. ¡Queremos ayudarte a que tengas una idea viable y bien fundamentada! Sólo así podrá ser exitosa en el mercado."
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Tienes identificados a los posibles proveedores de los insumos")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		when /Tienes identificados los atributos y características/
  			hash[:order] = 8
  			##### Set score #####
   			case hash[:answer]
  			when /sé muy bien cómo me diferenciaré/
  				hash[:score] = "Excelente"
  			when /Tengo medianamente claro/
  				hash[:score] = "Bueno"
  			when /no será diferente/
				hash[:score] = "Regular"
  			when /No lo sé/
				hash[:score] = "Malo"
  			end
  			##### Set message #####
  			case
  			when hash[:score] == "Excelente"
  				hash[:message] = "Para lograr diferenciarte verdaderamente de otros proyectos necesitas saber comunicar tu propuesta de valor, así que, si ya cuentas con los elementos para definirla, estás más cerca de obtener una idea de negocio estructurada."
  			when hash[:score] == "Bueno" || hash[:score] == "Regular"
  				hash[:message] = "Claro está que deseas ser diferente a la competencia, pero ¿cómo lograrlo? sabiéndo comunicar tu propuesta de valor. Nosotros te guiamos."
  			else
  				hash[:message] = "Tal vez consideres que no es necesario marcar una gran diferencia en el mercado, pero si no te haces notar con una propuesta de valor bien estructurada, estarás disminuyendo las posibilidades de éxito de tu idea de negocio en el mercado."
  			end
  			##### Evaluate user #####
  			evaluations.each do |eve|
  				if eve.name.include?("Tienes identificados los atributos y características")
  					save_update_user_evaluation(eve, hash[:score], user)
  					break
  				end
  			end
  		end
  	end

  	if first_time
	  	quanswers_1 = quanswers.find{|x| x[:order] == 1}
	  	quanswers_2 = quanswers.find{|x| x[:order] == 2}
	  	quanswers_3 = quanswers.find{|x| x[:order] == 3}
	  	quanswers_4 = quanswers.find{|x| x[:order] == 4}
	  	quanswers_5 = quanswers.find{|x| x[:order] == 5}
	  	quanswers_6 = quanswers.find{|x| x[:order] == 6}
	  	quanswers_7 = quanswers.find{|x| x[:order] == 7}
	  	quanswers_8 = quanswers.find{|x| x[:order] == 8}

      p points_obtained = program_bienvenido.points_earned(user)
      p total_points = program_bienvenido.total_points
      p avg = number_to_percentage(user_promedio_program(points_obtained, total_points), precision: 1)

  		DiagnosticTestMailer.send_results_user(user, 
  							quanswers_1[:question], quanswers_1[:answer], quanswers_1[:message],
  							quanswers_2[:question], quanswers_2[:answer], quanswers_2[:message],
  							quanswers_3[:question], quanswers_3[:answer], quanswers_3[:message],
  							quanswers_4[:question], quanswers_4[:answer], quanswers_4[:message],
  							quanswers_5[:question], quanswers_5[:answer], quanswers_5[:message],
  							quanswers_6[:question], quanswers_6[:answer], quanswers_6[:message],
  							quanswers_7[:question], quanswers_7[:answer], quanswers_7[:message],
  							quanswers_8[:question], quanswers_8[:answer], quanswers_8[:message],
  							points_obtained, total_points, avg)

  		DiagnosticTestMailer.send_results_suport(user, 
  							quanswers_1[:question], quanswers_1[:answer], quanswers_1[:message],
  							quanswers_2[:question], quanswers_2[:answer], quanswers_2[:message],
  							quanswers_3[:question], quanswers_3[:answer], quanswers_3[:message],
  							quanswers_4[:question], quanswers_4[:answer], quanswers_4[:message],
  							quanswers_5[:question], quanswers_5[:answer], quanswers_5[:message],
  							quanswers_6[:question], quanswers_6[:answer], quanswers_6[:message],
  							quanswers_7[:question], quanswers_7[:answer], quanswers_7[:message],
  							quanswers_8[:question], quanswers_8[:answer], quanswers_8[:message],
  							points_obtained, total_points, avg)

      DiagnosticTestMailer.send_results_user(User.find(3739), 
                quanswers_1[:question], quanswers_1[:answer], quanswers_1[:message],
                quanswers_2[:question], quanswers_2[:answer], quanswers_2[:message],
                quanswers_3[:question], quanswers_3[:answer], quanswers_3[:message],
                quanswers_4[:question], quanswers_4[:answer], quanswers_4[:message],
                quanswers_5[:question], quanswers_5[:answer], quanswers_5[:message],
                quanswers_6[:question], quanswers_6[:answer], quanswers_6[:message],
                quanswers_7[:question], quanswers_7[:answer], quanswers_7[:message],
                quanswers_8[:question], quanswers_8[:answer], quanswers_8[:message],
                points_obtained, total_points, avg)
  	end
  end

  def save_update_user_evaluation(eve, score, user)
	case score
	when "Excelente"
		user_points = 100
	when "Bueno"
		user_points = 75
	when "Regular" 
		user_points = 50
	else
		user_points = 25
	end
	user_evaluation = UserEvaluation.find_or_initialize_by(user: user, evaluation_id: eve.id) 
	user_evaluation.points = user_points
	user_evaluation.save!
  end
end  	