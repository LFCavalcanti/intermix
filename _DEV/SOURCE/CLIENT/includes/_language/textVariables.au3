#include "..\..\..\_INCLUDES\textCompanyName.au3"

Global $_g_sLabel_Start = "Carregando..."
Global $_g_sLabel_ID = "ID"
Global $_g_sLabel_Status = "STATUS"
Global $_g_sLabel_Contact = "CONTATO"
Global $_g_sLabel_Support = "SUPORTE"
Global $_g_sLabel_TelA = "(19) 4117-1560"
Global $_g_sLabel_TelB = "(19) 3515-7300"
Global $_g_sLabel_Email = "suporte@arriviera.com.br"
Global $_g_sLabel_Site = "www.arriviera.com.br"
Global $_g_sShortcutName = $_g_sLabel_Support & " " & $_g_sCompanyName
Global $_g_sRemoveShortcutName = "Desinstalar " & $_g_sShortcutName

Global $_g_sConfigTitle = $_g_sLabel_Support & " - " & $_g_sCompanyName

Global $_g_sSplash_Removing = "Desinstalando o Intermix Support, aguarde..."

Global $_g_sMsgBox_ServiceInstall = "Instalação do serviço"

Global $_g_sMsgBox_RemoveService = "Deseja remover o serviço e desinstalar?"
;~ Global $_g_sMsgBox_InputID = "Digite o número de ID:"
;~ Global $_g_sMsgBox_InvalidID = "ID inválido! Digite um ID entre 100.000 e 200.000."

Global $_g_sMsgBox_KeepConfigTitle = "SERVER SETUP"
Global $_g_sMsgBox_KeepConfig = "Deseja manter o ID e Repeater atuais?"
Global $_g_sMsgBox_InvalidID = "O número de ID deve estar entre 100000 e 199999."
Global $_g_sMsgBox_InvalidRepeater = "Repeater inválido, informações faltando no cadastro."
Global $_g_sMsgBox_CloseSupport = "Deseja encerrar o suporte remoto?"
Global $_g_sMsgBox_OpenInstalled = "O Suporte Remoto já está instalado em seu computador. Deseja inicia-lo?"
Global $_g_sMsgBox_ServiceRestartMsg = "O Serviço do Suporte Remoto não conseguiu iniciar corretamente."
Global $_g_sMsgBox_GeneralError = "ERRO: "
Global $_g_sMsgBox_ServiceRestartEnd = "A instalação será interrompida e os arquivos removidos."
Global $_g_sMsgBox_NeedReboot = "É necessário reiniciar o computador para terminar a instalação, deseja fazer isso agora?"
Global $_g_sMsgBox_RestartCountQuiet = "O sistema será reiniciado em 10 segundos ou clique em OK para reiniciar agora."
Global $_g_sSplash_ClosingSupport = "Finalizando conexão com o Help Desk, aguarde..."
Global $_g_sMsgBox_InstServerComplete = "O sistema foi instalado com sucesso! Verifique o status do serviço."
Global $_g_sSplash_Update = "Uma versão anterior foi detectada. Removendo versão anterior, aguarde..."
Global $_g_sMsgBox_UpdateFailed = "A atualização falhou. O processo será interrompido, por favor, entre em contato com o Help Desk."
Global $_g_sSplash_Setup = "A instalação está em andamento. Aguarde..."
Global $_g_sMsgBox_RepeaterIndexTitle = "Repeater de conexão - Servidor"
;~ Global $_g_sMsgBox_RepeaterIndex = "Digite o número do repeater que deseja usar(0, 1, 2 ou 3):"

Global $_g_sRestartWarning = "Seu computador irá reiniciar em 60 segundos..."

Global $_g_sMsgBox_UnknownParameter = "Parametro desconhecido"

Global $_g_sSystemWillRestart = "Seu computador irá reiniciar em 60 segundos..."

Global $_g_sTray_ButtonInstall = "Instalar Estação"
Global $_g_sTray_ButtonInstallServer = "Instalar Servidores"
Global $_g_sTray_ButtonExit = "Sair"