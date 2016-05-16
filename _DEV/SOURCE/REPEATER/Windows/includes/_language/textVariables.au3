#include "..\..\..\..\_INCLUDES\textCompanyName.au3"

$txtStart = "Carregando..."
$txtID = "ID"
;~ $idToolTip = "Clique para copiar o ID."
;~ $statusToolTip = "Clique para reconectar."
$txtStatus = "STATUS"
$txtContact = "CONTATO"
$txtSupport = "SUPORTE"
$txtTelA = "(00) 0000-0000"
$txtTelB = "(00) 0000-0000"
$txtEmail = "email@company.com"
$lnkEmail = "MAILTO:email@company.com"
$txtSite = "www.company.com"
$lnkSite = "http://www.company.com"
$txtDisclaimerMain = "0.1.0 A"
$txtShortcutName = $txtSupport & " " & $str_company_name
$txtRemoveShortcutName = "Desinstalar " & $txtShortcutName

$str_config_title = $txtSupport & " - " & $str_company_name
;~ $str_program_title = "INTERMIX " & $str_company_name

$str_button_install = "Instalar Estação"
$str_button_installserver = "Instalar Servidores"
$str_button_exit = "Sair"
$str_msgbox_serviceinstallation = "Instalação do serviço"

$str_msgbox_removeservice = "Deseja remover o serviço e desinstalar?"
$str_serviceenteranidnumber = "Digite o número de ID:"
$str_serviceinvalidid = "ID inválido! Digite um ID entre 100.000 e 200.000."

;~ $str_errorrepeaterconnectionfailed = "Não foi possivel estabelecer uma conexão com o servidor de suporte."
$str_endsupportsession = "Deseja encerrar o suporte remoto?"
$str_openinstalled = "O Suporte Remoto já está instalado em seu computador. Deseja inicia-lo?"
$str_error_servicestart = "O Serviço do Suporte Remoto não conseguiu iniciar corretamente."
$str_error_servicestart_error = "Erro: "
$str_error_servicestart_end = "A instalação será interrompida e os arquivos removidos."
$str_needrestart = "É necessário reiniciar o computador para terminar a instalação, deseja fazer isso agora?"
;~ $str_error_instconnection = "Não foi possivel estabelecer uma conexão com o servidor de Suporte, a instalação será cancelada"
$str_remove_countrestart = "O sistema será reiniciado em 10 segundos ou clique em OK para reiniciar agora."
$str_end_app = "Finalizando conexão com o Help Desk, aguarde..."
$str_inst_servcomplete = "O sistema foi instalado com sucesso! Verifique o status do serviço."
$str_inst_update = "Uma versão anterior foi detectada. Removendo versão anterior, aguarde..."
$str_update_fail = "A atualização falhou. O processo será interrompido, por favor, entre em contato com o Help Desk."
$str_inst_procedure = "A instalação está em andamento. Aguarde..."
$askRepIndexTitle = "Repeater de conexão - Servidor"
$askRepIndexMsg = "Digite o número do repeater que deseja usar(0, 1, 2 ou 3):"


$str_msgbox_error = "Erro"
$str_errorunknowncommand = "Parametro desconhecido"