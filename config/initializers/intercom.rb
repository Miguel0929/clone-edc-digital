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
    :visto => Proc.new { |user| user.content_visited_percentage.ceil },
    :contestado => Proc.new { |user| user.answered_questions_percentage.ceil },
    :minutos_por_sesion => Proc.new { |user| user.time_average.round },
    :ruta_fisica => Proc.new { |user| user.physical_route }, #strings
    :ruta_moral => Proc.new { |user| user.moral_route }, #strings
    :tiempo_en_plataforma => Proc.new { |user| user.total_time_hours }, #string
    :visitas_por_semana => Proc.new { |user| user.visits_per_week },
    :plantillas_contestadas => Proc.new { |user| user.number_answered_refilables }, #string
    :evaluaciones_contestadas => Proc.new { |user| user.number_answered_quizzes }, #string
    :genero => Proc.new { |user| user.gender.nil? ? 'Sin información' : user.gender }, #string
    :edad => Proc.new { |user| user.age },
    :industria => Proc.new { |user| user.industry.nil? ? 'Sin información' : user.industry }, #string
    :token_activacion => Proc.new { |user| user.intercom_activation_code }, #string
    :BNV_status => Proc.new { |user| user.intercom_prog_status(45) }, #string
    :BNV_examen => Proc.new { |user| user.intercom_prog_quizzes(45) },
    :BNV_plantillas => Proc.new { |user| user.intercom_prog_refillables(45) }, #string
    :BNV_visto => Proc.new { |user| user.intercom_prog_seen(45) },
    :BNV_contestado => Proc.new { |user| user.intercom_prog_answered(45) },
    :HD1_1_status => Proc.new { |user| user.intercom_prog_status(19) },
    :HD1_1_examen => Proc.new { |user| user.intercom_prog_quizzes(19) },
    :HD1_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(19) },
    :HD1_1_visto => Proc.new { |user| user.intercom_prog_seen(19) },
    :HD1_1_contestado => Proc.new { |user| user.intercom_prog_answered(19) },
    :HD2_status => Proc.new { |user| user.intercom_prog_status(20) },
    :HD2_examen => Proc.new { |user| user.intercom_prog_quizzes(20) },
    :HD2_plantillas => Proc.new { |user| user.intercom_prog_refillables(20) },
    :HD2_visto => Proc.new { |user| user.intercom_prog_seen(20) },
    :HD2_contestado => Proc.new { |user| user.intercom_prog_answered(20) },
    :CPR_status => Proc.new { |user| user.intercom_prog_status(26) },
    :CPR_examen => Proc.new { |user| user.intercom_prog_quizzes(26) },
    :CPR_plantillas => Proc.new { |user| user.intercom_prog_refillables(26) },
    :CPR_visto => Proc.new { |user| user.intercom_prog_seen(26) },
    :CPR_contestado => Proc.new { |user| user.intercom_prog_answered(26) },
    :CIM_status => Proc.new { |user| user.intercom_prog_status(6) },
    :CIM_examen => Proc.new { |user| user.intercom_prog_quizzes(6) },
    :CIM_plantillas => Proc.new { |user| user.intercom_prog_refillables(6) },
    :CIM_visto => Proc.new { |user| user.intercom_prog_seen(6) },
    :CIM_contestado => Proc.new { |user| user.intercom_prog_answered(6) },
    :PIT_status => Proc.new { |user| user.intercom_prog_status(65) },
    :PIT_examen => Proc.new { |user| user.intercom_prog_quizzes(65) },
    :PIT_plantillas => Proc.new { |user| user.intercom_prog_refillables(65) },
    :PIT_visto => Proc.new { |user| user.intercom_prog_seen(65) },
    :PIT_contestado => Proc.new { |user| user.intercom_prog_answered(65) },
    :CRW_status => Proc.new { |user| user.intercom_prog_status(65) },
    :CRW_examen => Proc.new { |user| user.intercom_prog_quizzes(65) },
    :CRW_plantillas => Proc.new { |user| user.intercom_prog_refillables(65) },
    :CRW_visto => Proc.new { |user| user.intercom_prog_seen(65) },
    :CRW_contestado => Proc.new { |user| user.intercom_prog_answered(65) },
    :PCN_status => Proc.new { |user| user.intercom_prog_status(70) },
    :PCN_examen => Proc.new { |user| user.intercom_prog_quizzes(70) },
    :PCN_plantillas => Proc.new { |user| user.intercom_prog_refillables(70) },
    :PCN_visto => Proc.new { |user| user.intercom_prog_seen(70) },
    :PCN_contestado => Proc.new { |user| user.intercom_prog_answered(70) },
    :DCG_status => Proc.new { |user| user.intercom_prog_status(27) },
    :DCG_examen => Proc.new { |user| user.intercom_prog_quizzes(27) },
    :DCG_plantillas => Proc.new { |user| user.intercom_prog_refillables(27) },
    :DCG_visto => Proc.new { |user| user.intercom_prog_seen(27) },
    :DCG_contestado => Proc.new { |user| user.intercom_prog_answered(27) },
    :PN3_status => Proc.new { |user| user.intercom_prog_status(51) },
    :PN3_examen => Proc.new { |user| user.intercom_prog_quizzes(51) },
    :PN3_plantillas => Proc.new { |user| user.intercom_prog_refillables(51) },
    :PN3_visto => Proc.new { |user| user.intercom_prog_seen(51) },
    :PN3_contestado => Proc.new { |user| user.intercom_prog_answered(51) },
    :ECI_1_status => Proc.new { |user| user.intercom_prog_status(22) },
    :ECI_1_examen => Proc.new { |user| user.intercom_prog_quizzes(22) },
    :ECI_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(22) },
    :ECI_1_visto => Proc.new { |user| user.intercom_prog_seen(22) },
    :ECI_1_contestado => Proc.new { |user| user.intercom_prog_answered(22) },
    :ECI_2_status => Proc.new { |user| user.intercom_prog_status(61) },
    :ECI_2_examen => Proc.new { |user| user.intercom_prog_quizzes(61) },
    :ECI_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(61) },
    :ECI_2_visto => Proc.new { |user| user.intercom_prog_seen(61) },
    :ECI_2_contestado => Proc.new { |user| user.intercom_prog_answered(61) },
    :EMT_status => Proc.new { |user| user.intercom_prog_status(4) },
    :EMT_examen => Proc.new { |user| user.intercom_prog_quizzes(4) },
    :EMT_plantillas => Proc.new { |user| user.intercom_prog_refillables(4) },
    :EMT_visto => Proc.new { |user| user.intercom_prog_seen(4) },
    :EMT_contestado => Proc.new { |user| user.intercom_prog_answered(4) },
    :EMP_status => Proc.new { |user| user.intercom_prog_status(16) },
    :EMP_examen => Proc.new { |user| user.intercom_prog_quizzes(16) },
    :EMP_plantillas => Proc.new { |user| user.intercom_prog_refillables(16) },
    :EMP_visto => Proc.new { |user| user.intercom_prog_seen(16) },
    :EMP_contestado => Proc.new { |user| user.intercom_prog_answered(16) },
    :ECI_3_status => Proc.new { |user| user.intercom_prog_status(3) },
    :ECI_3_examen => Proc.new { |user| user.intercom_prog_quizzes(3) },
    :ECI_3_plantillas => Proc.new { |user| user.intercom_prog_refillables(3) },
    :ECI_3_visto => Proc.new { |user| user.intercom_prog_seen(3) },
    :ECI_3_contestado => Proc.new { |user| user.intercom_prog_answered(3) },
    :ECM_status => Proc.new { |user| user.intercom_prog_status(10) },
    :ECM_examen => Proc.new { |user| user.intercom_prog_quizzes(10) },
    :ECM_plantillas => Proc.new { |user| user.intercom_prog_refillables(10) },
    :ECM_visto => Proc.new { |user| user.intercom_prog_seen(10) },
    :ECM_contestado => Proc.new { |user| user.intercom_prog_answered(10) },
    :ECF_status => Proc.new { |user| user.intercom_prog_status(9) },
    :ECF_examen => Proc.new { |user| user.intercom_prog_quizzes(9) },
    :ECF_plantillas => Proc.new { |user| user.intercom_prog_refillables(9) },
    :ECF_visto => Proc.new { |user| user.intercom_prog_seen(9) },
    :ECF_contestado => Proc.new { |user| user.intercom_prog_answered(9) },
    :ES_status => Proc.new { |user| user.intercom_prog_status(71) },
    :ES_examen => Proc.new { |user| user.intercom_prog_quizzes(71) },
    :ES_plantillas => Proc.new { |user| user.intercom_prog_refillables(71) },
    :ES_visto => Proc.new { |user| user.intercom_prog_seen(71) },
    :ES_contestado => Proc.new { |user| user.intercom_prog_answered(71) },
    :ICF_1_status => Proc.new { |user| user.intercom_prog_status(38) },
    :ICF_1_examen => Proc.new { |user| user.intercom_prog_quizzes(38) },
    :ICF_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(38) },
    :ICF_1_visto => Proc.new { |user| user.intercom_prog_seen(38) },
    :ICF_1_contestado => Proc.new { |user| user.intercom_prog_answered(38) },
    :ICM_1_status => Proc.new { |user| user.intercom_prog_status(29) },
    :ICM_1_examen => Proc.new { |user| user.intercom_prog_quizzes(29) },
    :ICM_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(29) },
    :ICM_1_visto => Proc.new { |user| user.intercom_prog_seen(29) },
    :ICM_1_contestado => Proc.new { |user| user.intercom_prog_answered(29) },
    :CIN_status => Proc.new { |user| user.intercom_prog_status(30) },
    :CIN_examen => Proc.new { |user| user.intercom_prog_quizzes(30) },
    :CIN_plantillas => Proc.new { |user| user.intercom_prog_refillables(30) },
    :CIN_visto => Proc.new { |user| user.intercom_prog_seen(30) },
    :CIN_contestado => Proc.new { |user| user.intercom_prog_answered(30) },
    :ICO_status => Proc.new { |user| user.intercom_prog_status(31) },
    :ICO_examen => Proc.new { |user| user.intercom_prog_quizzes(31) },
    :ICO_plantillas => Proc.new { |user| user.intercom_prog_refillables(31) },
    :ICO_visto => Proc.new { |user| user.intercom_prog_seen(31) },
    :ICO_contestado => Proc.new { |user| user.intercom_prog_answered(31) },
    :IPM_1_status => Proc.new { |user| user.intercom_prog_status(36) },
    :IPM_1_examen => Proc.new { |user| user.intercom_prog_quizzes(36) },
    :IPM_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(36) },
    :IPM_1_visto => Proc.new { |user| user.intercom_prog_seen(36) },
    :IPM_1_contestado => Proc.new { |user| user.intercom_prog_answered(36) },
    :IPS_status => Proc.new { |user| user.intercom_prog_status(41) },
    :IPS_examen => Proc.new { |user| user.intercom_prog_quizzes(41) },
    :IPS_plantillas => Proc.new { |user| user.intercom_prog_refillables(41) },
    :IPS_visto => Proc.new { |user| user.intercom_prog_seen(41) },
    :IPS_contestado => Proc.new { |user| user.intercom_prog_answered(41) },
    :IPR_1_status => Proc.new { |user| user.intercom_prog_status(37) },
    :IPR_1_examen => Proc.new { |user| user.intercom_prog_quizzes(37) },
    :IPR_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(37) },
    :IPR_1_visto => Proc.new { |user| user.intercom_prog_seen(37) },
    :IPR_1_contestado => Proc.new { |user| user.intercom_prog_answered(37) },
    :P123_1_status => Proc.new { |user| user.intercom_prog_status(50) },
    :P123_1_examen => Proc.new { |user| user.intercom_prog_quizzes(50) },
    :P123_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(50) },
    :P123_1_visto => Proc.new { |user| user.intercom_prog_seen(50) },
    :P123_1_contestado => Proc.new { |user| user.intercom_prog_answered(50) },
    :IDV_status => Proc.new { |user| user.intercom_prog_status(53) },
    :IDV_examen => Proc.new { |user| user.intercom_prog_quizzes(53) },
    :IDV_plantillas => Proc.new { |user| user.intercom_prog_refillables(53) },
    :IDV_visto => Proc.new { |user| user.intercom_prog_seen(53) },
    :IDV_contestado => Proc.new { |user| user.intercom_prog_answered(53) },
    :IDC_status => Proc.new { |user| user.intercom_prog_status(72) },
    :IDC_examen => Proc.new { |user| user.intercom_prog_quizzes(72) },
    :IDC_plantillas => Proc.new { |user| user.intercom_prog_refillables(72) },
    :IDC_visto => Proc.new { |user| user.intercom_prog_seen(72) },
    :IDC_contestado => Proc.new { |user| user.intercom_prog_answered(72) },
    :IEF_status => Proc.new { |user| user.intercom_prog_status(69) },
    :IEF_examen => Proc.new { |user| user.intercom_prog_quizzes(69) },
    :IEF_plantillas => Proc.new { |user| user.intercom_prog_refillables(69) },
    :IEF_visto => Proc.new { |user| user.intercom_prog_seen(69) },
    :IEF_contestado => Proc.new { |user| user.intercom_prog_answered(69) },
    :P123_2_status => Proc.new { |user| user.intercom_prog_status(49) },
    :P123_2_examen => Proc.new { |user| user.intercom_prog_quizzes(49) },
    :P123_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(49) },
    :P123_2_visto => Proc.new { |user| user.intercom_prog_seen(49) },
    :P123_2_contestado => Proc.new { |user| user.intercom_prog_answered(49) },
    :PE1_status => Proc.new { |user| user.intercom_prog_status(47) },
    :PE1_examen => Proc.new { |user| user.intercom_prog_quizzes(47) },
    :PE1_plantillas => Proc.new { |user| user.intercom_prog_refillables(47) },
    :PE1_visto => Proc.new { |user| user.intercom_prog_seen(47) },
    :PE1_contestado => Proc.new { |user| user.intercom_prog_answered(47) },
    :MGT_status => Proc.new { |user| user.intercom_prog_status(52) },
    :MGT_examen => Proc.new { |user| user.intercom_prog_quizzes(52) },
    :MGT_plantillas => Proc.new { |user| user.intercom_prog_refillables(52) },
    :MGT_visto => Proc.new { |user| user.intercom_prog_seen(52) },
    :MGT_contestado => Proc.new { |user| user.intercom_prog_answered(52) },
    :MNE_1_status => Proc.new { |user| user.intercom_prog_status(63) },
    :MNE_1_examen => Proc.new { |user| user.intercom_prog_quizzes(63) },
    :MNE_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(63) },
    :MNE_1_visto => Proc.new { |user| user.intercom_prog_seen(63) },
    :MNE_1_contestado => Proc.new { |user| user.intercom_prog_answered(63) },
    :MNE_2_status => Proc.new { |user| user.intercom_prog_status(35) },
    :MNE_2_examen => Proc.new { |user| user.intercom_prog_quizzes(35) },
    :MNE_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(35) },
    :MNE_2_visto => Proc.new { |user| user.intercom_prog_seen(35) },
    :MNE_2_contestado => Proc.new { |user| user.intercom_prog_answered(35) },
    :HD1_2_status => Proc.new { |user| user.intercom_prog_status(54) },
    :HD1_2_examen => Proc.new { |user| user.intercom_prog_quizzes(54) },
    :HD1_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(54) },
    :HD1_2_visto => Proc.new { |user| user.intercom_prog_seen(54) },
    :HD1_2_contestado => Proc.new { |user| user.intercom_prog_answered(54) },
    :HD1_3_status => Proc.new { |user| user.intercom_prog_status(55) },
    :HD1_3_examen => Proc.new { |user| user.intercom_prog_quizzes(55) },
    :HD1_3_plantillas => Proc.new { |user| user.intercom_prog_refillables(55) },
    :HD1_3_visto => Proc.new { |user| user.intercom_prog_seen(55) },
    :HD1_3_contestado => Proc.new { |user| user.intercom_prog_answered(55) },
    :CCF_status => Proc.new { |user| user.intercom_prog_status(23) },
    :CCF_examen => Proc.new { |user| user.intercom_prog_quizzes(23) },
    :CCF_plantillas => Proc.new { |user| user.intercom_prog_refillables(23) },
    :CCF_visto => Proc.new { |user| user.intercom_prog_seen(23) },
    :CCF_contestado => Proc.new { |user| user.intercom_prog_answered(23) },
    :CCM_status => Proc.new { |user| user.intercom_prog_status(24) },
    :CCM_examen => Proc.new { |user| user.intercom_prog_quizzes(24) },
    :CCM_plantillas => Proc.new { |user| user.intercom_prog_refillables(24) },
    :CCM_visto => Proc.new { |user| user.intercom_prog_seen(24) },
    :CCM_contestado => Proc.new { |user| user.intercom_prog_answered(24) },
    :PNI_status => Proc.new { |user| user.intercom_prog_status(18) },
    :PNI_examen => Proc.new { |user| user.intercom_prog_quizzes(18) },
    :PNI_plantillas => Proc.new { |user| user.intercom_prog_refillables(18) },
    :PNI_visto => Proc.new { |user| user.intercom_prog_seen(18) },
    :PNI_contestado => Proc.new { |user| user.intercom_prog_answered(18) },
    :ICF_2_status => Proc.new { |user| user.intercom_prog_status(57) },
    :ICF_2_examen => Proc.new { |user| user.intercom_prog_quizzes(57) },
    :ICF_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(57) },
    :ICF_2_visto => Proc.new { |user| user.intercom_prog_seen(57) },
    :ICF_2_contestado => Proc.new { |user| user.intercom_prog_answered(57) },
    :ICM_2_status => Proc.new { |user| user.intercom_prog_status(58) },
    :ICM_2_examen => Proc.new { |user| user.intercom_prog_quizzes(58) },
    :ICM_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(58) },
    :ICM_2_visto => Proc.new { |user| user.intercom_prog_seen(58) },
    :ICM_2_contestado => Proc.new { |user| user.intercom_prog_answered(58) },
    :HCI_status => Proc.new { |user| user.intercom_prog_status(56) },
    :HCI_examen => Proc.new { |user| user.intercom_prog_quizzes(56) },
    :HCI_plantillas => Proc.new { |user| user.intercom_prog_refillables(56) },
    :HCI_visto => Proc.new { |user| user.intercom_prog_seen(56) },
    :HCI_contestado => Proc.new { |user| user.intercom_prog_answered(56) },
    :VME_1_status => Proc.new { |user| user.intercom_prog_status(25) },
    :VME_1_examen => Proc.new { |user| user.intercom_prog_quizzes(25) },
    :VME_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(25) },
    :VME_1_visto => Proc.new { |user| user.intercom_prog_seen(25) },
    :VME_1_contestado => Proc.new { |user| user.intercom_prog_answered(25) },
    :VME_2_status => Proc.new { |user| user.intercom_prog_status(64) },
    :VME_2_examen => Proc.new { |user| user.intercom_prog_quizzes(64) },
    :VME_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(64) },
    :VME_2_visto => Proc.new { |user| user.intercom_prog_seen(64) },
    :VME_2_contestado => Proc.new { |user| user.intercom_prog_answered(64) },
    :IPM_2_status => Proc.new { |user| user.intercom_prog_status(60) },
    :IPM_2_examen => Proc.new { |user| user.intercom_prog_quizzes(60) },
    :IPM_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(60) },
    :IPM_2_visto => Proc.new { |user| user.intercom_prog_seen(60) },
    :IPM_2_contestado => Proc.new { |user| user.intercom_prog_answered(60) },
    :PPR_status => Proc.new { |user| user.intercom_prog_status(28) },
    :PPR_examen => Proc.new { |user| user.intercom_prog_quizzes(28) },
    :PPR_plantillas => Proc.new { |user| user.intercom_prog_refillables(28) },
    :PPR_visto => Proc.new { |user| user.intercom_prog_seen(28) },
    :PPR_contestado => Proc.new { |user| user.intercom_prog_answered(28) },
    :PVE_status => Proc.new { |user| user.intercom_prog_status(32) },
    :PVE_examen => Proc.new { |user| user.intercom_prog_quizzes(32) },
    :PVE_plantillas => Proc.new { |user| user.intercom_prog_refillables(32) },
    :PVE_visto => Proc.new { |user| user.intercom_prog_seen(32) },
    :PVE_contestado => Proc.new { |user| user.intercom_prog_answered(32) },
    :PE2_status => Proc.new { |user| user.intercom_prog_status(66) },
    :PE2_examen => Proc.new { |user| user.intercom_prog_quizzes(66) },
    :PE2_plantillas => Proc.new { |user| user.intercom_prog_refillables(66) },
    :PE2_visto => Proc.new { |user| user.intercom_prog_seen(66) },
    :PE2_contestado => Proc.new { |user| user.intercom_prog_answered(66) },
    :IPR_2_status => Proc.new { |user| user.intercom_prog_status(59) },
    :IPR_2_examen => Proc.new { |user| user.intercom_prog_quizzes(59) },
    :IPR_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(59) },
    :IPR_2_visto => Proc.new { |user| user.intercom_prog_seen(59) },
    :IPR_2_contestado => Proc.new { |user| user.intercom_prog_answered(59) },
    :PRT_1_status => Proc.new { |user| user.intercom_prog_status(40) },
    :PRT_1_examen => Proc.new { |user| user.intercom_prog_quizzes(40) },
    :PRT_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(40) },
    :PRT_1_visto => Proc.new { |user| user.intercom_prog_seen(40) },
    :PRT_1_contestado => Proc.new { |user| user.intercom_prog_answered(40) },
    :PRT_2_status => Proc.new { |user| user.intercom_prog_status(48) },
    :PRT_2_examen => Proc.new { |user| user.intercom_prog_quizzes(48) },
    :PRT_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(48) },
    :PRT_2_visto => Proc.new { |user| user.intercom_prog_seen(48) },
    :PRT_2_contestado => Proc.new { |user| user.intercom_prog_answered(48) },
    :RF_status => Proc.new { |user| user.intercom_prog_status(67) },
    :RF_examen => Proc.new { |user| user.intercom_prog_quizzes(67) },
    :RF_plantillas => Proc.new { |user| user.intercom_prog_refillables(67) },
    :RF_visto => Proc.new { |user| user.intercom_prog_seen(67) },
    :RF_contestado => Proc.new { |user| user.intercom_prog_answered(67) },
    :TMN_1_status => Proc.new { |user| user.intercom_prog_status(62) },
    :TMN_1_examen => Proc.new { |user| user.intercom_prog_quizzes(62) },
    :TMN_1_plantillas => Proc.new { |user| user.intercom_prog_refillables(62) },
    :TMN_1_visto => Proc.new { |user| user.intercom_prog_seen(62) },
    :TMN_1_contestado => Proc.new { |user| user.intercom_prog_answered(62) },
    :TMN_2_status => Proc.new { |user| user.intercom_prog_status(43) },
    :TMN_2_examen => Proc.new { |user| user.intercom_prog_quizzes(43) },
    :TMN_2_plantillas => Proc.new { |user| user.intercom_prog_refillables(43) },
    :TMN_2_visto => Proc.new { |user| user.intercom_prog_seen(43) },
    :TMN_2_contestado => Proc.new { |user| user.intercom_prog_answered(43) },
    :ECO_status => Proc.new { |user| user.intercom_prog_status(73) },
    :ECO_examen => Proc.new { |user| user.intercom_prog_quizzes(73) },
    :ECO_plantillas => Proc.new { |user| user.intercom_prog_refillables(73) },
    :ECO_visto => Proc.new { |user| user.intercom_prog_seen(73) },
    :ECO_contestado => Proc.new { |user| user.intercom_prog_answered(73) },
    :PF_status => Proc.new { |user| user.intercom_prog_status(74) },
    :PF_examen => Proc.new { |user| user.intercom_prog_quizzes(74) },
    :PF_plantillas => Proc.new { |user| user.intercom_prog_refillables(74) },
    :PF_visto => Proc.new { |user| user.intercom_prog_seen(74) },
    :PF_contestado => Proc.new { |user| user.intercom_prog_answered(74) },
    :DSA_status => Proc.new { |user| user.intercom_prog_status(75) },
    :DSA_examen => Proc.new { |user| user.intercom_prog_quizzes(75) },
    :DSA_plantillas => Proc.new { |user| user.intercom_prog_refillables(75) },
    :DSA_visto => Proc.new { |user| user.intercom_prog_seen(75) },
    :DSA_contestado => Proc.new { |user| user.intercom_prog_answered(75) }
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
