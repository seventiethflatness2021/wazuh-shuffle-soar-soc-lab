@echo off
:: ==============================================================================
:: Wazuh Active Response: netsh-isolate.cmd
:: Purpose: Dynamically isolates Windows host/service via Advanced Firewall
:: Author: Mohamed Sabry (@0xsabry)
:: ==============================================================================

set ACTION=%1
set USER=%2
set IP=%3

set LOG_FILE="C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

if "%ACTION%"=="add" (
    echo %date% %time% [netsh-isolate] Enabling Windows Firewall Isolation Rule >> %LOG_FILE%
    netsh advfirewall firewall add rule name="WAZUH_SOC_CONTAINMENT" dir=in action=block remoteip=%IP% enable=yes
    netsh advfirewall firewall add rule name="WAZUH_SOC_CONTAINMENT_OUT" dir=out action=block remoteip=%IP% enable=yes
    exit /b 0
)

if "%ACTION%"=="delete" (
    echo %date% %time% [netsh-isolate] Removing Windows Firewall Isolation Rule >> %LOG_FILE%
    netsh advfirewall firewall delete rule name="WAZUH_SOC_CONTAINMENT"
    netsh advfirewall firewall delete rule name="WAZUH_SOC_CONTAINMENT_OUT"
    exit /b 0
)

echo %date% %time% [netsh-isolate] Invalid arguments passed: %ACTION% %IP% >> %LOG_FILE%
exit /b 1
