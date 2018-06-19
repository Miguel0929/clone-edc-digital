IntercomRails.config do |config|
  # == Intercom app_id
  #
  config.app_id = ENV["INTERCOM_APP_ID"] || "mb7vwpp6"

  config.include_for_logged_out_users = true
  # == Intercom session_duration
  #
  # config.session_duration = 300000
  # == Intercom secret key
  # This is required to enable secure mode, you can find it on your Setup
  # guide in the "Secure Mode" step.
  #
  # config.api_secret = "..."

  # == Enabled Environments
  # Which environments is auto inclusion of the Javascript enabled for
  #
  config.enabled_environments = ["development", "production"]

  # == Current user method/variable
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
  # config.user.current = Proc.new { current_user }
  # config.user.current = [Proc.new { current_user }]

  config.user.custom_data = {
    :role => Proc.new { |user| user.role }, #string
    :group => Proc.new { |user| user.group.nil? ? 'Usuario administrador' : user.group.name }, #string
    :phone => Proc.new { |user| user.phone_number }, #string
    :visto => Proc.new { |user| user.user_seen.ceil }, #optiimizado
    :contestado => Proc.new { |user| user.user_progress.ceil }, #optimizado
    :minutos_por_sesion => Proc.new { |user| user.time_average.round },
    :ruta_fisica => Proc.new { |user| user.physical_route }, #strings
    :ruta_moral => Proc.new { |user| user.moral_route }, #strings
    :tiempo_en_plataforma => Proc.new { |user| user.total_time_hours }, #string
    :visitas_por_semana => Proc.new { |user| user.visits_per_week },
    :plantillas_contestadas => Proc.new { |user| user.number_answered_refilables }, #string #no se puede optimizar
    :evaluaciones_contestadas => Proc.new { |user| user.number_answered_quizzes }, #string #no se puede optimizar
    :genero => Proc.new { |user| user.gender.nil? ? 'Sin información' : user.gender }, #string
    :industria => Proc.new { |user| user.industry.nil? ? 'Sin información' : user.industry }, #string
    :status_perfil => Proc.new { |user| user.profile_info_status },
    :token_activacion => Proc.new { |user| user.intercom_activation_code }, #string
    :BNV_contestado => Proc.new { |user| user.program_progress_intercom(45) },
    :HD1_1_contestado => Proc.new { |user| user.program_progress_intercom(19) },
    :HD2_contestado => Proc.new { |user| user.program_progress_intercom(20) },
    :CPR_contestado => Proc.new { |user| user.program_progress_intercom(26) },
    :CIM_contestado => Proc.new { |user| user.program_progress_intercom(6) },
    :PIT_contestado => Proc.new { |user| user.program_progress_intercom(65) },
    :CRW_contestado => Proc.new { |user| user.program_progress_intercom(68) },
    :PCN_contestado => Proc.new { |user| user.program_progress_intercom(70) },
    :DCG_contestado => Proc.new { |user| user.program_progress_intercom(27) },
    :PN3_contestado => Proc.new { |user| user.program_progress_intercom(51) },
    :ECI_1_contestado => Proc.new { |user| user.program_progress_intercom(22) },
    :ECI_2_contestado => Proc.new { |user| user.program_progress_intercom(61) },
    :EMT_contestado => Proc.new { |user| user.program_progress_intercom(4) },
    :EMP_contestado => Proc.new { |user| user.program_progress_intercom(16) },
    :ECI_3_contestado => Proc.new { |user| user.program_progress_intercom(3) },
    :ECM_contestado => Proc.new { |user| user.program_progress_intercom(10) },
    :ECF_contestado => Proc.new { |user| user.program_progress_intercom(9) },
    :ES_contestado => Proc.new { |user| user.program_progress_intercom(71) },
    :ICF_1_contestado => Proc.new { |user| user.program_progress_intercom(38) },
    :ICM_1_contestado => Proc.new { |user| user.program_progress_intercom(29) },
    :CIN_contestado => Proc.new { |user| user.program_progress_intercom(30) },
    :ICO_contestado => Proc.new { |user| user.program_progress_intercom(31) },
    :IPM_1_contestado => Proc.new { |user| user.program_progress_intercom(36) },
    :IPS_contestado => Proc.new { |user| user.program_progress_intercom(41) },
    :IPR_1_contestado => Proc.new { |user| user.program_progress_intercom(37) },
    :P123_1_contestado => Proc.new { |user| user.program_progress_intercom(50) },
    :IDV_contestado => Proc.new { |user| user.program_progress_intercom(53) },
    :IDC_contestado => Proc.new { |user| user.program_progress_intercom(72) },
    :IEF_contestado => Proc.new { |user| user.program_progress_intercom(69) },
    :P123_2_contestado => Proc.new { |user| user.program_progress_intercom(49) },
    :PE1_contestado => Proc.new { |user| user.program_progress_intercom(47) },
    :MGT_contestado => Proc.new { |user| user.program_progress_intercom(52) },
    :MNE_1_contestado => Proc.new { |user| user.program_progress_intercom(63) },
    :MNE_2_contestado => Proc.new { |user| user.program_progress_intercom(35) },
    :HD1_2_contestado => Proc.new { |user| user.program_progress_intercom(54) },
    :HD1_3_contestado => Proc.new { |user| user.program_progress_intercom(55) },
    :CCF_contestado => Proc.new { |user| user.program_progress_intercom(23) },
    :CCM_contestado => Proc.new { |user| user.program_progress_intercom(24) },
    :PNI_contestado => Proc.new { |user| user.program_progress_intercom(18) },
    :ICF_2_contestado => Proc.new { |user| user.program_progress_intercom(57) },
    :ICM_2_contestado => Proc.new { |user| user.program_progress_intercom(58) },
    :HCI_contestado => Proc.new { |user| user.program_progress_intercom(56) },
    :VME_1_contestado => Proc.new { |user| user.program_progress_intercom(25) },
    :VME_2_contestado => Proc.new { |user| user.program_progress_intercom(64) },
    :IPM_2_contestado => Proc.new { |user| user.program_progress_intercom(60) },
    :PPR_contestado => Proc.new { |user| user.program_progress_intercom(28) },
    :PVE_contestado => Proc.new { |user| user.program_progress_intercom(32) },
    :PE2_contestado => Proc.new { |user| user.program_progress_intercom(66) },
    :IPR_2_contestado => Proc.new { |user| user.program_progress_intercom(59) },
    :PRT_1_contestado => Proc.new { |user| user.program_progress_intercom(40) },
    :PRT_2_contestado => Proc.new { |user| user.program_progress_intercom(48) },
    :RF_contestado => Proc.new { |user| user.program_progress_intercom(67) },
    :TMN_1_contestado => Proc.new { |user| user.program_progress_intercom(62) },
    :TMN_2_contestado => Proc.new { |user| user.program_progress_intercom(43) },
    :ECO_contestado => Proc.new { |user| user.program_progress_intercom(73) },
    :PF_contestado => Proc.new { |user| user.program_progress_intercom(74) },
    :DSA_contestado => Proc.new { |user| user.program_progress_intercom(75) }
  }
  # == Include for logged out Users
  # If set to true, include the Intercom messenger on all pages, regardless of whether
  # The user model class (set below) is present. Only available for Apps on the Acquire plan.
  # config.include_for_logged_out_users = true

  # == User model class
  # The class which defines your user model
  #
  # config.user.model = Proc.new { User }

  # == Lead/custom attributes for non-signed up users
  # Pass additional attributes to for potential leads or
  # non-signed up users as an an array.
  # Any attribute contained in config.user.lead_attributes can be used
  # as custom attribute in the application.
  # config.user.lead_attributes = %w(ref_data utm_source)

  # == Exclude users
  # A Proc that given a user returns true if the user should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.user.exclude_if = Proc.new { |user| user.deleted? }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.
  #
  # config.user.custom_data = {
  #   :plan => Proc.new { |current_user| current_user.plan.name },
  #   :favorite_color => :favorite_color
  # }

  # == Current company method/variable
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
  # config.company.current = Proc.new { current_company }
  #
  # Or if you are using devise you can just use the following config
  #
  # config.company.current = Proc.new { current_user.company }

  # == Exclude company
  # A Proc that given a company returns true if the company should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.company.exclude_if = Proc.new { |app| app.subdomain == 'demo' }

  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
  # config.company.custom_data = {
  #   :number_of_messages => Proc.new { |app| app.messages.count },
  #   :is_interesting => :is_interesting?
  # }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  # config.company.plan = Proc.new { |current_company| current_company.plan.name }

  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
  # config.company.monthly_spend = Proc.new { |current_company| current_company.plan.price }
  # config.company.monthly_spend = Proc.new { |current_company| (current_company.plan.price - current_company.subscription.discount) }

  # == Custom Style
  # By default, Intercom will add a button that opens the messenger to
  # the page. If you'd like to use your own link to open the messenger,
  # uncomment this line and clicks on any element with id 'Intercom' will
  # open the messenger.
  #
  # config.inbox.style = :custom
  #
  # If you'd like to use your own link activator CSS selector
  # uncomment this line and clicks on any element that matches the query will
  # open the messenger
  # config.inbox.custom_activator = '.intercom'
  #
  # If you'd like to hide default launcher button uncomment this line
  # config.hide_default_launcher = true
end
